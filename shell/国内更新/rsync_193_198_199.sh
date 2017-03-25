#!/bin/bash
#保持193,198,199更新脚本一致,以199服务器为准
#该脚本在199服务器部署 
#位置:/opt/fps/pack_tools/client_pack/rsync_keep.sh
#by 2016-02-01

front_path1=/opt/fps/pack_tools/client_pack/update_front_4399test.sh
front_path2=/opt/fps/pack_tools/client_pack/update_front_online.sh
front_path3=/opt/fps/pack_tools/client_pack/update_front_test99swf.sh
backend_path1=/opt/fps/pack_tools/backend_pack/autodeploy/update_backend_online.sh
backend_path2=/opt/fps/pack_tools/backend_pack/autodeploy/update_backend_4399test.sh

list=($front_path1 $front_path2 $front_path3 $backend_path1 $backend_path2)

for path in ${list[*]}
do
rsync -avzP $path 10.0.10.193:$path 1>/dev/null
rsync -avzP $path 10.0.10.198:$path 1>/dev/null
done
