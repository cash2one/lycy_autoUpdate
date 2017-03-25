#!/bin/bash
#func: used to update backend jars and wars
#path: 10.0.10.51:/home/op/script/update_back.sh
#should ssh-copy-id id_rsa.pub(10.0.10.51's public key) to root@front_entrance_list:/root/authorized_keys at first
#为了解决too many open files，在/etc/security/limit.conf 加入如下两行针对root用户的设置
# root soft nofile 65535
# root hard nofile 65535
# * 是通配所有用户 ; root用户必须单独指定，因为通配符不允许匹配root
# 为了解决更新失败，原因就是rsync或scp的时候，网络超时所致。经查，原因是单位网络是联通，而服务器IP是浙江电信，使用服务器上北京联通的IP解决问题
# 为了解决 -bash: line 5: [: -le: unary operator expected 的问题，在36和63行的while上加了双中括号，代替原来的单中括号。[[]]  测试变量时如果变量为空且变量未加引号，不会报错，但[]会
#2016.10.21

my_process=$$
outtmp=/tmp/$my_process-`date +%s-%N`.outtmp
errtmp=/tmp/$my_process-`date +%s-%N`.errtmp
starttmp=/tmp/starttmp.out
#login_server_list=(120.92.253.9 120.92.253.14)
#db_battle_list=(120.92.253.7 120.92.253.15)


# Test IP -----------------------
login_server_list=(42.62.106.36)
db_battle_list=(42.62.106.36)
# -------------------------------
len_arr=${#login_server_list[*]}
index_arr=$((len_arr-1))

stop_all(){
	for i in `seq 0 $index_arr`;do
		ssh -T root@${login_server_list[$i]} <<EOF 1>$outtmp
		ulimit -SHn 65535
		cd /home/ycone/gamex/server
		sudo ./legendary.sh stop
		j=1
		while [[ \$j -le 6 ]];
		do
			sleep 5
			ps -ef |grep state.jar |grep -v grep
			if [[ \$? -eq 0 ]];then
				sudo ./legendary_state.sh stop
			else
				echo "state_process=0"
				exit
			fi
			j=\$((j+1))
		done
EOF
		x=`grep "state_process=0" $outtmp|wc -l`
		if [ $x -eq 0 ];then
			echo "Failure : ${login_server_list[$i]} StateServer doesn't stoped, EXIT update! please connect admin!!"
			return 100
			exit
		else
			echo "Successful : ${login_server_list[$i]} StateServer stoped success!"
		fi

		ssh -T root@${db_battle_list[$i]} <<EOF 1>$outtmp
			ulimit -SHn 65535
			cd /home/ycone/gamex/server
			sudo ./legendary.sh stop

			while [[ \$j -le 60 ]];
			do
				ps -eaf|grep "db.jar"|grep -v grep
				if [[ \$? != 0 ]];then
					echo "db_process=0"
					exit
				fi
				sleep 10
				j=\$((j+1))
			done
EOF
		sleep 5
		z=`grep "db_process=0" $outtmp|wc -l`
		if [ $z -eq 0 ];then
			echo "Failure : ${login_server_list[$i]} db.jar doesn't stoped, EXIT update! please connect admin!!"
			return 100
			exit
		else
			echo "Successful : ${db_battle_list[$i]} db.jar service stoped!"
			rsync_res
		fi
	done

	return 200
}

rsync_res(){
	rsync -avzP /home/op/xgame/config.version/ root@${login_server_list[$i]}:/home/ycone/gamex/config.version/ 1>$outtmp
	rsync -avzP /home/op/xgame/server/state.jar root@${login_server_list[$i]}:/home/ycone/gamex/server/ 1>$outtmp
	rsync -avzP /home/op/xgame/server/battle.jar root@${login_server_list[$i]}:/home/ycone/gamex/server/ 1>$outtmp
	rsync -avzP /home/op/xgame/server/match.jar root@${login_server_list[$i]}:/home/ycone/gamex/server/ 1>$outtmp
	rsync -avzP /home/op/xgame/server/key.jar root@${login_server_list[$i]}:/home/ycone/gamex/server/ 1>$outtmp
	echo "Successful : ${login_server_list[$i]} All jars uploaded done!"
	rsync -avzP /home/op/xgame/config.version/ root@${db_battle_list[$i]}:/home/ycone/gamex/config.version/ 1>$outtmp
	rsync -avzP /home/op/xgame/server/battle.jar root@${db_battle_list[$i]}:/home/ycone/gamex/server/ 1>$outtmp
	rsync -avzP /home/op/xgame/server/db.jar root@${db_battle_list[$i]}:/home/ycone/gamex/server/ 1>$outtmp
	echo "Successful : ${db_battle_list[$i]} All jars uploaded done!"
}

start_all(){
	for i in ${login_server_list[*]};do
		ssh -T root@$i <<EOF 1>$starttmp
		ulimit -SHn 65535
		echo "-----------------------"
		ulimit -a
		echo "-----------------------"
		cd /home/ycone/gamex/server/
		sudo ./legendary.sh start
EOF
	done

	for j in ${db_battle_list[*]};do
		ssh -T root@$j <<EOF 1>$starttmp
		ulimit -SHn 65535
		echo "-----------------------"
		ulimit -a
		echo "-----------------------"
		cd /home/ycone/gamex/server/
		sudo ./legendary.sh start
EOF
	done

	echo "All Servers started!"
}

state(){
	for i in ${login_server_list[*]};do
		ssh -T root@$i <<EOF 1>$outtmp
		ulimit -SHn 65535
		cd /home/ycone/gamex/server/
		sudo ./legendary_state.sh $1
EOF
	rsync -avzuP /home/op/xgame/server/state.jar root@$i:/home/ycone/gamex/server/ 1>$outtmp
	done
}

battle(){
	for i in ${login_server_list[*]};do
		ssh -T root@$i <<EOF 1>$outtmp
		ulimit -SHn 65535
		cd /home/ycone/gamex/server/
		sudo ./legendary_battle.sh $1
EOF
	rsync -avzuP /home/op/xgame/server/battle.jar root@$i:/home/ycone/gamex/server/ 1>$outtmp
	done

	for j in ${db_battle_list[*]};do
		ssh -T root@$j <<EOF 1>$outtmp
		ulimit -SHn 65535
		cd /home/ycone/gamex/server/
		sudo ./legendary_battle.sh $1
EOF
	rsync -avzuP /home/op/xgame/server/battle.jar root@$j:/home/ycone/gamex/server/ 1>$outtmp
	done
}


match(){
	for i in ${login_server_list[*]};do
		ssh -T root@$i <<EOF 1>$outtmp
		ulimit -SHn 65535
		cd /home/ycone/gamex/server/
		sudo ./legendary_match.sh $1
EOF
	rsync -avzuP /home/op/xgame/server/match.jar root@$i:/home/ycone/gamex/server/ 1>$outtmp
	done
}

key(){
	for i in ${login_server_list[*]};do
		ssh -T root@$i <<EOF 1>$outtmp
		ulimit -SHn 65535
		cd /home/ycone/gamex/server/
		sudo ./legendary_key.sh $1
EOF
	rsync -avzuP /home/op/xgame/server/key.jar root@$i:/home/ycone/gamex/server/ 1>$outtmp
	done
}

db(){
	for i in ${db_battle_list[*]};do
		ssh -T root@$i <<EOF 1>$outtmp
		ulimit -SHn 65535
		cd /home/ycone/gamex/server/
		sudo ./legendary_db.sh $1
EOF
	rsync -avzuP /home/op/xgame/server/db.jar root@$i:/home/ycone/gamex/server/ 1>$outtmp
	done
}

####### script start #######
if [ $# -ne 2 ];then
	echo "This script need two arguments!"
	echo "Usage: ./update_back.sh [all|state|battle|match|db|key] [start|stop]"
	rm -rf /tmp/$my_process-[0-9]*-[0-9]*.errtmp /tmp/$my_process-[0-9]*-[0-9]*.outtmp
	exit 2
fi

case $1 in
	all)
		if [ "$2" == "stop" ];then
			stop_all
		elif [ "$2" == "start" ];then
			start_all
		else
			echo "Only start or stop support!"
		fi
		;;
	state)
		state $2;;
	battle)
		battle $2;;
	match)
		match $2;;
	db)
		db $2;;
	key)
		key $2;;
	h|H)
		echo "Usage: ./update_back.sh [all|state|battle|match|db|key] [start|stop]";;
	*)
		echo "Usage: ./update_back.sh [all|state|battle|match|db|key] [start|stop]";;
esac

#end