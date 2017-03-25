#!/bin/bash
#Server:  server0.uc.ppweb.com.cn
#path: /data/opt/front_client_update/update_test4399.sh
#update test4399's res,rsync from 10.0.10.193
#by 2016-11-18

config_dir=/data/www/config.fps.kukuplay.com/4399
res_dir=/data/www/fps.cdnsrc.kukuplay.com/res4399

#old_json=`ls -rt $config_dir/S99.0.1.*|tail -1|awk -F'/' '{print $NF}'`
old_json=`ls -t $config_dir/S99.0.1.*|awk '$NR'`
old_json_ver=`ls -lrt $config_dir/S99.0.1.*|tail -1|awk -F'/' '{print $NF}'|awk -F'.' '{print $4}'`
add_json_ver=$((old_json_ver+1))
new_json=S99.0.1.$add_json_ver.json

old_res_ver=`ls $res_dir/res0.1.99.bak/ |grep config|awk -F'.' '{print $NF}'`
add_res_ver=$((old_res_ver+1))
new_res_ver=config.0.1.$add_res_ver

old_ver_in_json=`awk -F'ver' ' {print $2}' $old_json|awk -F'.' '{print $3}'|awk -F'"' '{print $1}'`
json_in_php=`awk -F'" +' '/json/ {print $2}' $config_dir/test99.php|awk -F'.' '{print $NF}'`

test99_php=/data/www/config.fps.kukuplay.com/4399/test99.php

/bin/cp $old_json $config_dir/$new_json
#back up res0.1.99 before rsync
#/bin/rm -rf /data/www/fps.cdnsrc.kukuplay.com/res4399/res0.1.99.bak
#/bin/cp -ra /data/www/fps.cdnsrc.kukuplay.com/res4399/res0.1.99 /data/www/fps.cdnsrc.kukuplay.com/res4399/res0.1.99.bak
/bin/mv $res_dir/res0.1.99/config.* $res_dir/res0.1.99/$new_res_ver

sed -i 's/0.1.'$old_ver_in_json'/0.1.'$add_res_ver'/' $config_dir/$new_json

sed -i '/json/s/0.1.'$json_in_php'/0.1.'$add_json_ver'/' $test99_php

#更新binghun_x
cd /data/opt/front_client_update
./update_front_online_binghun_x.sh test99
