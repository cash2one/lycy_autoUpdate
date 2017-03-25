#!/bin/bash
#used for zabbix_key
#path: server:/home/op/sh/zabbix_key.sh
#2016.11.17

select_mongo(){
    python /home/op/sh/select_mongo.py
}

uc.eth0.in(){
	python /home/op/python-sdk-v2-master/get_metric_in.py|tail -6|head -1|awk '{print $2}'
}

uc.eth0.out(){
	python /home/op/python-sdk-v2-master/get_metric_out.py|tail -6|head -1|awk '{print $2}'
}

cpu.MatchServer(){
	pid=`cat /opt/fps/MatchServer/MatchServer.pid`
	num=`ps -eaf|grep $pid|grep -v grep|wc -l`
	case $num in
	1)
	top -b -n 1 -p $pid |grep $pid|grep -v grep|awk '{print $9}'
	;;
	*)
	echo 0
	;;
	esac
}

cpu.BattleServer(){
	pid=`cat /opt/fps/BattleServer/BattleServer.pid`
	num=`ps -eaf|grep $pid|grep -v grep|wc -l`
	case $num in
	1)
	top -b -n 1 -p $pid |grep $pid|grep -v grep|awk '{print $9}'
	;;
	*)
	echo 0
	;;
	esac
}

cpu.EnrollServer(){
	pid=`cat /opt/fps/EnrollServer/EnrollServer.pid`
	num=`ps -eaf|grep $pid|grep -v grep|wc -l`
	case $num in
	1)
	top -b -n 1 -p $pid |grep $pid|grep -v grep|awk '{print $9}'
	;;
	*)
	echo 0
	;;
	esac
}

cpu.PVRServer(){
	pid=`cat /opt/fps/PVRServer/PVRServer.pid`
	num=`ps -eaf|grep $pid|grep -v grep|wc -l`
	case $num in
	1)
	top -b -n 1 -p $pid |grep $pid|grep -v grep|awk '{print $9}'
	;;
	*)
	echo 0
	;;
	esac
}

cpu.StateServer(){
	top -bc -n 1|grep java-7-oracle|grep -v grep|awk '{print $9}' |sed -n 1p
}

match_ping_loss(){
	domain='fps17.uc.ppweb.com.cn'
	ping $domain -c 5 |grep loss |awk -F',' '{print $3}'|awk -F"%" '{print $1}'|sed 's/^[ \t]//g'
}

match_ping_delay(){
	domain='fps17.uc.ppweb.com.cn'
	ping $domain -c 3|grep avg |awk -F"=" '{print $2}'|awk -F"/" '{print $2}'|sed 's/^[ \t]//g'|awk -F"." '{print $1}'
}

cpu.transfer(){
	pid=`cat /opt/fps/transfer$1/transfer.pid`
	num=`ps -eaf|grep $pid|grep -v grep|wc -l`
	case $num in
	1)
	top -b -n 1 -p $pid |grep $pid|grep -v grep|awk '{print $9}'
	;;
	*)
	echo 0
	;;
	esac
}

battle_onlineplayer(){
	curl -s  curl http://localhost:8082/BattleServer/Health|grep onlinePlayer |awk '{print $NF}'|sed 's/,//'
}

onlineplayer(){
	curl -s http://localhost:8080/DarkForestService/Health|awk '$1~/onlinePlayer/ {print $2}'|sed s/,//g|awk '{print $1}'
	# curl -s http://{{ grains['fqdn'] }}:8080/DarkForestService/Health|awk '$1~/onlinePlayer/ {print $2}'|sed s/,//g|awk '{print $1}'
}

battleNum_by_MatchServer_allocation(){
	curl -s --connect-timeout 5 -m 5 localhost:8081/MatchServer/Health|awk '$1~/battleNum/ {print $2}'|sed 's/,//'
	#curl -s --connect-timeout 5 -m 5 localhost:8081/MatchServer/Health|awk -F':' '/battleNum/ {print $2}'|sed 's/,//'|sed 's/^[ \t]//g'
}

battles_on_BattleServer(){
	for i in `seq 1 14`;do
		if [ $i == $2 ];then
			#同sed，所有单引号中的内容都是不解释的，再加一对单引号给抛出来
			curl -s --connect-timeout 5 -m 5 $1.ppweb.com.cn:8081/MatchServer/Health|awk '/'$i':/ {print $'$((i+1))'}'|awk -F':' '{print $2}'
			break
		fi
	done
}

inode(){
	df -i / |awk '{if ($NF=="/") print $(NF-1)}'|awk -F'%' '{print $1}'
}

num.MatchServer(){
	ps -ef |grep MatchServer.jar|grep -v grep|wc -l
}

num.BattleServer(){
	ps -ef |grep BattleServer.jar|grep -v grep|wc -l
}

num.PVRServer(){
	ps -ef |grep PVRServer.jar|grep -v grep|wc -l
}

num.trans(){
	ps -ef |grep NewTransferServer.jar|grep -v grep|wc -l
}

num.mysqld(){
	ps -ef |grep mysqld|grep -v grep|awk '$1~/mysql/'|grep -v 'num.mysqld'|wc -l
}

droped_in_battle_or_ladder(){
	python /home/op/sh/droped_in_battle_or_ladder.py $1 $2
}


case $1 in
	select_mongo)
		select_mongo;;
	uc.eth0.in)
		uc.eth0.in;;
	uc.eth0.out)
		uc.eth0.out;;
	cpu.MatchServer)
		cpu.MatchServer;;
	cpu.BattleServer)
		cpu.BattleServer;;
	cpu.EnrollServer)
		cpu.EnrollServer;;
	cpu.StateServer)
		cpu.StateServer;;
	cpu.PVRServer)
		cpu.PVRServer ;;
	onlineplayer)
		onlineplayer;;
	battle_onlineplayer)
		battle_onlineplayer;;
	battleNum_by_MatchServer_allocation)
		battleNum_by_MatchServer_allocation;;
	battles_on_BattleServer)
		for i in fps14.uc fps17.uc;do
			if [ $2 == $i ];then
				battles_on_BattleServer $2 $3
				break
			fi
		done;;

	inode)
		inode;;
	num.MatchServer)
		num.MatchServer;;
	num.BattleServer)
		num.BattleServer;;
	num.PVRServer)
		num.PVRServer;;
	num.trans)
		num.trans;;
	num.mysqld)
		num.mysqld;;
	cpu.trans.1)
		cpu.transfer 1 ;;
	cpu.trans.2)
		cpu.transfer 2 ;;
	cpu.trans.3)
		cpu.transfer 3 ;;
	cpu.trans.4)
		cpu.transfer 4 ;;
	cpu.trans.5)
		cpu.transfer 5 ;;
	cpu.trans.6)
		cpu.transfer 6 ;;
	cpu.trans.7)
		cpu.transfer 7 ;;
	ping_loss)
		match_ping_loss ;;
	ping_delay)
		match_ping_delay ;;
	dorped_fenzi)
		droped_in_battle_or_ladder $2 $3 |awk '{print $1}';;
	dorped_fenmu)
		droped_in_battle_or_ladder $2 $3 |awk '{print $2}';;
	dorped_rate)
		droped_in_battle_or_ladder $2 $3 |awk '{print $3}';;
	*)
		select_mongo;;
esac