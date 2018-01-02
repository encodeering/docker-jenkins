#!/bin/bash

set -ev

TAG="$REPOSITORY/$PROJECT-$ARCH"
TAGSPECIFIER="$VERSION${CUSTOM:+-$CUSTOM}"

[[ "$JAVA" =~ ^8-jdk.* ]];

docker pull "$REPOSITORY/java-$ARCH:$JAVA"
docker tag  "$REPOSITORY/java-$ARCH:$JAVA" "openjdk:8-jdk"

case "$CUSTOM" in
    walle* )
        if [[ "$JAVA" =~ .*-oracle$ ]]; then sed -i -r '/ENTRYPOINT/ s!/usr/bin/supervisord!docker-eula-java", "/usr/bin/supervisord!g' "contrib/walle/Dockerfile"; fi

        docker build -t "$TAG:$TAGSPECIFIER" "contrib/walle"

        if [[ "$JAVA" =~ .*-oracle$ ]]; then
             if docker run --rm -e eula-java=accept "$TAG:$TAGSPECIFIER" -v; then             true; fi
             if docker run --rm -e eula-java=       "$TAG:$TAGSPECIFIER" -v; then false; else true; fi
        else
                docker run --rm                     "$TAG:$TAGSPECIFIER" -v
        fi

        ;;
    * )
        if [[ "$JAVA" =~ .*-oracle$ ]]; then sed -i -r '/ENTRYPOINT/ s!/sbin/tini!docker-eula-java", "/sbin/tini!g' "$PROJECT/Dockerfile"; fi

        docker build -t "$TAG:$TAGSPECIFIER" \
                     --build-arg JENKINS_VERSION="$VERSIONPIN" \
                     --build-arg JENKINS_SHA="$SHA"            \
                     "$PROJECT"

        if [[ "$JAVA" =~ .*-oracle$ ]]; then
             if docker run --rm -e eula-java=accept "$TAG:$TAGSPECIFIER" java -jar /usr/share/jenkins/jenkins.war --version; then             true; fi
             if docker run --rm -e eula-java=       "$TAG:$TAGSPECIFIER" java -jar /usr/share/jenkins/jenkins.war --version; then false; else true; fi
        else
                docker run --rm                     "$TAG:$TAGSPECIFIER" java -jar /usr/share/jenkins/jenkins.war --version
        fi

        ;;
esac
