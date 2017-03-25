echo "start full_backup at" `date +%Y-%m-%d` >> /home/ycone/gamex/backuplog.txt
backup_dir='/home/ycone/backup/'`date +%Y-%m-%d`
sudo xtrabackup --innodb_log_file_size=536870912 --backup --target-dir=$backup_dir -datadir=/data/mysql

