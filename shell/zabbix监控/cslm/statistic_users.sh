#!/bin/bash
#used for statistic total users on platform 4399 
#path: tools.uc.ppweb.com.cn:/srv/salt/auto-update/statistic.sh
#2016.7.8

statistics(){
    total=0
    while read line;do
        count=`curl -s --connect-timeout 5 -m 5 $line:8083/StateServer/UserOnlineNum|awk -F':' '/onlinePlayer/ {print $2}'|sed 's/}//g'`
    total=$((total+count))
done<$server_list
    echo $total
}

if [[ $# -ne 1 ]];then
    echo "Usage: bash statistics.sh [4399|all]"
    exit 1
fi

case $1 in
4399)
    server_list=/srv/salt/cslm/server_list.conf.4399
    statistics;;
all)
    server_list=/srv/salt/cslm/server_list.conf.all
    statistics;;
*)
    echo "Wrong platform!"
    echo "Usage: bash statistics.sh [4399|all]";;
esac
