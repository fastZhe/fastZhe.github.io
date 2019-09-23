---
title: localtunnel server端搭建
date: 2018-03-15 09:56:46
tags: ["localtunnel","nginx","内网穿透"]
category: ["内网穿透"]
---

## localtunnel server
### 下载程序
> 以下地址为localtunnel server的git页面

`https://github.com/localtunnel/server`

> 下载安装

* 前提：本机安装git、 nodejs 
* 有独立域名、独立主机（公网ip）
<!--more-->

```bash
$ git clone  https://github.com/localtunnel/server.git
$ cd localtunnel-server
$ npm install
```

> 启动

```bash
# 直接使用
$ bin/server --port 2000
# 配合 pm2 使用
$ pm2 start bin/server --name lt -- --port 2000
```

> server配合nginx使用

* 配置如下：

```nginx
upstream server {

                server 127.0.0.1:8099;
        }
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}

server {
        listen 80 default_server;
        server_name example.com;
    location / {
        proxy_pass http://server;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-Proto http;
        proxy_set_header X-NginX-Proxy true;
     #  proxy_set_header Upgrade $http_upgrade;
     #  proxy_set_header Connection $connection_upgrade;

        proxy_redirect off;
                }
        }

 server {
        listen       443 default_server ssl;
        server_name  example.com;
        ssl on;
        ssl_certificate      /etc/letsencrypt/live/example.com/fullchain.pem;
        ssl_certificate_key  /etc/letsencrypt/live/example.com/privkey.pem;

        ssl_session_cache    shared:SSL:1m;
        ssl_session_timeout  5m;

        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers  on;

        location / {

        proxy_pass http://server/;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;

        proxy_set_header X-NginX-Proxy true;
        proxy_redirect off;
        }
    }
```


> client端使用

```bash
# 安装client端
$ npm i localtunnel -g
# 使用localtunnel默认服务器启动本地监听8080端口
$ lt --port 8080
# 使用自己搭建的服务器启动监听本地8080端口
$ lt -h http://example.com --port 8080
# 指定二级域名启动监听
$ lt -s ceshi -h http://example.com --port 8080 
```


