FROM konstruktoid/alpine:latest

ENV VERSION 1.12.1
ENV SHA256 05ceec7fd937e1416e5dce12b0b6e1c655907d349d52574319a1e875077ccb79

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
