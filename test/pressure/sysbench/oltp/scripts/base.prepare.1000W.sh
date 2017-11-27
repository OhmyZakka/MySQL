#!/bin/bash

#sysbench --test=/root/sysbench-0.5/sysbench/tests/db/oltp.lua --db-driver=mysql --oltp-table-size=10000000 --mysql-db=sysbench1000w --mysql-user=sysbench --mysql-password=sysbench prepare

testmode=`find / -name oltp.lua | head -1`      # the template file of test mode

sysbench --test=$testmode --mysql-table-engine=innodb --oltp-table-size=10000000  --max-requests=0 --max-time=1800 --num-threads=16 --oltp-tables-count=10 --oltp-read-only=off --rand-type=uniform --report-interval=10 --mysql-socket=/data/mysql3306/mysql.sock --mysql-db=sysbench --mysql-user=sysbench  --mysql-password=sysbench prepare
