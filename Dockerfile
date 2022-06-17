FROM alpine:latest as smartdns-builder

RUN apk update && \
    apk add --no-cache git dpkg make gcc build-base linux-headers openssl-dev openssl-libs-static && \
    git clone https://github.com/pymumu/smartdns /smartdns && \
    cd /smartdns && \
    sh ./package/build-pkg.sh --platform linux --arch `dpkg --print-architecture` --static && \
    mkdir /release -p && \
    cd /smartdns/package && tar xf *.tar.gz && \
    cp /smartdns/package/smartdns/etc /release/ -a && \
    cp /smartdns/package/smartdns/usr /release/ -a && \
    strip /release/usr/sbin/smartdns

FROM golang:1.18.3-alpine3.15 as webproc

RUN apk update && \
    apk upgrade && \
    apk add --no-cache git gcc \
	&& git clone https://github.com/jpillora/webproc \
	&& cd webproc \
    && VERSION=$(git describe --tags) \
    && CGO_ENABLED=0 go build -trimpath -ldflags '-X "main.version='${VERSION}'" \
    -w -s -buildid=' -o webproc .

FROM alpine:latest

COPY --from=smartdns-builder /release/ /
COPY --from=webproc /go/webproc/webproc /usr/sbin/webproc
COPY docker-entrypoint.sh /entrypoint.sh

EXPOSE 53/udp
VOLUME "/etc/smartdns/"

ENTRYPOINT ["/entrypoint.sh"]

CMD ["smartdns"]
