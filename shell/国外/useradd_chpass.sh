#!/bin/bash
# auto add user for batch
# the user will be root when use salt to run this script
# ubuntu command passwd can't use --stdin：echo "new_passwd" | passwd --stdin $user
# if user is exist,the old passwd will be changed to the new one
# 合二为一：新加用户和批量修改密码都用此脚本
# both of add new user and change password can use this script
#2016.4.1

new_user=(gm fpsdev)
new_pass=qingdao0613
new_pass_gm=ychd@0613

add_new_user(){
	if [ `id -u` -ne 0 ];then
		echo "You should run this script as root"
		exit 1
	fi

	which expect 2>&1 /dev/null || apt-get install -y --force-yes expect
	
	for user in ${new_user[*]};do
		if [[ $user == "gm" ]];then
			chmod o-x /usr/bin/mongo
			chown -R root.op /usr/bin/mongo
			usermod -a -G op $user

			id $user 2>/dev/null || useradd -m -s /bin/bash $user
			expect -c "
				set timeout 300
				spawn passwd $user
				expect {
					password {send \"$new_pass_gm\r\";exp_continue}
					password {send \"$new_pass_gm\r\"}
				};
				expect eof
				"
		else
			id $user 2>/dev/null || useradd -m -s /bin/bash $user
			expect -c "
				set timeout 300
				spawn passwd $user
				expect {
					password {send \"$new_pass\r\";exp_continue}
					password {send \"$new_pass\r\"}
				};
				expect eof
				"
		fi
		

	done
}

add_new_user