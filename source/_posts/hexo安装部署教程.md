---
title: hexo安装部署教程
date: 2018-01-30 23:18:15
tags: "hexo"
---
##    建立一个githubpage项目
### 使用自定义域名访问博客的前提：
> 有域名解析至你的github page 我的域名为：blog.wudd.top


####   建立一个分支 hexo
* hexo为项目管理分支，即hexo博客项目的主分支
* master分支为博客展示页面的分支（建好项目即存在的分支）

##  在本地 clone hexo 分支
<!--more-->

```bash
#克隆hexo分支
$ git clone -b hexo git地址
#进入克隆好的项目
$ cd 项目名
```
##  安装hexo 以及相关的主题
```bash
#全局安装hexo
$ sudo npm install -g hexo-cli
#初始化hexo
$ hexo init .
```
####  编辑项目目录下的 _config.yml文件
##### ps
* site:为博客自定义内容
* 主题theme：主题配置项为第四步安装的，默认为自带的，也可不修改
* deploy:填写自己的githubpage地址，分支为master
* url:填写自己的博客访问url
```bash
#编辑项目根目录下的配置文件，修改以下其他可不修改：
$ vim _config.yml
 
  5 # Site
  6 title: Hzhe
  7 subtitle: you...
  8 description: blog java
  9 author: hzz
 10 language:
 11 timezone:
 12
 13 # URL
 14 ## If your site is put in a subdirectory, set url as 'http://yoursite.com/ch    ild' and root as '/child/'
 15 url: http://blog.wudd.top
 16 root: /
 17 permalink: :year/:month/:day/:title/
 18 permalink_defaults:
# Extensions
 73 ## Plugins: https://hexo.io/plugins/
 74 ## Themes: https://hexo.io/themes/ 
 75 theme: hexo-theme-laughing
 76
 77 # Deployment
 78 ## Docs: https://hexo.io/docs/deployment.html
 79 deploy:
 80   type: git
 81   repo: https://github.com/fastZhe/fastZhe.github.io
 82   branch: master

```
##  安装hexo相关的主题
* signature:个人签名
* author.head:个人头像
* navication:菜单栏
* copyright：建议都关闭
* socail:社交媒体连接
```bash
#进入theme文件夹
$ cd theme
#安装主题（不是必须）
$ npm install hexo-renderer-pug --save
$ git clone git@github.com:BoizZ/hexo-theme-laughing.git
#删除主题文件夹内的.git
$ cd hexo-theme-laughing ; rm -fr .git
#编辑主题配置文件
$ vim _config.yml

  6 page_background: http://callfiles.ueibo.com/hexo-theme-laughing/page_backgro    und.jpg
  7 page_menu_button: dark
  8 post_background: http://callfiles.ueibo.com/hexo-theme-laughing/post_backgro    und.jpg
  9 post_menu_button: light
 10 title_plancehold: 随笔
 11 author:
 12   head: https://tva3.sinaimg.cn/crop.0.0.750.750.180/cbe52eb6jw8ew3l78tj4qj2    0ku0kv75s.jpg
 13   signature: 世界那么大，我想去看看。。。KEEP FIGHTING
 14 navication:
 15   - name: Github
 16     link: https://github.com/fastZhe
 17 # content
 18 content_width: 800

 21 social:
 22   - name: Github
 23     icon: github
 24     link: https://github.com
 25   - name: Weibo
 26     icon: weibo
 27     link: https://weibo.com/p/1005053420794550/home?from=page_100505&mod=TAB    &is_all=1

 # Copyright
 33 copyright:
 34   record: false
 35   hexo: false
 36   laughing: true
```

##  编辑githubpage 项目根目录下的.gitignore
* 配置成以下：避免项目管理分支缺少相关目录
* 推送至hexo分支
```bash
$ vim .gitignore

.DS_Store
Thumbs.db
*.log
.deploy*/

$ git add .gitignore 
$ git commit -m ""
$ git push origin hexo
```

##  新建编辑CNAME 自动映射对应的域名
* 填写自己访问的博客地址
* ps 这个是我的域名，请换成自己的
* 推送至hexo分支
```bash
$ vim source/CNAME
blog.wudd.top

$ git add . 
$ git commit -m ""
$ git push origin hexo
```


##  发布博客以及推送操作
```bash
#新建博客
$ hexo new "博客名"
INFO  Created: ~/me/blog/fast/fastZhe.github.io/source/_posts/hexo安装部署教程.md
#编辑博客
$ vim ~/me/blog/fast/fastZhe.github.io/source/_posts/hexo安装部署教程.md
#推送至远程项目目录进行保存分支为hexo（保存项目目录，多机操作）
$ git add .
$ git commit -m "最新博客等。。。"
$ git push origin hexo
#生成博客
$ hexo g
#本地预览（在本地验证博客是否有问题）,访问以下地址即可
$ hexo server
➜  fastZhe.github.io git:(hexo) ✗ hexo server
INFO  Start processing
INFO  Hexo is running at http://localhost:4000/. Press Ctrl+C to stop.

#部署博客至githubpage
hexo d
```

### 打开页面 你的域名，请尽情欣赏吧！！！
