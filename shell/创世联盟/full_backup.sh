#!/bin/bash
#by 2016-07-27
#

date=`date +%Y-%m-%d`
rmdate=`date -d "90 days ago" +%Y-%m-%d`
date2=`date +%Y%m%d_%H`


dbpasswd=gameX2015
dpath=/home/ycone/backup/$date
rm -rf /home/ycone/backup/db$rmdate.tar.gz
mkdir -p $dpath

find /home/ycone/backup/ -type d -ctime +30 -exec rm {} \;
innobackupex --user=root --password=$dbpasswd --slave-info --stream=tar --tmpdir=/tmp --no-timestamp $dpath |gzip 1>$dpath/db$date2.tar.gz

#end