#!/bin/bash
#front update script
#10.0.10.193/198/199
#script_path: /opt/fps/pack_tools/client_pack/update_front_4399test.sh
#by 2016-01-08

a=`date +%s`
true >/tmp/front_update_error.log

#backup resdir
ssh server0.uc.ppweb.com.cn  <<EOF 2>/tmp/front_update_error.log
rm -rf /data/www/fps.cdnsrc.kukuplay.com/res4399/res0.1.99.bak
mv /data/www/fps.cdnsrc.kukuplay.com/res4399/res0.1.99 /data/www/fps.cdnsrc.kukuplay.com/res4399/res0.1.99.bak
EOF

#update resdir
rsync  -avzuP --delete /opt/fps/www/client/client_res/  server0.uc.ppweb.com.cn:/data/www/fps.cdnsrc.kukuplay.com/res4399/res0.1.99  1>/dev/null 2>>/tmp/front_update_error.log

#change resdir parameter
ssh server0.uc.ppweb.com.cn  <<EOF 2>>/tmp/front_update_error.log
/data/opt/front_client_update/update_test4399.sh 
EOF

#Whether update correctly
errornum=`cat /tmp/front_update_error.log|wc -l`

case $errornum in
0)
b=`date +%s`
num="$(((b-a)/60)) minutes $(((b-a)%60)) seconds"
echo "Successful !!! The front-end update cost for $num "
;;
*)
echo "Error !!! The front-end update failed , An error is as follows"
echo "-----------------------------------"
cat /tmp/front_update_error.log
echo "-----------------------------------"
;;
esac

#script end
