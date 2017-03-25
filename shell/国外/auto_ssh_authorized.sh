#!/bin/bash
#path: 10.0.10.50:/home/op/sh
#这是expect嵌套在shell中的用法，如果shebang是/usr/bin/expect，那语法又不一样了
#if use rsync to upload,you should set ff=unix
#2016.3.8

export LANG=zh_cn.UTF-8
foreigh_backserver=(78.46.112.249)
remote_user=op
remote_pass=ychd@0613
local_pass=qingdao0613
home_dir=/home/op

add_ssh_key(){
        which expect
        if [ $? -ne 0 ];then
                echo $local_pass|sudo -S apt-get install -y --force-yes expect
        fi

        for i in ${foreigh_backserver[*]};do
                expect -c "
                        set timeout 300
                        spawn ssh-copy-id -i $home_dir/.ssh/id_rsa.pub $remote_user@$i -p 22
                        expect {
                                yes/no {send \"yes\r\";exp_continue}
                                password {send \"$remote_pass\r\"}
                        };
                        expect eof
                "
        done
}


add_ssh_key
