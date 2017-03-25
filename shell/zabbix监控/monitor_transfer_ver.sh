#!/bin/bash
#check_transfer version on http
#by 2016-04-08

date=`date +%F-%H:%M:%S`
list=(19010 19040 19070 19100 19130 19160 19190)
week=`date +%w`
time=`date +%H`

num=1
for i in ${list[*]};do
	curl -s --connect-timeout 5 -m 5 http://localhost:$i/TransferServer/Health > /dev/null
	if [ $? -ne 0 ];then
		sleep 10
		curl -s --connect-timeout 5 -m 5 http://localhost:$i/TransferServer/Health > /dev/null
		if [ $? -ne 0 ];then
			cd /opt/fps/transfer$num
			if [ ! -f dont-start-TRANSFER ];then
				./transfer.sh restart
				hostname=`hostname -f`
				case $week in
				4)
					case $time in
					00|01|02|03|04|05|06|07|08)
						echo "$hostname tranfer$num:$i restart at $date"
					;;
					*)
						echo "$hostname tranfer$num:$i restart at $date" |mail -s "transfer restart" mis@cloudacc-inc.com
						echo "$hostname tranfer$num:$i restart at $date"
					;;
					esac
				;;
				*)
					echo "$hostname tranfer$num:$i restart at $date" |mail -s "transfer restart" mis@cloudacc-inc.com
					echo "$hostname tranfer$num:$i restart at $date"
				;;
				esac
			fi
		fi
	fi
	num=$((num+1))
done


