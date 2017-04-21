FROM konstruktoid/alpine:latest

LABEL org.label-schema.name="docker-garby" \
      org.label-schema.url="https://github.com/konstruktoid/docker-garby" \
      org.label-schema.vcs-url="https://github.com/konstruktoid/docker-garby.git"

ENV VERSION 17.04.0-ce
ENV SHA256 c52cff62c4368a978b52e3d03819054d87bcd00d15514934ce2e0e09b99dd100

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
