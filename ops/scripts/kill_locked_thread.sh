#!/bin/bash
mysql -u root -proot -e "show processlist" | grep -i "Locked" >> locked_log.txt

for line in `cat locked_log.txt | awk '{print $1}'`
do 
echo "kill $line;" >> kill_thread_id.sql
done
