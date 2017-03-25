#!/bin/bash
#server : 10.0.10.193/198/199
#path : /opt/fps/pack_tools/backend_pack/autodeploy/update_backend_online.sh
#by 2016-01-16

case $1 in
config)
        ssh tools.uc.ppweb.com.cn <<EOF
        bash /srv/salt/auto-update/update_backend_online.sh config
EOF
;;
state)
        ssh tools.uc.ppweb.com.cn <<EOF
        bash /srv/salt/auto-update/update_backend_online.sh StateServerExt
EOF
;;
all)
        ssh tools.uc.ppweb.com.cn <<EOF
        bash /srv/salt/auto-update/update_backend_online.sh all
EOF
;;
*)
        echo "please enter a right parameter!"
;;
esac
