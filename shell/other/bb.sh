#!/bin/bash
export LANG=zh_CN.utf8
my_process=$$
outtmp=/tmp/$my_process-`date +%s-%N`.outtmp
errtmp=/tmp/$my_process-`date +%s-%N`.errtmp
tmp=/tmp/haha8


update() {
while read line
do

	for dd in `seq 1 7`
	do
	rsync -avzuLP /srv/salt/glassfish/apps_wars/test4399/NewTransferServer.jar $line:/opt/fps/transfer$dd 1>/dev/null
	done

done<$outtmp

}

restart() {
while read line
do
	ssh -q $line <<EOF
	cd /home/op/bin
	bash stop-all-transfer.sh
	sleep 3
	bash start-all-transfer.sh
	echo "$line is ok"
EOF

done<$outtmp
}

operation() {
case $1 in
update)
update
;;
restart)
restart
;;
all)
update
restart
;;
*)
echo "请输入第二个正确的参数 (update | restart)"
;;
esac
}

case $1 in
7k7k)
sed  '/^+/d' /home/op/fps_list.conf|awk '$1~/7k/{print $5}' >$outtmp
operation $2
;;
4399)
sed  '/^+/d' /home/op/fps_list.conf|awk '$1~/43/{print $5}' >$outtmp
operation $2
;;
other)
sed  '/^+/d' /home/op/fps_list.conf|awk '$1!~/43/ && $1!~/7k/ {print $5}' >$outtmp
operation $2
;;
all)
sed  '/^+/d' /home/op/fps_list.conf|awk '{print $5}' >$outtmp
operation $2
;;
*)
echo "请输入第一个正确的参数 (7k7k | 4399 | other | all)"
;;
esac


rm -rf /tmp/$my_process-[0-9]*-[0-9]*.errtmp /tmp/$my_process-[0-9]*-[0-9]*.outtmp