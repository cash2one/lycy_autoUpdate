#!/bin/bash
#update swf after confusion,this swf should named as DarkForrest.swf
#10.0.10.193/198/199
#script_path:/opt/fps/pack_tools/client_pack/update_front_test99swf.sh
#2016.11.24

times=`date +"%F %H:%M:%S"`

source_dir=/opt/fps/www/client
config_dir=/data/www/config.fps.kukuplay.com/4399
dest_dir=/data/www/fps.cdnsrc.kukuplay.com/res4399

binghun_config_dir=/data/www/config.fps.kukuplay.com/binghun_x
binghun_dest_dir=/data/www/fps.cdnsrc.kukuplay.com/resbinghun

#获取测试服swf旧版本信息
test99_swf_old_ver=`ssh server0.uc.ppweb.com.cn "grep 'dark forrest version' \$config_dir/test99.php" | awk -F'.swf' '{print $1}'|awk -F'.' '{print $NF}'`
test99_swf_old_ver_num=`echo $test99_swf_old_ver|awk -F'T' '{print $1}'`
test99_swf_old_ver_t=`echo $test99_swf_old_ver|awk -F'T' '{print $2}'`
test99_swf_in_php=DarkForrest.0.1.$test99_swf_old_ver

binghun_swf_old_ver=`ssh server0.uc.ppweb.com.cn "grep 'binghun dark forrest version' \$binghun_config_dir/GamePage.php" | awk -F'.swf' '{print $1}'|awk -F'.' '{print $NF}'`
binghun_swf_old_ver_num=`echo $binghun_swf_old_ver|awk -F'T' '{print $1}'`
binghun_swf_old_ver_t=`echo $binghun_swf_old_ver|awk -F'T' '{print $2}'`
binghun_swf_in_php=DarkForrest.1.1.$binghun_swf_old_ver

#获取正式服swf版本信息
online_swf_ver=`ssh server0.uc.ppweb.com.cn "ls -rt $dest_dir/*.swf"|grep -v T|sed -n '$p'|awk -F'.swf' '{print $1}'|awk -F'.' '{print $NF}'|awk -F'T' '{print $1}'`
binghun_online_swf_ver=`ssh server0.uc.ppweb.com.cn "ls -rt $binghun_dest_dir/*.swf"|grep -v T|sed -n '$p'|awk -F'.swf' '{print $1}'|awk -F'.' '{print $NF}'|awk -F'T' '{print $1}'`

#传输最新的swf文件到前端服务器
echo qingdao0613| sudo chmod 644 /opt/fps/www/client/swf_update/*
if [ -f /opt/fps/www/client/swf_update/DarkForrest.swf ];then
	rsync -avzuP /opt/fps/www/client/swf_update/DarkForrest.swf  server0.uc.ppweb.com.cn:$dest_dir  1>/dev/null 2>>/tmp/swf_update_error.log
	rsync -avzuP /opt/fps/www/client/swf_update/DarkForrest.swf  server0.uc.ppweb.com.cn:$binghun_dest_dir  1>/dev/null 2>>/tmp/swf_update_error.log
else
	echo "Please upload the right DarkForrest.swf"
	exit 1
fi

#判断并修改
#command date better use `stat file`
# bug: 如果判断日期相等，那么每次都是像 1385T1，1385T2，一直往上加，这样的话，更新线上就是测试版本加1 ，就是1386；如果一天更新多次线上，那就一直是T+1，线上永远是1386，CDN推的也是1386，
# 所以CDN上的1386就不是一个版本，所以总是有的人是对的，有的人是错的。
# 为了解决这个问题，每次线上测试服都是T1，比如：现在是1385T1，线上是1386，下次测试服就是1386T1，线上用的哪个版本也一目了然，CDN也不会再推同一个版本的swf了
# 现已修改为判断正式服和测试服的版本号是否一致,一致则小版本+1,不一致则大版本+1


if [[ $test99_swf_old_ver_num -eq $online_swf_ver ]]; then
	test99_new_swf_ver_t=$(($test99_swf_old_ver_t+1))
	test99_new_swf_ver=DarkForrest.0.1."$test99_swf_old_ver_num"T"$test99_new_swf_ver_t"
else
	test99_new_swf_ver=DarkForrest.0.1."$online_swf_ver"T1
fi

if [[ $binghun_swf_old_ver_num -eq $binghun_online_swf_ver ]];then
	binghun_new_swf_ver_t=$(($binghun_swf_old_ver_t+1))
	binghun_new_swf_ver=DarkForrest.1.1."$binghun_swf_old_ver_num"T"$binghun_new_swf_ver_t"
else
	binghun_new_swf_ver=DarkForrest.1.1."$binghun_online_swf_ver"T1
fi
	



ssh server0.uc.ppweb.com.cn "mv $dest_dir/DarkForrest.swf $dest_dir/$test99_new_swf_ver.swf"
ssh server0.uc.ppweb.com.cn "sed -i s/$test99_swf_in_php/$test99_new_swf_ver/ $config_dir/test99.php"

ssh server0.uc.ppweb.com.cn "mv $binghun_dest_dir/DarkForrest.swf $binghun_dest_dir/$binghun_new_swf_ver.swf"
ssh server0.uc.ppweb.com.cn "sed -i s/$binghun_swf_in_php/$binghun_new_swf_ver/ $binghun_config_dir/GamePage.php"


message=`cat <<EOF
\n
update test99 DarkForrest.swf is ok .\n
update binghun_test DarkForrest.swf is ok .\n
The version changed is :  $test99_swf_in_php -->  $test99_new_swf_ver .\n
The version changed is :  $binghun_swf_in_php -->  $binghun_new_swf_ver .\n
by date : $times .\n
EOF`

echo -e $message


#end
#
