#!/bin/bash
# by 2016-08-18
# 用于将所有服务器的日志拷贝至tools.uc服务器用于归档使用

export LANG=zh_CN.utf8
my_process=$$
outtmp=/tmp/$my_process-`date +%s-%N`.outtmp
errtmp=/tmp/$my_process-`date +%s-%N`.errtmp


sed  '/^+/d' /home/op/fps_list.conf|awk '{print $3":"$4":"$5}' >$outtmp

while read line
do
platform=`echo $line|awk -F":" '{print $1}'`
serverid=`echo $line|awk -F":" '{print $2}'`
serverip=`echo $line|awk -F":" '{print $3}'`

case $platform in
3)
ptname="7k7k"
;;
7)
ptname="4399"
;;
9)
ptname="fyzb"
;;
21)
ptname="360"
;;
22)
ptname="kugou"
;;
10)
ptname="2144"
;;
13)
ptname="tencent"
;;
25)
ptname="tiexue"
;;
27)
ptname="xunlei"
;;
esac

cd /data1/logs/commonLog
mkdir -p "$ptname"_"$platform"
cd "$ptname"_"$platform"
rsync -avzuP $serverip:/var/lib/StateServer/commonLog/"$platform"/"$serverid" . 1>$errtmp
echo "$serverip is ok"

done<$outtmp
#
rm -rf /tmp/$my_process-[0-9]*-[0-9]*.errtmp /tmp/$my_process-[0-9]*-[0-9]*.outtmp
#