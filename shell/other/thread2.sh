#!/bin/bash


server_list=`cat /home/op/server_list.conf`


mkfifo testfifo
exec 100<>testfifo
rm testfifo

thread_num(){
  for ((i=1;i<=10;i++))
  do
    echo 
  done >&100
}

update(){
	echo "this is server:$server"
	sleep 5
}

thread_num
#for ((i=1;i<=$server_list_num;i++))
for server in $server_list
do
  read -u100
  {
    update
    echo >&100
  }&
done

wait
exec 100>&-
exec 100<&-

echo "update down!!!"


