#!/bin/bash

echo "The repeat loop begin@"`date`

##repeat test after sleep x senconds
echo "Sleep begin@"`date`
sleep 1000;
echo "Sleep end@"`date`

echo "The repeat loop begin@"`date`

for i in $( seq 1 3 ) ;do

./oltp.read.write.8to2048threads.run.1000w.sh

echo "The LOOP RUN"$i" is over..." 
date;
sleep 30;
done


echo "change to my.cnf as defual setting@"`date`

mv /etc/my.cnf /etc/my.cnf.baktmp
cp /etc/my.cnf.bak /etc/my.cnf

echo "################################################################################"
echo "The defualt setting of repeat loop begin@"`date`

for j in $( seq 1 3 ) ;do

./oltp.read.write.8to2048threads.run.1000w.sh

echo "The LOOP RUN"$j" is over..."
date;
sleep 30;
done

