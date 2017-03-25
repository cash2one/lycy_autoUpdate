#!/bin/bash
#by 2016-11-14
#创世兵魂

date=`date +%Y-%m-%d`
rmdate=`date -d "4 weeks ago" +%Y-%m-%d`


dbpasswd=BHlog2014
dpath=/data/dbbackup/
rm -rf /data/dbbackup/zabbix.$rmdate.tar.gz

innobackupex --user=root --password=$dbpasswd --stream=tar --tmpdir=/tmp --no-timestamp $dpath |gzip 1>$dpath/zabbix.$date.tar.gz

#end