---
title: solr安装分词
date: 2018-04-03 16:31:51
tags: ["solr","lucene","search"]
category: ["linux","solr"]
---

* 环境 centos7
### 下载solr
`地址：http://www.apache.org/dyn/closer.lua/lucene/solr/7.2.1`

#### 解压
```bash
tar -xvf solr-7.2.1.tgz

```
<!--more-->

### 1. 直接使用solr
```
cd solrHome(solrHome是solr的路径)
cd bin
solr start
```
#### 1.1. 创建core 或者collection 意义一致
```bash
solr create -c articles
控制台：http://127.0.0.1:8983/solr
```

#### 1.2. 创建分词器
```bash
下载地址：https://pan.baidu.com/s/1smOxPhF
将解分词资料里的ik-analyzer-solr5-5.x.jar拷贝到你的solr目录下的\server\solr-webapp\webapp\WEB-INF\lib目录中去，
将IKAnalyzer.cfg.xml，mydict.dic（搜狗的扩展词库），stopword.dic放在你的solr目录下的\server\solr-webapp\webapp\WEB-INF\classes目录中去


修改 articles集合目录下的managed-schema

添加以下4行：

<fieldType name="text_ik" class="solr.TextField">  
        <analyzer class="org.wltea.analyzer.lucene.IKAnalyzer"/>  
</fieldType>  


重启或者reload

```
#### 1.3. 创建字段
```
{
    "add-field" : {
        "name" : "name",
        "type" : "text_ik"
    },
    "add-field" : {
        "name" : "content",
        "type" : "text_ik",
        "stored" : "true"
    },
    "add-field" : {
        "name" : "createTime",
        "type" : "date"
    }
}

post提交：
http://localhost:8983/solr/articles/schema
```

#### 1.4. 删除字段

```
{
    "delete-field" : {
        "name" : "name"
    },
    "delete-field" : {
        "name" : "content"
    }
}
http://localhost:8983/solr/articles/schema
```


### 2. 使用tomcat作为容器运行solr
#### 2.1 新创建一个solr_home_new文件夹

```
export solr_home=/app/solr-7.2.1
export solr_home_new=/app/solr_home

复制 ${solr_home}/server/solr-webapp/webapp 并重命名 ${tomcat}/webapp/solr
cp -r ${solr_home}/dist  ${solr_home_new}/
cp ${solr_home}/server/lib/ext/*.jar ${tomcat}/webapp/solr/WEB-INF/lib/
cp ${solr_home}/server/lib/*.jar ${tomcat}/webapp/solr/WEB-INF/lib/
#classes文件夹没有自己创建
cp ${solr_home}/server/resources/log4j.properties ${tomcat}/webapp/solr/WEB-INF/classes 


#进入 ${tomcat}/webapp/solr/WEB-INF/ 修改web.xml
修改：修改中间为自己的solr_home_new，我的solr_home_new为solr_home/solr

 <env-entry>
         <env-entry-name>solr/home</env-entry-name>
         <env-entry-value>/Users/huangzhe/app/solr_home/solr</env-entry-value>
         <env-entry-type>java.lang.String</env-entry-type>
</env-entry>
并注释以下，防止403：
<!--  <security-constraint>
    <web-resource-collection>
      <web-resource-name>Disable TRACE</web-resource-name>
      <url-pattern>/</url-pattern>
      <http-method>TRACE</http-method>
    </web-resource-collection>
    <auth-constraint/>
  </security-constraint>
  <security-constraint>
    <web-resource-collection>
      <web-resource-name>Enable everything but TRACE</web-resource-name>
      <url-pattern>/</url-pattern>
      <http-method-omission>TRACE</http-method-omission>
    </web-resource-collection>
  </security-constraint>
-->

```


#### 2.2 创建core
```
cp -r ${solr_home}/server/solr ${solr_home_new}/
cd ${solr_home_new}/solr
mkdir new_core
cp -r configsets/_default/conf new_core

打开浏览器：http://localhost:8080/solr/index.html
点击：core Admin ,然后更改schema.xml为 managed-schema，点击确定
```


#### 2.3 添加分词器
与1.2一致，在tomcat下面对应的路径去改
