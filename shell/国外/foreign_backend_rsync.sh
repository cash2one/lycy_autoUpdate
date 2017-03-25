#!/bin/bash
#path:/home/op/sh/foreign_backend_rsync.sh
#if use rsync to upload,you should set ff=unix
#2016.3.9

server_list=(78.46.112.249)

rsync(){
	update_time=`date +%y%m%d%H%M%S`
	local_path=/opt/fps/pack_tools/backend_pack/upload

	remote_path=/data/backup-update
	remote_user=op
	remote_pass=ychd@0613

	for i in ${server_list[*]};do
	        ssh -T $i <<EOF
	        [ ! -d $remote_path/$update_time ] && echo $remote_pass|sudo -S mkdir -p $remote_path/$update_time
	        sudo chown -R $remote_user.$remote_user $remote_path
	EOF
	        rsync -avzp $local_path/* $i:$remote_path/$update_time
	done
}

rsync