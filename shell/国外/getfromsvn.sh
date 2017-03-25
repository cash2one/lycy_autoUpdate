#!/bin/bash
NOWPATH=/opt/svnwork
TIME=`date +%Y%m%d%H%M%S`
SVN_DIR=/opt/svnwork/op
OUTPUT_DIR=/opt/svnwork/res
ZLIBFUN=/opt/svnwork/zlib-9.py
LOGFILE=$NOWPATH/log/alter-$TIME.log
SVN_URL=https://svn.lieyan.com.cn/repos/ppweb/webp2p/flashp2p/DarkForrest/op
SVN_UP="--username siriaodao.bao --password siriaodao841206" 



function exec_platform()
{
 	PLAT_NAME=$1
	if [[ -d $SVN_DIR/assets && -d $SVN_DIR/config.version && -d  $SVN_DIR/$PLAT_NAME ]];then
		mkdir $PLAT_NAME -p
		rsync -a --delete $SVN_DIR/assets                $PLAT_NAME
		rsync -a --delete $SVN_DIR/config.version        $PLAT_NAME
		rsync -a $SVN_DIR/$PLAT_NAME         $OUTPUT_DIR
	elif [[ -d $SVN_DIR/assets && -d $SVN_DIR/config.version ]];then
		mkdir $PLAT_NAME -p
                rsync -a --delete $SVN_DIR/assets                $PLAT_NAME
                rsync -a --delete $SVN_DIR/config.version        $PLAT_NAME
	else
		echo "ERROR_SEVERE. please check if exist assets or config.version !!!" >>$LOGFILE
		cat $LOGFILE|grep ERROR_SEVERE|mail -s "SVN ERR. $PLAT_FORM assets or config.version  problem" cloudacc@163.com
		exit 102;
	fi

}

function justnamexml()
{
        PLAT_NAME=$1
        XMLFILE=$2
        ALTER_DIR=$3
	PLATFORM_PATH=$OUTPUT_DIR/$1
        if [ -f $OUTPUT_DIR/$PLAT_NAME/config.version/$XMLFILE ];then
		echo $XMLFILE
                awk '$1=$1' $OUTPUT_DIR/$PLAT_NAME/config.version/$XMLFILE|sed -n '/key/s/<version key="\(\w\+\)" value="\([0-9.]*\)"\/>/\1 \2/gp;'|tr -d "\015" >$NOWPATH/tmp/list
                if [ -d $OUTPUT_DIR/$PLAT_NAME/$ALTER_DIR ];then
                	cd $OUTPUT_DIR/$PLAT_NAME/$ALTER_DIR
                	while read keyline
                        	do
                                	KEYNAME=`echo $keyline|awk '{print $1}'`
					if [ -d $SVN_DIR/$PLAT_NAME/$ALTER_DIR/$KEYNAME ] || [ -f $SVN_DIR/$PLAT_NAME/$ALTER_DIR/$KEYNAME ];then
						echo %%% svn log $SVN_URL/$PLAT_NAME/$ALTER_DIR/$KEYNAME
						VERSION_NUM=`svn log $SVN_URL/$PLAT_NAME/$ALTER_DIR/$KEYNAME $SVN_UP|grep ^r|awk '{print $1}'|sed 's/^r//g'|sort -nr|head -1`
						if [ ! -z VERSION_NUM ];then
							echo "$OUTPUT_DIR/$PLAT_NAME/$ALTER_DIR/$KEYNAME $OUTPUT_DIR/$PLAT_NAME/$ALTER_DIR/$KEYNAME.$VERSION_NUM" >>$LOGFILE
                                        		mv $OUTPUT_DIR/$PLAT_NAME/$ALTER_DIR/$KEYNAME $OUTPUT_DIR/$PLAT_NAME/$ALTER_DIR/$KEYNAME.$VERSION_NUM
							sed -i "/<version key=\"$KEYNAME\" value=\"[0-9.]*\"\/>/s/\(<version key=\"$KEYNAME\" value=\"\)\([0-9.]*\)\(\"\/>\)/\1$VERSION_NUM\3/" $OUTPUT_DIR/$PLAT_NAME/config.version/$XMLFILE
						else
                                                	echo "ERROR_SEVERE. NO SVN version of $SVN_URL/$PLAT_NAME/$ALTER_DIR/$KEYNAME" >>$LOGFILE
						fi
                                	elif [ -d $KEYNAME ] || [ -f $KEYNAME ];then
						echo svn log $SVN_URL/$ALTER_DIR/$KEYNAME
						VERSION_NUM=`svn log $SVN_URL/$ALTER_DIR/$KEYNAME $SVN_UP|grep ^r|awk '{print $1}'|sed 's/^r//g'|sort -nr|head -1`
						if [ ! -z VERSION_NUM ];then
							echo "$OUTPUT_DIR/$PLAT_NAME/$ALTER_DIR/$KEYNAME $OUTPUT_DIR/$PLAT_NAME/$ALTER_DIR/$KEYNAME.$VERSION_NUM" >>$LOGFILE
                                        		mv $OUTPUT_DIR/$PLAT_NAME/$ALTER_DIR/$KEYNAME $OUTPUT_DIR/$PLAT_NAME/$ALTER_DIR/$KEYNAME.$VERSION_NUM
							sed -i "/<version key=\"$KEYNAME\" value=\"[0-9.]*\"\/>/s/\(<version key=\"$KEYNAME\" value=\"\)\([0-9.]*\)\(\"\/>\)/\1$VERSION_NUM\3/" $OUTPUT_DIR/$PLAT_NAME/config.version/$XMLFILE
                                        	else
                                                	echo "ERROR_SEVERE. NO SVN version of $SVN_URL/$ALTER_DIR/$KEYNAME" >>$LOGFILE
						fi
					else
		                                FULL_PATH_NAME=`ls -1 $PLATFORM_PATH/$ALTER_DIR/$KEYNAME.*`
						FULL_NAME=`ls -1 $KEYNAME.*`
						NUMBER_OF_FULL_NAME=`ls -1 $KEYNAME.*|wc -l`
						if [ ! -z $NUMBER_OF_FULL_NAME ] && [ $NUMBER_OF_FULL_NAME -gt 1 ];then
							echo  "ERROR_SEVERE. Multiplex $FULL_NAME" >>$LOGFILE
		                                elif [[ -z $FULL_NAME ]];then
		                                        echo  "ERROR_SEVERE. NO $keyline file or directory" >>$LOGFILE
						else
							LAST_NAME=`echo $FULL_NAME|awk -F\. '{print $2}'`
							if [ -f $SVN_DIR/$PLAT_NAME/$ALTER_DIR/$FULL_NAME ] || [ -d $SVN_DIR/$PLAT_NAME/$ALTER_DIR/$FULL_NAME ];then
		                                                echo %%% svn log $SVN_URL/$PLAT_NAME/$FULL_NAME
		                                                VERSION_NUM=`svn log $SVN_URL/$PLAT_NAME/$ALTER_DIR/$FULL_NAME $SVN_UP|grep ^r|awk '{print $1}'|sed 's/^r//g'|sort -nr|head -1`
                                                		if [ ! -z $VERSION_NUM ] && [ ! -z $LAST_NAME ];then
                                                        		echo "$FULL_PATH_NAME $PLATFORM_PATH/$KEYNAME.$VERSION_NUM.$LAST_NAME"   >> $LOGFILE
									mv $FULL_PATH_NAME $PLATFORM_PATH/$ALTER_DIR/$KEYNAME.$VERSION_NUM.$LAST_NAME
									sed -i "/<version key=\"$KEYNAME\" value=\"[0-9.]*\"\/>/s/\(<version key=\"$KEYNAME\" value=\"\)\([0-9.]*\)\(\"\/>\)/\1$VERSION_NUM\3/" $OUTPUT_DIR/$PLAT_NAME/config.version/$XMLFILE
                                        	        	else
                                                	        	echo "ERROR_SEVERE. NO version of svn log $SVN_URL/$PLAT_NAME/$FULL_NAME" >>$LOGFILE
                                                        		echo "ERROR_SEVERE. or No $FULL_NAME" >>$LOGFILE
                                                		fi
							elif [ -f $PLATFORM_PATH/$ALTER_DIR/$FULL_NAME ] || [ -d $PLATFORM_PATH/$ALTER_DIR/$FULL_NAME ];then
		                                                echo svn log $SVN_URL/$ALTER_DIR/$FULL_NAME
                		                                VERSION_NUM=`svn log $SVN_URL/$ALTER_DIR/$FULL_NAME $SVN_UP|grep ^r|awk '{print $1}'|sed 's/^r//g'|sort -nr|head -1`
								if  [ ! -z $VERSION_NUM ] && [ ! -z $LAST_NAME ];then
		                                                        echo "$FULL_PATH_NAME $PLATFORM_PATH/$KEYNAME.$VERSION_NUM.$LAST_NAME"   >> $LOGFILE
                		                                        mv $FULL_PATH_NAME $PLATFORM_PATH/$ALTER_DIR/$KEYNAME.$VERSION_NUM.$LAST_NAME
									sed -i "/<version key=\"$KEYNAME\" value=\"[0-9.]*\"\/>/s/\(<version key=\"$KEYNAME\" value=\"\)\([0-9.]*\)\(\"\/>\)/\1$VERSION_NUM\3/" $OUTPUT_DIR/$PLAT_NAME/config.version/$XMLFILE
                                                		else
                                                        		echo "ERROR_SEVERE. NO version of svn log $SVN_URL/$FULL_NAME" >>$LOGFILE
                                                        		echo "ERROR_SEVERE. or NO $FULL_NAME" >>$LOGFILE
								fi
							else
		                                                echo "ERROR_SEVERE. NO $PLATFORM_PATH/$FULL_NAME" >>$LOGFILE
							fi
						fi
                                	fi
                        	done< $NOWPATH/tmp/list
                else	
                        echo "ERROR_SEVERE. NO $OUTPUT_DIR/$PLAT_NAME/$ALTER_DIR" >>$LOGFILE
			cat $LOGFILE|grep ERROR_SEVERE|mail -s "SVN ERR. $PLAT_FORM NO $OUTPUT_DIR/$PLAT_NAME/$ALTER_DIR" cloudacc@163.com
			exit 105;

                fi
        else
                echo "ERROR_SEVERE. NO $OUTPUT_DIR/$PLAT_NAME/config.version/$XMLFILE" >>$LOGFILE
		cat $LOGFILE|grep ERROR_SEVERE|mail -s "SVN ERR. $PLAT_FORM NO $OUTPUT_DIR/$PLAT_NAME/config.version/$XMLFILE" cloudacc@163.com
		exit 106;
        fi
}

function altersvnversion()
{
	PLAT_NAME=$1
	PLATFORM_PATH=$OUTPUT_DIR/$1
	cd $PLATFORM_PATH

	if [ -f $PLATFORM_PATH/config.version/resource.xml ];then
        	awk '$1=$1' $PLATFORM_PATH/config.version/resource.xml|sed -n '/name=/s/<resource name="\([a-zA-Z0-9_]\+\)" url="\(.\+\)"\/>/\1 \2/gp'|tr -d "\015">$NOWPATH/tmp/resoucre
	fi

	if [ -f $PLATFORM_PATH/config.version/version.xml ];then
	while read line
        	do
                	LABEL_TAG=`echo $line|awk '{print $1}'`
                	FIRST_NAME=`echo $line|awk '{print $2}'`
			if [ -d $SVN_DIR/$PLAT_NAME/$FIRST_NAME ] || [ -f $SVN_DIR/$PLAT_NAME/$FIRST_NAME ];then
				echo %%% svn log $SVN_URL/$PLAT_NAME/$FIRST_NAME
				VERSION_NUM=`svn log $SVN_URL/$PLAT_NAME/$FIRST_NAME $SVN_UP|grep ^r|awk '{print $1}'|sed 's/^r//g'|sort -nr|head -1`
                        	if [ ! -z $VERSION_NUM ];then
                                	echo "$PLATFORM_PATH/$FIRST_NAME $PLATFORM_PATH/$FIRST_NAME.$VERSION_NUM" >> $LOGFILE
                                	mv $PLATFORM_PATH/$FIRST_NAME $PLATFORM_PATH/$FIRST_NAME.$VERSION_NUM
                                	sed  -i "/<version key=\"$LABEL_TAG\" value=\"[0-9.]*\"\/>/s/\(<version key=\"$LABEL_TAG\" value=\"\)\([0-9.]*\)\(\"\/>\)/\1$VERSION_NUM\3/" $PLATFORM_PATH/config.version/version.xml
                        	else
                                	echo "ERROR_SEVERE. svn log $SVN_URL/$PLAT_NAME/$FIRST_NAME" >>$LOGFILE
                        	fi    
                	elif [ -d $PLATFORM_PATH/$FIRST_NAME ] || [ -f $PLATFORM_PATH/$FIRST_NAME ];then
				echo svn log $SVN_URL/$FIRST_NAME
				VERSION_NUM=`svn log $SVN_URL/$FIRST_NAME $SVN_UP|grep ^r|awk '{print $1}'|sed 's/^r//g'|sort -nr|head -1`
				if [ ! -z $VERSION_NUM ];then
                        		echo "$PLATFORM_PATH/$FIRST_NAME $PLATFORM_PATH/$FIRST_NAME.$VERSION_NUM" >> $LOGFILE
                        		mv $PLATFORM_PATH/$FIRST_NAME $PLATFORM_PATH/$FIRST_NAME.$VERSION_NUM
                        		sed  -i "/<version key=\"$LABEL_TAG\" value=\"[0-9.]*\"\/>/s/\(<version key=\"$LABEL_TAG\" value=\"\)\([0-9.]*\)\(\"\/>\)/\1$VERSION_NUM\3/" $PLATFORM_PATH/config.version/version.xml
				else
                        		echo "ERROR_SEVERE. svn log $SVN_URL/$FIRST_NAME" >>$LOGFILE

				fi
			else
                        	FULL_PATH_NAME=`ls -1 $PLATFORM_PATH/$FIRST_NAME.*`
				FULL_NAME=`ls -1 $FIRST_NAME.*`
				NUMBER_OF_FULL_NAME=`ls -1 $FIRST_NAME.*|wc -l`
                                if [ ! -z $NUMBER_OF_FULL_NAME ] && [ $NUMBER_OF_FULL_NAME -gt 1 ];then
  	                              echo  "ERROR_SEVERE. Multiplex $FULL_NAME" >>$LOGFILE
                        	elif [[ -z $FULL_NAME ]];then
                                	echo  "ERROR_SEVERE. NO $line file or directory" >>$LOGFILE
				else
                                	LAST_NAME=`echo $FULL_NAME|awk -F\. '{print $2}'`
					if [ -f $SVN_DIR/$PLAT_NAME/$FULL_NAME ] || [ -d $SVN_DIR/$PLAT_NAME/$FULL_NAME ];then
		                                echo %%% svn log $SVN_URL/$PLAT_NAME/$FULL_NAME
                                		VERSION_NUM=`svn log $SVN_URL/$PLAT_NAME/$FULL_NAME $SVN_UP|grep ^r|awk '{print $1}'|sed 's/^r//g'|sort -nr|head -1`
						if [ ! -z $VERSION_NUM ] && [ ! -z $LAST_NAME ];then
                	                		echo "$FULL_PATH_NAME $PLATFORM_PATH/$FIRST_NAME.$VERSION_NUM.$LAST_NAME"   >> $LOGFILE
                                			mv $FULL_PATH_NAME $PLATFORM_PATH/$FIRST_NAME.$VERSION_NUM.$LAST_NAME
                                			sed  -i "/<version key=\"$LABEL_TAG\" value=\"[0-9.]*\"\/>/s/\(<version key=\"$LABEL_TAG\" value=\"\)\([0-9.]*\)\(\"\/>\)/\1$VERSION_NUM\3/" $PLATFORM_PATH/config.version/version.xml
						else
							echo "ERROR_SEVERE. NO version of SVN log $SVN_URL/$PLAT_NAME/$FULL_NAME" >>$LOGFILE
                                        		echo "ERROR_SEVERE. or No $FULL_NAME" >>$LOGFILE
						fi
					elif [ -f $PLATFORM_PATH/$FULL_NAME ] || [ -d $PLATFORM_PATH/$FULL_NAME ];then
						echo svn log $SVN_URL/$FULL_NAME
						VERSION_NUM=`svn log $SVN_URL/$FULL_NAME $SVN_UP|grep ^r|awk '{print $1}'|sed 's/^r//g'|sort -nr|head -1`
						if [ ! -z $VERSION_NUM ] && [ ! -z $LAST_NAME ];then
                	                		echo "$FULL_PATH_NAME $PLATFORM_PATH/$FIRST_NAME.$VERSION_NUM.$LAST_NAME"   >> $LOGFILE
                                			mv $FULL_PATH_NAME $PLATFORM_PATH/$FIRST_NAME.$VERSION_NUM.$LAST_NAME
                                			sed  -i "/<version key=\"$LABEL_TAG\" value=\"[0-9.]*\"\/>/s/\(<version key=\"$LABEL_TAG\" value=\"\)\([0-9.]*\)\(\"\/>\)/\1$VERSION_NUM\3/" $PLATFORM_PATH/config.version/version.xml
						else
                                        		echo "ERROR_SEVERE. NO version of SVN log $SVN_URL/$FULL_NAME" >>$LOGFILE
                                        		echo "ERROR_SEVERE. or NO $FULL_NAME" >>$LOGFILE
						fi
					else
						echo "ERROR_SEVERE. NO $PLATFORM_PATH/$FULL_NAME" >>$LOGFILE
					fi
				fi
			fi
        	done<$NOWPATH/tmp/resoucre
	fi
}


function zlib()
{
        PLAT_NAME=$1
	###########生成后端使用config文件##########
	if [ -d $OUTPUT_DIR/config_$PLAT_NAME ];then
		rm -rf $OUTPUT_DIR/config_$PLAT_NAME
	fi
	
        if [ $PLAT_NAME = "elex" ];then
                if [ -d $OUTPUT_DIR/$PLAT_NAME/language ];then
                        rm -rf $OUTPUT_DIR/$PLAT_NAME/language
                fi
	fi


	if [ ! -f $ZLIBFUN ];then
		echo "ERROR_SEVERE. NO $ZLIBFUN,Please check!!!" >>$LOGFILE
		cat $LOGFILE|grep ERROR_SEVERE|mail -s "SVN ERR. $PLAT_NAME there are some errors when producing" cloudacc@163.com
		exit 107;
	fi
	if [ -d $OUTPUT_DIR/$PLAT_NAME ];then
        	find $OUTPUT_DIR/$PLAT_NAME/ -name *.xml >$NOWPATH/tmp/listxml.txt
        	find $OUTPUT_DIR/$PLAT_NAME/ -name *.json >$NOWPATH/tmp/listjson.txt
	fi
        mkdir $NOWPATH/tmp/$PLAT_NAME -p
        >$NOWPATH/tmp/needtozlib.txt

        while read line
        do
                echo $line|sed 's/\(.*\).xml/\1.xml \1.dfdt/g' >>$NOWPATH/tmp/needtozlib.txt
        done<$NOWPATH/tmp/listxml.txt

        >$NOWPATH/tmp/needtozlibjson.txt
        while read line
        do
                echo $line|sed 's/\(.*\).json/\1.json \1.dfdt/g' >>$NOWPATH/tmp/needtozlibjson.txt
        done<$NOWPATH/tmp/listjson.txt

        while read line
        do
                python $ZLIBFUN $line
        done<$NOWPATH/tmp/needtozlib.txt

        while read line
        do
                python $ZLIBFUN $line
        done<$NOWPATH/tmp/needtozlibjson.txt

	find $OUTPUT_DIR/$PLAT_NAME/ -name ".svn" >>$LOGFILE
	find $OUTPUT_DIR/$PLAT_NAME/ -name ".svn"|xargs rm -rf

	cp -r $OUTPUT_DIR/$PLAT_NAME/config.version $OUTPUT_DIR/config_$PLAT_NAME
        
	while read line
        do
                OLDFILE=`echo $line|awk '{print $1}'`
                NEWFILE=`echo $line|awk '{print $2}'`
                if [ -f $NEWFILE ] && [ -f $OLDFILE ];then
			echo "rm $OLDFILE" >>$LOGFILE
                	mv $OLDFILE $NOWPATH/tmp/$PLAT_NAME/
		else
			echo "ERROR_SEVERE. NO  $NEWFILE ,please check!!!" >>$LOGFILE
			cat $LOGFILE|grep ERROR_SEVERE|mail -s "SVN ERR. $PLAT_NAME NO $NEWFILE" cloudacc@163.com
			exit 108;
                fi
        done<$NOWPATH/tmp/needtozlib.txt

	if [ $PLAT_NAME = "elex" ];then
		if [ -d $OUTPUT_DIR/$PLAT_NAME/language ];then
			rm -rf $OUTPUT_DIR/$PLAT_NAME/language
		fi
		mkdir $OUTPUT_DIR/$PLAT_NAME/language -p
		        while read line
		        do
                		cp $line $OUTPUT_DIR/$PLAT_NAME/language/
        		done<$NOWPATH/tmp/listjson.txt
	fi

}

function xmlline_count()
{
	cat $OUTPUT_DIR/$1/config.version/$2|grep key|wc -l
}


function main_program()
{
	PLAT_NAME=$1
	exec_platform $PLAT_NAME

	XMLIST="animVersion.xml chaVersion.xml mapVersion.xml weaponVersion.xml version.xml adornmentVersion.xml boxWeaponVersion.xml skyboxVersion.xml"
	SUM=0
	for xmlnm in $XMLIST
	do
		xmlnum=`xmlline_count $PLAT_NAME $xmlnm`
		SUM=`expr $SUM + $xmlnum`
	done 
	echo $SUM 
	justnamexml $PLAT_NAME animVersion.xml assets/animation
	justnamexml $PLAT_NAME chaVersion.xml assets/character
	justnamexml $PLAT_NAME mapVersion.xml assets/map
	justnamexml $PLAT_NAME weaponVersion.xml  assets/weapon
	justnamexml $PLAT_NAME adornmentVersion.xml  assets/adornment
	justnamexml $PLAT_NAME boxWeaponVersion.xml  assets/boxweapon
	justnamexml $PLAT_NAME skyboxVersion.xml  assets/skybox
	altersvnversion $PLAT_NAME
	err_num=`cat $LOGFILE|grep ERROR_SEVERE|wc -l`
	echo $err_num
	
	log_num=`cat $LOGFILE|wc -l`
	echo $log_num
	if [ $err_num != 0 ];then
		echo "There are same error when producing !!! " 
		cat $LOGFILE|grep ERROR_SEVERE
		cat $LOGFILE|grep ERROR_SEVERE|mail -s "SVN ERR. $PLAT_NAME there are some errors when producing" cloudacc@163.com
		exit 110;
	elif [ $log_num != $SUM ];then
		echo "xml number is not the same as alter number !!!"
		cat $LOGFILE|grep ERROR_SEVERE
		cat $LOGFILE|grep ERROR_SEVERE|mail -s "SVN ERR. $PLAT_NAME xml number is not the same as alter number" cloudacc@163.com
		exit 111;
	else
		zlib $PLAT_NAME
	fi
}



############start from here ############
cd $NOWPATH
echo "svn co https://svn.lieyan.com.cn/repos/ppweb/webp2p/flashp2p/DarkForrest/op $SVN_UP >$NOWPATH/tmp/svn-version"
svn co https://svn.lieyan.com.cn/repos/ppweb/webp2p/flashp2p/DarkForrest/op $SVN_UP >$NOWPATH/tmp/svn-version

if [ ! -d $SVN_DIR ];then
	echo "ERROR_SEVERE. NO $SVN_DIR directory,Please check first!!!" >> $LOGFILE
	cat $LOGFILE|grep ERROR_SEVERE|mail -s "SVN ERR. $PLAT_NAME NO $SVN_DIR directory" cloudacc@163.com
	exit 101;
fi
if [ ! -d $NOWPATH/log ];then
	mkdir -p $NOWPATH/log
fi
if [ ! -d $NOWPATH/tmp ];then
        mkdir -p $$NOWPATH/tmp
fi
if [ ! -d $OUTPUT_DIR ];then
        mkdir -p /opt/svnwork/res
fi

cd $OUTPUT_DIR
if [[ $# != 1 ]];then
        echo " Warning info:"
        echo " Please enter platform info aflter this script."
        echo " such as 'bash main.sh 4399',now this script   "
        echo " only support platform as: 4399 7k7k duowan    "
        echo " dongwang 2144 fengyunzhibo and elex"
        echo " if want to add new platform please edit script first"
	echo "no platform to exec,please check"|mail -s "SVN ERR. no platfrom to produce" cloudacc@163.com
	exit 10;
else
	PLATFORM=$1
	if [[ $PLATFORM != "4399" && $PLATFORM != "7k7k" && $PLATFORM != "russia" && $PLATFORM != "2144" && $PLATFORM != "fengyunzhibo" && $PLATFORM != "dongwang" && $PLATFORM != "elex" && $PLATFORM != "bilibili" && $PLATFORM != "elex_pt_br" && $PLATFORM != "elex_en" && $PLATFORM != "vietnam" && $PLATFORM != "indonesia" && $PLATFORM != "elex_th" && $PLATFORM != "elex_tr" && $PLATFORM != "elex_sp" && $PLATFORM != "temp" ]] ;then
		echo "Warning info:"
		echo "This script only support platform: 4399 7k7k 2144 fengyunzhibo duowan dongwang elex"
		echo "This script only support platform: 4399 7k7k 2144 fengyunzhibo duowan dongwang elex"|mail -s "SVN ERR. no $1 platfrom" cloudacc@163.com
		exit 11;
	fi
fi
main_program $PLATFORM
