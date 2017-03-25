#!/bin/bash
#used for statistic total users on platform 4399 or 7k7k or all platforms
#path: tools.uc.ppweb.com.cn:/srv/salt/auto-update/statistic.sh
#2016.3.14

statistics(){
    total=0
    while read line;do
        count=`curl -s --connect-timeout 5 -m 5 $line.ppweb.com.cn:8080/DarkForestService/Health|grep "onlinePlayer"|awk '{print $2}'|awk -F',' '{print $1}'`
    total=$((total+count))
done<$server_list
    echo $total
}

if [[ $# -ne 1 ]];then
    echo "Usage: bash statistics.sh [4399|7k7k|all]"
    exit 1
fi

case $1 in
4399)
    server_list=/srv/salt/auto-update/server_list.conf.4399
    statistics;;
7k7k)
    server_list=/srv/salt/auto-update/server_list.conf.7k7k
    statistics;;
all)
    server_list=/srv/salt/auto-update/server_list.conf.all
    statistics;;
*)
    echo "Wrong platform!"
    echo "Usage: bash statistics.sh [4399|7k7k|all]";;
esac
