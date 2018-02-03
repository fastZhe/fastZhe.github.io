---
title: linux下使用rsync快速删除大量文件
date: 2018-01-31 18:07:52
tags: ["rsync","rm"]
category: ["linux","shell"]
---

## 问题：快速删除一个文件夹下的大量文件？
* 使用rm 大量文件会很慢，更大时并且会报错
> 实际原理：遍历删除

```bash
$ rm -fr *
```
<!--more-->
* 使用rsync删除
> 实际原理：使用空文件夹替换要删除的文件夹



```bash
#建立新的空文件夹
$ mkdir src
#建立实际有很多文件的文件夹
$ mkdir dest
#模拟生成大量文件  900000个文件
$ touch file{1..900000}
#使用rsync删除
# -r 包含文件夹 -l 符号链接 -p 权限 permission -t 保持文件修改时间 -D 特殊设备
$ rsync --delete-before -rlptD src/ dest
#或者(与上面一样的效果)
$ rsync -a --delete-before --no-o --no-g src/ dest
```
