###############################################################################################################################################
# This script will run one test for input thread x . It will run x threaded tests, which seem to be the most common tests to run.
# This test does selects, updates, and various other things and is considered to be a "read / write" MySQL mixed workload.
################################################################################################################################################

if [ $# -lt 1 ]
then thread=1024
else
thread=$1
fi

echo $thread

runtime=30                  # 1800
logname=pt-signal-thread{$thread}-${runtime}s-`date +%Y%m%d%H%M%S`.log
testmode=`find / -name oltp.lua | head -1`      # the template file of test mode
echo "                                                      "  > ./$logname

#for thread in 8 16 32 64 128 256 512 1024 2048 ;do

echo "##########################################################################################################################################"  >> ./$logname
echo "Performing test for SQ-${thread}T-`date +%Y%m%d%H%M%S`"  >> ./$logname
sysbench --test=$testmode --db-driver=mysql --oltp-table-size=10000000 --mysql-db=sysbench --mysql-user=sysbench --mysql-password=sysbench --mysql-localhost=localhost  --oltp-test-mode=complex --rand-type=uniform --max-time=${runtime} --max-requests=0 --num-threads=${thread} run >> ./$logname

sync                               #将脏数据刷新到磁盘
echo 3 > /proc/sys/vm/drop_caches  #清除OS Cache

echo "Restart the MySQL server..."
/etc/init.d/mysql5.7 restart

#date; sleep 60; date
#echo "loop into next RUN--->>> "  >> ./$logname

#done
