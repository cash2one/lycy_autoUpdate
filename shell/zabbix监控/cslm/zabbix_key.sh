#!/bin/bash
#used for zabbix_key
#path: server:/home/ycone/sh/zabbix_key.sh
#2017.1.17

onlinePlayer(){
    curl -s http://localhost:8083/StateServer/UserOnlineNum|awk -F':' '/onlinePlayer/ {print $2}'|sed 's/}//g'
}

num.state(){
	ps -ef |grep state.jar|grep -v grep|wc -l
}

num.match(){
	ps -ef |grep match.jar|grep -v grep|wc -l
}

num.battle(){
	ps -ef |grep battle.jar|grep -v grep|wc -l
}

num.key(){
	ps -ef |grep key.jar|grep -v grep|wc -l
}

num.mysql(){
	sudo netstat -nalp|grep mysqld|grep -w LISTEN |wc -l 
}


case $1 in
	onlinePlayer)
		onlinePlayer;;
	num.state)
		num.state;;
	num.match)
		num.match;;
	num.battle)
		num.battle;;
	num.key)
		num.key;;
	num.mysqld)
		num.mysql;;
	*)
		onlinePlayer;;
esac
