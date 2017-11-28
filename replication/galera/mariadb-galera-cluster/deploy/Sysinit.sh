#!/bin/bash
#Description Set kernel parameters for Mysql_pre;
#notice: This script is suit for CentOS7.
#Date 02/05/2017 2nd release
#Author Jamie Sun

echo "=====stop iptables;selinux====="
/etc/init.d/iptables stop
sed -i 's/SELINUX.*$/SELINUX=disabled/g'  /etc/selinux/config

echo "=======set IO Scheduler,noop======"
echo noop > /sys/block/sda/queue/scheduler

echo "================set gemfire file describle=========="
grep "mysql hard nofile" $sec_limitfile
if [ $? -eq 0 ]
then
	sed -i "s/gemfire hard.*$/gemfire hard nofile 65535/g"
else
	echo "gemfire hard nofile 65535" >> $sec_limitfile
fi

grep "gemfire soft nofile" $sec_limitfile
if [ $? -eq 0 ]
then
        sed -i "s/gemfire soft nofile.*$/gemfire soft nofile 65535/g"
else 
	echo "gemfire soft nofile 65535" >> $sec_limitfile
	
fi

grep "gemfire hard nproc" $sec_limitfile
if [ $? -eq 0 ]
then
        sed -i "s/gemfire hard nproc.*$/gemfire hard nproc 65535/g"
else
        echo "gemfire hard nproc 65535" >> $sec_limitfile
  
fi
	
grep "gemfire soft nproc" $sec_limitfile
if [ $? -eq 0 ]
then
        sed -i "s/gemfire soft nproc.*$/gemfire soft nproc 65535/g"
else
        echo "gemfire soft nproc 65535" >> $sec_limitfile

fi

#echo "BINDIP="`hostname -i`";export BINDIP" >> .bashrc

echo "===============set file describle================="
grep "ulimit -u" $sec_limitfile
if [ $? -eq 0 ]
then
        sed -i "s/ulimit -u.*$/ulimit -u 65535/g"
else
        echo "ulimit -u 65535" >> /root/.bashrc 

fi

grep "ulimit -n" $sec_limitfile
if [ $? -eq 0 ]
then
        sed -i "s/ulimit -n.*$/ulimit -n 65535/g"
else
        echo "ulimit -n 65535" >> /root/.bashrc

fi

echo "=========reload /etc/sysctl.conf=============="
/sbin/sysctl -p
echo "`hostname` is done"
