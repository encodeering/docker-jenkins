#!/bin/bash

set -ev

TAG="$REPOSITORY/$PROJECT-$ARCH"
TAGSPECIFIER="$VERSION"

docker pull   "$REPOSITORY/openjdk-$ARCH:8-jdk"
docker tag -f "$REPOSITORY/openjdk-$ARCH:8-jdk" "java:8-jdk"

docker build -t "$TAG:$TAGSPECIFIER" \
             --build-arg JENKINS_VERSION="$VERSION" \
             --build-arg JENKINS_SHA="$SHA"         \
             "$PROJECT"
