#!/bin/bash
#百度云初始化服务器脚本
#请先挂载磁盘/data目录
#然后使用root执行该脚本
echo "请先格式化磁盘, 执行 mkfs.ext4 -L /data /dev/vdb ; mount /data"
read -p "已挂载磁盘了么 (y|Y|N|n) ? " tag
case $tag in
y|Y)
#1
echo "开始部署目录结构..."
sudo chown op.op /data
cd /data
sudo mkdir backup mongodata logs
sudo ln -s -n -f /data/backup /backup
sudo ln -s -n -f /data/mongodata /mongodata
sudo chown -R op.op /data/backup /data/mongodata /data/logs

#2
sudo mkdir -p /backup/mongodata/backup/{differential,full}
sudo mkdir -p /backup/mysql/backup
sudo chown -R op.op /backup/

sudo mkdir -p /data/mongodata/{log{,1,2,3},data{,1,2,3}/{shard{1,2},config}}
sudo chown op:op -R /data/mongodata
sudo mkdir -p /var/lib/StateServer/logs
sudo mkdir -p /var/lib/StateServer/bin
sudo chown -R StateServer.StateServer  /var/lib/StateServer

#3
cd /data/logs
mkdir BattleServer EnrollServer MatchServer PVRServer StateServer transfer
sudo chown StateServer StateServer

#4
sudo tar xzvfp /home/op/mysql.tar.gz -C /data 1>/dev/null
echo "mysql启动停止脚本: /data/mysql/data/mysql5.5.18_3306.sh (start|stop)"

#5
while true
do
read -p "请输入主机名: " hostname
read -p "请确认你输入的主机名: $hostname (y|Y|n|N)" nn
case $nn in 
y|Y)
	ip=`ifconfig |grep "inet addr"|grep -v '127.0.0.1'|awk -F":" '{print $2}'|awk '{print $1}'`
	echo $hostname
	echo $ip
	sudo sed -i '/tools/i '$ip'      '$hostname'.ppweb.com.cn   '$hostname'' /etc/hosts
	sudo sed -i 's/localhost/'$hostname'/' /etc/hostname
	echo "-------------------主机名如下------------------"
	cat /etc/hostname
	echo "------------------/etc/hosts如下---------------"
	cat /etc/hosts
	echo "-----------------------------------------------"
	echo "请重启计算机"
	break
;;
n|N)
	continue
;;
esac
done
;;

#6

*)
exit
;;
esac



