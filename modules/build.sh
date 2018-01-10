#!/usr/bin/env bash

set -e

import com.encodeering.ci.config
import com.encodeering.ci.docker

./build-${BASE}.sh

case "$VARIANT" in
    walle* )
        if [[ "$JAVA" =~ .*-oracle$ ]]; then
                docker-verify-config "-e eula-java=accept"
             if docker-verify -v; then             true; fi

                docker-verify-config "-e eula-java="
             if docker-verify -v; then false; else true; fi
        else
                docker-verify -v
        fi

        ;;
    * )
        if [[ "$JAVA" =~ .*-oracle$ ]]; then
                docker-verify-config "-e eula-java=accept"
             if docker-verify java -jar /usr/share/jenkins/jenkins.war --version; then             true; fi

                docker-verify-config "-e eula-java="
             if docker-verify java -jar /usr/share/jenkins/jenkins.war --version; then false; else true; fi
        else
                docker-verify java -jar /usr/share/jenkins/jenkins.war --version
        fi

        ;;
esac
