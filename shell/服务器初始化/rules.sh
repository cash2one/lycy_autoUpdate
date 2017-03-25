#!/bin/sh
#filename rules.sh
#version 20110312
PATH=/sbin:/bin:/usr/sbin:/usr/bin
#choose=CentOS5
wan0='eth0'
wan1='em2'
#if [[ "`cat /etc/issue`" =~ "6." ]];then
#	choose=CentOS6
#	wan0='em1'
#fi
#if [[ "`ifconfig | awk '{print $1}' | grep ' eth[0-9] '`" != "" ]];then
#        wan0='eth0'
#	wan1='eth1'
#fi
#echo "操作系统为: $choose"
#echo "正在为对网卡配置$wan0防火墙:"



Denyip=""
###
iptables -F
iptables -t nat -F
iptables -t raw -F
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

iptables -t raw -A OUTPUT -o $wan1 -j NOTRACK
iptables -t raw -A PREROUTING -i $wan1 -j NOTRACK
iptables -t raw -A OUTPUT -o lo -j NOTRACK
iptables -t raw -A PREROUTING -i lo -j NOTRACK


###ssh###
iptables -A INPUT -i $wan0 -s 115.182.52.0/255.255.255.0 -p tcp -m tcp --dport 22 -j ACCEPT 
iptables -A INPUT -i $wan0 -s 210.13.211.221 -p tcp -m tcp --dport 22 -j ACCEPT  
iptables -A INPUT -i $wan0 -s 111.200.57.162 -p tcp -m tcp --dport 22 -j ACCEPT  
iptables -A INPUT -i $wan0 -s 210.13.211.218 -p tcp -m tcp --dport 22 -j ACCEPT

if [ "$Denyip" != "" ];then
        for X in $Denyip
        do
                echo $X ---deny
                iptables -A INPUT -i $wan0 -s $X -p all -j DROP
        done
fi

###allow tcp 
iptables -A INPUT -i $wan0 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -s 115.182.52.17 -i $wan0 -p tcp --dport 5666 -j ACCEPT     #allow nrep
iptables -A INPUT -s 115.182.52.17 -i $wan0 -p tcp --dport 8649 -j ACCEPT	#allow gmond
iptables -A INPUT -s 115.182.52.108 -i $wan0 -p tcp --dport 10050 -j ACCEPT     #allow zabbix
iptables -A INPUT -s 42.62.64.239 -i $wan0 -p tcp --dport 10050 -j ACCEPT     #allow zabbix


iptables -A INPUT -s 111.200.57.162 -i $wan0 -p tcp --dport 3306 -j ACCEPT     #allow zabbix
#iptables -A INPUT -s 60.191.252.132 -i $wan0 -p tcp --dport 3306 -j ACCEPT     #allow zabbix

iptables -A INPUT -i $wan0 -p tcp --dport 1831 -j ACCEPT
iptables -A INPUT -i $wan0 -p tcp --dport 843 -j ACCEPT
###allow udp
iptables -A INPUT -s 115.182.52.17 -i $wan0 -p udp --dport 161 -j ACCEPT       #allow snmp
iptables -A INPUT -s 115.182.52.17 -i $wan0 -p udp --dport 8649 -j ACCEPT	#allow gmond

###deny 
iptables -A INPUT -i $wan0 -p tcp -j DROP        

###deny udp
iptables -A INPUT -i $wan0 -p udp -j DROP



###allow ESTABLISHED,RELATED
iptables -I INPUT -m state --state RELATED,ESTABLISHED  -j ACCEPT
iptables -I OUTPUT -m state --state RELATED,ESTABLISHED  -j ACCEPT

sysctl net.nf_conntrack_max=986400
