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

[[ "$JAVA" =~ ^8-jdk-alpine-openjdk$ ]];

docker-pull "$REPOSITORY/java-$ARCH:$JAVA" "openjdk:8-jdk-alpine"

docker build -t "$DOCKER_IMAGE" -f "$PROJECT/Dockerfile-alpine" \
             --build-arg JENKINS_VERSION="$VERSIONPIN" \
             --build-arg JENKINS_SHA="$SHA"         \
             "$PROJECT"
