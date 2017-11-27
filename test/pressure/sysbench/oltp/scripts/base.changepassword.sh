##change root password 
pass=$1

mysql -uroot -p -e " set password=password('$pass');
flush privileges;
quit"
