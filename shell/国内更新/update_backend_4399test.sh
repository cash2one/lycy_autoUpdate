#!/bin/bash
#bakend update script
#10.0.10.193/198/199
#script_path: /opt/fps/pack_tools/backend_pack/autodeploy/update_backend_4399test.sh
#by 2016-02-26

upload_ftp() { 
ftp -nv 10.0.10.52 <<EOF 1>/dev/null 2>/tmp/back_end_error.log
user upload upload
binary
hash
cd CSBH_WARS
mkdir $ftp_path
cd $ftp_path
lcd $spath
prompt
mput * 
bye
EOF
echo "Successful !!! FTP upload is ok .The Directory: $ftp_path "
}

upload_transfer_ftp() { 
ftp -nv 10.0.10.52 <<EOF 
user upload upload
binary
hash
cd CSBH_WARS/$ftp_path
mkdir transfer
mkdir transfer/lib
cd transfer
lcd /opt/fps/pack_tools/tools_sh/transfer
prompt
mput * 
bye
EOF

ftp -nv 10.0.10.52 <<EOF 
user upload upload
binary
hash
cd CSBH_WARS/$ftp_path/transfer/lib
lcd /opt/fps/pack_tools/tools_sh/transfer/lib
prompt
mput * 
bye
EOF
echo "Successful !!! FTP upload transfer is ok .The Directory: $ftp_path "
}

control_BattleServer() {
path=/opt/fps/BattleServer/
case $1 in
stop)
	ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
	cd $path
	touch dont-start-BattleServer
	./BattleServer.sh stop
EOF
	sleep 2
	#echo "BattleServer is stoped..."
;;
start)
	ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
	cd $path
	rm -rf dont-start-BattleServer
EOF
	sleep 2
	#echo "BattleServer is starting..."
;;
restart)
	ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
	cd $path
	./BattleServer.sh restart
EOF
	sleep 2
;;
esac
}

control_EnrollServer() {
path=/opt/fps/EnrollServer/
case $1 in
stop)
	ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
	cd $path
	touch dont-start-EnrollServer
	./EnrollServer.sh stop
EOF
	sleep 2
	#echo "EnrollServer is stoped..."
;;
start)
	ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
	cd $path
	rm -rf dont-start-EnrollServer
EOF
	sleep 2
	#echo "EnrollServer is starting..."
;;
restart)
	ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
	cd $path
	./EnrollServer.sh restart
EOF
	sleep 2
;;
esac
}

control_MatchServer() {
path=/opt/fps/MatchServer/
case $1 in
stop)
	ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
	cd $path
	touch dont-start-MatchServer
	./MatchServer.sh stop
EOF
	sleep 2
	#echo "MatchServer is stoped..."
;;
start)
	ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
	cd $path
	rm -rf dont-start-MatchServer
EOF
	sleep 2
	#echo "MatchServer is starting..."
;;
restart)
	ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
	cd $path
	./MatchServer.sh restart
EOF
	sleep 2
;;
esac
}

control_PVRServer() {
path=/opt/fps/PVRServer
case $1 in
stop)
	ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
	cd $path
	touch dont-start-PVR
	./PVRServer.sh stop
EOF
	sleep 2
	#echo "PVRServer is stoped..."
;;
start)
	ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
	cd $path
	rm -rf dont-start-PVR
	./PVRServer.sh start
EOF
	sleep 2
	#echo "PVRServer is starting..."	
;;
restart)
	ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
	cd $path
	./PVRServer.sh restart
EOF
	sleep 2
;;
esac
}

control_StateServer() {
path=/var/lib/glassfish3/domains/
case $1 in
stop)
	ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
	cd $path
	sudo touch dont-start-StateServer
	sudo -u StateServer /usr/lib/glassfish3/bin/asadmin stop-domain StateServer
EOF
	sleep 5
	#echo "StateServer is stoped..."
;;
start)
	ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
	cd $path
	sudo rm -rf dont-start-StateServer
EOF
	sleep 5
	#echo "StateServer is starting..."	
;;
restart)
	ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
	cd $path
	sudo -u StateServer /usr/lib/glassfish3/bin/asadmin restart-domain StateServer
EOF
	sleep 5
;;
esac
}

control_transfer() {
path=/opt/fps
case $1 in
stop)
	for dd in `seq 1 7`
	do
		ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
		cd $path/transfer$dd
		touch dont-start-TRANSFER
		./transfer.sh stop
EOF
		#echo "transfer$dd is stoped..."
	done
;;
start)
	for dd in `seq 1 7`
	do
		ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
		cd $path/transfer$dd
		rm -rf dont-start-TRANSFER
EOF
		#echo "transfer$dd is starting..."	
	done
;;
restart)
	for dd in `seq 1 7`
	do
		ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
		cd $path/transfer$dd
		./transfer.sh restart
EOF
	done
;;
esac
}

stop_all_server() {
ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
/home/op/bin/stop_xserver_glassfish_pve.sh
EOF
sleep 10
echo "4399Test Server is stoped"
}

start_all_server() {
ssh fps1.esj.ppweb.com.cn  <<EOF 2>>/tmp/back_end_error.log
/home/op/bin/start_xserver_glassfish_pve.sh
EOF
sleep 10
echo "4399Test Server is starting..."
}

backend_update() {
cd $spath

#BattleServer
	if [[ $old_battle != $new_battle ]];then 
		if [ -f BattleServer*.jar ];then
			control_BattleServer stop
			sleep 5
			rsync -avzP $spath/BattleServer*.jar  fps1.esj.ppweb.com.cn:/opt/fps/BattleServer/BattleServer.jar 1>/dev/null
			control_BattleServer start
			echo "Successful !!! The BattleServer update is ok"
		fi
	else
		control_BattleServer restart
		echo "Warning !!! The BattleServer version number is consistent, this is not updated"
	fi

#EnrollServer
if [ -f EnrollServer*.jar ];then
	control_EnrollServer stop
	sleep 5
	rsync -avzP $spath/EnrollServer*.jar  fps1.esj.ppweb.com.cn:/opt/fps/EnrollServer/EnrollServer.jar 1>/dev/null
	control_EnrollServer start
fi

#MatchServer
	if [[ $old_match != $new_match ]];then
		if [ -f MatchServer*.jar ];then
			control_MatchServer stop
			sleep 5
			rsync -avzP $spath/MatchServer*.jar   fps1.esj.ppweb.com.cn:/opt/fps/MatchServer/MatchServer.jar 1>/dev/null
			control_MatchServer start
			echo "Successful !!! The MatchServer update is ok"
		fi	
	else
		control_MatchServer restart
		echo "Warning !!! The MatchServer version number is consistent, this is not updated"
	fi

#PVRServer
	if [[ $old_pvr != $new_pvr ]];then
		if [ -f PVRServer*.jar ];then
			control_PVRServer stop
			sleep 5
			rsync -avzP $spath/PVRServer*.jar  fps1.esj.ppweb.com.cn:/opt/fps/PVRServer/PVRServer.jar 1>/dev/null
			control_PVRServer start
			echo "Successful !!! The PVRServer update is ok"
		fi
	else
		control_PVRServer restart
		echo "Warning !!! The PVRServer version number is consistent, this is not updated"
	fi

#StateServer
	if [[ $old_state != $new_state ]];then
		if [ -f StateServer*.war ];then
			control_StateServer stop
			sleep 5
			rsync -avzP $spath/StateServer*.war  fps1.esj.ppweb.com.cn:/home/op/temp/StateServer-current.war 1>/dev/null
			ssh fps1.esj.ppweb.com.cn <<EOF 2>>/tmp/back_end_error.log
			sudo chown root.root /home/op/temp/StateServer-current.war
			sudo mv -f /home/op/temp/StateServer-current.war /usr/share/glassfish3/apps/StateServer/
EOF
			control_StateServer start
			echo "Successful !!! The StateServer update is ok"
		fi
	else
		control_StateServer restart
		echo "Warning !!! The StateServer version number is consistent, this is not updated"
	fi

#TransferServer
	if [[ $old_trans != $new_trans ]];then
		if [ -f *TransferServer*.jar ];then
			control_transfer stop
			sleep 5
			for dd in `seq 1 7`
			do
				rsync -avzP /opt/fps/pack_tools/backend_pack/upload/*TransferServer*.jar fps1.esj.ppweb.com.cn:/opt/fps/transfer$dd/NewTransferServer.jar 1>/dev/null 2>>/tmp/back_end_error.log
			done
			control_transfer start
			echo "Successful !!! The TransferServer update is ok"
		fi
	else
		control_transfer restart
		echo "Warning !!! The TransferServer version number is consistent, this is not updated"
	fi

}

backend_update_hot_config() {
cd $spath
if [ -f config*.zip ];then
	rsync -avzP $spath/config*.zip fps1.esj.ppweb.com.cn:/home/op/temp/ 1>/dev/null
	ssh fps1.esj.ppweb.com.cn <<EOF 2>>/tmp/back_end_error.log
	cd /home/op/temp
	unzip config*.zip 1>/dev/null
	rm -rf config*.zip
	tmpname=\`ls -t|awk '{print \$NR}'\`
	print \$tmpname
	sudo chown -R root.root \$tmpname
	sudo rm -rf /usr/share/glassfish3/apps/StateServer/csweb/config
	sudo /bin/mv /home/op/temp/\$tmpname /usr/share/glassfish3/apps/StateServer/csweb/config
	#sudo rsync -avzP --delete /home/op/temp/\$tmpname/ /usr/share/glassfish3/apps/StateServer/csweb/config 1>/dev/null
	#sudo rm -rf /home/op/temp/*
	
EOF
	echo "Successful !!! Config hot update is ok"
fi

}

backend_update_hot_state() {
cd $spath
if [ -f StateServerExt*.zip ];then
	rsync -avzP $spath/StateServerExt*.zip fps1.esj.ppweb.com.cn:/home/op/temp 1>/dev/null
	ssh fps1.esj.ppweb.com.cn <<EOF 2>>/tmp/back_end_error.log
	cd /home/op/temp
	unzip StateServerExt*.zip 1>/dev/null
	rm -rf StateServerExt*.zip
	tmpname=\`ls -t|awk '{print \$NR}'\`
	sudo chown -R StateServer.StateServer \$tmpname
	sudo rsync -avzP --delete /home/op/temp/\$tmpname/ /opt/fps/StateServerExt 1>/dev/null
	sudo rm -rf /home/op/temp/*
EOF
	echo "Successful !!! The StateServerExt hot update is ok"
fi
}

get_version () {
#match_version
old_match=`curl -s --connect-timeout 5 -m 5 http://localhost:8081/MatchServer/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
old_match=`curl -s --connect-timeout 5 -m 5 http://localhost:8081/MatchServer/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
new_match=`curl -s --connect-timeout 5 -m 5 http://fps1.esj.ppweb.com.cn:8081/MatchServer/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
new_match=`curl -s --connect-timeout 5 -m 5 http://fps1.esj.ppweb.com.cn:8081/MatchServer/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
#battle_version
old_battle=`curl -s --connect-timeout 5 -m 5 http://localhost:8082/BattleServer/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
old_battle=`curl -s --connect-timeout 5 -m 5 http://localhost:8082/BattleServer/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
new_battle=`curl -s --connect-timeout 5 -m 5 http://fps1.esj.ppweb.com.cn:8082/BattleServer/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
new_battle=`curl -s --connect-timeout 5 -m 5 http://fps1.esj.ppweb.com.cn:8082/BattleServer/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
#pvrserver_version
old_pvr=`curl -s --connect-timeout 5 -m 5 http://localhost:8083/PVRServer/Health|grep -w version|awk -F":" '{print $2}'|awk -F"}" '{print $1}'|sed 's/,//'|sed 's/^[ \t]//g'`
old_pvr=`curl -s --connect-timeout 5 -m 5 http://localhost:8083/PVRServer/Health|grep -w version|awk -F":" '{print $2}'|awk -F"}" '{print $1}'|sed 's/,//'|sed 's/^[ \t]//g'`
new_pvr=`curl -s --connect-timeout 5 -m 5 http://fps1.esj.ppweb.com.cn:8083/PVRServer/Health|grep -w version|awk -F":" '{print $2}'|awk -F"}" '{print $1}'|sed 's/,//'|sed 's/^[ \t]//g'`
new_pvr=`curl -s --connect-timeout 5 -m 5 http://fps1.esj.ppweb.com.cn:8083/PVRServer/Health|grep -w version|awk -F":" '{print $2}'|awk -F"}" '{print $1}'|sed 's/,//'|sed 's/^[ \t]//g'`
#DarkForestService_version
old_state=`curl -s --connect-timeout 5 -m 5 http://localhost:8080/DarkForestService/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
old_state=`curl -s --connect-timeout 5 -m 5 http://localhost:8080/DarkForestService/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
new_state=`curl -s --connect-timeout 5 -m 5 http://fps1.esj.ppweb.com.cn:8080/DarkForestService/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
new_state=`curl -s --connect-timeout 5 -m 5 http://fps1.esj.ppweb.com.cn:8080/DarkForestService/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
#transfer_version
old_trans=`curl -s --connect-timeout 5 -m 5 http://localhost:19010/TransferServer/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
old_trans=`curl -s --connect-timeout 5 -m 5 http://localhost:19010/TransferServer/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
new_trans=`curl -s --connect-timeout 5 -m 5 http://fps1.esj.ppweb.com.cn:19010/TransferServer/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
new_trans=`curl -s --connect-timeout 5 -m 5 http://fps1.esj.ppweb.com.cn:19010/TransferServer/Health|grep -w version|awk -F":" '{print $2}'|sed 's/,//'|sed 's/^[ \t]//g'`
}

upload_package() {
cd $spath
file=`ls .`
config=`ls *.zip 2>/dev/null |grep config`
StateServerExt=`ls *.zip 2>/dev/null |grep StateServerExt`
Battle=`ls *.jar 2>/dev/null |grep Battle`
Enroll=`ls *.jar 2>/dev/null |grep Enroll`
Match=`ls *.jar 2>/dev/null |grep Match`
Transfer=`ls *.jar 2>/dev/null |grep Transfer`
PVR=`ls *.jar 2>/dev/null |grep PVR`
StateServer=`ls *.war 2>/dev/null `

case $1 in
config)
rsync -avzP $config tools.uc.ppweb.com.cn:/home/op/salt-wars 1>/dev/null
;;
state)
rsync -avzP $StateServerExt tools.uc.ppweb.com.cn:/home/op/salt-wars 1>/dev/null
;;
all)
rsync -avzP $file tools.uc.ppweb.com.cn:/home/op/salt-wars 1>/dev/null
;;
esac


ssh tools.uc.ppweb.com.cn <<EOF 2>>/tmp/back_end_error.log
cd /home/op/salt-wars/

nnn=\`ls -d *|grep -Ev "zip|jar|war"\`
#rm -rf \$nnn

if [ -n "$Battle" ] && [ -f "$Battle" ];then
	ln -s -f /home/op/salt-wars/$Battle /srv/salt/glassfish/apps_wars/test4399/BattleServer.jar
fi

if [ -n "$Enroll" ] && [ -f "$Enroll" ];then
	ln -s -f /home/op/salt-wars/$Enroll /srv/salt/glassfish/apps_wars/test4399/EnrollServer.jar
fi

if [ -n "$Match" ] && [ -f "$Match" ];then
	ln -s -f /home/op/salt-wars/$Match /srv/salt/glassfish/apps_wars/test4399/MatchServer.jar
fi

if [ -n "$StateServer" ] && [ -f "$StateServer" ];then
	ln -s -f /home/op/salt-wars/$StateServer /srv/salt/glassfish/apps_wars/test4399/StateServer-current.war
fi

if [ -n "$Transfer" ] && [ -f "$Transfer" ];then
	ln -s -f /home/op/salt-wars/$Transfer /srv/salt/glassfish/apps_wars/test4399/NewTransferServer.jar
fi

if [ -n "$config" ] && [ -f "$config" ];then
	dirs=\`ls $config |sed 's/.zip//'\`
	rm -rf \$dirs
	unzip $config 1>/dev/null
	ln -s -n -f /home/op/salt-wars/\$dirs /srv/salt/glassfish/apps_wars/test4399/config
	ln -s -n -f /home/op/salt-wars/\$dirs /srv/salt/glassfish/apps_wars/hotupdate-config-only/config
fi

if [ -n "$StateServerExt" ] && [ -f "$StateServerExt" ];then
	dirs=\`ls $StateServerExt |sed 's/.zip//'\`
	rm -rf \$dirs
	unzip $StateServerExt 1>/dev/null
	ln -s -n -f /home/op/salt-wars/\$dirs /srv/salt/glassfish/apps_wars/hotupdate-config-only/StateServerExt
fi

if [ -n "$PVR" ] && [ -f "$PVR" ];then
	ln -s -f /home/op/salt-wars/$PVR /srv/salt/glassfish/apps_wars/test4399/PVRServer.jar
fi
EOF

# if [[ $transfer_upload == yes ]];then
	# ssh tools.uc.ppweb.com.cn <<EOF 2>>/tmp/back_end_error.log
	# cd /srv/salt/transfer/tmp
	# tar czvfp ../transfer.tar.gz *
# EOF
# fi
# ssh tools.uc.ppweb.com.cn <<EOF 2>>/tmp/back_end_error.log
# cd /srv/salt/glassfish/apps_wars
# perl  Beta-To-online.pl
# EOF
}

#script start
a=`date +%s`
true >/tmp/back_end_error.log
ftp_path=$2
spath=/opt/fps/pack_tools/backend_pack/upload
cd $spath

case $1 in
config)
	# get_version
	zip=`ls $spath/config*.zip 2>/dev/null | wc -l`
	case $zip in
	0)
		echo "Error !!! config file does not exist"
		exit
	;;
	1)
		backend_update_hot_config
		upload_ftp
		upload_package config
	;;
	esac
;;
state)
	# get_version
	zip=`ls $spath/StateServerExt*.zip 2>/dev/null | wc -l`
	case $zip in
	0)
		echo "Error !!! StateServerExt file does not exist"
		exit
	;;
	*)
		backend_update_hot_state
		upload_ftp
		upload_package state
	;;
	esac
;;
all)
	jar_war_num=`ls *.jar *.war 2>/dev/null | wc -l`
	case $jar_war_num in
	0)
		echo "Warning !!! Did not found jar or war update"
		zip_num=`ls $spath/*.zip 2>/dev/null | wc -l`
		case $zip_num in
		1|2)
			# get_version
			backend_update_hot_config
			backend_update_hot_state
			upload_ftp
			upload_package all
		;;
		0)
			echo "Error !!! Did not found any update"
			exit
		;;
		esac
	;;
	*)
		zip_num=`ls $spath/*.zip 2>/dev/null | wc -l`
		case $zip_num in
		1|2)
			get_version
			backend_update_hot_config
			backend_update_hot_state
			backend_update
			upload_ftp
			upload_package all
		;;
		0)
			get_version
			backend_update
			upload_ftp
			upload_package all
		;;
		esac
	;;
	esac

;;
*)
	echo "Please enter the correct parameters (config|state|all)"
;;
esac



#
errornum=`cat /tmp/back_end_error.log 2>/dev/null|wc -l`
case $errornum in
0)
	b=`date +%s`
	num="$(((b-a)/60)) minutes $(((b-a)%60)) seconds"
	echo "Successful !!! The back-end update cost for $num "
;;
*)
	echo "Error !!! The back-end update failed , An error is as follows"
	echo "-----------------------------------"
	cat /tmp/back_end_error.log
	echo "-----------------------------------"
;;
esac

#script end