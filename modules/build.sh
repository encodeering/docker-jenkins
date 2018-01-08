#!/usr/bin/env bash

set -e

import com.encodeering.docker.config
import com.encodeering.docker.docker

./build-${BASE}.sh

case "$VARIANT" in
    walle* )
        if [[ "$JAVA" =~ .*-oracle$ ]]; then
             if docker run --rm -e eula-java=accept "$DOCKER_IMAGE" -v; then             true; fi
             if docker run --rm -e eula-java=       "$DOCKER_IMAGE" -v; then false; else true; fi
        else
                docker run --rm                     "$DOCKER_IMAGE" -v
        fi

        ;;
    * )
        if [[ "$JAVA" =~ .*-oracle$ ]]; then
             if docker run --rm -e eula-java=accept "$DOCKER_IMAGE" java -jar /usr/share/jenkins/jenkins.war --version; then             true; fi
             if docker run --rm -e eula-java=       "$DOCKER_IMAGE" java -jar /usr/share/jenkins/jenkins.war --version; then false; else true; fi
        else
                docker run --rm                     "$DOCKER_IMAGE" java -jar /usr/share/jenkins/jenkins.war --version
        fi

        ;;
esac
