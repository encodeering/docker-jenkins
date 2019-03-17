#!/usr/bin/env bash

set -e

import com.encodeering.ci.config
import com.encodeering.ci.docker

docker-pull "$REPOSITORY/java-$ARCH:$JAVA" "openjdk:8-jdk-alpine"

docker-build -f "$PROJECT/Dockerfile-alpine" \
             --build-arg JENKINS_VERSION="$VERSIONPIN" \
             --build-arg JENKINS_SHA="$SHA"         \
             "$PROJECT"

docker-verify java -jar /usr/share/jenkins/jenkins.war --version | dup | matches "^${VERSIONPIN}"
