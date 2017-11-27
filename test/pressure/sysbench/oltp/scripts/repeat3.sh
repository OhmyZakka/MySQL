#!/bin/bash

echo "The repeat loop begin@"`date`

##repeat test after sleep x senconds
#echo "Sleep begin@"`date`
#sleep 100;
#echo "Sleep end@"`date`

echo "The repeat loop begin@"`date`

for i in $( seq 1 3 ) ;do

./oltp.read.write.8to2048threads.run.1000w.sh

echo "The LOOP RUN"$i" is over..." 
date;
sleep 120;
ps -ef | grep mysql

done
