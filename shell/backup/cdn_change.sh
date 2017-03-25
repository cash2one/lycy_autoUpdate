#!/bin/bash
#cdn自由切换
#支持qq,dl的相互切换
#by 2016-03-06



change_json(){
id=`ls -rt *.json|sed -n '$'p|awk -F"." '{print $(NF-1)}'`
json=`ls -rt *.$id.json`
for i in $json
do
	sed -i 's/.'$ss'./.'$dd'./' $i
done

}

change_php(){
sed -i 's/fps.'$ss'./fps.'$dd'./g' GamePage.php
}

case_list(){
# echo $ptname
cd /data/www/config.fps.kukuplay.com/$ptname
case $ptname in
7k7k)
change_json
;;
4399)
change_json
change_php
;;
2144)
change_json
change_php
;;
kugou)
change_json
change_php
;;
360wan)
change_json
change_php
;;
tiexue)
change_json
change_php
;;
esac
}

status(){
# echo $ptname
if [ -d "/data/www/config.fps.kukuplay.com/$2" ];then
cd /data/www/config.fps.kukuplay.com/$ptname
id=`ls -rt *.json|sed -n '$'p|awk -F"." '{print $(NF-1)}'`
json=`ls -rt *.$id.json`
for i in $json
do
	echo "echo $ptname-$i---------------------------------------------------------------------"
	grep 'fps.qq.' $i
	grep 'fps.dl.' $i
done
echo $json|awk '{print NF}'
fi
}

message=`cat <<EOF
\n
请输入正确的两个参数 \n
\n
举例: 		bash $0 (qq|dl|status) (7k7k|4399|2144|kugou|360wan|tiexue) \n
\n
qq:         表示将CDN由dl切换到qq,后跟需要切换的平台;\n
dl:         表示将CDN由qq切换到dl,后跟需要切换的平台;\n
status:     表示查询当前CDN状态,后跟需要查询的平台;\n
EOF`

if [ -z $1 ] || [ -z $2 ];then
	echo -e $message
	exit
else
	ptname=$2
	if [ "$1" == "qq" ];then
		ss=dl
		dd=qq
		case_list
	elif [ "$1" == "dl" ];then
		ss=qq
		dd=qq
		case_list
	elif [ "$1" == "status" ];then
		status
	else
		echo -e $message
	fi
fi



#end
