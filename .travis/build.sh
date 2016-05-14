#!/bin/bash

set -ev

SEMANTIC="${VERSION:0:3}"

TAG="$REPOSITORY/$PROJECT-$ARCH"
TAGSPECIFIER="$SEMANTIC"

docker pull   "$REPOSITORY/openjdk-$ARCH:8-jdk"
docker tag -f "$REPOSITORY/openjdk-$ARCH:8-jdk" "java:8-jdk"

docker build -t "$TAG:$TAGSPECIFIER" \
             --build-arg JENKINS_VERSION="$VERSION" \
             --build-arg JENKINS_SHA="$SHA"         \
             "$PROJECT"
