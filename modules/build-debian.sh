#!/usr/bin/env bash

set -e

import com.encodeering.docker.config
import com.encodeering.docker.docker

[[ "$JAVA" =~ ^8-jdk.* ]];

docker-pull "$REPOSITORY/java-$ARCH:$JAVA" "openjdk:8-jdk"

case "$VARIANT" in
    walle* )
        if [[ "$JAVA" =~ .*-oracle$ ]]; then sed -i -r '/ENTRYPOINT/ s!/usr/bin/supervisord!docker-eula-java", "/usr/bin/supervisord!g' "walle/Dockerfile"; fi

        docker build -t "$DOCKER_IMAGE" "walle"

        ;;
    * )
        if [[ "$JAVA" =~ .*-oracle$ ]]; then sed -i -r '/ENTRYPOINT/ s!/sbin/tini!docker-eula-java", "/sbin/tini!g' "$PROJECT/Dockerfile"; fi

        docker build -t "$DOCKER_IMAGE" \
                     --build-arg JENKINS_VERSION="$VERSIONPIN" \
                     --build-arg JENKINS_SHA="$SHA"         \
                     "$PROJECT"

        ;;
esac
