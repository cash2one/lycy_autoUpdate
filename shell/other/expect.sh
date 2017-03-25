#!/bin/bash

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
		 spawn ssh -t -p $PORT root@$IP \" sh /root/aa.sh \"
		 jiaohu
	}
	rsync_shell  {
		spawn rsync -tvzuP \"-e ssh -p $PORT\" /home/op/tt.php root@$IP:/root
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
RemotePassword='ychd@0613'
PORT='36000'
path=/root
IP='10.182.48.22'
expect_sh rsync_shell |awk 'BEGIN{RS="(expect_start|expect_eof|expect_failure)"}END{print $0}' 