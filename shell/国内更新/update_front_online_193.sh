#!/bin/bash
#server : 10.0.10.193/198/199
#path : /opt/fps/pack_tools/client_pack/update_front_online.sh
#by 2016-10-27

case $1 in
swf)
	ssh server0.uc.ppweb.com.cn <<EOF
	bash /data/opt/front_client_update/update_online_cdn.sh swf
EOF
;;
res)
	ssh server0.uc.ppweb.com.cn <<EOF
	bash /data/opt/front_client_update/update_online_cdn.sh res
EOF
;;
swf1)
	ssh server0.uc.ppweb.com.cn <<EOF
	bash /data/opt/front_client_update/update_online_cdn.sh swf1
EOF
;;
res1)
	ssh server0.uc.ppweb.com.cn <<EOF
	bash /data/opt/front_client_update/update_online_cdn.sh res1
EOF
;;
all)
	ssh server0.uc.ppweb.com.cn <<EOF
	bash /data/opt/front_client_update/update_online_cdn.sh all
EOF
;;
*)
echo "error args"
;;
esac


echo "success!!!"
