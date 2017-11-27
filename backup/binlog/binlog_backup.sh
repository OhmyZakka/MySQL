#!/bin/sh
REMOTE_HOSTNAME=
REMOTE_HOSTIP=xxx.xxx.xxx.xxx
BACKUP_BIN=/usr/local/mysql/bin/mysqlbinlog
BASEDIR=/data/
LOCAL_BACKUP_DIR=$BASEDIR/backup/binlog/$REMOTE_HOSTNAME/
BACKUP_LOG=$BASEDIR/backup/binlog/$REMOTE_HOSTNAME/backuplog
REMOTE_PORT=18913
REMOTE_USER=repl
REMOTE_PASS=repl
FIRST_BINLOG=mysql-bin.000001

#time to wait before reconnecting after failure
SLEEP_SECONDS=10

##create local_backup_dir if necessary
mkdir -p ${LOCAL_BACKUP_DIR}
cd ${LOCAL_BACKUP_DIR}

## run while loop, Wait for a specified time to reconnect when the connection is broken
while :
do
  if [ `ls -A "${LOCAL_BACKUP_DIR}" |wc -l` -eq 0 ];then
     LAST_FILE=${FIRST_BINLOG}
  else
     LAST_FILE=`ls -l ${LOCAL_BACKUP_DIR} | grep -v backuplog |tail -n 1 |awk '{print $9}'`
  fi
  ${BACKUP_BIN} --raw --read-from-remote-server --stop-never --host=${REMOTE_HOSTIP} --port=${REMOTE_PORT} --user=${REMOTE_USER} --password=${REMOTE_PASS} ${LAST_FILE}

  echo "`date +"%Y/%m/%d %H:%M:%S"` mysqlbinlog stop ，return code：$?" | tee -a ${BACKUP_LOG}
  echo "${SLEEP_SECONDS} seconds after connect again and continue to backup" | tee -a ${BACKUP_LOG}  
  sleep ${SLEEP_SECONDS}
done
