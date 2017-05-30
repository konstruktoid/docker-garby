FROM konstruktoid/alpine:latest

LABEL org.label-schema.name="docker-garby" \
      org.label-schema.url="https://github.com/konstruktoid/docker-garby" \
      org.label-schema.vcs-url="https://github.com/konstruktoid/docker-garby.git"

ENV WDIR /usr/bin
WORKDIR ${WDIR}

RUN apk upgrade --no-cache && \
  apk add --no-cache coreutils docker && \
  rm -rf /usr/bin/docker-* /usr/bin/dockerd /var/cache/apk/*

COPY ./docker-garby.sh $WDIR/docker-garby.sh

HEALTHCHECK CMD exit 0

ENTRYPOINT ["/bin/sh", "docker-garby.sh"]
