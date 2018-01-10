#!/usr/bin/env bash

set -e

import com.encodeering.ci.config
import com.encodeering.ci.docker

[[ "$JAVA" =~ ^8-jdk.* ]];

docker-pull "$REPOSITORY/java-$ARCH:$JAVA" "openjdk:8-jdk"

case "$VARIANT" in
    walle* )
        if [[ "$JAVA" =~ .*-oracle$ ]]; then sed -i -r '/ENTRYPOINT/ s!/usr/bin/supervisord!docker-eula-java", "/usr/bin/supervisord!g' "walle/Dockerfile"; fi

        docker-build "walle"

        ;;
    * )
        if [[ "$JAVA" =~ .*-oracle$ ]]; then sed -i -r '/ENTRYPOINT/ s!/sbin/tini!docker-eula-java", "/sbin/tini!g' "$PROJECT/Dockerfile"; fi

        docker-build --build-arg JENKINS_VERSION="$VERSIONPIN" \
                     --build-arg JENKINS_SHA="$SHA"         \
                     "$PROJECT"

        ;;
esac
