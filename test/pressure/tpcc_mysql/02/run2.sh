./tpcc_load xxx.xxx.xxx.xxx:3306 tpcc100 admin admin 100 >> 1.out 
sleep 120
for i in `seq 1 3`; do ./run.sh;sleep 100; done
