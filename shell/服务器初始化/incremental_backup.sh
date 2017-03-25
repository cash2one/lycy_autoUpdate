echo "start incremental_backup at" `date +%Y-%m-%d` >> /home/ycone/gamex/backuplog.txt
backup_dir='/home/ycone/backup/'`date +%Y-%m-%d`
#yesterday
base_backup_dir='/home/ycone/backup/'`date --date="1 days ago" +%Y-%m-%d`

if [ -d $base_backup_dir ]; then
    sudo xtrabackup --innodb_log_file_size=536870912 --backup --target-dir=$backup_dir --incremental-basedir=$base_backup_dir -datadir=/data/mysql
else
    sh full_backup.sh
fi

