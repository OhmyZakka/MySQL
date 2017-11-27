#!/usr/bin/env bash
#set -x
#:***********************************************
#:Program: MariaDB Openstack User privilege Initialize the script
#:
#:Author: ohmyzakka@gmail.com
#:
#:History: 2017-11-27
#:
#:Version: 1.0
#:***********************************************

#Please first configure the root account password and grant ip_net

user=''
passwd=''
port=''
allow_ip_net=''
nova_user_pass=''
keystone_user_pass=''
cinder_user_pass=''
glance_user_pass=''
neutron_user_pass=''
sstuser_user_pass=''
admin_user_pass=''
bkpuser_user_pass=''
clustercheckuser_user_pass=''

/usr/local/mysql/bin/mysql -P$port -u$user -p$passwd -e "

flush privileges;
#nova
drop user if exists nova@'localhost';
grant select, insert, update, delete on nova.* to 'nova'@'localhost' identified by \"$nova_user_pass\";
grant select, insert, update, delete on nova_api.* to 'nova'@'localhost';
grant select, insert, update, delete on nova_cell0.* to 'nova'@'localhost';

drop user if exists nova@'%';
grant select, insert, update, delete on nova.* to 'nova'@\"$allow_ip_net\" identified by \"$nova_user_pass\";
grant select, insert, update, delete on nova_api.* to 'nova'@\"$allow_ip_net\";
grant select, insert, update, delete on nova_cell0.* to 'nova'@\"$allow_ip_net\";

#keystone
drop user if exists keystone@'localhost';
grant select, insert, update, delete on keystone.* to 'keystone'@'localhost' identified by \"$keystone_user_pass\";
drop user if exists keystone@'%';
grant select, insert, update, delete on keystone.* to 'keystone'@\"$allow_ip_net\" identified by \"$keystone_user_pass\";

#cinder
drop user if exists cinder@'localhost';
grant select, insert, update, delete on cinder.* to 'cinder'@'localhost' identified by \"$cinder_user_pass\";
drop user if exists cinder@'%';
grant select, insert, update, delete on cinder.* to 'cinder'@\"$allow_ip_net\" identified by \"$cinder_user_pass\";

#glance
drop user if exists glance@'localhost';
grant select, insert, update, delete on glance.* to 'glance'@'localhost' identified by \"$glance_user_pass\";
drop user if exists glance@'%';
grant select, insert, update, delete on glance.* to 'glance'@\"$allow_ip_net\" identified by \"$glance_user_pass\";

#neutron
drop user if exists neutron@'localhost';
grant select, insert, update, delete on neutron.* to 'neutron'@'localhost' identified by \"$neutron_user_pass\";
drop user if exists neutron@'%';
grant select, insert, update, delete on neutron.* to 'neutron'@\"$allow_ip_net\" identified by \"$neutron_user_pass\";

#sstuser
drop user if exists sstuser@'localhost';
grant reload,lock tables,process,replication client on *.* to 'sstuser'@'localhost' identified by \"$sstuser_user_pass\";

#bkpuser
drop user if exists bkpuser@'localhost';
grant reload,lock tables,process,replication client on *.* to 'bkpuser'@'localhost' identified by \"$bkpuser_user_pass\";

#admin
drop user if exists admin@'localhost';
grant create,drop,alter,insert,select,update,delete,index,create view,show view,alter routine,create routine,execute,lock tables,create user,process,reload,replication client,replication slave,show databases,shutdown,super on *.* to 'admin'@'localhost' identified by \"$admin_user_pass\";

#clustercheckuser
drop user if exists clustercheckuser@'localhost';
grant process on *.* to 'clustercheckuser'@'localhost' identified by \"$clustercheckuser_user_pass\";
