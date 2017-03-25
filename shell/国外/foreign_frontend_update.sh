#!/bin/bash
#Function: used to update test server and online server
#if use rsync to upload,you should set ff=unix
#Fomat:
#  config: like config.0.1.1001
#  json: like S1.0.1.1.json,not S1.0.1.1001.json
#  DarkForrest: like DarkForrest.0.1.1.swf

#  S1 instead of S99 at russia platform

#russia test server update process:res and swf for update should in /opt/upload first
#online server update process:use test server's res,json and DarkForrest

#Usage:
#  bash update.sh test [-O|-D|-A]
#  bash update.sh online [-O|-D|-A]

#path: /data/www/fps-cdnsrc/res_dir/update.sh
#date: 2016.3.7

#------------------ test server variables ----------------------------
res_source_dir=/opt/upload/res_source_dir
swf_source_dir=/opt/upload/swf_source_dir
res_dir=/data/www/fps-cdnsrc/res_dir
res99=/data/www/fps-cdnsrc/res_dir/res0.1.99
conf_dir=/data/www/config-fps/conf_dir
test99php=/data/www/config-fps/conf_dir/test99.php

old_test99_json_ver=`awk -F'+' '/json/ {print $4}' $test99php|awk -F'.' '{print $3}'|awk -F'"' '{print $1}'`
new_test99_json_ver=$((old_test99_json_ver+1))
old_test99_res_ver=`awk -F'"ver"' '{print $2}' $conf_dir/S99.0.1.$old_test99_json_ver.json|awk -F'"' '{print $2}'|awk -F'.' '{print $NF}'`
new_test99_res_ver=$((old_test99_res_ver+1))

old_test99_swf_ver=`awk -F'.' '/var dfv/ {print $4}' $test99php`
new_test99_swf_ver=$((old_test99_swf_ver+1))


#------------------- test to online variables --------------------------
indexphp=$conf_dir/index.php
res_online_dir=$res_dir/res0.1.15

old_online_json_ver=`awk -F'+' '/json/ {print $4}' $indexphp|awk -F'.' '{print $3}'|awk -F'"' '{print $1}'`
new_online_json_ver=$((old_online_json_ver+1))
jsoncount=`ls $conf_dir/S*.0.1.$old_online_json_ver.json |grep -v S99|awk -F'S' '{print $2}'|awk -F'.' '{print $1}'`
old_online_res_ver=`awk -F'"ver"' '{print $2}' $conf_dir/S1.0.1.$old_online_json_ver.json|awk -F'"' '{print $2}'|awk -F'.' '{print $NF}'`
new_online_res_ver=$((old_online_res_ver+1))

old_online_swf_ver=`awk -F'.' '/var dfv/ {print $4}' $indexphp`
new_online_swf_ver=$((old_online_swf_ver+1))

if [ $# -ne 2 ];then
     echo "Wrong fomat!"
     echo "usage: sh update.sh [-O | -D | -A]"
     exit 1
fi

#To make sure res dir is op:op
if [ `id -u` -eq 0 ];then
     echo "Please run this script use op!"
     exit 2
fi

test_update_res() {
    read -p "Did you prepare res or swf on $swf_source_dir and $res_source_dir[Y/N]?" choice
    if [ $choice != "Y" ] && [ $choice != "y" ];then
	echo "You should rsync res or swf from china to $res_source_dir or $swf_source_dir on this server!"
     	exit 3
    fi

    if [[ ! -d $res_source_dir || ! -d $swf_source_dir ]];then
    	 echo "$res_source_dir or $swf_source_dir for update doesn't exist!" 
   	 exit 4
    fi

    rm -rf $res99.bak 2>&1
    mv $res99 $res99.bak
    cp -ra $res_source_dir $res99
    cd $res99
    mv config.* config.0.1.$new_test99_res_ver
    cp $conf_dir/S99.0.1.$old_test99_json_ver.json $conf_dir/S99.0.1.$new_test99_json_ver.json
    sed -i s/0.1.$old_test99_res_ver/0.1.$new_test99_res_ver/ $conf_dir/S99.0.1.$new_test99_json_ver.json
    sed -i s/0.1.$old_test99_json_ver/0.1.$new_test99_json_ver/ $test99php

    echo "config.0.1.$old_test99_res_ver  -->  config.0.1.$new_test99_res_ver"
    echo "S99.0.1.$old_test99_json_ver.json  -->  S99.0.1.$new_test99_json_ver.json"
    echo "Update test server res done!"
}

test_update_swf() {
    cp $swf_source_dir/* $res_dir/DarkForrest.0.1.$new_test99_swf_ver.swf
    sed -i s/DarkForrest.0.1.$old_test99_swf_ver.swf/DarkForrest.0.1.$new_test99_swf_ver.swf/ $test99php
    echo "DarkForrest.0.1.$old_test99_swf_ver.swf  -->  DarkForrest.0.1.$new_test99_swf_ver.swf"
    echo "Update test server DarkForrest done!"
}

online_update_res() {
    for i in $jsoncount;do
	cp $conf_dir/S$i.0.1.$old_online_json_ver.json $conf_dir/S$i.0.1.$new_online_json_ver.json
	sed -i s/$old_online_res_ver/$new_online_res_ver/ $conf_dir/S$i.0.1.$new_online_json_ver.json
    done

    rm -rf $res_online_dir.bak 2>&1
    mv $res_online_dir $res_online_dir.bak
    cp -ra $res99 $res_online_dir
    cd $res_online_dir
    mv config.* config.0.1.$new_online_res_ver
    echo "res: config.0.1.$old_online_res_ver  -->  config.0.1.$new_online_res_ver"

    for i in $jsoncount;do
        echo "S$i.0.1.$old_online_json_ver.json  -->  S$i.0.1.$new_online_json_ver.json"
    done

    echo "Update online server res done!"
}

online_update_swf() {
    sed -i s/DarkForrest.0.1.$old_online_swf_ver.swf/DarkForrest.0.1.$new_test99_swf_ver.swf/ $indexphp
    echo "DarkForrest.0.1.$old_online_swf_ver.swf  -->  DarkForrest.0.1.$new_test99_swf_ver.swf"
    echo "Update online server DarkForrest done!"
}

### script start ###

if [[ $1 == "test" && $2 == "-O" ]];then
	test_update_res;
elif [[ $1 == "test" && $2 == "-D" ]];then
	test_update_swf;
elif [[ $1 == "test" && $2 == "-A" ]];then
	test_update_res;
	sleep 2;
	test_update_swf;
elif [[ $1 == "online" && $2 == "-O" ]];then
	online_update_res;
elif [[ $1 == online ]] && [[ $2 == "-D" ]];then
	online_update_swf;
elif [[ $1 == "online" && $2 == "-A" ]];then
	online_update_res;
	sleep 2;
	online_update_swf;
else
	echo "Wrong format!"
	echo "Usage: bash update.sh [test | online] [-O | -D | -A]";
fi


### script stop ###