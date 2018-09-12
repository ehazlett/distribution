FROM golang:1.10-alpine as build

ENV DISTRIBUTION_DIR /go/src/github.com/docker/distribution
ENV DOCKER_BUILDTAGS include_oss include_gcs

ARG GOOS=linux
ARG GOARCH=amd64

RUN set -ex \
    && apk add --no-cache make git

WORKDIR $DISTRIBUTION_DIR
COPY . $DISTRIBUTION_DIR

RUN make PREFIX=/go clean binaries

FROM alpine:latest
COPY --from=build /go/src/github.com/docker/distribution/bin/ /usr/local/bin/
COPY --from=build /go/src/github.com/docker/distribution/cmd/registry/config-dev.yml /etc/docker/registry/config.yml
VOLUME ["/var/lib/registry"]
EXPOSE 5000
ENTRYPOINT ["registry"]
CMD ["serve", "/etc/docker/registry/config.yml"]
