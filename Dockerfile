FROM alpine:3.2

ENV VERSION 1.9.1

WORKDIR /usr/bin

RUN apk update && \
    apk upgrade && \
    apk --update add coreutils curl && \
    curl -sS https://get.docker.com/builds/Linux/x86_64/docker-$VERSION > docker-$VERSION && \
    curl -sS https://get.docker.com/builds/Linux/x86_64/docker-$VERSION.sha256 > docker-$VERSION.sha256 && \
    sha256sum -c docker-$VERSION.sha256 && \
    ln -s docker-$VERSION docker && \
    chmod u+x docker-$VERSION && \
    apk del curl && \
    rm -rf /var/cache/apk/*

COPY ./docker-garby.sh /docker-garby.sh

ENTRYPOINT ["/bin/sh", "/docker-garby.sh"]
