FROM alpine:3.17.1 as builder

ARG OPENFORTIVPN_VERSION=v1.17.3
ARG GLIDER_VERSION=v0.16.2

RUN \
  apk add --no-cache \
    autoconf automake build-base ca-certificates curl git go openssl-dev ppp && \
  # build openfortivpn
  mkdir -p /usr/src/openfortivpn && \
  curl -sL https://github.com/adrienverge/openfortivpn/archive/${OPENFORTIVPN_VERSION}.tar.gz \
    | tar xz -C /usr/src/openfortivpn --strip-components=1 && \
  cd /usr/src/openfortivpn && \
  ./autogen.sh && \
  ./configure --prefix=/usr --sysconfdir=/etc && \
  make -j$(nproc) && \
  make install && \
  apk add --no-cache make git ca-certificates tzdata && \
  wget -O /Country.mmdb https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb && \
  wget -O /config.yaml https://github.com/yurhett/docker-fortivpn-clash-aarch64/raw/master/config.yaml

WORKDIR /workdir
COPY --from=tonistiigi/xx:golang / /
ARG TARGETOS TARGETARCH TARGETVARIANT
RUN --mount=target=. \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    make BINDIR= ${TARGETOS}-${TARGETARCH}${TARGETVARIANT} && \
    mv /clash* /clash

# mkdir -p /go/src/github.com/nadoo/glider && \
#   curl -sL https://github.com/nadoo/glider/archive/${GLIDER_VERSION}.tar.gz \
#     | tar xz -C /go/src/github.com/nadoo/glider --strip-components=1 && \
#   cd /go/src/github.com/nadoo/glider && \
#   awk '/^\s+_/{if (!/http/ && !/socks5/ && !/mixed/) $0="//"$0} {print}' feature.go > feature.go.tmp && \
#   mv feature.go.tmp feature.go && \
#   go build -v -ldflags "-s -w"

COPY entrypoint.sh /usr/bin/

FROM alpine:3.17.1
RUN apk add --no-cache ca-certificates openssl ppp
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /Country.mmdb /root/.config/clash/
COPY --from=builder /config.yaml /root/.config/clash/
COPY --from=builder /clash /
COPY --from=builder /usr/bin/openfortivpn /usr/bin/entrypoint.sh /usr/bin/
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
EXPOSE 8443/tcp
CMD ["openfortivpn"]


