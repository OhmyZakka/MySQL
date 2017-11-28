#!/bin/bash

cat >> /etc/yum.repos.d/MariaDB.repo << EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB

yum install MariaDB-server MariaDB-client

systemctl start mariadb

echo >> /etc/my.cnf << EOF

EOF
systemctl start --wsrep-new-cluster
mysqld --wsrep-new-cluster
mysqld_safe --wsrep-new-cluster

mysql_secure_installation

systemctl start mariadb
