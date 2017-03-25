#!/bin/sh
# chkconfig: - 69 88
# description: this script is used for mysql
# author: mysql
# 统计数据库启动脚本
# 2016-06-27
# sudo apt-get install libaio-dev libaio1
# 部署数据库,需要将mysql.tar.gz 解包至/data目录,然后执行如下命令
# chown -R root.mysql /data/mysql
# chown -R mysql.mysql /data/mysql/data /data/mysql/logs
#
lpath=/data/mysql
dport=3306

#innodb_buffer_pool_size参数，该参数根据本服务器的内存大小而定，一般为内存的75%值
innodb_size=2048M
#thread_concurrency参数，该参数根据服务器的CPU核数而定，一般为服务器核数的2倍
thread_size=8
#服务器root用户密码
dbpasswd=BHlog2014

case $1 in
start)
cd $lpath
$lpath/bin/safe_mysqld --user=mysql --pid-file=$lpath/logs/mysql.pid --log-error=$lpath/logs/mysql.log --max_allowed_packet=100000000 --wait_timeout=2880000 --interactive_timeout=2880000 --slow_query_log=1 --slow-query-log-file=$lpath/logs/slow-queries.log --character_set_server=utf8 --basedir=$lpath --datadir=$lpath/data --max_connections=2000  --long_query_time=1 --key_buffer_size=128M --innodb_buffer_pool_size=$innodb_size --skip-innodb_doublewrite --innodb_file_per_table --innodb_flush_log_at_trx_commit=0 --innodb_log_file_size=128M --innodb_log_buffer_size=64M --innodb_file_format=Barracuda --table_cache=256 --thread_concurrency=$thread_size --thread_cache_size=32 --port=$dport --socket=/tmp/mysql.sock --skip-name-resolve --myisam-recover=FORCE,BACKUP &

sleep 10
echo "数据库已经正常启动"
;;
stop)
$lpath/bin/mysqladmin -uroot -p$dbpasswd -S /tmp/mysql.sock shutdown
;;
status)
if [ -f $lpath/data/mysql.pid ] ; then
echo "mysqld process(`cat $lpath/data/mysql.pid`)running..."
else
echo "mysqld stoped."
fi
;;
*)
echo "Usage: $lpath/data/mysql5.sh start|stop|status"
;;
esac
