#!/bin/bash

set -ev

SEMANTIC="${VERSION:0:3}"

TAG="$REPOSITORY/$PROJECT-$ARCH"
TAGSPECIFIER="$SEMANTIC${CUSTOM:+-$CUSTOM}"

docker pull   "$REPOSITORY/openjdk-$ARCH:8-jdk"
docker tag -f "$REPOSITORY/openjdk-$ARCH:8-jdk" "java:8-jdk"

case "$CUSTOM" in
    walle )
        docker build -t "$TAG:$TAGSPECIFIER"      \
                     --build-arg SCRIPT="$SCRIPT" \
                     "contrib/$CUSTOM"

        docker run --rm "$TAG:$TAGSPECIFIER" -v
        ;;
    * )
        docker build -t "$TAG:$TAGSPECIFIER" \
                     --build-arg JENKINS_VERSION="$VERSION" \
                     --build-arg JENKINS_SHA="$SHA"         \
                     "$PROJECT"

        docker run --rm "$TAG:$TAGSPECIFIER" java -jar /usr/share/jenkins/jenkins.war --version
        ;;
esac
