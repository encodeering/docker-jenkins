#!/usr/bin/env bash
# configuration
#   env.ARCH
#   env.PROJECT
#   env.VERSION
#   env.VERSIONPIN
#   env.SHA
#   env.VARIANT
#   env.REPOSITORY

set -e

import com.encodeering.docker.config
import com.encodeering.docker.docker

[[ "$JAVA" =~ ^8-jdk.* ]];

docker-pull "$REPOSITORY/java-$ARCH:$JAVA" "openjdk:8-jdk"

case "$VARIANT" in
    walle* )
        if [[ "$JAVA" =~ .*-oracle$ ]]; then sed -i -r '/ENTRYPOINT/ s!/usr/bin/supervisord!docker-eula-java", "/usr/bin/supervisord!g' "walle/Dockerfile"; fi

        docker build -t "$DOCKER_IMAGE" "walle"

        if [[ "$JAVA" =~ .*-oracle$ ]]; then
             if docker run --rm -e eula-java=accept "$DOCKER_IMAGE" -v; then             true; fi
             if docker run --rm -e eula-java=       "$DOCKER_IMAGE" -v; then false; else true; fi
        else
                docker run --rm                     "$DOCKER_IMAGE" -v
        fi

        ;;
    * )
        if [[ "$JAVA" =~ .*-oracle$ ]]; then sed -i -r '/ENTRYPOINT/ s!/sbin/tini!docker-eula-java", "/sbin/tini!g' "$PROJECT/Dockerfile"; fi

        docker build -t "$DOCKER_IMAGE" \
                     --build-arg JENKINS_VERSION="$VERSIONPIN" \
                     --build-arg JENKINS_SHA="$SHA"         \
                     "$PROJECT"

        if [[ "$JAVA" =~ .*-oracle$ ]]; then
             if docker run --rm -e eula-java=accept "$DOCKER_IMAGE" java -jar /usr/share/jenkins/jenkins.war --version; then             true; fi
             if docker run --rm -e eula-java=       "$DOCKER_IMAGE" java -jar /usr/share/jenkins/jenkins.war --version; then false; else true; fi
        else
                docker run --rm                     "$DOCKER_IMAGE" java -jar /usr/share/jenkins/jenkins.war --version
        fi

        ;;
esac
