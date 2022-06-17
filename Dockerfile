FROM alpine:3.15 as base

ENV LANG=C.UTF-8

# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.23-r4" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    echo \
        "-----BEGIN PUBLIC KEY-----\
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
        y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
        tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
        m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
        KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
        Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
        1QIDAQAB\
        -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

FROM base as smartdns-builder

RUN apk update && \
    apk upgrade && \
    apk add --no-cache git make gcc openssl-dev dpkg build-base linux-headers && \
    git clone https://github.com/pymumu/smartdns && \
    cd smartdns && \
    sh ./package/build-pkg.sh --platform linux --arch `dpkg --print-architecture`

FROM golang:1.18.3-alpine3.15 as webproc

RUN apk update && \
    apk upgrade && \
    apk add --no-cache git \
	&& git clone https://github.com/jpillora/webproc \
	&& cd webproc \
    && VERSION=$(git describe --tags) \
    && CGO_ENABLED=0 go build -trimpath -ldflags '-X "main.version='${VERSION}'" \
    -w -s -buildid=' -o webproc .

FROM base

COPY --from=smartdns-builder /smartdns/package/*.tar.gz /opt/
COPY --from=webproc /go/webproc/webproc /usr/local/bin/webproc
COPY docker-entrypoint.sh /entrypoint.sh

RUN tar -xvf /opt/*.tar.gz && \
    mkdir -p /etc/default/ && \
    cd smartdns && \
    mv usr/sbin/smartdns /usr/sbin/smartdns && \
    mv etc/default/smartdns /etc/default/smartdns && \
    mv etc/smartdns/ /etc/smartdns/ && \
    cd / && rm -rf /smartdns /opt/*.tar.gz

EXPOSE 53/udp
VOLUME "/etc/smartdns/"

# ENTRYPOINT ["/entrypoint.sh"]

# CMD ["smartdns"]

# FROM ubuntu:latest as smartdns-builder

# COPY . /smartdns/
# RUN apt-get update && \
#     apt-get install -y make gcc libssl-dev && \
#     cd smartdns && \
#     sh ./package/build-pkg.sh --platform debian --arch `dpkg --print-architecture`

# # #configure dnsmasq
# # RUN mkdir -p /etc/default/
# # RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
# # COPY dnsmasq.conf /etc/dnsmasq.conf
# # #run!
# # ENTRYPOINT ["webproc","--config","/etc/dnsmasq.conf","--","dnsmasq","--no-daemon"]

# FROM ubuntu:latest
# COPY --from=smartdns-builder /smartdns/package/*.deb /opt/
# COPY --from=webproc /usr/local/bin/webproc /usr/local/bin/webproc
# COPY docker-entrypoint.sh /entrypoint.sh
# RUN dpkg -i /opt/*.deb && \
#     rm /opt/*.deb -fr
# RUN apt-get update \
#   && apt-get install -y libssl1.1 \
#   && apt autoremove \
#   && apt autoclean \
#   && rm -rf /tmp/*

# EXPOSE 53/udp
# VOLUME "/etc/smartdns/"

# ENTRYPOINT ["/entrypoint.sh"]

# CMD ["smartdns"]
