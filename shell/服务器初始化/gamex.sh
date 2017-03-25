#!/bin/bash
#used for gamex(lol)
#mysql root's passwd "gameX2015"
#mysql moba's passwd "moba2015"
#2016.4.26

if [ `id -u` != 0 ];then
	echo "please run this script by root"
	exit 1
fi

cat > /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
EOF
apt-get update
apt-get install -y --force-yes nginx php5 php5-mysql php5-fpm mysql-server-5.6 percona-xtrabackup lrzsz java-common oracle-jdk7
mysql -uroot -pgameX2015 -e "grant all on *.* to 'moba'@'%' identified by 'moba2015'"
mysql -uroot -pgameX2015 -e "grant all on *.* to 'moba'@'111.200.57.162' identified by 'moba2015'"
mysql -uroot -ppgameX2015 -e "flush privileges"
iptables -I INPUT 2 -s 111.200.57.162 -p tcp --dport 3306 -j ACCEPT
iptables-save

service mysql stop
[ ! -d /data ] && mkdir /data
cp -ra /var/lib/mysql /data
sed -i.bak '/\/var\/lib\/mysql\/ r,/a \/data\/mysql\/ r,' /etc/apparmor.d/usr.sbin.mysqld
sed -i 's/\/var\/lib\/mysql\/ r,/#&/' /etc/apparmor.d/usr.sbin.mysqld
# *号也需要转义
# show global variables like 'datadir';
# php5-fpm -c php.ini -y /etc/php5/fpm/php-fpm.conf
sed -i '/\/var\/lib\/mysql\/\*\* rwk,/a \/data\/mysql\/\*\* rwk,' /etc/apparmor.d/usr.sbin.mysqld
sed -i 's/\/var\/lib\/mysql\/\*\* rwk,/#&/' /etc/apparmor.d/usr.sbin.mysqld
/etc/init.d/apparmor restart

sed -i '/^datadir/c datadir         = \/data\/mysql' /etc/mysql/my.cnf
service mysql start

echo "deb http://mirrors.ustc.edu.cn/ubuntu lucid main universe multiverse restricted" > /etc/apt/sources.list
echo "deb http://mirrors.ustc.edu.cn/ubuntu lucid-updates main universe multiverse restricted" >> /etc/apt/sources.list
echo "deb http://mirrors.lieyan.com.cn/ppweb-ubuntu/ lucid main non-free contrib" > /etc/apt/sources.list.d/ppweb.list

#apt-get install -y --force-yes --no-install-recommends ppweb-archive-keyring ppweb-bashrc ppweb-sysctl ppweb-policy-server ganglia-monitor-config-game fps-glassfish-app-stateserver fps-glassfish-domain-stateserver

#跟flash和服务器通信有关。现在137上部署的客户端 链接不了137上的state服务器
#locate flashShitD
ps -ef |grep flashShitD
if [ $? -ne 0 ];then
	apt-get install -y --force-yes ppweb-policy-server
fi