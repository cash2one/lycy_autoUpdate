#!/bin/bash
#update test and online servers backend
#path: 10.0.10.100/199:/home/op/sh
#2016.3.10

test_server=(78.47.251.193)
online_servers=()
update_time=`date +%y%m%d%H%M%S`


update_test(){
	for i in ${test_server[*]};do
		ssh -T $i<<EOF
		bash /home/op/sh/foreign_back_end_update.sh >> /tmp/test-$update_time.log
EOF
	done
}

update_online(){
	for i in ${online_servers[*]};do
		ssh -T $i<<EOF
		bash /home/op/sh/foreign_back_end_update.sh >> /tmp/online-$update_time.log
EOF
	done
}

case $1 in 
	test)
		update_test;;
	online)
		update_online;;
	*)
		echo "wrong parameters!"
		echo "Usage: bash update_back_from_local [test|online]"
		;;
esac