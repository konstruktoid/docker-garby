FROM konstruktoid/alpine:latest

LABEL org.label-schema.name="docker-garby" \
      org.label-schema.url="https://github.com/konstruktoid/docker-garby" \
      org.label-schema.vcs-url="https://github.com/konstruktoid/docker-garby.git"

ENV VERSION 1.12.6
ENV SHA256 cadc6025c841e034506703a06cf54204e51d0cadfae4bae62628ac648d82efdd

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
