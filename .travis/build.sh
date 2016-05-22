#!/bin/bash

set -ev

SEMANTIC="${VERSION:0:3}"

TAG="$REPOSITORY/$PROJECT-$ARCH"
TAGSPECIFIER="$SEMANTIC${CUSTOM:+-$CUSTOM}"
TINIBUILDPACK="$REPOSITORY/buildpack-$ARCH:jessie"
TINIDIRECTORY=mktini
TINIVERSION="v0.9.0"

mktini () {
    rm -rf   "$TINIDIRECTORY"
    mkdir -p "$TINIDIRECTORY"

    cat <<-EOF > "$TINIDIRECTORY/Dockerfile.tini.static"
		FROM $TINIBUILDPACK
		ENV CFLAGS="-DPR_SET_CHILD_SUBREAPER=36 -DPR_GET_CHILD_SUBREAPER=37" CC="gcc"
		RUN apt-get update && apt-get -y install cmake git libcap-dev python-dev python-pip
		RUN git clone --depth 1 --branch "$TINIVERSION" https://github.com/krallin/tini.git /usr/src/tini
		WORKDIR /usr/src/tini
EOF

    docker build -f   "$TINIDIRECTORY/Dockerfile.tini.static" -t tini:static "$TINIDIRECTORY"
    docker rm         "tini" || true
    docker run --name "tini" tini:static bash -c "cmake . && make"
    docker cp         "tini:/usr/src/tini/tini-static" "$PROJECT/tini"
}

docker pull   "$REPOSITORY/java-$ARCH:8-jdk-openjdk"
docker tag -f "$REPOSITORY/java-$ARCH:8-jdk-openjdk" "java:8-jdk"

case "$CUSTOM" in
    walle )
        docker build -t "$TAG:$TAGSPECIFIER"      \
                     --build-arg SCRIPT="$SCRIPT" \
                     "contrib/$CUSTOM"

        docker run --rm "$TAG:$TAGSPECIFIER" -v
        ;;
    * )
        patch -p1 --no-backup-if-mismatch --directory=$PROJECT < .patch/Dockerfile.patch

        mktini

        docker build -t "$TAG:$TAGSPECIFIER" \
                     --build-arg JENKINS_VERSION="$VERSION" \
                     --build-arg JENKINS_SHA="$SHA"         \
                     "$PROJECT"

        docker run --rm "$TAG:$TAGSPECIFIER" java -jar /usr/share/jenkins/jenkins.war --version
        ;;
esac
