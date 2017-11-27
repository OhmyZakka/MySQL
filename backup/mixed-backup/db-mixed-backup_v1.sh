#!/bin/bash
#mysql backup script demo
#author Jamie Sun
#contact ohmyzakka@gmail.com
#!/bin/bash
#mysql backup script demo
#author Jamie Sun
#contact ohmyzakka@gmail.com

#config evn
export PATH=/usr/local/mysql/bin:$PATH

HOST=localhost
PORT=3306
BAKUSER=root
BAKPASSWD=password
BAKCNF=/etc/my.cnf
OBJECK_NAME=openstack_demo
XTRA_BAKDIR=/backup/xtrabackup/xtradata
XTRA_LOGDIR=/backup/xtrabackup/xtralog
DUMP_BAKDIR=/backup/mysqldump/dumpdata
DUMP_LOGDIR=/backup/mysqldump/dumplog
CURRENTDATE=`date '+%Y%m%d'`
CURRENTTIME=`date '+%Y%m%d%H%M%S'`
FULLXTRA_BAKDIR=$XTRA_BAKDIR/$CURRENTDATE
INCREMENTDIR=$XTRA_BAKDIR/$CURRENTTIME
INCREMENT_BASE=`grep -E "full backup" $XTRA_LOGDIR/backup_history.log |tail -1 |awk -F ' ' '{print $5}'`
INCREMENT_BASEDIR=$XTRA_BAKDIR/$INCREMENT_BASE
MYSQLCMD="/usr/local/mysql/bin/mysql -S /tmp/mysql.sock -u$BAKUSER -p$BAKPASSWD"
MYSQLDUMPCMD="/usr/local/mysql/bin/mysqldump -S /tmp/mysql.sock -u$BAKUSER -p$BAKPASSWD"

#backup work dir
workpath()
{
if [ ! -d $XTRA_BAKDIR ]; then
	mkdir -p $XTRA_BAKDIR
fi

if [ ! -d $XTRA_LOGDIR ]; then
	mkdir -p $XTRA_LOGDIR 
fi

if [ ! -d $DUMP_BAKDIR ]; then
	mkdir -p $DUMP_BAKDIR
fi

if [ ! -d $DUMP_LOGDIR ]; then
	mkdir -p $DUMP_LOGDIR
fi

if [ ! -d $CURRENTDATE ];then
        mkdir -p $DUMP_BAKDIR/$CURRENTDATE
fi
if [ ! -d /var/remotebak/binlog/$CURRENTDATE ];then
        mkdir -p /var/remotebak/binlog/$CURRENTDATE
fi

}

#rm old file
rmoldbak()
{
        find $XTRA_BAKDIR -mtime +7 |xargs rm -rf
}

#compress last day backup file
compressbak()
{
        LASTDT=`date -d last-day +%Y%m%d`
        cd $XTRA_BAKDIR
        tar -zcf xtrabak_$LASTDT.tar.gz $LASTDT*
#        rm -rf $LASTDT*
}

rmolddump()
{
        find $DUMP_BAKDIR -mtime +7 |xargs rm -rf
}

#compress last day backup file
compressdump()
{
        LASTDT=`date -d last-day +%Y%m%d`
        cd $DUMP_BAKDIR
        tar -zcf dbbak_$LASTDT.tar.gz $LASTDT*
#       rm -rf $LASTDT*
}

#backup db function
dumpfulldb()
{
	$MYSQLDUMPCMD --all-databases --single-transaction --master-data=2 --triggers --routines --events   > $DUMP_BAKDIR/$CURRENTDATE/full_db.dmp
        cp /etc/my.cnf $DUMP_BAKDIR/$CURRENTDATE/$OBJECK_NAME.cnf
}

dumptabledb()
{
	$MYSQLCMD -e "show databases;"|grep -vE "(Database|_schema)" > $DUMP_BAKDIR/db_list
	while read DBNAME
	do

	if [ ! -d $DBNAME ];then 
		mkdir -p $DUMP_BAKDIR/$CURRENTDATE/$DBNAME
	fi

		$MYSQLCMD -e "use $DBNAME; show tables;" |grep -vE "(Tables_in|general_log|slow_log)" > $DUMP_BAKDIR/table_list
		#xmysql -e "flush tables with read lock;"

		while read TABLENAME
		do
			$MYSQLDUMPCMD --single-transaction --triggers --events --routines $DBNAME $TABLENAME  > $DUMP_BAKDIR/$CURRENTDATE/$DBNAME/$TABLENAME.sql

    		done < $DUMP_BAKDIR/table_list

	done < $DUMP_BAKDIR/db_list
	echo "logic full backup & Sechema backup on `date '+%Y%m%d %H:%M:%S'`" >> $DUMP_LOGDIR/backup_history.log 
	rm -rf $DUMP_BAKDIR/db_list
	rm -rf $DUMP_BAKDIR/table_list
}
binlogbak()
{
	
	mysqladmin -S /tmp/mysql.sock -u$BAKUSER -p$BAKPASSWD flush-logs && cp -rf /mariadb/galera/openstack_3306/logs/mysql-bin.[0-9]* /var/remotebak/binlog/$CURRENTDATE &
& echo "binlog backup on `date '+%Y%m%d %H:%M:%S'`"  >> /var/remotebak/binlog/binlog_history.log
}

fullbakdb()
{
        innobackupex  --defaults-file=$BAKCNF --user=$BAKUSER --password=$BAKPASSWD --parallel=2 --throttle=50 --slave-info --no-timestamp $FULLXTRA_BAKDIR  >> $XTRA_LOGDIR
/xtrabak_$CURRENTTIME.log 2>&1
}

incrementbakdb()
{
        innobackupex   --defaults-file=$BAKCNF --user=$BAKUSER --password=$BAKPASSWD --parallel=2 --throttle=50 --slave-info --no-timestamp --incremental --incremental-base
dir=$INCREMENT_BASEDIR $INCREMENTDIR >> $XTRA_LOGDIR/xtrabak_$CURRENTTIME.log 2>&1
} 

#copy to remote server
cptoremote()
{
        #cp a b or scp a to b or rsync a to b
        echo "cp $1 to /remote"
	cp -rp $1 $2 /var/remotebak
}

#backup action
case `date +%u` in
   1) echo  "physical full backup on `date '+%Y%m%d %H:%M:%S'`" >> $XTRA_LOGDIR/backup_history.log
	workpath
        rmoldbak
	rmolddump
	compressbak
	compressdump
        fullbakdb
	dumpfulldb
	dumptabledb
	binlogbak
        cptoremote $XTRA_BAKDIR $XTRA_LOGDIR
	cptoremote $DUMP_BAKDIR $DUMP_LOGDIR
	;;
   2) echo "physical increment backup on `date '+%Y%m%d %H:%M:%S'`" >> $XTRA_LOGDIR/backup_history.log
	workpath
        rmoldbak
	rmolddump
	compressbak
	compressdump
        incrementbakdb
	dumpfulldb
	dumptabledb
	binlogbak
        cptoremote $XTRA_BAKDIR $XTRA_LOGDIR
	cptoremote $DUMP_BAKDIR $DUMP_LOGDIR
	;;
   3) echo "physical increment backup on `date '+%Y%m%d %H:%M:%S'`" >> $XTRA_LOGDIR/backup_history.log
	workpath
        rmoldbak
	rmolddump
	compressbak
	compressdump
        incrementbakdb
	dumpfulldb
	dumptabledb
	binlogbak
        cptoremote $XTRA_BAKDIR $XTRA_LOGDIR
	cptoremote $DUMP_BAKDIR $DUMP_LOGDIR
	;;
   4) echo "physical full backup on `date '+%Y%m%d %H:%M:%S'`"  >> $XTRA_LOGDIR/backup_history.log
	workpath
        rmoldbak
        rmolddump
        compressbak
        compressdump
        fullbakdb
        dumpfulldb
        dumptabledb
        binlogbak
        cptoremote $XTRA_BAKDIR $XTRA_LOGDIR
        cptoremote $DUMP_BAKDIR $DUMP_LOGDIR
	;;
   5) echo "physical increment backup on `date '+%Y%m%d %H:%M:%S'`"  >> $XTRA_LOGDIR/backup_history.log
	workpath
        rmoldbak
        rmolddump
        compressbak
        compressdump
        incrementbakdb
        dumpfulldb
        dumptabledb
        binlogbak
        cptoremote $XTRA_BAKDIR $XTRA_LOGDIR
        cptoremote $DUMP_BAKDIR $DUMP_LOGDIR
	;;
   6) echo "physical increment backup on `date '+%Y%m%d %H:%M:%S'`" >> $XTRA_LOGDIR/backup_history.log
	workpath
        rmoldbak
        rmolddump
        compressbak
        compressdump
        incrementbakdb
        dumpfulldb
        dumptabledb
        binlogbak
        cptoremote $XTRA_BAKDIR $XTRA_LOGDIR
        cptoremote $DUMP_BAKDIR $DUMP_LOGDIR
	;;
   7) echo "physical full backup on `date '+%Y%m%d %H:%M:%S'`"  >> $XTRA_LOGDIR/backup_history.log
	workpath
        rmoldbak
        rmolddump
        compressbak
        compressdump
        fullbakdb
        dumpfulldb
        dumptabledb
        binlogbak
        cptoremote $XTRA_BAKDIR $XTRA_LOGDIR
        cptoremote $DUMP_BAKDIR $DUMP_LOGDIR
	;;
   *) echo "error on `date '+%Y%m%d %H:%M:%S'`" >> $XTRA_LOGDIR/backup_history.log
	;;
esac
