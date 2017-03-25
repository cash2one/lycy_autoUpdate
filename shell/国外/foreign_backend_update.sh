#!/bin/bash
#update back-end
#path:/home/op/sh/foreign_back_end_update.sh
#if use rsync to upload,you should set ff=unix
#2016.3.9

source_dir=/data/backup-update
update_dir=`ls -rt /data/backup-update|tail -1`
StateServer=$source_dir/$update_dir/StateServer*.war
BattleServer=$source_dir/$update_dir/BattleServer*.jar
MatchServer=$source_dir/$update_dir/MatchServer*.jar
EnrollServer=$source_dir/$update_dir/EnrollServer.jar
NewTrans=$source_dir/$update_dir/NewTransferServer*.jar
config=`ls $source_dir/$update_dir/config*.zip |awk -F'.' '{print $1}'|awk -F'/' '{print $NF}'`

user=op
pass=ychd@0613

update_backend(){
	echo $pass|sudo -S /bin/cp -rf $StateServer /usr/share/glassfish3/apps/StateServer/StateServer-current.war
	echo $pass|sudo -S /bin/cp -rf $config /usr/share/glassfish3/apps/StateServer/csweb/
	cd /usr/share/glassfish3/apps/StateServer/csweb/
	echo $pass|sudo -S rm -f config
	unzip $config.zip
	echo $pass|sudo mv $config config

	/bin/cp -rf $BattleServer /opt/fps/BattleServer
	/bin/cp -rf $MatchServer /opt/fps/MatchServer
	/bin/cp -rf $EnrollServer /opt/fps/EnrollServer
	for i in `seq 1 7`;do
		/bin/cp $NewTrans /opt/fps/transfer$i
	done

	cd /home/op/bin
	echo $pass|sudo -S bash stop_xserver_glassfish.sh
	sleep5
	ps -ef|grep jar|grep -v grep|grep -v supervise|awk '{print $2}'|xargs kill -9
	sleep 10
	bash start_xserver_glassfish_pve.sh
}

update_backend
