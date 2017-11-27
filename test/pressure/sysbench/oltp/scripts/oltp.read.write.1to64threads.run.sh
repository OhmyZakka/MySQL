#!/bin/bash

###############################################################################################################################################
# This script will run 6 tests, each lasting 4 minutes. It will run 1 through 64 threaded tests, which seem to be the most common tests to run.
# This test does selects, updates, and various other things and is considered to be a "read / write" MySQL mixed workload.
################################################################################################################################################

runtime=1800
logname=pt-run-${runtime}s-`date +%Y%m%d%H%M%S`.log
testmode=`find / -name oltp.lua | head -1`      # the template file of test mode
echo "                                                      "  > ./$logname

for thread in 1 4 8 16 32 64 ;do

echo "##########################################################################################################################################"  >> ./$logname
echo "Performing test for SQ-${thread}T-`date +%Y%m%d%H%M%S`"  >> ./$logname
sysbench --test=$testmode --db-driver=mysql --oltp-table-size=5000000 --mysql-db=sysbench --mysql-user=sysbench --mysql-password=sysbench --max-time=${runtime} --max-requests=0 --num-threads=${thread} run >> ./$logname

done
