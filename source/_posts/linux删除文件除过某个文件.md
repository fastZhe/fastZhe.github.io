---
title: linux删除文件除过某个文件
date: 2018-02-01 09:43:10
tags: find, rm
category: shell ,linux
---

### 使用rm 
> 删除除了file1 的文件

```bash
rm -fr !(file1)
```


### 使用find
> 删除除了file1

```bash
find ./* -not -name "file1" | xargs rm -fr
find ./* -not -name "file1" -exec rm -fr {} \;
```



