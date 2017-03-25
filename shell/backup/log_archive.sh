#!/bin/bash
#script_name : log_archive.sh
#script_path : /home/op/sh/log_archive.sh
#crontab : 30 00 * * * /home/op/bin/sh/log_archive.sh　>/tmp/log_archive.log 2>&1
#日志归档
#每台游戏服务器
#by 2016-11-14

if [ -z $1 ];then
date1=`date -d "1 days ago" +%Y%m%d`
date2=`date -d "1 days ago" +%Y%m`
date3=`date -d "1 days ago" +%Y%m%d.%h`
else
date1=`date -d "$1 days ago" +%Y%m%d`
date2=`date -d "$1 days ago" +%Y%m`
date3=`date -d "$1 days ago" +%Y%m%d.%h`
fi

cd /data/logs

list=(BattleServer EnrollServer MatchServer PVRServer StateServer transfer)

for path in ${list[*]}
do
	cd /data/logs/$path
	mkdir -p $date2/$date1
	mv $date2[0-2][0-9] $date2 2>/dev/null
	files=`ls server*.log.$date1.[0-2][0-9] 2>/dev/null`
	if [[ ! -z $files ]];then
	mv $files $date2/$date1
	fi
done


#删除日志,保留近3个月日志
find /data/logs/ -type f -name "*.log.*" -atime +30 -exec rm -rf {} \;

#每月末备份mysql程序,以便留作查询使用
date4=`date -d "1 days" +%d`
date5=`date +%Y%m%d`
date6=`date -d "6 month ago" +%Y%m%d`
case $date4 in
09)
export PATH=/home/op/mysql/bin:$PATH
mysqldump -uroot -p'BHlog2014' -h 127.0.0.1 -P 3306 --default-character-set=utf8 --hex-blob --skip-lock-tables bh_log > /backup/mysql/backup/mysql$date5.sql
cd /backup/mysql/backup
tar czvfp mysql$date5.sql.tar.gz mysql$date5.sql
rm -rf /backup/mysql/backup/mysql$date5.sql
rm -rf /backup/mysql/backup/mysql$date6.sql.tar.gz
;;
esac
