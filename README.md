# 简单易用的docker-smartdns，使用 webproc 作为 web 配置界面，支持 amd64，arm64，armvl7
```
docker pull kayuii/smartdns
docker run --rm -it -p 8080:8080 -p 1053:53/udp --name smartdns  -v ./config.conf:/etc/smartdns/smartdns.conf kayuii/smartdns webproc
```
配置满意后可以只启动 smartdns
```
docker run -d -p 8080:8080 -p 1053:53/udp --restart=always --name smartdns -v ./config.conf:/etc/smartdns/smartdns.conf kayuii/smartdns
```
tcp可以按需映射,一般都是用udp,增加tcp使用-p 53:53

高级配置
```
docker run --rm -it -p 8080:8080 -p 1053:53/udp -v ./config.conf:/etc/smartdns/smartdns.conf  kayuii/smartdns webproc -c /etc/smartdns/smartdns.conf -- smartdns -f -x -c /etc/smartdns/smartdns.conf

docker run --rm -it -p 8080:8080 -p 1053:53/udp -v ./config.conf:/etc/smartdns/smartdns.conf  kayuii/smartdns smartdns -f -x -c /etc/smartdns/smartdns.conf
```

dns测试
```
$ dig google.com -p 1053 @127.0.0.1
; <<>> DiG 9.16.1-Ubuntu <<>> google.com -p 1053 @127.0.0.1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 36275
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 512
;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		293	IN	A	142.250.66.142

;; Query time: 100 msec
;; SERVER: 127.0.0.1#1053(127.0.0.1)
;; WHEN: 二 6月 21 12:37:57 CST 2022
;; MSG SIZE  rcvd: 55

$ nslookup -port=1053 google.com 127.0.0.1
Server:		127.0.0.1
Address:	127.0.0.1#1053

Non-authoritative answer:
Name:	google.com
Address: 93.46.8.90

```

项目地址：https://github.com/kayuii/docker-smartdns

介绍

本项目使用https://github.com/pymumu/smartdns 提供的程序制作.

SmartDNS是一个运行在本地的DNS服务器，SmartDNS接受本地客户端的DNS查询请求，从多个上游DNS服务器获取DNS查询结果，并将访问速度最快的结果返回给客户端，避免DNS污染，提高网络访问速度。 同时支持指定特定域名IP地址，并高性匹配，达到过滤广告的效果。

与dnsmasq的all-servers不同，smartdns返回的是访问速度最快的解析结果。

本项目 web 配置使用https://github.com/jpillora/webproc 提供的程序制作.

webproc 是个简单易用文本配置工具，结合各种应用程序构建快速配置，保存重载。
