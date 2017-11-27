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
rollback_ip_net='%'

#: drop_exist_ip_net is Re-init allow_ip_net
drop_exist_ip_net=''

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
grant all privileges on nova.* to 'nova'@'localhost' identified by \"$nova_user_pass\";
grant all privileges on nova_api.* to 'nova'@'localhost';
grant all privileges on nova_cell0.* to 'nova'@'localhost';

drop user if exists nova@\"$drop_exist_ip_net\";
grant all privileges on nova.* to 'nova'@\"$rollback_ip_net\" identified by \"$nova_user_pass\";
grant all privileges on nova_api.* to 'nova'@\"$rollback_ip_net\";
grant all privileges on nova_cell0.* to 'nova'@\"$rollback_ip_net\";

#keystone
drop user if exists keystone@'localhost';
grant all privileges on keystone.* to 'keystone'@'localhost' identified by \"$keystone_user_pass\";
drop user if exists keystone@\"$drop_exist_ip_net\";
grant all privileges on keystone.* to 'keystone'@\"$rollback_ip_net\" identified by \"$keystone_user_pass\";

#cinder
drop user if exists cinder@'localhost';
grant all privileges on cinder.* to 'cinder'@'localhost' identified by \"$cinder_user_pass\";
drop user if exists cinder@\"$drop_exist_ip_net\";
grant all privileges on cinder.* to 'cinder'@\"$rollback_ip_net\" identified by \"$cinder_user_pass\";

#glance
drop user if exists glance@'localhost';
grant all privileges on glance.* to 'glance'@'localhost' identified by \"$glance_user_pass\";
drop user if exists glance@\"$drop_exist_ip_net\";
grant all privileges on glance.* to 'glance'@\"$rollback_ip_net\" identified by \"$glance_user_pass\";

#neutron
drop user if exists neutron@'localhost';
grant all privileges on neutron.* to 'neutron'@'localhost' identified by \"$neutron_user_pass\";
drop user if exists neutron@\"$drop_exist_ip_net\";
grant all privileges on neutron.* to 'neutron'@\"$rollback_ip_net\" identified by \"$neutron_user_pass\";
