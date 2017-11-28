#!/bin/bash
#MariaDb Galera Cluster Install
#author Jamie Sun
#contact ohmyzakka@gmail.com




##install mariadb galera needed
object_name=openstack
dbport=3306
softdir=$work_path/software
xtra_file=/usr/bin/xtrabackup
work_path=/data
mysql_version=mariadb-10.1.21-linux-x86_64
mariadb_url=xxx.xxx.xxx.xxx/mariadb
cluster_address=xxx.xxx.xxx.xxx,xxx.xxx.xxx.xxx,xxx.xxx.xxx.xxx

#galera config
clustercheck_user=mycheckuser
clustercheck_pass=P@ssW0rd
mysql_dbpass=P@ssW0rd
node_ip=$1
my_hostname=`cat /etc/hostname`
serverid=`echo $node_ip | awk -F . '{ print $4}'`

# Environment Check
Env_Check()
{
# Check if user is root
echo "Checking..."
if [ $(id -u) != "0" ]; then
	echo "Error: you must be root to install,please use root install MySQL"
	exit 1
fi

#Disable Selinux
if [ -s /etc/selinux/config ]; then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi

if [ -s /usr/bin/socat ] && [ -s /usr/lib64/libcrypto.so.6 ]; then
	echo "packages is installed"
else
	yum -y install perl-DBD-MySQL socat libev openssl openssl-devel perl-IO-Socket-SSL openssl098e python2-PyMySQL wget libaio
fi

}

Env_Check;

#Installation of depend on and optimization options. 
Install_Opt() 
{ 
cp /etc/security/limits.conf /etc/security/limits.conf.bak-`date +%F`
cat >> /etc/security/limits.conf <<EOF 
* soft nproc 65535 
* hard nproc 65535 
* soft nofile 65535 
* hard nofile 65535 
EOF
echo "fs.file-max=65535" >> /etc/sysctl.conf 
} 

Install_Opt;

echo "================================================================================="
echo "    A tool to auto-compile & install MariaDB-10.1.21 on CentOS 7.2 For Linux     "
echo "================================================================================="

sleep 3  
  
#Added MySQL group and user
group()
{
cat /etc/group | grep mysql

if [ $? = 1 ]; then
	groupadd -g 1000 mysql
else
	echo "mysql group always exists"
fi 
}

group;

user()
{
if
	cat /etc/passwd |awk -F: '{print $1}' |grep mysql > /dev/null 2>&1
then
	echo "mysql user always exists"
else
	/usr/sbin/useradd -u 1000 -g mysql -s /sbin/nologin -d /home/mysql mysql
	echo "mysql user have been added for first to add"
fi

}

user;

#Install MySQL

work_path()
{
if [ ! -d $work_path/galera/${object_name}_${dbport}/data ]; then
	mkdir -p $work_path/galera/${object_name}_${dbport}/data
else
	echo "MySQL data dir already exists" 
fi


if [ ! -d $work_path/galera/${object_name}_${dbport}/logs ]; then
	mkdir -p $work_path/galera/${object_name}_${dbport}/logs
else
	echo "MySQL logs dir already exists" 
fi


if [ ! -d $work_path/galera/${object_name}_${dbport}/tmp ]; then
	mkdir -p $work_path/galera/${object_name}_${dbport}/tmp
else
	echo "MySQL tmp dir already exists" 
fi

chown -R mysql:mysql $work_path/galera/${object_name}_${dbport}
}

work_path; 

install_package()
{
if [ ! -d $softdir ];then
	mkdir -p $softdir
else
	echo "sotfware dir already exists"
fi
	wget -P $softdir $mariadb_url/${mysql_version}.tar.gz
	tar zxf $softdir/${mysql_version}.tar.gz -C /usr/local/
	chown -R root:root /usr/local/$mysql_version
	ln -s /usr/local/$mysql_version /usr/local/mysql
	cd /usr/local/mysql
	chown -R mysql:mysql *

if [ ! -f $xtra_file ];then
	wget -P $softdir $mariadb_url/percona-xtrabackup-2.4.4-Linux-x86_64.tar.gz
	tar zxf $softdir/percona-xtrabackup-2.4.4-Linux-x86_64.tar.gz -C $softdir
	cp -a $softdir/percona-xtrabackup-2.4.4-Linux-x86_64/bin/* /usr/bin
else
	echo "xtrabackup tool installed"
fi
}

install_package;

modify_params()
{
if [ -s /etc/my.cnf ]; then
	mv /etc/my.cnf /etc/my.cnf.bak-`date +%F.%T`
fi

cat >> /etc/my.cnf <<EOF
#Maria Galera Cluster Configure File
#my.cnf
#
[mysql]
prompt="\\u@\\h \\R:\\m:\\s [\\d]> "
#pager="less -i -n -S"
no-auto-rehash 
#tee=/home/mysql/query.log
#socket = /tmp/mysql.sock

[mysqld]
basedir = /usr/local/mysql
datadir = $work_path/galera/${object_name}_${dbport}/data
port = 3306
socket = /tmp/mysql.sock
pid_file = mysql.pid
skip_name_resolve = 1
max_allowed_packet = 32M
event_scheduler = 0
open_files_limit = 65535
back_log = 1024


#connections set
max_connections = 1000
max_connect_errors = 100000

#character set
character-set-server = utf8
collation-server = utf8_general_ci

#timeout
interactive_timeout = 1000
wait_timeout = 1000
net_read_timeout = 60
lock_wait_timeout = 300




#logs
log_output=file
slow_query_log = 1
slow_query_log_file = slow.log
log_error = error.log
log_warnings = 2
long_query_time = 1
log_slow_admin_statements = 0
log_queries_not_using_indexes = 0
log_slow_slave_statements = 0


#buffers & cache
sort_buffer_size = 16M
join_buffer_size = 16M
thread_cache_size = 768
thread_stack = 512K
key_buffer_size = 16M
read_buffer_size = 8M
read_rnd_buffer_size = 16M
bulk_insert_buffer_size = 64M
table_open_cache = 1024
table_definition_cache = 1024
tmp_table_size = 96M
max_heap_table_size = 96M

#binlog & replication
server_id = ${serverid}${dbport}
log-bin = $work_path/galera/${object_name}_${dbport}/logs/mysql-bin
binlog_cache_size = 4M
log-slave-updates  = 1
max_binlog_cache_size = 512M
max_binlog_size = 1G
relay-log-purge = 1
sync_binlog = 1
innodb-support-xa = 0
binlog_format = ROW
expire_logs_days = 7
slave_compressed_protocol = 1
slave_transaction_retries = 10
net_retry_count = 10
slave_net_timeout = 10
relay_log_recovery = 1

#thread pool
thread_handling = pool-of-threads


#innodb buffer pool
innodb_buffer_pool_size = 1G   
innodb_data_file_path = ibdata1:1G:autoextend
innodb_thread_concurrency = 20
innodb_flush_log_at_trx_commit = 0
innodb_log_buffer_size = 32M
innodb_log_file_size = 256M
innodb_log_files_in_group = 2
innodb_max_dirty_pages_pct = 50
innodb_file_per_table = 1
innodb_rollback_on_timeout = 1
transaction_isolation = READ-COMMITTED
innodb_buffer_pool_load_at_startup = 1
innodb_buffer_pool_dump_at_shutdown = 1
innodb_open_files = 65535
innodb_flush_method = O_DIRECT
innodb_file_format = Barracuda
innodb_file_format_max = Barracuda
innodb_undo_tablespaces = 2
#innodb_io_capacity = 4000
innodb_io_capacity_max = 8000
innodb_write_io_threads = 8
innodb_read_io_threads = 8
innodb_purge_threads = 4
innodb_sync_spin_loops = 100
innodb_spin_wait_delay = 30
innodb_lru_scan_depth = 4000
innodb_lock_wait_timeout = 10
innodb_print_all_deadlocks = 1
innodb_status_output = 1
innodb_status_output_locks = 1
innodb_stats_on_metadata = 0
innodb_autoinc_lock_mode = 2
innodb_locks_unsafe_for_binlog = 1
explicit_defaults_for_timestamp = 1

##Galera Cluster
wsrep_provider = /usr/local/mysql/lib/libgalera_smm.so
wsrep_cluster_address = "gcomm://$cluster_address"
wsrep_provider_options = "gcache.size=4G"
wsrep_cluster_name = $object_name
wsrep_sst_auth = sstuser:sstuser
wsrep_sst_method = xtrabackup-v2
#wsrep_sst_method = rsync
wsrep_node_address = $node_ip
wsrep_node_name = $my_hostname
wsrep_slave_threads = 4
wsrep_on= on
#innodb_flush_log_at_trx_commit = 0
innodb_autoinc_lock_mode = 2
#query_cache_size = 0


#performance_schema
performance_schema = 1

#innodb monitor
innodb_monitor_enable="module_innodb"
innodb_monitor_enable="module_server"
innodb_monitor_enable="module_dml"
innodb_monitor_enable="module_ddl"
innodb_monitor_enable="module_trx"
innodb_monitor_enable="module_os"
innodb_monitor_enable="module_purge"
innodb_monitor_enable="module_log"
innodb_monitor_enable="module_lock"
innodb_monitor_enable="module_buffer"
innodb_monitor_enable="module_index"
innodb_monitor_enable="module_ibuf_system"
innodb_monitor_enable="module_buffer_page"
innodb_monitor_enable="module_adaptive_hash"
EOF

chown mysql.mysql /etc/my.cnf
cp /etc/my.cnf $work_path/galera/${object_name}_${dbport}/$object_name.cnf
}

modify_params;

#Initialization MySQL  

init_db()
{
/usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=$work_path/galera/${object_name}_${dbport}/data --defaults-file=/etc/my.cnf --user=mysql 
if [ $? -eq "0" ]; then
	echo "=================== MariaDB 10.1.21 Initializaion completed ==================="
	sleep 3
else
	echo "Error: MariaDB Initialization failed,please Please initialized again"
	exit 1
fi
#cat >> /etc/init.d/galera_autoinstall << EOF


#EOF

#chmod 700 /etc/init.d/galera_autoinstall
#chkconfig --add galera_autoinstall
#chkconfig --level 2345 galera_autoinstall on 

cat >>/etc/profile <<EOF 
export PATH=$PATH:/usr/local/mysql/bin
export LD_LIBRARY_PATH=/usr/local/mysql/lib
EOF

source /etc/profile
}
init_db;

start_db()
{
if [ "$my_hostname" = "$1" ]
then
	/usr/local/mysql/bin/mysqld_safe --defaults-file=/etc/my.cnf --wsrep-new-cluster --user=mysql &
	echo bootstrap $my_hostname 2=$1 > /tmp/log
else
	/usr/local/mysql/bin/mysqld_safe --defaults-file=/etc/my.cnf --user=mysql&
	echo other $my_hostname 2=$1 > /tmp/log
fi
if [ $? -eq 0 ]; then
	echo "========================== MariaDB Server is started =========================="
	sleep 3
fi

}

start_db $2;

CheckInstall() 
{ 

ismysql=""
	echo "Checking..."
  
if [ -s /usr/local/mysql/bin/mysql ] && [ -s /usr/local/mysql/bin/mysqld_safe ] && [ -s /etc/my.cnf ]; then
	echo "MySQL: OK"
        ismysql="ok"
else
    	echo "Error: /usr/local/mysql not found!!! MySQL install failed."
fi
  
if [ "$ismysql" = "ok" ]; then
	echo "===================== MariaDB 10.1.21 completed! enjoy it. ===================="
	sleep 3
else
	echo "Sorry,Failed to install MySQL!"
	#echo "You cantail /root/mysql-install.log from your server."
fi
	echo "================== MariaDB Service is ok check finished ======================="
}

CheckInstall;


#Security Settings
[ "$my_hostname" = "$2" ] && 
{
cat >/tmp/mysql_sec_script<<EOF 
delete from mysql.user where user!='root' or host!='localhost'; 
drop database test;
truncate mysql.db;
grant all privileges on *.* to 'sstuser'@'%' identified by 'sstuser';
grant usage on *.* to 'sstuser'@'%' identified by 'sstuser';
grant process on *.* to '$clustercheck_user'@'localhost' identified by '$clustercheck_pass';
set password for root@'localhost'=password('$mysql_dbpass');
flush privileges; 
EOF

/usr/local/mysql/bin/mysql -uroot -S /tmp/mysql.sock < /tmp/mysql_sec_script
}
