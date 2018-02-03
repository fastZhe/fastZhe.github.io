#!/bin/bash
curDate=$(date +%Y%m%d%H%M)
defaultmsg="commit new msg:${curDate}"
if [ ! -z "$1" ]; then
defaultmsg=$1
fi

echo "use msg:${defaultmsg}"

basedir=$(cd `dirname $0`;pwd)
echo $basedir

cd $basedir
#生成html
hexo g
#git add .
git add .
#commit 
git commit -m "${defaultmsg}"
#git push hexo
git push origin hexo
#hexo push master
hexo d

echo "everything is done"
