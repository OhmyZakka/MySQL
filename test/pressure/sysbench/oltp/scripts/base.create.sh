##Create Database 
pass=Ysyhl9t

mysql -uroot -p$pass -e "CREATE DATABASE sysbench;"

##Create User
mysql -uroot -p$pass -e "CREATE USER 'sysbench'@'localhost' IDENTIFIED BY 'sysbench';"

##Grant Access 
mysql -uroot -p$pass -e "GRANT ALL PRIVILEGES ON *.* TO 'sysbench'@'localhost' IDENTIFIED  BY 'sysbench';
flush privileges;
exit
"
