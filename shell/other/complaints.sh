#!/bin/bash
# stasistics compains for users on platform
# 统计被投诉次数并发运营
# salt: /tmp/complaints/complaints.sh
# 2016.9.9

LANG=zh_CN.utf8
cd /tmp/complaints
true > result.txt
yestoday=`date -d "1 days ago" +%Y-%m-%d`
logs=/opt/fps/ACG/complaintsInfo$yestoday*.log
mail_list=(yi.zhao@cloudacc-inc.com jiao.ma@cloudacc-inc.com qiuping.wang@cloudacc-inc.com ting.gong@cloudacc-inc.com)
# mail_list=(mis@cloudacc-inc.com)
#mail_list=(yongwei.zhang@cloudacc-inc.com)
echo "被投诉次数,平台ID,服务器ID,玩家UID" | iconv -f utf8 -t gbk > /tmp/complaints/$yestoday-4399.csv
echo "被投诉次数,平台ID,服务器ID,玩家UID" | iconv -f utf8 -t gbk > /tmp/complaints/$yestoday-7k7k.csv



salt -N 'groupall' cmd.run "cat $logs" > /tmp/complaints/$yestoday.log
awk '$1!~/^fps|^cat/ {split($0,a,"[:,]");print a[8]","a[10]","a[12]}' /tmp/complaints/$yestoday.log > /tmp/complaints/$yestoday.txt

cat /tmp/complaints/$yestoday.txt | iconv -f utf8 -t gbk |uniq -c |sort -nr | sed 's/^ *//'|sed 's/ /,/'|awk -F'-' '{print $1}' >>/tmp/complaints/result.txt


while read line
do
num=`echo $line|awk -F"," '{print $1}'`
pt=`echo $line|awk -F"," '{print $2}'`
id=`echo $line|awk -F"," '{print $3}'`
pid=`echo $line|awk -F"," '{print $4}'|awk -F"-" '{print $1}'`
if [[ $pt == 7 ]];then
	name=`grep -B 1 'state_server_id = "'$id'"' xserver.xml|grep 4399|awk -F"--" '{print $2}'`
	echo "$num,4399,$name,$pid" | iconv -f utf8 -t gbk  >> /tmp/complaints/$yestoday-4399.csv
else
	name=`grep -B 1 'state_server_id = "'$id'"' xserver.xml|grep 7k7k|awk -F"--" '{print $2}'`
	echo "$num,7k7k,$name,$pid" | iconv -f utf8 -t gbk  >> /tmp/complaints/$yestoday-7k7k.csv
fi

done</tmp/complaints/result.txt

#echo '$yestoday投诉名单' | mail -s 111 mis@cloudacc-inc.com
#单引号不解释附件
echo "各平台投诉名单" | mutt -s "$yestoday日投诉名单" ${mail_list[*]} -a /tmp/complaints/$yestoday-4399.csv -a /tmp/complaints/$yestoday-7k7k.csv