#!/bin/sh
# chkconfig: - 69 88
# description: this script is used for mysql
# author: mysql
# ͳ�����ݿ������ű�
# 2016-06-27
# sudo apt-get install libaio-dev libaio1
# �������ݿ�,��Ҫ��mysql.tar.gz �����/dataĿ¼,Ȼ��ִ����������
# chown -R root.mysql /data/mysql
# chown -R mysql.mysql /data/mysql/data /data/mysql/logs
#
lpath=/data/mysql
dport=3306

#innodb_buffer_pool_size�������ò������ݱ����������ڴ��С������һ��Ϊ�ڴ��75%ֵ
innodb_size=2048M
#thread_concurrency�������ò������ݷ�������CPU����������һ��Ϊ������������2��
thread_size=8
#������root�û�����
dbpasswd=BHlog2014

case $1 in
start)
cd $lpath
$lpath/bin/safe_mysqld --user=mysql --pid-file=$lpath/logs/mysql.pid --log-error=$lpath/logs/mysql.log --max_allowed_packet=100000000 --wait_timeout=2880000 --interactive_timeout=2880000 --slow_query_log=1 --slow-query-log-file=$lpath/logs/slow-queries.log --character_set_server=utf8 --basedir=$lpath --datadir=$lpath/data --max_connections=2000  --long_query_time=1 --key_buffer_size=128M --innodb_buffer_pool_size=$innodb_size --skip-innodb_doublewrite --innodb_file_per_table --innodb_flush_log_at_trx_commit=0 --innodb_log_file_size=128M --innodb_log_buffer_size=64M --innodb_file_format=Barracuda --table_cache=256 --thread_concurrency=$thread_size --thread_cache_size=32 --port=$dport --socket=/tmp/mysql.sock --skip-name-resolve --myisam-recover=FORCE,BACKUP &

sleep 10
echo "���ݿ��Ѿ���������"
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
