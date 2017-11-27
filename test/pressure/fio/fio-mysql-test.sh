[global]
runtime=172800
time_based
group_reporting
directory=/data
ioscheduler=deadline
refill_buffers
 
[binlog]
filename=demo_name-mysql-bin.log
bsrange=512-1024
ioengine=sync
rw=write
size=30G
sync=1
rw=write
overwrite=1
fsync=100
rate_iops=64
invalidate=1
numjobs=64
 
[innodb-data]
filename=demo_name-innodb.dat
bs=16K
ioengine=psync
rw=randrw
size=200G
direct=1
rwmixread=80
numjobs=32
 
thinktime=600
thinktime_spin=200
thinktime_blocks=2
 
[innodb-log]
filename=demo_name-innodb.log
bs=512
ioengine=sync
rw=write
size=2G
fsync=1
overwrite=1
invalidate=1
numjobs=64

