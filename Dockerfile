FROM konstruktoid/alpine:latest

LABEL org.label-schema.name="docker-garby" \
      org.label-schema.vcs-url="git@github.com:konstruktoid/docker-garby.git"

ENV VERSION 1.12.3
ENV SHA256 626601deb41d9706ac98da23f673af6c0d4631c4d194a677a9a1a07d7219fa0f

ENV WDIR /usr/bin
WORKDIR ${WDIR}

RUN apk update && \
    apk upgrade && \
    apk --update add coreutils wget ca-certificates && \
    wget https://get.docker.com/builds/Linux/x86_64/docker-$VERSION.tgz && \
    wget https://get.docker.com/builds/Linux/x86_64/docker-$VERSION.tgz.sha256 && \
    sha256sum -c docker-$VERSION.tgz.sha256 && \
    echo "$SHA256 docker-$VERSION.tgz" | sha256sum -c - && \
    tar -xzvf docker-$VERSION.tgz -C /tmp && \
    mv /tmp/docker/docker . && \
    chmod u+x docker* && \
    rm -rf /tmp/docker* && \
    apk del wget ca-certificates && \
    rm -rf /var/cache/apk/* docker-$VERSION.tgz docker-$VERSION.tgz.sha256

COPY ./docker-garby.sh $WDIR/docker-garby.sh

ENTRYPOINT ["/bin/sh", "docker-garby.sh"]
