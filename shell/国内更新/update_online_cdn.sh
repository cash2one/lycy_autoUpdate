#/bin/sh
#front res or swf update formal script
#server : server0.uc.ppweb.com.cn
#path : /data/opt/front_client_update/update_online_cdn.sh
#by 2017-01-20

fabu_dl() {
domain=dl
urlpath='res0.1.15/'
urls=(
http://fps.$domain.kukuplay.com/res4399/ \
http://fps.$domain.kukuplay.com/res7k/ \
http://fps.$domain.kukuplay.com/res2144/ \
http://fps.$domain.kukuplay.com/res360wan/ \
http://fps.$domain.kukuplay.com/reskugou/ \
http://fps.$domain.kukuplay.com/restiexue/ \
http://fps.$domain.kukuplay.com/restencent/ \
http://fps.$domain.kukuplay.com/resxunlei/ \
)
num=0
for url in ${urls[*]}
do
	case $canshu in
	swf)
		curl -s --connect-timeout 10 -m 10 -d captcha=436bd523 -d type=1 -d url=$url${swf_all[(num)]} http://push.dnion.com/cdnUrlPush.do |grep -i 'success' >/dev/null && echo "Successful !!! DLKJ swf is Post ok" || echo "Warning !!! DLKJ swf is Post failure"
		sleep 5
	;;
	res)
		curl -s --connect-timeout 10 -m 10 -d captcha=436bd523 -d type=0 -d url=$url$urlpath http://push.dnion.com/cdnUrlPush.do |grep -i 'success' >/dev/null && echo "Successful !!! DLKJ res is Post ok" || echo "Warning !!! DLKJ res is Post failure"
		sleep 5
	;;
	all)
		curl -s --connect-timeout 10 -m 10 -d captcha=436bd523 -d type=1 -d url=$url${swf_all[(num)]} http://push.dnion.com/cdnUrlPush.do |grep -i 'success' >/dev/null && echo "Successful !!! DLKJ swf is Post ok" || echo "Warning !!! DLKJ swf is Post failure"
		sleep 5
		curl -s --connect-timeout 10 -m 10 -d captcha=436bd523 -d type=0 -d url=$url$urlpath http://push.dnion.com/cdnUrlPush.do |grep -i 'success' >/dev/null && echo "Successful !!! DLKJ res is Post ok" || echo "Warning !!! DLKJ res is Post failure"
		sleep 5
	;;
	esac
	num=$((num+1))
done
#curl -d captcha=436bd523 -d type=1 -d url=$url$ http://push.dnion.com/cdnUrlPush.do 
}

fabu_wskj() {
domain=wskj
urlpath='res0.1.15/'
urls=(
http://fps.$domain.kukuplay.com/res4399/ \
http://fps.$domain.kukuplay.com/res7k/ \
http://fps.$domain.kukuplay.com/res2144/ \
http://fps.$domain.kukuplay.com/res360wan/ \
http://fps.$domain.kukuplay.com/reskugou/ \
http://fps.$domain.kukuplay.com/restiexue/ \
http://fps.$domain.kukuplay.com/restencent/ \
http://fps.$domain.kukuplay.com/resxunlei/ \
)
num=0
for url in ${urls[*]}
do
	case $canshu in
	swf)
		md5pass_swf=`echo -n "kukuplayQingdao0613$url${swf_all[(num)]}" | md5sum |awk '{print $1}'`
		curl -s --connect-timeout 10 -m 10 -X POST -d "username=kukuplay&passwd=$md5pass_swf&url=$url${swf_all[(num)]}" "http://wscp.lxdns.com:8080/wsCP/servlet/contReceiver" |grep -i 'success' >/dev/null && echo "Successful !!! WSKJ swf is Post ok" || echo "Warning !!! WSKJ swf is Post failure"
		sleep 1
	;;
	res)
		md5pass_res=`echo -n "kukuplayQingdao0613$url$urlpath" | md5sum |awk '{print $1}'`
		curl -s --connect-timeout 10 -m 10 -X POST -d "username=kukuplay&passwd=$md5pass_res&dir=$url" "http://wscp.lxdns.com:8080/wsCP/servlet/contReceiver" |grep -i 'success' >/dev/null && echo "Successful !!! WSKJ res is Post ok" || echo "Warning !!! WSKJ res is Post failure"
		sleep 1
	;;
	all)
		md5pass_swf=`echo -n "kukuplayQingdao0613$url${swf_all[(num)]}" | md5sum |awk '{print $1}'`
		md5pass_res=`echo -n "kukuplayQingdao0613$url$urlpath" | md5sum |awk '{print $1}'`
		curl -s --connect-timeout 10 -m 10 -X POST -d "username=kukuplay&passwd=$md5pass_swf&url=$url${swf_all[(num)]}" "http://wscp.lxdns.com:8080/wsCP/servlet/contReceiver" |grep -i 'success' >/dev/null && echo "Successful !!! WSKJ swf is Post ok" || echo "Warning !!! WSKJ swf is Post failure"
		sleep 1
		curl -s --connect-timeout 10 -m 10 -X POST -d "username=kukuplay&passwd=$md5pass_res&dir=$url" "http://wscp.lxdns.com:8080/wsCP/servlet/contReceiver" |grep -i 'success' >/dev/null && echo "Successful !!! WSKJ res is Post ok" || echo "Warning !!! WSKJ res is Post failure"
		sleep 1
	;;
	esac
	num=$((num+1))
done
#curl -X POST -d "username=kukuplay&passwd=Qingdao0613&url=url1;url2;...&dir=dir1;dir2" " http://wscp.lxdns.com:8080/wsCP/servlet/contReceiver" 
}

fabu_qq(){
cd /data/opt/front_client_update/cdn_qq
case $canshu in
res)
python qqcdn_res.py |grep '"code":0' >>/dev/null && echo "Successful !!! QQcloud res is Post ok" || echo "Warning !!! QQcloud res is Post failure"
;;
swf)
python qqcdn_swf.py ${swf_all[*]} |grep '"code":0' >>/dev/null && echo "Successful !!! QQcloud swf is Post ok" || echo "Warning !!! QQcloud swf is Post failure"
;;
all)
python qqcdn_res.py |grep '"code":0' >>/dev/null && echo "Successful !!! QQcloud res is Post ok" || echo "Warning !!! QQcloud res is Post failure"
python qqcdn_swf.py ${swf_all[*]} |grep '"code":0' >>/dev/null && echo "Successful !!! QQcloud swf is Post ok" || echo "Warning !!! QQcloud swf is Post failure"
;;
esac
}

Version_query(){
#2144
swf_2144=`ls -lrt  /data/www/fps.cdnsrc.kukuplay.com/res2144/*.swf |grep -v T |sed -n '$p'|awk -F"/" '{print $NF}'`
#360
swf_360wan=`ls -lrt  /data/www/fps.cdnsrc.kukuplay.com/res360wan/*.swf |grep -v T |sed -n '$p'|awk -F"/" '{print $NF}'`
#4399
swf_4399=`ls -lrt  /data/www/fps.cdnsrc.kukuplay.com/res4399/*.swf |grep -v T |sed -n '$p'|awk -F"/" '{print $NF}'`
#7k7k
swf_7k7k=`ls -lrt  /data/www/fps.cdnsrc.kukuplay.com/res7k/*.swf |grep -v T |sed -n '$p'|awk -F"/" '{print $NF}'`
#kugou
swf_kugou=`ls -lrt  /data/www/fps.cdnsrc.kukuplay.com/reskugou/*.swf |grep -v T |sed -n '$p'|awk -F"/" '{print $NF}'`
#tencent
swf_tencent=`ls -lrt  /data/www/fps.cdnsrc.kukuplay.com/restencent/*.swf |grep -v T |sed -n '$p'|awk -F"/" '{print $NF}'`
if [[ "$swf_tencent" == "DarkForrest_tencent.swf" ]];then
swf_tencent=$newswf
fi
res_tencent=`ls -drt  /data/www/fps.cdnsrc.kukuplay.com/restencent/res0.1.15/config.*|awk -F"/" '{print $NF}'`
#tiexue
swf_tiexue=`ls -lrt  /data/www/fps.cdnsrc.kukuplay.com/restiexue/*.swf |grep -v T |sed -n '$p'|awk -F"/" '{print $NF}'`
#xunlei
swf_xunlei=`ls -lrt  /data/www/fps.cdnsrc.kukuplay.com/resxunlei/*.swf |grep -v T |sed -n '$p'|awk -F"/" '{print $NF}'`

swf_all=($swf_4399 $swf_7k7k $swf_2144 $swf_360wan $swf_kugou $swf_tiexue $swf_tencent $swf_xunlei)
}

expect_sh () {
LANG="en_us.utf8"
/usr/bin/expect -c "
proc jiaohu {} {
	send_user expect_start
	expect {
		#ssh connect
		Password {
			send ${RemotePassword}\r;
			send_user expect_eof
			expect {
				incorrect {
					send_user expect_failure
					exit 1
				}
				eof
			}
		}
		#host was not connect
		\"No route to host\" {
			send_user expect_failure
			exit 2
		}
		#IP port or illegal
		\"Invalid argument\" {
			send_user expect_failure
			exit 3
		}
		#port error
		\"Connection refused\" {
			send_user expect_failure
			exit 4
		}
		#root not exits
		\"does not exist\" {
			send_user expect_failure
			exit 5
		}
		#ssh connect timeout
		\"Connection timed out\" {
			send_user expect_failure
			exit 6
		}
		#expect timeout
		timeout {
			send_user expect_failure
			exit 7
		}
		eof
	}
}

#set timeout
set timeout -1
#
switch $1 {
	change  {
		spawn ssh -t -p $qq_PORT root@$qq_IP \" sh /root/change_qq.sh $canshu \"
		jiaohu
	}
	rsync_shell  {
		spawn rsync -tvzuP \"-e ssh -p $qq_PORT\" /home/op/change_qq.sh root@$qq_IP:/root
		jiaohu
	}
}
"
case $? in
0)
echo -e "\e[32m$ip---------------(OK)\e[m"
;;
1)
echo -e '\e[31m$ip---------------(Error) \e[m'
;;
*)
echo -e '\e[31m$ip---------------(Other Error) \e[m'
;;
esac
}

general () {
#front_file_upload
cd /data/opt/front_client_update/upload_file/
perl 1111.pl $canshu

#front_file_make
cd /data/opt/front_client_update/
perl Cron_client_update.pl 4399,2144,7k7k,360wan,kugou,tiexue,xunlei $PRM

#change bingun_x
# cd /data/opt/front_client_update/
# bash update_front_online_binghun_x.sh online
}

general_with_out360 () {
#front_file_upload,不含360
cd /data/opt/front_client_update/upload_file/
perl 1111.pl $canshu

#front_file_make,不含360
cd /data/opt/front_client_update/
perl Cron_client_update.pl 4399,2144,7k7k,kugou,tiexue,xunlei $PRM

#change bingun_x
# cd /data/opt/front_client_update/
# bash update_front_online_binghun_x.sh online
}

change_bingun_x_swf() {

cd /data/opt/front_client_update/
bash update_front_online_binghun_x.sh online_swf

}

change_bingun_x_res() {

cd /data/opt/front_client_update/
bash update_front_online_binghun_x.sh online_res

}

console_qq_swf(){
#only_qq
cd /data/www/fps.cdnsrc.kukuplay.com/restencent
newswf=`ls -rt *.swf|grep -v "_tencent"|sed -n '$p'|awk -F"." '{print $1"."$2"."$3"."($4+1)"."$5}'`
mv DarkForrest_tencent.swf $newswf
#end
}

console_qq_res() {
#only_qq
cd /data/www/fps.cdnsrc.kukuplay.com/restencent
rm -rf res0.1.15.bak
mv res0.1.15 res0.1.15.bak
cp -a ../res4399/res0.1.15 .
qq_config_version=(`ls -d res0.1.15.bak/config.*|awk -F"/" '{print $2}'|awk -F"." '{print $1"."$2"."$3"."$4,$1"."$2"."$3"."($4+1)}'`)
mv res0.1.15/config.* res0.1.15/${qq_config_version[1]} 
#end
}

console_qq_remote() {

RemotePassword='ychd@0613'
qq_PORT=36000
qq_IP=10.182.48.22

message=`cat <<EOF>/home/op/change_qq.sh
#!/bin/bash
LANG="en_US.utf8"
swf_version=\\\`echo $swf_tencent\\\`
res_version=\\\`echo $res_tencent|awk -F"config." '{print \\\$NF}'\\\`
case \\\$1 in
swf)
	cd /data/www/s3.app1101337509.qqopenapp.com/
	#cd /home/op
	old_swf_in_php=\\\`grep DarkForrest.[0-9].*.swf index.php |awk -F"," '{print \\\$1}'|awk -F"/" '{print \\\$NF}'|awk -F'"' '{print \\\$1}'\\\`
	sed -i '/DarkForrest.[0-9].*.swf/s/'\\\$old_swf_in_php'/'\\\$swf_version'/' index.php
	
	echo "swf update is ok"
;;
res)
	cd /data/www/s3.app1101337509.qqopenapp.com/
	#cd /home/op
	old_qq_json=\\\`ls -rt *.json |sed -n '\\\$p'\\\`
	new_qq_json=(\\\`ls -rt *.json |sed -n '\\\$p'|awk -F"." '{print \\\$1"."\\\$2."."\\\$3"."(\\\$4+1)"."\\\$5,\\\$2"."\\\$3"."(\\\$4+1)}'\\\`)
	/bin/cp -a \\\$old_qq_json \\\${new_qq_json[0]}
	old_res_version=\\\`awk -F'"ver":"' '{print \\\$2}' \\\$old_qq_json |awk -F'"' '{print \\\$1}'\\\`
	sed -i 's/'\\\$old_res_version'/'\\\$res_version'/' \\\${new_qq_json[0]}
	/bin/cp -a index.php index.php.bak
	old_json_in_php=\\\`awk -F'" +' '/.json/ {print \\\$3}' index.php |awk -F'"' '{print \\\$2}'\\\`
	sed -i '/.json/s/'\\\$old_json_in_php'/'\\\${new_qq_json[1]}'/' index.php
	
	echo "res update is ok"
;;
all)
	#res change
	cd /data/www/s3.app1101337509.qqopenapp.com/
	#cd /home/op
	old_qq_json=\\\`ls -rt *.json |sed -n '\\\$p'\\\`
	new_qq_json=(\\\`ls -rt *.json |sed -n '\\\$p'|awk -F"." '{print \\\$1"."\\\$2."."\\\$3"."(\\\$4+1)"."\\\$5,\\\$2"."\\\$3"."(\\\$4+1)}'\\\`)
	/bin/cp -a \\\$old_qq_json \\\${new_qq_json[0]}
	old_res_version=\\\`awk -F'"ver":"' '{print \\\$2}' \\\$old_qq_json |awk -F'"' '{print \\\$1}'\\\`
	sed -i 's/'\\\$old_res_version'/'\\\$res_version'/' \\\${new_qq_json[0]}
	/bin/cp -a index.php index.php.bak
	old_json_in_php=\\\`awk -F'" +' '/.json/ {print \\\$3}' index.php |awk -F'"' '{print \\\$2}'\\\`
	sed -i '/.json/s/'\\\$old_json_in_php'/'\\\${new_qq_json[1]}'/' index.php
	
	#swf change
	old_swf_in_php=\\\`grep DarkForrest.[0-9].*.swf index.php |awk -F"," '{print \\\$1}'|awk -F"/" '{print \\\$NF}'|awk -F'"' '{print \\\$1}'\\\`
	sed -i '/DarkForrest.[0-9].*.swf/s/'\\\$old_swf_in_php'/'\\\$swf_version'/' index.php
	
	echo "all update is ok"
;;
esac
EOF
`

expect_sh rsync_shell |awk 'BEGIN{RS="(expect_start|expect_eof|expect_failure)"}END{print $0}' 
expect_sh change |awk 'BEGIN{RS="(expect_start|expect_eof|expect_failure)"}END{print $0}' 
}




#script start

case $1 in
swf)
	canshu='swf'
	PRM='-D'
	general
	console_qq_swf
	Version_query
	console_qq_remote
	change_bingun_x_swf
;;
swf1)
	#不含360
	canshu='swf'
	PRM='-D'
	echo "there do not have 360 swf"
	general_with_out360
	console_qq_swf
	Version_query
	console_qq_remote
	change_bingun_x_swf
	
;;
res)
	canshu='res'
	PRM='-O'
	general
	console_qq_res
	Version_query
	console_qq_remote
	change_bingun_x_res
;;
res1)
	#不含360
	canshu='res'
	PRM='-O'
	echo "there do not have 360 res"
	general_with_out360
	console_qq_res
	Version_query
	console_qq_remote
	change_bingun_x_res
	
;;
all)
	canshu='all'
	PRM='-A'
	general
	console_qq_swf
	console_qq_res
	Version_query
	console_qq_remote
	change_bingun_x_swf
	change_bingun_x_res
;;
esac

#CDN
#fabu_dl
fabu_wskj
fabu_qq

#script end