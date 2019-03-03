---
title: docker-shadowsocks多用户镜像
date: 2018-11-20 12:36:02
tags: shadowsocks
categories: ["docker","shadowsocks"]
---

## 简介

搭建一个使用docker镜像实现的shadowsocks server端，支持多用户


## 使用

可以使用作者已有的仓库镜像

* 默认开启五个端口，密码都为hhhzz，加密方法为：aes-256-cfb

```
# 使用默认的配置文件
docker run -d -p 9991:9991 -p 9992:9992 -p 9993:9993 -p 9994:9994 -p 9995:9995  hzdan/shadowsocks_manyusers:1.0
# 使用自定义文件
# /mnt/shadowsocks.json 为具体配置项，自己可定义，并挂载覆盖
docker run -d -p 9991:9991 -p 9992:9992 -p 9993:9993 -p 9994:9994 -p 9995:9995  -v `pwd`:/mnt hzdan/shadowsocks_manyusers:1.0

```

## 自定义镜像

### 创建dockerfile && shadowsocks.json && start.sh

* dockerfile

> 本镜像借鉴与oddrationale@gmail.com 作者的镜像

```
# shadowsocks
#
# VERSION 0.0.3

FROM ubuntu:16.04
MAINTAINER hzz

RUN apt-get update && \
    apt-get install -y python-pip libsodium18
RUN pip install shadowsocks==2.8.2
COPY shadowsocks.json /mnt
COPY start.sh /usr/local

# Configure container to run as an executable
CMD /usr/local/start.sh
```

* shadowsocks.json

> 用户密码，端口都可以更改


```
{
    "server":"0.0.0.0",
    "local_address":"127.0.0.1",
    "local_port":1080,
    "port_password":{
        "9991":"hhhzz",
        "9992":"hhhzz",
        "9993":"hhhzz",
        "9994":"hhhzz",
        "9995":"hhhzz"
},
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open":false
}
```

* start.sh

```
#!/bin/sh
/usr/local/bin/ssserver -c /mnt/shadowsocks.json
```


## 打包、使用


```
# 打包
docker build -t <tag> .

# 运行，-p使用的端口与配置文件中需要一致
docker run -d -p 9991:9991 -p 9992:9992 -p 9993:9993 -p 9994:9994 -p 9995:9995 <tag>

```

