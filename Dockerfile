FROM alpine:3.3

ENV VERSION 1.10.0
ENV SHA256 a66b20423b7d849aa8ef448b98b41d18c45a30bf3fe952cc2ba4760600b18087

WORKDIR /usr/bin

RUN apk update && \
    apk upgrade && \
    apk --update add coreutils curl && \
    curl -sS https://get.docker.com/builds/Linux/x86_64/docker-$VERSION > docker-$VERSION && \
    curl -sS https://get.docker.com/builds/Linux/x86_64/docker-$VERSION.sha256 > docker-$VERSION.sha256 && \
    sha256sum -c docker-$VERSION.sha256 && \
    echo "$SHA256 docker-$VERSION" | sha256sum -c - && \
    ln -s docker-$VERSION docker && \
    chmod u+x docker-$VERSION && \
    apk del curl && \
    rm -rf /var/cache/apk/*

COPY ./docker-garby.sh /docker-garby.sh

ENTRYPOINT ["/bin/sh", "/docker-garby.sh"]
