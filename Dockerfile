FROM kayuii/smartdns:Release36.1 as smartdns

FROM kayuii/webproc:v0.4.0 as webproc

FROM alpine:latest

COPY --from=smartdns /release/ /
COPY --from=webproc /usr/sbin/webproc /usr/sbin/webproc
COPY docker-entrypoint.sh /entrypoint.sh

EXPOSE 53/udp
VOLUME "/etc/smartdns/"

ENTRYPOINT ["/entrypoint.sh"]

CMD ["smartdns"]
