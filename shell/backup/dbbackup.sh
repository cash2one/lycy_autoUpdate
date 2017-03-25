#!/bin/sh
date=`date +%Y-%m-%d`
date1=`date -d "15 days ago" +%Y-%m-%d`

mysqldump -uroot -pBHlog2014 --default-character-set=utf8 --hex-blob --databases zabbix > /data/dbbackup/zabbix."$date".sql
rm -rf /data/dbbackup/zabbix."$date1".sql
