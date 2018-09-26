---
title: mongodb 整合kerberos以及java连接
date: 2018-09-26 08:36:02
tags: mongodb
categories: ["kerberos","mongodb","java"]
---

### 简介

* Kerberos（KDC） 几个重要的概念：

```
Principal：任何服务器所提供的用户、计算机、服务都将被定义成Principal。本例使用客户端使用：mongodb@HZ.COM  mongodb服务端使用：mongodb/hz.com@HZ.COM
Instances：用于服务principals和特殊管理Principal。
Realms：Kerberos安装提供的独特的域的控制，把它想象成你的主机和用户所属的主机或者组。官方约定这域需要大写。默认的，Ubuntu将把DNS域名转换为大写当成这里的域。 本例使用HZ.COM
Key Distribution Center: （KDC）由三部分组成，一是principal数据库，认证服务器，和票据授予服务器。每个Realm至少要有一个。
Ticket Granting Ticket：由认证服务器（AS）签发，Ticket Granting Ticket (TGT)使用用户的密码加密，这个密码只有用户和KDC知道。
Ticket Granting Server: (TGS) 根据请求签发服务的票据。
Tickets：确认两个Principal的身份。一个主体是用户，另一个是由用户请求的服务。门票会建立一个加密密钥，用于在身份验证会话中的安全通信。
Keytab Files：从KDC主数据库中提取的文件，并且包含的服务或主机的加密密钥。
```

* mongodb 启用kerberos
使用kerberos授权登录可以更大的增加安全性


### 安装带有kerberos认证的mongodb
#### 安装kerberos
    请参照网上相关的教程，作者后续会发布相关的安装教程


#### 安装mongodb enterprice

这是企业版下载链接 [mongodb enterprice](https://downloads.mongodb.com/linux/mongodb-linux-x86_64-enterprise-rhel70-4.0.2.tgz?_ga=2.98831574.996585356.1537869301-553143157.1537869299 "mongodb") 

本次安装基于centos7.2

* 安装依赖的一些库
```
yum install cyrus-sasl cyrus-sasl-gssapi cyrus-sasl-plain krb5-libs libcurl libpcap lm_sensors-libs net-snmp net-snmp-agent-libs openldap openssl rpm-libs tcp_wrappers-libs -y
```

* 解压下载的mongodb

```
# 解压
$ tar -xvf mongodb-linux-x86_64-enterprise-rhel70-4.0.2.tgz
$ cd mongodb-linux-x86_64-enterprise-rhel70-4.0.2/
$ mkdir data
$ mkdir conf
```

$ vi conf/mongod.conf  #更改以下路径为自己的路径,ip为服务器的ip
```
dbpath=/root/mongodb/mongodb-linux-x86_64-enterprise-rhel70-4.0.2/data

#where to log
logpath=/root/mongodb/mongodb-linux-x86_64-enterprise-rhel70-4.0.2/mongodb.log

logappend=true

bind_ip = 10.211.55.5
port = 27017

# Enable journaling, http://www.mongodb.org/display/DOCS/Journaling
journal=true

```

* 创建对应的kerberos用户以及keytab文件（hz.com为我自己的主机名）

客户端用户：mongodb@HZ.COM  mongodb服务端用户：mongodb/hz.com@HZ.COM

keytab文件：mongodb.keytab                  mongodb_hz.keytab


* 将mongodb目录下的bin文件夹加入到PATH
以下两句可以追加到文件末尾：/etc/profile   具体路径请根据自己的进行修改
```
export MONGODB_HOME=/root/mongodb/mongodb-linux-x86_64-enterprise-rhel70-4.0.2
export PATH=$MONGODB_HOME/bin:$PATH
export KRB5_KTNAME=/root/mongodb_hz.keytab
```
执行source，使上面的追加起作用
source /etc/profile

* 添加kerberos登录用户到mongodb
```
cd $MONGODB_HOME
./bin/mongod -f conf/mongod.conf

另起一个窗口，使用shell登录进去mongodb，并添加kerberos用户,请替换以下的kerberos客户端用户为你的用户

$ mongo --host hz.com

use $external
 db.getSiblingDB("$external").createUser(
   {
     user: "mongodb@HZ.COM",
     roles: [ { role: "root", db: "admin" } ]
   }
)
exit
```
* 使用kerberos认证启动mongodb
```
首先关闭上一个mongod服务,然后使用下面命令启动mongodb
$ kdestory
$ kinit -kt /root/mongodb_hz.keytab mongodb/hz.com
$ mongod-auth --setParameter authenticationMechanisms=GSSAPI -f /root/mongodb/mongodb-linux-x86_64-enterprise-rhel70-4.0.2/conf/mongod.conf

```
启动后如下图
![mongodb](/images/mongodb/2018-09-26-01.png)

* 使用kerberos，登录mongodb
```
$ kdestory
$ kinit -kt mongodb.keytab mongodb
$ mongo --host hz.com --authenticationMechanism=GSSAPI --authenticationDatabase='$external' --username mongodb@HZ.COM
$ show dbs
```
如下图，表示成功
![mongodb](/images/mongodb/2018-09-26-02.png)



### 使用java连接带有kerberos的mongodb

使用maven工程构建，依赖如下
```
    <dependency>
        <groupId>org.apache.hadoop</groupId>
        <artifactId>hadoop-common</artifactId>
        <version>2.6.0-cdh5.13.0</version>
    </dependency>
    <dependency>
        <groupId>org.mongodb</groupId>
        <artifactId>mongo-java-driver</artifactId>
        <version>3.8.2</version>
    </dependency>
```

创建连接类MyMongo,请替换相关的用户名、host、krb5.conf、keytab文件位置等
```
package com.hz.mongodb;

import com.mongodb.MongoClient;
import com.mongodb.MongoCredential;
import com.mongodb.ServerAddress;
import com.mongodb.client.*;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.security.UserGroupInformation;
import org.bson.Document;
import java.io.IOException;
import java.security.PrivilegedAction;
import java.security.PrivilegedExceptionAction;
import java.util.Arrays;

/**
 * Created with hzz
 * Description:
 *
 * @author: huangzhe
 * @date: 2018-01-25
 * @time: 下午20:14
 */
public class MyMongo {
    public static void main(String[] args) {
        Configuration conf = new Configuration();
        conf.set("hadoop.security.authentication", "Kerberos");
        System.setProperty("java.security.krb5.conf", "/Users/huangzhe/Downloads/krb5.conf");
        UserGroupInformation.setConfiguration(conf);
         MongoClient client = null;
        try {
            UserGroupInformation ugi = UserGroupInformation.loginUserFromKeytabAndReturnUGI("mongodb@HZ.COM", "/Users/huangzhe/Downloads/mongodb.keytab");

            try {
                client=ugi.doAs((PrivilegedExceptionAction<MongoClient>) () -> {
                    MongoCredential credential = MongoCredential.createGSSAPICredential("mongodb@HZ.COM");
                    MongoClient result = new MongoClient(new ServerAddress("hz.com", 27017),
                            Arrays.asList(credential));
                    MongoDatabase db = result.getDatabase("ceshi");
                    MongoIterable<String> tbs = db.listCollectionNames();
                    MongoCursor<String> tbCursor = tbs.iterator();
                    System.out.println("连接mongodb 成功");
                    return result;
                });
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("连接mongodb 失败");
        }

        //获取对应的表
        MongoDatabase db = client.getDatabase("mybase");
        MongoIterable<String> tbs = db.listCollectionNames();

        MongoCursor<String> tbCursor = tbs.iterator();
        while (tbCursor.hasNext()) {
            System.out.println(tbCursor.next());
        }

        MongoCollection<Document> t = db.getCollection("test");
        FindIterable<Document> ds = t.find();
        MongoCursor<Document> ss = ds.iterator();
        while (ss.hasNext()){
            System.out.println(ss.next());
        }
        System.out.println(t.count());
    }
}
```

