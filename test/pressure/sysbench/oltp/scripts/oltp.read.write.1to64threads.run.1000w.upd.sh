#!/bin/bash

###############################################################################################################################################
# This script will run 6 tests, each lasting 4 minutes. It will run 1 through 64 threaded tests, which seem to be the most common tests to run.
# This test does selects, updates, and various other things and is considered to be a "read / write" MySQL mixed workload.
################################################################################################################################################

runtime=1800
logname=pt-run-${runtime}s-`date +%Y%m%d%H%M%S`.log
testmode=`find / -name oltp.lua | head -1`      # the template file of test mode
echo "                                                      "  > ./$logname

for thread in 1024 2048 ;do

echo "##########################################################################################################################################"  >> ./$logname
echo "Performing test for SQ-${thread}T-`date +%Y%m%d%H%M%S`"  >> ./$logname
sysbench --test=$testmode --db-driver=mysql --oltp-table-size=10000000 --mysql-db=sysbench1000w --mysql-user=sysbench --mysql-password=sysbench  --oltp-test-mode=complex --rand-type=uniform --max-time=${runtime} --max-requests=0 --num-threads=${thread} run >> ./$logname

sync  #  将脏数据刷新到磁盘

/etc/init.d/mysqld restart

date; sleep 60; date 

echo "loop into next RUN--->>> "  >> ./$logname

done
