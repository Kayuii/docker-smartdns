#!/bin/sh

set -e

if [[ $# -eq 1 && ("$1" == "smartdns" || "$1" == "/usr/sbin/smartdns") ]]; then
    exec "$@" -f -x -c /etc/smartdns/smartdns.conf
fi
if [[ $# -eq 1 && ( "$1" == "webproc" || "$1" == "/usr/sbin/webproc") ]]; then
    exec "$@" -c /etc/smartdns/smartdns.conf -- smartdns -f -x -c /etc/smartdns/smartdns.conf
fi
exec "$@"
