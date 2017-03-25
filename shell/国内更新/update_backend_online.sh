#!/bin/bash
#update online servers:group4399,group2144,group7k7k,group360wan,groupkugou,grouptiexue
#path: tools.uc.ppweb.com.cn:/srv/salt/auto-update/update_backend_online.sh
#使用wait、read命令、管道、文件描述符实现多线程并发更新，解决ssh登录、ping等等这种单进程比较慢而不耗费cpu的情况
#2016-08-05


#export LANG="zh_CN.UTF-8"
my_process=$$
outtmp=/tmp/$my_process-`date +%s-%N`.outtmp
errtmp=/tmp/$my_process-`date +%s-%N`.errtmp

export LANG="zh_CN.utf8"
testserver=http://fps1.esj.ppweb.com.cn
State_ver_new=`curl -s --connect-timeout 5 -m 5 $testserver:8080/DarkForestService/Health|awk -F':' '/version/ {print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
Battle_ver_new=`curl -s --connect-timeout 5 -m 5 $testserver:8082/BattleServer/Health|awk -F':' '/version/ {print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
Match_ver_new=`curl -s --connect-timeout 5 -m 5 $testserver:8081/MatchServer/Health|awk -F':' '/version/ {print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
PVR_ver_new=`curl -s --connect-timeout 5 -m 5 $testserver:8083/PVRServer/Health|grep -w version|awk -F: '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'|awk -F"}" '{print $1}'`
trans_ver_new=`curl -s --connect-timeout 5 -m 5 $testserver:19010/TransferServer/Health|grep -w version|awk -F: '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
server_list=`cat /srv/salt/auto-update/server_list.conf`
standard_domain='http://fps20.hy.ppweb.com.cn'
#standard_domain='http://fps2.esj.ppweb.com.cn'
match_standard_domain='http://fps14.uc.ppweb.com.cn'
#match_standard_domain='http://fps2.esj.ppweb.com.cn'

thread_num(){
  for((i=1;i<=10;i++))
  do
    echo 
  done >&100
}

updatestate(){
  >/srv/salt/auto-update/checklist/checkstate.txt
  State_ver_current=`curl -s --connect-timeout 5 -m 5 $standard_domain:8080/DarkForestService/Health|awk -F':' '/version/ {print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
  sleep 5
  State_ver_current=`curl -s --connect-timeout 5 -m 5 $standard_domain:8080/DarkForestService/Health|awk -F':' '/version/ {print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
  if [[ -z $State_ver_current ]] || [[ $State_ver_current != $State_ver_new ]];then
    for server in $server_list
    do
      read -u100
      {
        echo $server >> /srv/salt/auto-update/checklist/checkstate.txt
        rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/StateServer-current.war $server.ppweb.com.cn:/home/op 1>/dev/null
        ssh -T $server.ppweb.com.cn <<EOF 1>>$outtmp 2>>$errtmp
        echo Lieyan@1206 |sudo -S mv -f /home/op/StateServer-current.war /usr/share/glassfish3/apps/StateServer
        echo Lieyan@1206 |sudo -S chown -R StateServer.StateServer /usr/share/glassfish3/apps/StateServer/StateServer-current.war
        #sudo -u StateServer /usr/lib/glassfish3/bin/asadmin stop-domain StateServer
EOF
        echo >&100
      }&
    done
    wait
  else
    echo "StateServer's version is same as $testserver,will not update!"
    return
  fi
}

checkstate_new(){
i=0
while [ $i -le 3 ];
do
	read -u100
	{
	for server in `cat /srv/salt/auto-update/checklist/checkstate.txt`
	do
		unset State_ver_current
		State_ver_current=`curl -s --connect-timeout 5 -m 5 --connect-timeout 5 -m 5 http://$server.ppweb.com.cn:8080/DarkForestService/Health|awk -F':' '/version/ {print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
		sleep 1
		State_ver_current=`curl -s --connect-timeout 5 -m 5 --connect-timeout 5 -m 5 http://$server.ppweb.com.cn:8080/DarkForestService/Health|awk -F':' '/version/ {print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
		if [[ $State_ver_current == $State_ver_new ]];then
			sed -i '/'$server'/d' /srv/salt/auto-update/checklist/checkstate.txt
		else
			if [[ $i == 2 ]];then
				rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/StateServer-current.war $server.ppweb.com.cn:/home/op 1> /dev/null
				if [ $? -ne 0 ];then
					echo "rsync $server StateServer-current.war failure,rsync again!"
					rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/StateServer-current.war $server.ppweb.com.cn:/home/op 1> /dev/null
				fi
				ssh -T $server.ppweb.com.cn <<EOF 1>>$outtmp 2>>$errtmp
					echo Lieyan@1206 |sudo -S mv -f /home/op/StateServer-current.war /usr/share/glassfish3/apps/StateServer
					echo Lieyan@1206 |sudo -S chown -R StateServer.StateServer /usr/share/glassfish3/apps/StateServer/StateServer-current.war
					sudo -u StateServer /usr/lib/glassfish3/bin/asadmin stop-domain StateServer
					if [ $? -ne 0 ];then
						bash /home/op/bin/stop_xserver_glassfish_pve.sh 1> /dev/null
						sleep 3
						bash /home/op/bin/start_xserver_glassfish_pve.sh 1> /dev/null
						sleep 60
					fi
EOF
			else
				echo "only check_state_update $server NO.$i"
			fi
		fi
	done
	echo >&100
	}&
	wait
i=$((i+1))
done
if [ -s /srv/salt/auto-update/checklist/checkstate.txt ];then
	echo -e "StateServer未更新服务器:\n`cat /srv/salt/auto-update/checklist/checkstate.txt`"
else
	echo "All StateServer update successed!"
fi
}
  
updatebattle(){
  >/srv/salt/auto-update/checklist/checkbattle.txt
  Battle_ver_current=`curl -s --connect-timeout 5 -m 5 $standard_domain:8082/BattleServer/Health|awk -F':' '/version/ {print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
  sleep 5
  Battle_ver_current=`curl -s --connect-timeout 5 -m 5 $standard_domain:8082/BattleServer/Health|awk -F':' '/version/ {print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
  if [[ -z $Battle_ver_current ]] || [[ $Battle_ver_current != $Battle_ver_new ]];then
    for server in $server_list
    do
      read -u100
      {
        echo $server >> /srv/salt/auto-update/checklist/checkbattle.txt
        rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/BattleServer.jar $server.ppweb.com.cn:/opt/fps/BattleServer 1> /dev/null
        # ssh -T $server.ppweb.com.cn <<EOF 1>>$outtmp 2>>$errtmp
        # cd /opt/fps/BattleServer/;./BattleServer.sh stop
# EOF
        echo >&100
      }&
    done
	wait
  else
    echo "BattleServer's version is same as $testserver,will not update!"
    return
  fi
}

checkbattle_new() {
i=0
while [ $i -le 3 ];
do
	read -u100
	{
	for server in `cat /srv/salt/auto-update/checklist/checkbattle.txt`
	do
		unset Battle_ver_current
		Battle_ver_current=`curl -s --connect-timeout 5 -m 5 --connect-timeout 5 -m 5 http://$server.ppweb.com.cn:8082/BattleServer/Health|awk -F':' '/version/ {print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
		sleep 1
		Battle_ver_current=`curl -s --connect-timeout 5 -m 5 --connect-timeout 5 -m 5 http://$server.ppweb.com.cn:8082/BattleServer/Health|awk -F':' '/version/ {print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
		if [[ $Battle_ver_current == $Battle_ver_new ]];then
			sed -i '/'$server'/d' /srv/salt/auto-update/checklist/checkbattle.txt
		else
			if [[ $i == 2 ]];then
				rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/BattleServer.jar $server.ppweb.com.cn:/opt/fps/BattleServer 1> /dev/null
				if [ $? -ne 0 ];then
					echo "rsync $server BattleServer.jar failure,rsync again!"
					rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/BattleServer.jar $server.ppweb.com.cn:/opt/fps/BattleServer 1> /dev/null
				fi
				ssh -T $server.ppweb.com.cn <<EOF 1>>$outtmp 2>>$errtmp
					ps -ef |grep BattleServer |grep -v grep >/dev/null
					if [ \$? -eq 0 ];then
						ps -ef |grep BattleServer|grep -v grep|grep -v logstash|awk '{print \$2}'|xargs kill -9
						cd /opt/fps/BattleServer/;./BattleServer.sh start
						sleep 60
					fi
EOF
			else
				echo "only check_battle_update $server NO.$i"
			fi
		fi
	done
	echo >&100
	}&
	wait
i=$((i+1))
done
if [ -s /srv/salt/auto-update/checklist/checkbattle.txt ];then
	echo -e "BattleServer未更新服务器:\n`cat /srv/salt/auto-update/checklist/checkbattle.txt`"
else
    echo "All BattleServer update successed!"
fi
}

updatematch(){
  >/srv/salt/auto-update/checklist/checkmatch.txt
  Match_ver_current=`curl -s --connect-timeout 5 -m 5 $match_standard_domain:8081/MatchServer/Health|awk -F':' '/version/ {print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
  sleep 5
  Match_ver_current=`curl -s --connect-timeout 5 -m 5 $match_standard_domain:8081/MatchServer/Health|awk -F':' '/version/ {print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
  if [[ -z $Match_ver_current ]] || [[ $Match_ver_current != $Match_ver_new ]];then
    for server in $server_list
    do
	  case $server in
	  fps17.uc|fps14.uc|fps18.uc)
      read -u100
      {
        echo $server >> /srv/salt/auto-update/checklist/checkmatch.txt
        rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/MatchServer.jar $server.ppweb.com.cn:/opt/fps/MatchServer 1> /dev/null        
        # ssh -T $server.ppweb.com.cn <<EOF 1>>$outtmp 2>>$errtmp
        # cd /opt/fps/MatchServer/;./MatchServer.sh stop
# EOF
        echo >&100
      }&
	  ;;
	  esac
    done
	wait
  else 
    echo "MatchServer's version is same as $testserver,will not update!"
    return
  fi
}

checkmatch_new(){
i=0
while [ $i -le 3 ];
do
	read -u100
	{
	for server in `cat /srv/salt/auto-update/checklist/checkmatch.txt`
	do
		unset Match_ver_current
		Match_ver_current=`curl -s --connect-timeout 5 -m 5 http://$server.ppweb.com.cn:8081/MatchServer/Health|awk -F':' '/version/ {print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
		sleep 1
		Match_ver_current=`curl -s --connect-timeout 5 -m 5 http://$server.ppweb.com.cn:8081/MatchServer/Health|awk -F':' '/version/ {print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
		if [[ $Match_ver_current == $Match_ver_new ]];then
			sed -i '/'$server'/d' /srv/salt/auto-update/checklist/checkmatch.txt
		else
			if [[ $i == 2 ]];then
				rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/MatchServer.jar $server.ppweb.com.cn:/opt/fps/MatchServer 1> /dev/null
				if [ $? -ne 0 ];then
					echo "rsync $server MatchServer.jar failure,rsync again!"
					rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/MatchServer.jar $server.ppweb.com.cn:/opt/fps/MatchServer 1> /dev/null
				fi
				ssh -T $server.ppweb.com.cn <<EOF 1>>$outtmp 2>>$errtmp
					ps -ef |grep MatchServer |grep -v grep>/dev/null
					if [ \$? -eq 0 ];then
						ps -ef |grep MatchServer|grep -v grep|grep -v logstash|awk '{print \$2}'|xargs kill -9
						cd /opt/fps/MatchServer/;./MatchServer.sh start
						sleep 30
					fi
EOF
			else
				echo "only check_match_update $server NO.$i"
			fi
		fi
	done
	echo >&100
	}&
	wait
i=$((i+1))
done
if [ -s /srv/salt/auto-update/checklist/checkmatch.txt ];then
    echo -e "MatchServer未更新服务器:\n`cat /srv/salt/auto-update/checklist/checkmatch.txt`"
else
    echo "All MatchServer update successed!"
fi
}

updateenroll(){
for server in $server_list
do
  case $server in
  fps17.uc|fps14.uc|fps18.uc)
  read -u100
  {
    rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/EnrollServer.jar $server.ppweb.com.cn:/opt/fps/EnrollServer/EnrollServer.jar 1> /dev/null
    ssh -T $server.ppweb.com.cn <<EOF 1>>$outtmp 2>>$errtmp
    cd /opt/fps/EnrollServer;./EnrollServer.sh stop
    sleep 3
    ps -ef |grep EnrollServer |grep -v grep >/dev/null
    if [ \$? -eq 0 ];then
		echo $?
        ps -ef |grep EnrollServer|grep -v grep|grep -v logstash|awk '{print \$2}'|xargs kill -9
    else
        cd /opt/fps/EnrollServer/;./EnrollServer.sh start
    fi
EOF
    echo >&100
  }&
  ;;
  esac
done
wait

echo "All EnrollServer update successed!"
}

updatepvr(){
  >/srv/salt/auto-update/checklist/checkpvr.txt
  PVR_ver_current=`curl -s --connect-timeout 5 -m 5 $standard_domain:8083/PVRServer/Health|grep -w version|awk -F: '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'|awk -F"}" '{print $1}'`
  sleep 5
  PVR_ver_current=`curl -s --connect-timeout 5 -m 5 $standard_domain:8083/PVRServer/Health|grep -w version|awk -F: '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'|awk -F"}" '{print $1}'`
  if [[ -z $PVR_ver_current ]] || [[ $PVR_ver_current != $PVR_ver_new ]];then
    for server in $server_list
    do
      read -u100
      {
        echo $server >> /srv/salt/auto-update/checklist/checkpvr.txt
        rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/PVRServer.jar $server.ppweb.com.cn:/opt/fps/PVRServer 1> /dev/null
        # ssh -T $server.ppweb.com.cn <<EOF 1>>$outtmp 2>>$errtmp
        # cd /opt/fps/PVRServer/
		# ./PVRServer.sh stop
		# sleep 5
        # ./PVRServer.sh start
# EOF
        echo >&100
      }&
    done
	wait
  else
    echo "$server PVRServer's version is same as $testserver,will not update!"
    return
  fi
}
  
checkpvr_new(){
i=0
while [ $i -le 5 ];
do
	read -u100
    {
	for server in `cat /srv/salt/auto-update/checklist/checkpvr.txt`
	do
		unset PVR_ver_current
		PVR_ver_current=`curl -s --connect-timeout 5 -m 5 http://$server.ppweb.com.cn:8083/PVRServer/Health|grep -w version|awk -F: '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'|awk -F"}" '{print $1}'`
		sleep 1
        PVR_ver_current=`curl -s --connect-timeout 5 -m 5 http://$server.ppweb.com.cn:8083/PVRServer/Health|grep -w version|awk -F: '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'|awk -F"}" '{print $1}'`
		if [[ $PVR_ver_current == $PVR_ver_new ]];then
			sed -i '/'$server'/d' /srv/salt/auto-update/checklist/checkpvr.txt
		else
			if [[ $i == 2 ]];then
				rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/PVRServer.jar $server.ppweb.com.cn:/opt/fps/PVRServer 1> /dev/null
				if [ $? -ne 0 ];then
					echo "rsync $server PVRServer.jar failure,rsync again!"
					rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/PVRServer.jar $server.ppweb.com.cn:/opt/fps/PVRServer 1> /dev/null
                fi
				ssh -T $server.ppweb.com.cn <<EOF 1>>$outtmp 2>>$errtmp
					ps -ef |grep PVRServer |grep -v grep >/dev/null
				    if [ \$? -eq 0 ];then
						ps -ef |grep PVRServer|grep -v grep|grep -v logstash|awk '{print \$2}'|xargs kill -9
						cd /opt/fps/PVRServer
						./PVRServer.sh start
						sleep 10
				    fi
EOF
			else
				echo "only check_pvr_update $server NO.$i"
			fi
		fi
	done
	echo >&100
	}&
	wait
i=$((i+1))
done
if [ -s /srv/salt/auto-update/checklist/checkpvr.txt ];then
    echo -e "PVRServer未更新服务器:\n`cat /srv/salt/auto-update/checklist/checkpvr.txt`"
else
    echo "All PVRServer update successed!"
fi
}

updatetrans(){
  >/srv/salt/auto-update/checklist/checktrans.txt
  trans_ver_current=`curl -s --connect-timeout 5 -m 5 $standard_domain:19190/TransferServer/Health|grep -w version|awk -F: '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
  sleep 5
  trans_ver_current=`curl -s --connect-timeout 5 -m 5 $standard_domain:19190/TransferServer/Health|grep -w version|awk -F: '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
  if [[ -z $trans_ver_current ]] || [[ $trans_ver_current != $trans_ver_new ]];then
    for server in $server_list
    do
      read -u100
      {
        echo $server >> /srv/salt/auto-update/checklist/checktrans.txt
        rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/NewTransferServer.jar $server.ppweb.com.cn:/opt/fps/transfer1 1> /dev/null 
        ssh -T $server.ppweb.com.cn <<EOF 1>>$outtmp 2>>$errtmp
        for i in \`seq 1 7\`;do
          if [ \$i -ne 1 ];then
            /bin/cp -a /opt/fps/transfer1/NewTransferServer.jar /opt/fps/transfer\$i/
          fi
          # cd /opt/fps/transfer\$i
		  # ./transfer.sh stop
		  # sleep 3
		  # ./transfer.sh start
        done         
EOF
        echo >&100
      }&
    done
	wait
  else
    echo "Transfer's version is same as $testserver,will not update!"
    return
  fi
}

checktrans_new(){
i=0
while [ $i -le 3 ];
do
	read -u100
	{
	for server in `cat /srv/salt/auto-update/checklist/checktrans.txt`
	do
		unset trans_ver_current
		trans_ver_current=`curl -s --connect-timeout 5 -m 5 http://$server.ppweb.com.cn:19010/TransferServer/Health|grep -w version|awk -F: '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
		sleep 5
		trans_ver_current=`curl -s --connect-timeout 5 -m 5 http://$server.ppweb.com.cn:19010/TransferServer/Health|grep -w version|awk -F: '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
		if [[ $trans_ver_current == $trans_ver_new ]];then
			sed -i '/'$server'/d' /srv/salt/auto-update/checklist/checktrans.txt
		else
			if [[ $i == 2 ]];then
				rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/NewTransferServer.jar $server.ppweb.com.cn:/opt/fps/transfer1 1> /dev/null
				if [ $? -ne 0 ];then
					echo "rsync $server NewTransferServer.jar failure,rsync again!"
					rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/NewTransferServer.jar $server.ppweb.com.cn:/opt/fps/transfer1 1> /dev/null
				fi
				ssh -T $server.ppweb.com.cn <<EOF 1>>$outtmp 2>>$errtmp
					for i in \`seq 1 7\`;do
						if [ \$i -ne 1 ];then
							/bin/cp -a /opt/fps/transfer1/NewTransferServer.jar /opt/fps/transfer\$i/
						fi
					done
					ps -ef |grep NewTransferServer.jar |grep -v grep >/dev/null
					if [ \$? -eq 0 ];then
						ps -ef |grep NewTransferServer.jar|grep -v grep|grep -v logstash|awk '{print \$2}'|xargs kill -9
					else
						cd /home/op/bin/;bash start-all-transfer.sh
						sleep 40
					fi            
EOF
			else
				echo "only check_transfer_update $server NO.$i"
			fi
		fi
	done
	echo >&100
	}&
	wait
i=$((i+1))
done
if [ -s /srv/salt/auto-update/checklist/checktrans.txt ];then
    echo -e "trans未更新服务器:\n`cat /srv/salt/auto-update/checklist/checktrans.txt`"
else
    echo "All trans update successed!"
fi
}

hotupdate_StateServerExt(){
  for server in $server_list
  do
    read -u100
    {
      rsync -avzLP --delete /srv/salt/glassfish/apps_wars/hotupdate-config-only/StateServerExt $server.ppweb.com.cn:/opt/fps 1> /dev/null
      if [ $? -ne 0 ];then
        echo "$server StateServerExt doesn't update scuccess!update again!"
        rsync -avzLP --delete /srv/salt/glassfish/apps_wars/hotupdate-config-only/StateServerExt $server.ppweb.com.cn:/opt/fps 1> /dev/null
      fi
      echo >&100
    }&
  done
  wait
  echo "StateServerExt hotupdate done!"
}

hotupdate_cofig(){
  for server in $server_list
  do
    read -u100
    {
      rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/config $server.ppweb.com.cn:/home/op 1> /dev/null
      if [ $? -ne 0 ];then
        echo "$server config doesn't update scuccess!update again!"
        rsync -avzLP /srv/salt/glassfish/apps_wars/test4399/config $server.ppweb.com.cn:/home/op 1> /dev/null
      else
        ssh -T $server.ppweb.com.cn <<EOF 1>$outtmp 2>$errtmp
          echo Lieyan@1206|sudo -S rm -rf /usr/share/glassfish3/apps/StateServer/csweb/config
          echo Lieyan@1206|sudo -S mv /home/op/config /usr/share/glassfish3/apps/StateServer/csweb/
EOF
      fi
      echo >&100
    }&
  done
  wait
  echo "config hotupdate done!"  
}

restart_debin(){
for list in fps6.hy fps18.hy fps22.hy
do
ssh op@$list.ppweb.com.cn <<EOF 1>>$outtmp 2>>$errtmp
	cd /home/op/bin/
	echo Lieyan@1206 |sudo -S bash stop_xserver_glassfish_pve.sh
	sleep 10
	echo Lieyan@1206 |sudo -S bash start_xserver_glassfish_pve.sh
EOF
done
}

restart_all() {
for server in $server_list
do
	read -u100
	{
		ssh -T $server.ppweb.com.cn <<EOF 1>>$outtmp 2>>$errtmp
			cd /home/op/bin
			echo Lieyan@1206 |sudo -S bash stop_xserver_glassfish_pve.sh
			sleep 5
			cd /opt/fps/PVRServer
			bash PVRServer.sh stop
			sleep 5
			ps -eaf|grep jar|grep -v supervise|grep -v logstash |grep -v grep |awk '{print \$2}'|xargs kill -9 2>/dev/null
			cd /home/op/bin
			echo Lieyan@1206 |sudo -S bash start_xserver_glassfish_pve.sh
			cd /opt/fps/PVRServer
			bash PVRServer.sh start			
EOF
		echo >&100
	}&
done
wait
}

restart_transfer() {
for server in $server_list
do
	read -u100
	{
		ssh -T $server.ppweb.com.cn <<EOF 1>>$outtmp 2>>$errtmp
			cd /home/op/bin
			bash stop-all-transfer.sh
			sleep 5
			bash stop-all-transfer.sh	
EOF
		echo >&100
	}&
done
wait
}

##### script start #####
mkfifo testfifo
exec 100<>testfifo
rm testfifo

thread_num

case $1 in
config)
	hotupdate_cofig
    wait
;;
StateServerExt)
	hotupdate_StateServerExt
	wait
;;
all)
	hotupdate_StateServerExt
	hotupdate_cofig
	updatestate
	updatebattle
	updatematch
	updateenroll
	updatepvr
	updatetrans
	wait
	echo "Now wait startup ... Sleep 600 seconds"
	sleep 300
	restart_all
	sleep 300
	checkstate_new
	checkbattle_new
	checkmatch_new
	checkpvr_new
	checktrans_new
	echo "4399,7k7k,2144,360,kugou,tiexue,tencent $1 update done!"
;;
stateserver)
	updatestate
	restart_all
	wait
	echo "Now wait startup ... Sleep 300 seconds"
	sleep 300
	checkstate_new
	echo "4399,7k7k,2144,360,kugou,tiexue,tencent $1 update done!"
;;
match)
	updatematch
	restart_all
	wait
	echo "Now wait startup ... Sleep 300 seconds"
	sleep 300
	checkmatch_new
	echo "4399,7k7k,2144,360,kugou,tiexue,tencent $1 update done!"
;;
battle)
	updatebattle
	restart_all
	wait
	echo "Now wait startup ... Sleep 300 seconds"
	sleep 300
	checkbattle_new
	echo "4399,7k7k,2144,360,kugou,tiexue,tencent $1 update done!"
;;
pvr)
	updatepvr
	restart_all
	wait
	echo "Now wait startup ... Sleep 300 seconds"
	sleep 300
	checkpvr_new
	echo "4399,7k7k,2144,360,kugou,tiexue,tencent $1 update done!"
;;
transfer)
	updatetrans
	restart_all
	wait
	echo "Now wait startup ... Sleep 300 seconds"
	sleep 300
	checktrans_new
	echo "4399,7k7k,2144,360,kugou,tiexue,tencent $1 update done!"
;;
enroll)
	echo enroll
;;
restartall)
	restart_all
	wait
;;
*)
	echo "Wrong parameters!"
esac

exec 100>&-
exec 100<&-


#统计错误日志
num=`cat $errtmp|grep -v 'sudo'|wc -l`
case $num in
0)
echo ok >/dev/null
;;
*)
echo ""
echo "The error log as follows-----------------------------------"
echo ""
cat $errtmp
echo ""
echo "-----------------------------------------------------------"
;;
esac

rm -rf /tmp/$my_process-[0-9]*-[0-9]*.errtmp /tmp/$my_process-[0-9]*-[0-9]*.outtmp
