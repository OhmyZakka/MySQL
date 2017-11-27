
###
 - step1 : install package yum -y install perl-version perl-Class-Data-Inheritable perl-Module-Build
 - step2 : cp orzdba /usr/bin/orzdba
 - step3 : tar zxvf orzdba_rt_depend_perl_module.tar.gz && tar zxvf version-0.99.tar.gz && install version
 - step4 : download tcprstat && cp tcprstat /usr/bin/tcprstat

 - ./orzdba -lazy -S /tmp/mysql_3306.sock -i 1
 - ./orzdba -innodb -S /tmp/mysql_3306.sock -i 1
 - ./orzdba -innodb_rows -S /tmp/mysql_3306.sock -i 1
 - ./orzdba -n eth0 -S /tmp/mysql_3306.sock -i 1
 - ./orzdba -n sys -S /tmp/mysql_3306.sock -i 1 
