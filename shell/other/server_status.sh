#!/bin/bash
#脚本所在服务器:
#脚本位置:
#脚本功能:用于获取所有服务器的状态
#by 2016-12-15

#函数区

#定义管道
tmpfile=/tmp/$$.fifo
mkfifo $tmpfile
exec 6<>$tmpfile
rm $tmpfile

#控制线程
thred_control() {
for ((i=1;i<=6;i++))
do
echo 
done >&6
}

get_4399(){

name=test4399
urllink=fps1.esj.ppweb.com.cn

#获取数据(包的更新时间)
#--------------------------------------
battle_jar_time=$(ssh $urllink 'LANG=en.us;stat /opt/fps/BattleServer/BattleServer.jar' 2>$errtmp|grep Modify |awk -F":" '{print $2":"$3}'|awk -F"-" '{print $2"-"$3}')
if [ -z "$battle_jar_time" ];then
battle_jar_time=null
fi
#--------------------------------------
match_jar_time=$(ssh $urllink "LANG=en.us;stat /opt/fps/MatchServer/MatchServer.jar" 2>$errtmp|grep Modify |awk -F":" '{print $2":"$3}'|awk -F"-" '{print $2"-"$3}')
enroll_jar_time=$(ssh $urllink "LANG=en.us;stat /opt/fps/EnrollServer/EnrollServer.jar" 2>$errtmp |grep Modify |awk -F":" '{print $2":"$3}'|awk -F"-" '{print $2"-"$3}')
if [ -z "$match_jar_time" ];then
match_jar_time=null
fi
if [ -z "$enroll_jar_time" ];then
enroll_jar_time=null
fi
#--------------------------------------
pvr_jar_time=$(ssh $urllink "LANG=en.us;stat /opt/fps/PVRServer/PVRServer.jar" 2>$errtmp|grep Modify |awk -F":" '{print $2":"$3}'|awk -F"-" '{print $2"-"$3}')
if [ -z "$pvr_jar_time" ];then
pvr_jar_time=null
fi
#--------------------------------------
transfer_jar_time=$(ssh $urllink "LANG=en.us;stat /opt/fps/transfer1/NewTransferServer.jar" 2>$errtmp|grep Modify |awk -F":" '{print $2":"$3}'|awk -F"-" '{print $2"-"$3}')
if [ -z "$transfer_jar_time" ];then
transfer_jar_time=null
fi
#--------------------------------------
ext_file_time=$(ssh $urllink "LANG=en.us;stat /opt/fps/StateServerExt" 2>$errtmp|grep Modify |awk -F":" '{print $2":"$3}'|awk -F"-" '{print $2"-"$3}')
if [ -z "$ext_file_time" ];then
ext_file_time=null
fi
#--------------------------------------
war_file_time=$(ssh $urllink "LANG=en.us;stat /usr/share/glassfish3/apps/StateServer/StateServer-current.war" 2>$errtmp|grep Modify |awk -F":" '{print $2":"$3}'|awk -F"-" '{print $2"-"$3}')
if [ -z "$war_file_time" ];then
war_file_time=null
fi
#--------------------------------------
config_file_time=$(ssh $urllink "LANG=en.us;stat /usr/share/glassfish3/apps/StateServer/csweb/config" 2>$errtmp|grep Modify |awk -F":" '{print $2":"$3}'|awk -F"-" '{print $2"-"$3}')
if [ -z "$config_file_time" ];then
config_file_time=null
fi
#--------------------------------------
#获取时间(服务的启动时间)
start_battle=$(ssh $urllink "ps -eaf|grep BattleServer.jar"|grep -v grep|awk '{print $5}')
if [ -z "$start_battle" ];then
start_battle=null
fi
start_match=$(ssh $urllink "ps -eaf|grep MatchServer.jar"|grep -v grep|awk '{print $5}')
start_enroll=$(ssh $urllink "ps -eaf|grep EnrollServer.jar"|grep -v grep|awk '{print $5}')
if [ -z "$start_match" ];then
start_match=null
fi
if [ -z "$start_enroll" ];then
start_enroll=null
fi

#--------------------------------------
start_pvr=$(ssh $urllink "ps -eaf|grep PVRServer.jar"|grep -v grep|awk '{print $5}')
if [ -z "$start_pvr" ];then
start_pvr=null
fi
#--------------------------------------
start_state=$(ssh $urllink "ps -eaf|grep java"|grep glassfish3|grep -v grep|awk '{print $5}')
if [ -z "$start_state" ];then
start_state=null
fi
#--------------------------------------
start_transfer=$(ssh $urllink "ps -eaf|grep NewTransferServer.jar"|grep -v grep|awk '{print $5}'|sort -u)
if [ -z "$start_transfer" ];then
start_transfer=null
fi
#--------------------------------------
#获取版本(Version)
ver_match=`curl -s --connect-timeout 5 -m 5 http://"$urllink":8081/MatchServer/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_match" ];then
ver_match=null
fi
#--------------------------------------
ver_battle=`curl -s --connect-timeout 5 -m 5 http://"$urllink":8082/BattleServer/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_battle" ];then
ver_battle=null
fi
#--------------------------------------
ver_pvr=`curl -s --connect-timeout 5 -m 5 http://"$urllink":8083/PVRServer/Health|grep -w version|awk -F":" '{print $2}'|awk -F"}" '{print $1}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_pvr" ];then
ver_pvr=null
fi
#--------------------------------------
ver_state=`curl -s --connect-timeout 5 -m 5 http://"$urllink":8080/DarkForestService/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_state" ];then
ver_state=null
fi
#--------------------------------------
ver_trans_1=`curl -s --connect-timeout 5 -m 5 http://"$urllink":19010/TransferServer/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_trans_1" ];then
ver_trans_1=0
fi
ver_trans_2=`curl -s --connect-timeout 5 -m 5 http://"$urllink":19040/TransferServer/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_trans_2" ];then
ver_trans_2=0
fi
ver_trans_3=`curl -s --connect-timeout 5 -m 5 http://"$urllink":19070/TransferServer/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_trans_3" ];then
ver_trans_3=0
fi
ver_trans_4=`curl -s --connect-timeout 5 -m 5 http://"$urllink":19100/TransferServer/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_trans_4" ];then
ver_trans_4=0
fi
ver_trans_5=`curl -s --connect-timeout 5 -m 5 http://"$urllink":19130/TransferServer/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_trans_5" ];then
ver_trans_5=0
fi
ver_trans_6=`curl -s --connect-timeout 5 -m 5 http://"$urllink":19160/TransferServer/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_trans_6" ];then
ver_trans_6=0
fi
ver_trans_7=`curl -s --connect-timeout 5 -m 5 http://"$urllink":19190/TransferServer/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_trans_7" ];then
ver_trans_7=0
fi
ver_trans=$ver_trans_1$ver_trans_2$ver_trans_3$ver_trans_4$ver_trans_5$ver_trans_6$ver_trans_7
if [[ $ver_trans == 0000000 ]];then
ver_trans=null
fi
# echo $ver_trans_1
# echo $ver_trans_2
# echo $ver_trans_3
# echo $ver_trans_4
# echo $ver_trans_5
# echo $ver_trans_6
# echo $ver_trans_7
# echo $ver_trans

mysql -u$dbuser -p$dbpass -h$dbip -P$dbport --default-character-set=utf8 <<EOF
use csbh_stat;
update info set  name="$name",batt_t="$battle_jar_time",match_t="$match_jar_time",enro_t="$enroll_jar_time",pvr_t="$pvr_jar_time",tran_t="$transfer_jar_time",ext_t="$ext_file_time",war_t="$war_file_time",conf_t="$config_file_time",start_batt="$start_battle",start_match="$start_match",start_enro="$start_enroll",start_pvr="$start_pvr",start_state="$start_state",start_trans="$start_transfer",match_v="$ver_match",batt_v="$ver_battle",pvr_v="$ver_pvr",state_v="$ver_state",trans_v="$ver_trans" where server="$urllink";
EOF

mysql -uoop -p'BHlog2016' -h$dbip -P$dbport --default-character-set=utf8 <<EOF
use oop;
update op_vertion set  name="$name",batt_t="$battle_jar_time",match_t="$match_jar_time",enro_t="$enroll_jar_time",pvr_t="$pvr_jar_time",tran_t="$transfer_jar_time",ext_t="$ext_file_time",war_t="$war_file_time",conf_t="$config_file_time",start_batt="$start_battle",start_match="$start_match",start_enro="$start_enroll",start_pvr="$start_pvr",start_state="$start_state",start_trans="$start_transfer",match_v="$ver_match",batt_v="$ver_battle",pvr_v="$ver_pvr",state_v="$ver_state",trans_v="$ver_trans" where server="$urllink";
EOF

echo "$urllink is ok"

}




#脚本开始
a=`date +%s`
export LANG=ZH_CN.utf8
my_process=$$
outtmp=/tmp/$my_process-`date +%s-%N`.outtmp
errtmp=/tmp/$my_process-`date +%s-%N`.errtmp

if [ -f .status_temp ];then
echo "script is running..."
else
touch .status_temp

dbip=127.0.0.1
dbport=3306
dbuser=serverinfo
dbpass=serverinfo

fps_list=`sed  '/^+/d' /home/op/fps_list.conf|awk '{print $1":"$2":"$5":"$4}'`
thred_control

for line in $fps_list
do
#
read -u6
#
{
domain=`echo $line|awk -F":" '{print $1}'`
arena=`echo $line|awk -F":" '{print $2}'`
urllink=`echo $line|awk -F":" '{print $3}'`
billingID=`echo $line|awk -F":" '{print $4}'`

case $domain in
7k_double)
name="7k7k双线$arena区"
;;
7k_unicom)
name="7k7k联通$arena区"
;;
7k_telecom)
name="7k7k电信$arena区"
;;
43_double)
name="4399双线$arena区"
;;
43_unicom)
name="4399联通$arena区"
;;
43_telecom)
name="4399电信$arena区"
;;
fyzb_double)
name="风云双线$arena区"
;;
360_double)
name="360双线$arena区"
;;
kg_double)
name="酷狗双线$arena区"
;;
2144_unicom)
name="2144联通$arena区"
;;
2144_telecom)
name="2144电信$arena区"
;;
qq_double)
name="腾讯双线$arena区"
;;
tx_double)
name="铁血双线$arena区"
;;
xl_double)
name="迅雷双线$arena区"
;;
esac

#获取数据(包的更新时间)
#--------------------------------------
battle_jar_time=$(ssh $urllink 'LANG=en.us;stat /opt/fps/BattleServer/BattleServer.jar' 2>$errtmp|grep Modify |awk -F":" '{print $2":"$3}'|awk -F"-" '{print $2"-"$3}')
if [ -z "$battle_jar_time" ];then
battle_jar_time=null
fi
#--------------------------------------
case $urllink in
fps17.uc*|fps14.uc*|fps18.uc*)
match_jar_time=$(ssh $urllink "LANG=en.us;stat /opt/fps/MatchServer/MatchServer.jar" 2>$errtmp|grep Modify |awk -F":" '{print $2":"$3}'|awk -F"-" '{print $2"-"$3}')
enroll_jar_time=$(ssh $urllink "LANG=en.us;stat /opt/fps/EnrollServer/EnrollServer.jar" 2>$errtmp |grep Modify |awk -F":" '{print $2":"$3}'|awk -F"-" '{print $2"-"$3}')
if [ -z "$match_jar_time" ];then
match_jar_time=null
fi
if [ -z "$enroll_jar_time" ];then
enroll_jar_time=null
fi
;;
*)
match_jar_time=null
enroll_jar_time=null
;;
esac
#--------------------------------------
pvr_jar_time=$(ssh $urllink "LANG=en.us;stat /opt/fps/PVRServer/PVRServer.jar" 2>$errtmp|grep Modify |awk -F":" '{print $2":"$3}'|awk -F"-" '{print $2"-"$3}')
if [ -z "$pvr_jar_time" ];then
pvr_jar_time=null
fi
#--------------------------------------
transfer_jar_time=$(ssh $urllink "LANG=en.us;stat /opt/fps/transfer1/NewTransferServer.jar" 2>$errtmp|grep Modify |awk -F":" '{print $2":"$3}'|awk -F"-" '{print $2"-"$3}')
if [ -z "$transfer_jar_time" ];then
transfer_jar_time=null
fi
#--------------------------------------
ext_file_time=$(ssh $urllink "LANG=en.us;stat /opt/fps/StateServerExt" 2>$errtmp|grep Modify |awk -F":" '{print $2":"$3}'|awk -F"-" '{print $2"-"$3}')
if [ -z "$ext_file_time" ];then
ext_file_time=null
fi
#--------------------------------------
war_file_time=$(ssh $urllink "LANG=en.us;stat /usr/share/glassfish3/apps/StateServer/StateServer-current.war" 2>$errtmp|grep Modify |awk -F":" '{print $2":"$3}'|awk -F"-" '{print $2"-"$3}')
if [ -z "$war_file_time" ];then
war_file_time=null
fi
#--------------------------------------
config_file_time=$(ssh $urllink "LANG=en.us;stat /usr/share/glassfish3/apps/StateServer/csweb/config" 2>$errtmp|grep Modify |awk -F":" '{print $2":"$3}'|awk -F"-" '{print $2"-"$3}')
if [ -z "$config_file_time" ];then
config_file_time=null
fi
#--------------------------------------
#获取时间(服务的启动时间)
start_battle=$(ssh $urllink "ps -eaf|grep BattleServer.jar"|grep -v grep|awk '{print $5}')
if [ -z "$start_battle" ];then
start_battle=null
fi
#--------------------------------------
case $urllink in
fps17.uc*|fps14.uc*|fps18.uc*)
start_match=$(ssh $urllink "ps -eaf|grep MatchServer.jar"|grep -v grep|awk '{print $5}')
start_enroll=$(ssh $urllink "ps -eaf|grep EnrollServer.jar"|grep -v grep|awk '{print $5}')
if [ -z "$start_match" ];then
start_match=null
fi
if [ -z "$start_enroll" ];then
start_enroll=null
fi
;;
*)
start_match=null
start_enroll=null
;;
esac
#--------------------------------------
start_pvr=$(ssh $urllink "ps -eaf|grep PVRServer.jar"|grep -v grep|awk '{print $5}')
if [ -z "$start_pvr" ];then
start_pvr=null
fi
#--------------------------------------
start_state=$(ssh $urllink "ps -eaf|grep java"|grep glassfish3|grep -v grep|awk '{print $5}')
if [ -z "$start_state" ];then
start_state=null
fi
#--------------------------------------
start_transfer=$(ssh $urllink "ps -eaf|grep NewTransferServer.jar"|grep -v grep|awk '{print $5}'|sort -u)
if [ -z "$start_transfer" ];then
start_transfer=null
fi
#--------------------------------------
#获取版本(Version)
case $urllink in
fps17.uc*|fps14.uc*|fps18.uc*)
ver_match=`curl -s --connect-timeout 5 -m 5 http://"$urllink":8081/MatchServer/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_match" ];then
ver_match=null
fi
;;
*)
ver_match=null
;;
esac
#--------------------------------------
ver_battle=`curl -s --connect-timeout 5 -m 5 http://"$urllink":8082/BattleServer/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_battle" ];then
ver_battle=null
fi
#--------------------------------------
ver_pvr=`curl -s --connect-timeout 5 -m 5 http://"$urllink":8083/PVRServer/Health|grep -w version|awk -F":" '{print $2}'|awk -F"}" '{print $1}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_pvr" ];then
ver_pvr=null
fi
#--------------------------------------
ver_state=`curl -s --connect-timeout 5 -m 5 http://"$urllink":8080/DarkForestService/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_state" ];then
ver_state=null
fi
#--------------------------------------
# ver_trans=`curl -s --connect-timeout 5 -m 5 http://"$urllink":8083/PVRServer/Health|grep trans_version|awk -F'"' '{print $4}'|awk -F"_" '{print $2$4$6$8$10$12$14}'`
# if [ -z "$ver_trans" ];then
# ver_trans=null
# fi
ver_trans_1=`curl -s --connect-timeout 5 -m 5 http://"$urllink":19010/TransferServer/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_trans_1" ];then
ver_trans_1=0
fi
ver_trans_2=`curl -s --connect-timeout 5 -m 5 http://"$urllink":19040/TransferServer/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_trans_2" ];then
ver_trans_2=0
fi
ver_trans_3=`curl -s --connect-timeout 5 -m 5 http://"$urllink":19070/TransferServer/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_trans_3" ];then
ver_trans_3=0
fi
ver_trans_4=`curl -s --connect-timeout 5 -m 5 http://"$urllink":19100/TransferServer/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_trans_4" ];then
ver_trans_4=0
fi
ver_trans_5=`curl -s --connect-timeout 5 -m 5 http://"$urllink":19130/TransferServer/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_trans_5" ];then
ver_trans_5=0
fi
ver_trans_6=`curl -s --connect-timeout 5 -m 5 http://"$urllink":19160/TransferServer/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_trans_6" ];then
ver_trans_6=0
fi
ver_trans_7=`curl -s --connect-timeout 5 -m 5 http://"$urllink":19190/TransferServer/Health|grep -w version|awk -F": " '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
if [ -z "$ver_trans_7" ];then
ver_trans_7=0
fi
ver_trans=$ver_trans_1$ver_trans_2$ver_trans_3$ver_trans_4$ver_trans_5$ver_trans_6$ver_trans_7
if [[ $ver_trans == 0000000 ]];then
ver_trans=null
fi
#--------------------------------------
#调试输入查看信息是否准确(上线后关闭即可)
case $1 in
debug)
echo "$name"
echo "$urllink"
echo "battle_jar_time   : $battle_jar_time"
echo "match_jar_time    : $match_jar_time"
echo "enroll_jar_time   : $enroll_jar_time"
echo "pvr_jar_time      : $pvr_jar_time"
echo "transfer_jar_time : $transfer_jar_time"
echo "ext_file_time     : $ext_file_time"
echo "war_file_time     : $war_file_time"
echo "config_file_time  : $config_file_time"
echo "--"
echo "start_battle      : $start_battle"
echo "start_match       : $start_match"
echo "start_enroll      : $start_enroll"
echo "start_pvr         : $start_pvr"
echo "start_state       : $start_state"
echo "start_transfer    : $start_transfer"
echo "--"
echo "ver_match         : $ver_match"
echo "ver_battle        : $ver_battle"
echo "ver_pvr           : $ver_pvr"
echo "ver_state         : $ver_state"
echo "ver_trans         : $ver_trans" 
echo "--"
echo "billingID         : $billingID"
echo "-------------------------------------"
;;
esac
#--------------------------------------
#插入数据库(字段内容)
#table:info
#id:
#name:
#server: $urllink
#batt_t:
#match_t:
#enro_t:
#pvr_t:
#tran_t:
#ext_t:
#war_t:
#conf_t:
#start_batt: $start_battle
#start_match:
#start_enro:
#start_pvr:
#start_state:
#start_trans:
#match_v
#batt_v
#pvr_v
#state_v
#trans_v
mysql -u$dbuser -p$dbpass -h$dbip -P$dbport --default-character-set=utf8 <<EOF
use csbh_stat;
update info set  name="$name",batt_t="$battle_jar_time",match_t="$match_jar_time",enro_t="$enroll_jar_time",pvr_t="$pvr_jar_time",tran_t="$transfer_jar_time",ext_t="$ext_file_time",war_t="$war_file_time",conf_t="$config_file_time",start_batt="$start_battle",start_match="$start_match",start_enro="$start_enroll",start_pvr="$start_pvr",start_state="$start_state",start_trans="$start_transfer",match_v="$ver_match",batt_v="$ver_battle",pvr_v="$ver_pvr",state_v="$ver_state",trans_v="$ver_trans",billingid="$billingID" where server="$urllink";
EOF


mysql -uoop -p'BHlog2016' -h$dbip -P$dbport --default-character-set=utf8 <<EOF
use oop;
update op_vertion set  name="$name",batt_t="$battle_jar_time",match_t="$match_jar_time",enro_t="$enroll_jar_time",pvr_t="$pvr_jar_time",tran_t="$transfer_jar_time",ext_t="$ext_file_time",war_t="$war_file_time",conf_t="$config_file_time",start_batt="$start_battle",start_match="$start_match",start_enro="$start_enroll",start_pvr="$start_pvr",start_state="$start_state",start_trans="$start_transfer",match_v="$ver_match",batt_v="$ver_battle",pvr_v="$ver_pvr",state_v="$ver_state",trans_v="$ver_trans",billingid="$billingID" where server="$urllink";
EOF

echo "$urllink is ok"
echo >&6
}&
done
wait
exec 6>&-

get_4399

rm .status_temp
fi

b=`date +%s`
num="$(((b-a)/60)) minutes $(((b-a)%60)) seconds"
echo "update cost $num "

#删除临时文件
rm -rf /tmp/$my_process-[0-9]*-[0-9]*.errtmp /tmp/$my_process-[0-9]*-[0-9]*.outtmp
#脚本结束