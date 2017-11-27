#!/bin/bash

sysbench --test=/root/sysbench-0.5/sysbench/tests/db/oltp.lua --db-driver=mysql --oltp-table-size=5000000 --mysql-db=sysbench --mysql-user=sysbench --mysql-password=sysbench prepare
