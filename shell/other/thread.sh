#/bin/bash
#多线程控制脚本
#by jcui
#2016-01-22
export LANG=zh_CN.UTF-8


#定义管道
tmpfile=/tmp/$$.fifo
mkfifo $tmpfile
exec 6<>$tmpfile
rm $tmpfile

#控制线程
thred_control() {
for ((i=1;i<=10;i++))
do
echo 
done >&6
}

dodo() {
echo "sleep 5秒"
sleep $x
echo "$x sleep ok"
echo >&6
}

thred_control

for x in `seq 1 100`
do
	echo $x
	read -u6
	dodo &
done

wait
exec 6>&-

echo "script end"