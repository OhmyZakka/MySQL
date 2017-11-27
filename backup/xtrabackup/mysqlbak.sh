#!/bin/bash
#mysql backup script demo
#author Jamie Sun
#contact ohmyzakka@gmail.com

#config evn
export PATH=/usr/local/mysql/bin:$PATH

BAKUSER=bakdb
BAKPASSWD=bakpass
BAKCNF=/etc/my.cnf
OBJECK_NAME=openstack
BAKDIR=/backup/$OBJECT_NAME/data
LOGDIR=/backup/$OBJECT_NAME/log
CURRENTDATE=`date '+%Y%m%d'`
FULLBAKDIR=$BAKDIR/$CURRENTDATE
INCREMENTDIR=$BAKDIR/`date '+%Y%m%d%H%M%S'`


#rm old file
rmoldbak()
{
        find $BAKDIR -mtime +6|xargs rm -rf
}

#compress last day backup file
compressbak()
{
        LASTDT=`date -d last-day +%Y%m%d`
        cd $BAKDIR
        tar -zcf dbbak_$LASTDT.tgz $LASTDT*
        rm -rf $LASTDT*
}

#backup db function
fullbakdb ()
{
        innobackupex   --defaults-file=$BAKCNF --user=$BAKUSER --password=$BAKPASSWD --parallel=2 --throttle=50 --slave-info --no-timestamp $FULLBAKDIR  >> $LOGDIR/bak.log.$CURRENTDATE 2>&1
}

incrementbakdb()
{
        innobackupex   --defaults-file=$BAKCNF --user=$BAKUSER --password=$BAKPASSWD --parallel=2 --throttle=50 --slave-info --no-timestamp --incremental --incremental-basedir=$FULLBAKDIR $INCREMENTDIR >> $LOGDIR/bak.log.$CURRENTDATE 2>&1
} 

#copy to remote server
cptoremote()
{
        #cp a b or scp a to b or rsync a to b
        echo "cp $1 to remote"
}

#backup action
if [ "`date +%s`" -lt $((`date -d $CURRENTDATE +%s` + 7200)) ];then
        rmoldbak
        compressbak
        fullbakdb
        cptoremote $FULLBAKDIR
else
        incrementbakdb
        cptoremote $INCREMENTDIR
fi

