#!/bin/bash
#func: used to update res from 10.0.10.51 to 132:60.191.252.132 and 137:120.92.253.14
#path: 10.0.10.51:/home/op/script/update_front.sh
#should ssh-copy-id id_rsa.pub(10.0.10.51's public key) to root@front_entrance_list:/root/authorized_keys at first
#2016.12.23

update_time_log=`date +%Y%m%d%H%M%S`.log
#online_server
front_cdn_source_list=(120.92.253.9)
front_entrance_index_list=(120.92.253.9 120.92.253.14)
#Test_server
# front_cdn_source_list=(42.62.106.36)
# front_entrance_index_list=(42.62.106.36)
#
front_res_source_path=/home/op/xgame/website/
front_res_source_file=(assets config.* Gamelauncher*.swf hoh*.swf)
front_res_dest_path=/home/ycone/gamex/html
old_config_ver=`ssh root@60.191.252.132 "grep configRoot $front_res_dest_path/index.php"|awk -F'/' '{print $4}'|awk -F'g.' '{print $2}'`			# -O
old_clientVersion=`ssh root@60.191.252.132 "grep clientVersion $front_res_dest_path/index.php"|awk -F'"' '{print $2}'`								# -C
old_Gamelauncher=`ssh root@60.191.252.132 "grep Gamelauncher $front_res_dest_path/index.php"|awk -F'"' '{print $2}'|awk -F'r.' '{print $2}'`		# -G
old_hoh=`ssh root@60.191.252.132 "grep hoh $front_res_dest_path/index.php"|awk -F'hoh.' '{print $2}'|awk -F'.swf' '{print $1}'`					    # -D
new_config_ver=`cd $front_res_source_path;ls -d config*|awk -F'g.' '{print $2}'|tail -1`
new_clientVersion=$new_config_ver
new_Gamelauncher=`cd $front_res_source_path;ls Gamelauncher.*.swf|awk -F'.swf' '{print $1}'|awk -F'r.' '{print $2}'|tail -1`
new_hoh=`cd $front_res_source_path;ls hoh.*.swf|awk -F'.swf' '{print $1}'|awk -F'hoh.' '{print $2}'|tail -1`


update_A(){
	update_O
	update_C
	update_G
	update_D
	echo "All update is ok"
}

update_O(){
	for i in ${front_cdn_source_list[*]};do
		# EOF 这种方法在脚本中不执行，在shell中可执行
		#ssh -t -t root@$i <<EOF >>/tmp/$update_time_log
		#sed -n '/configRoot/ s/\$old_config_ver/\$new_config_ver/p' $front_res_dest_path/index.php
#EOF
		ssh root@$i "rm -rf $front_res_dest_path/assets"
		rsync -avzuP --delete "$front_res_source_path"assets root@$i:$front_res_dest_path 1>/dev/null
		rsync -avzuP "$front_res_source_path"config.* root@$i:$front_res_dest_path 1>/dev/null
	done

	for i in ${front_entrance_index_list[*]};do
		# 所有单引号中的内容都是不解释的，再加一对单引号给抛出来，sed 抛出来，再转义（这里不需要转义，因为是本地变量，不是远程服务器变量）
		ssh root@$i "sed -i '/configRoot/ s/'$old_config_ver'/'$new_config_ver'/' $front_res_dest_path/index.php"
	done
	echo "Assets,Config update is ok"
}

update_C(){
	for i in ${front_entrance_index_list[*]};do
		ssh root@$i "sed -i '/clientVersion/ s/'$old_clientVersion'/'$new_clientVersion'/' $front_res_dest_path/index.php"
	done
	echo "ClientVersion update is ok"
}

update_G(){
	for i in ${front_cdn_source_list[*]};do
		rsync -avzuP "$front_res_source_path"Gamelauncher*.swf root@$i:$front_res_dest_path 1>/dev/null
	done

	for i in ${front_entrance_index_list[*]};do
		ssh root@$i "sed -i '/Gamelauncher/ s/'$old_Gamelauncher'/'$new_Gamelauncher'/' $front_res_dest_path/index.php"
	done
	echo "Gamelauncher update is ok"
}

update_D(){
	for i in ${front_cdn_source_list[*]};do
		rsync -avzuP "$front_res_source_path"hoh*.swf root@$i:$front_res_dest_path 1>/dev/null
	done

	for i in ${front_entrance_index_list[*]};do
		ssh root@$i "sed -i '/hoh/ s/'$old_hoh'/'$new_hoh'/' $front_res_dest_path/index.php"
	done
	echo "Hoh update is ok"
}

case $1 in
	-A)
		update_A;;
	-O)
		update_O;;
	-C)
		update_C;;
	-G)
		update_G;;
	-D)
		update_D;;
	-H|-h)
		echo "Usage: bash update_front.sh [-A|-O|-C|-G|-D|-H|-h]"
		echo "-A：Used to update config_ver、clientVersion、Gamelauncher.swf and hoh.swf"
		echo "-O：Used to update config_ver"
		echo "-C：Used to update clientVersion"
		echo "-G：Used to update Gamelauncher.swf"
		echo "-D：Used to update hoh.swf"
		echo "-H|-h：Used for help";;
	*)
		echo "Usage: bash update_front.sh [-A|-O|-C|-G|-D|-H|-h]"
		echo "-A：Used to update config_ver、clientVersion、Gamelauncher.swf and hoh.swf"
		echo "-O：Used to update config_ver"
		echo "-C：Used to update clientVersion"
		echo "-G：Used to update Gamelauncher.swf"
		echo "-D：Used to update hoh.swf"
		echo "-H|-h：Used for help"
		exit 1;;
esac