#!/bin/bash
#用于实时更新binghun_x目录的GamePage.php中对应的swf版本号及各平台对应的json版本号
#2017-1-20

#swf修改
online_swf(){

get_online_swf_file=`ls -rt /data/www/fps.cdnsrc.kukuplay.com/res4399/DarkForrest.[0-9].[0-9].*[0-9].swf|grep -v T|sed -n '$p'|awk -F"/" '{print $NF}'`
get_old_swf_file=`ls -rt /data/www/fps.cdnsrc.kukuplay.com/resbinghun/DarkForrest.[0-9].[0-9].*[0-9].swf|grep -v T|sed -n '$p'|awk -F"/" '{print $NF}'`
get_old_swf_ver=`echo $get_old_swf_file|awk -F"." '{print $4}'`
cp -a /data/www/fps.cdnsrc.kukuplay.com/res4399/$get_online_swf_file /data/www/fps.cdnsrc.kukuplay.com/resbinghun/DarkForrest.1.1.$((get_old_swf_ver+1)).swf
new_swf_file=DarkForrest.1.1.$((get_old_swf_ver+1)).swf
sed -i 's/'$get_old_swf_file'/'$new_swf_file'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php

}


#json修改

get_test99_json=`ls -rt /data/www/config.fps.kukuplay.com/4399/S99.*.json|sed -n '$p'|awk -F"/" '{print $NF}'|awk -F"." '{print $2"."$3"."$4}'`
get_4399_json=`ls -rt /data/www/config.fps.kukuplay.com/4399/S1.*.json|sed -n '$p'|awk -F"/" '{print $NF}'|awk -F"." '{print $2"."$3"."$4}'`
get_7k7k_json=`ls -rt /data/www/config.fps.kukuplay.com/7k7k/S1.*.json|sed -n '$p'|awk -F"/" '{print $NF}'|awk -F"." '{print $2"."$3"."$4}'`
get_360wan_json=`ls -rt /data/www/config.fps.kukuplay.com/360wan/S1.*.json|sed -n '$p'|awk -F"/" '{print $NF}'|awk -F"." '{print $2"."$3"."$4}'`
get_kugou_json=`ls -rt /data/www/config.fps.kukuplay.com/kugou/S1.*.json|sed -n '$p'|awk -F"/" '{print $NF}'|awk -F"." '{print $2"."$3"."$4}'`
get_2144_json=`ls -rt /data/www/config.fps.kukuplay.com/2144/S1.*.json|sed -n '$p'|awk -F"/" '{print $NF}'|awk -F"." '{print $2"."$3"."$4}'`
get_tiexue_json=`ls -rt /data/www/config.fps.kukuplay.com/tiexue/S1.*.json|sed -n '$p'|awk -F"/" '{print $NF}'|awk -F"." '{print $2"."$3"."$4}'`
get_xunlei_json=`ls -rt /data/www/config.fps.kukuplay.com/xunlei/S1.*.json|sed -n '$p'|awk -F"/" '{print $NF}'|awk -F"." '{print $2"."$3"."$4}'`
get_fengyunzhibo_json=`ls -rt /data/www/config.fps.kukuplay.com/fengyunzhibo/S1.*.json|sed -n '$p'|awk -F"/" '{print $NF}'|awk -F"." '{print $2"."$3"."$4}'`

old_test99_json=`grep test99json /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php |awk -F"+" '{print $(NF-1)}'|awk -F'"' '{print $2}'`
old_4399_json=`grep 4399json /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php |awk -F"+" '{print $(NF-1)}'|awk -F'"' '{print $2}'`
old_7k7k_json=`grep 7k7kjson /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php |awk -F"+" '{print $(NF-1)}'|awk -F'"' '{print $2}'`
old_360wan_json=`grep 360wanjson /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php |awk -F"+" '{print $(NF-1)}'|awk -F'"' '{print $2}'`
old_kugou_json=`grep kugoujson /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php |awk -F"+" '{print $(NF-1)}'|awk -F'"' '{print $2}'`
old_2144_json=`grep 2144json /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php |awk -F"+" '{print $(NF-1)}'|awk -F'"' '{print $2}'`
old_tiexue_json=`grep tiexuejson /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php |awk -F"+" '{print $(NF-1)}'|awk -F'"' '{print $2}'`
old_xunlei_json=`grep xunleijson /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php |awk -F"+" '{print $(NF-1)}'|awk -F'"' '{print $2}'`
old_fengyunzhibo_json=`grep fengyunzhibojson /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php |awk -F"+" '{print $(NF-1)}'|awk -F'"' '{print $2}'`

# sed -i '/test99json/ s/'$old_test99_json'/'$get_test99_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php
# sed -i '/4399json/ s/'$old_4399_json'/'$get_4399_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php
# sed -i '/7k7kjson/ s/'$old_7k7k_json'/'$get_7k7k_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php
# sed -i '/360wanjson/ s/'$old_360wan_json'/'$get_360wan_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php
# sed -i '/kugoujson/ s/'$old_kugou_json'/'$get_kugou_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php
# sed -i '/2144json/ s/'$old_2144_json'/'$get_2144_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php
# sed -i '/tiexuejson/ s/'$old_tiexue_json'/'$get_tiexue_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php
# sed -i '/xunleijson/ s/'$old_xunlei_json'/'$get_xunlei_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php

case $1 in 
online_swf)
	online_swf
;;
online_res)
	sed -i '/4399json/ s/'$old_4399_json'/'$get_4399_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php
	sed -i '/7k7kjson/ s/'$old_7k7k_json'/'$get_7k7k_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php
	sed -i '/360wanjson/ s/'$old_360wan_json'/'$get_360wan_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php
	sed -i '/kugoujson/ s/'$old_kugou_json'/'$get_kugou_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php
	sed -i '/2144json/ s/'$old_2144_json'/'$get_2144_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php
	sed -i '/tiexuejson/ s/'$old_tiexue_json'/'$get_tiexue_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php
	sed -i '/xunleijson/ s/'$old_xunlei_json'/'$get_xunlei_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php
	sed -i '/fengyunzhibojson/ s/'$old_fengyunzhibo_json'/'$get_fengyunzhibo_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php
;;
test99)
	sed -i '/test99json/ s/'$old_test99_json'/'$get_test99_json'/' /data/www/config.fps.kukuplay.com/binghun_x/GamePage.php
;;
*)
echo '请正确使用 ./update_front_online_binghun_x.sh (online|test99)'
;;
esac
