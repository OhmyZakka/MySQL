#!/bin/bash
DBIP=""
DBPORT=""
DBNAME="tpcc2000"
DBUSER=""
DBPASS=""
WIREHOUSE=2000
WARMUP=180
DURUNING=3600

for THREADS in 8 16 32 64 128 256 512
do 
    NOW=`date +'%Y%m%d%H%M'`
    ./tpcc_start -h $DBIP -P $DBPORT -d $DBNAME -u $DBUSER -p"${DBPASS}" -w $WIREHOUSE -c $THREADS -r $WARMUP -l $DURUNING -f ./logs/tpcc_${NOW}_${THREADS}_THREADS.res >>./logs/tpcc_runlog_${NOW}_${THREADS}_THREADS 2>&1
    sleep 60
    #mysql -h $DBIP -P $DBPORT -u $DBUSER -p ${DBPASS} -e "set global innodb_max_dirty_pages_pct=0;set global innodb_max_dirty_pages_pct=90;"
    #ssh $DBIP mysqladmin -S /tmp/mysql.socket shutdown;/usr/local/mysql/bin/start.sh 
    sleep 60
done
