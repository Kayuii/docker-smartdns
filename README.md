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

项目地址：https://github.com/kayuii/docker-smartdns

介绍

本项目使用https://github.com/pymumu/smartdns 提供的程序制作.

SmartDNS是一个运行在本地的DNS服务器，SmartDNS接受本地客户端的DNS查询请求，从多个上游DNS服务器获取DNS查询结果，并将访问速度最快的结果返回给客户端，避免DNS污染，提高网络访问速度。 同时支持指定特定域名IP地址，并高性匹配，达到过滤广告的效果。

与dnsmasq的all-servers不同，smartdns返回的是访问速度最快的解析结果。

本项目 web 配置使用https://github.com/jpillora/webproc 提供的程序制作.

webproc 是个简单易用文本配置工具，结合各种应用程序构建快速配置，保存重载。
