## Inception
Inception是由去哪儿网的DBA大神开发的一款自动审核SQL的开源工具。Inception是集审核、执行、回滚于一体的一个自动化运维系统，它可以对提交的所有语句的语法分析，如果语法有问题，都会将相应的错误信息返回给审核者。
Inception还提供SQL语句的执行功能，可执行的语句类型包括常用的DML及DDL语句及truncate table等操作。Inception在执行 DML时还提供生成回滚语句的功能，对应的操作记录及回滚语句会被存储在备份机器上面，备份机器通过配置Inception参数来指定。

[官方文档地址]：(/http://mysql-inception.github.io/inception-document/)    
[源码下载地址]：(https://github.com/mysql-inception/inception.git)

### 规划：
node1：192.168.0.127  安装inception服务、安装mysql数据库（充当线上mysql服务器）
node2：192.168.0.128  安装mysql服务器（用于inception备份数据库，用于数据备分和回滚）

### 安装说明
一、下载源码包    
`$ git clone https://github.com/mysql-inception/inception.git`

二、安装编译时所依赖的包    
`$ yum install cmake bison  ncurses-devel gcc gcc-c++  openssl-devel`

创建Inception的安装目录    
`$ mkdir -p /usr/local/incepition   #创建的是Inception的安装目录`    

三、编译安装

1.自动编译安装
在执行编译脚本前需要修改脚本中的

`$ inception_build.sh debug [Xcode]`

2.手动编译安装

```cmake -DWITH_DEBUG=OFF \
-DCMAKE_INSTALL_PREFIX=/usr/local/inception \ 
-DMYSQL_DATADIR=/data/inception \ 
-DWITH_SSL=yes \ 
-DCMAKE_BUILD_TYPE=RELEASE-DWITH_ZLIB=bundled-DMY_MAINTAINER_CXX_WARNINGS="-Wall -Wextra -Wunused -Wwrite-strings -Wno-strict-aliasing -Wno-unused-parameter 
-Woverloaded-virtual" \
-DMY_MAINTAINER_C_WARNINGS="-Wall -Wextra -Wunused -Wwrite-strings -Wno-strict-aliasing -Wdeclaration-after-statement"
```

3.Inception 配置文件
`$ cat inc.cnf`

```
[inception]
general_log=1    
general_log_file=/usr/local/inception/data/inception.log    
port=6669
socket=/data/inception/inc.socket
character-set-server=utf8    
#mysql原生参数

#
###Inception 审核规则
#
inception_check_autoincrement_datatype=1 
inception_check_autoincrement_init_value=1 
inception_check_autoincrement_name=1 
inception_check_column_comment=1 
inception_check_column_default_value=0 
inception_check_dml_limit=1 
inception_check_dml_orderby=1 
inception_check_dml_where=1 
inception_check_identifier=1 
inception_check_index_prefix=1 
inception_check_insert_field=1  
inception_check_primary_key=1 
inception_check_table_comment=1 
inception_check_timestamp_default=0 
inception_enable_autoincrement_unsigned=1 
inception_enable_blob_type=0 
inception_enable_column_charset=0 
inception_enable_enum_set_bit=0 
inception_enable_foreign_key=0 
inception_enable_identifer_keyword=0 
inception_enable_not_innodb=0 
inception_enable_nullable=0 
inception_enable_orderby_rand=0 
inception_enable_partition_table=0 
inception_enable_select_star=0 
inception_enable_sql_statistic=1 
inception_max_char_length=16 
inception_max_key_parts=5 
inception_max_keys=16 
inception_max_update_rows=10000
inception_merge_alter_table=1 
#
###inception 支持 OSC 参数
#
inception_osc_bin_dir=/data/temp 
inception_osc_check_interval=5 
inception_osc_chunk_size=1000 
inception_osc_chunk_size_limit=4 
inception_osc_chunk_time=0.1 
inception_osc_critical_thread_connected=1000 
inception_osc_critical_thread_running=80 
inception_osc_drop_new_table=1 
inception_osc_drop_old_table=1 
inception_osc_max_lag=3 
inception_osc_max_thread_connected=1000
inception_osc_max_thread_running=80 
inception_osc_min_table_size=0
inception_osc_on=1 
inception_osc_print_none=1 
inception_osc_print_sql=1 
#inception_user 
#inception_password 
inception_read_only=0 
#
###备份服务器信息
#
inception_remote_system_password=123456
inception_remote_system_user=root
inception_remote_backup_port=3306
inception_remote_backup_host=192.168.1.54
inception_support_charset=utf8 

```

*Inception 配置文件详细解释*
```
[inception]
general_log=1    
#这个参数就是原生的MySQL的参数，用来记录在Inception服务上执行过哪些语句，用来定位一些问题等

general_log_file=/usr/local/inception/data/inception.log    
#设置general log写入的文件路径

port=6669
#Inception的服务端口

socket=/data/inception/inc.socket
#Inception的套接字文件存放位置

character-set-server=utf8    
#mysql原生参数

#
###Inception 审核规则
#

inception_check_autoincrement_datatype=1 #当建表时自增列的类型不为int或者bigint时报错

inception_check_autoincrement_init_value=1 
#当建表时自增列的值指定的不为1，则报错

inception_check_autoincrement_name=1 #建表时，如果指定的自增列的名字不为ID，则报错，说明是有意义的，给提示

inception_check_column_comment=1 
#建表时，列没有注释时报错

inception_check_column_default_value=0 #检查在建表、修改列、新增列时，新的列属性是不是要有默认值

inception_check_dml_limit=1 
#在DML语句中使用了LIMIT时，是不是要报错

inception_check_dml_orderby=1 
#在DML语句中使用了Order By时，是不是要报错

inception_check_dml_where=1 
#在DML语句中没有WHERE条件时，是不是要报错

inception_check_identifier=1 
#打开与关闭Inception对SQL语句中各种名字的检查，如果设置为ON，则如果发现名字中存在除数字、字母、下划线之外的字符时，会报Identifier "invalidname" is invalid, valid options: [a-z,A-Z,0-9,_].

inception_check_index_prefix=1 #是不是要检查索引名字前缀为"idx_"，检查唯一索引前缀是不是"uniq_"

inception_check_insert_field=1  
#是不是要检查插入语句中的列链表的存在性

inception_check_primary_key=1 
#建表时，如果没有主键，则报错

inception_check_table_comment=1 
#建表时，表没有注释时报错

inception_check_timestamp_default=0 #建表时，如果没有为timestamp类型指定默认值，则报错

inception_enable_autoincrement_unsigned=1 
#自增列是不是要为无符号型

inception_enable_blob_type=0 
#检查是不是支持BLOB字段，包括建表、修改列、新增列操作 默认开启

inception_enable_column_charset=0 
#允许列自己设置字符集

inception_enable_enum_set_bit=0 
#是不是支持enum,set,bit数据类型

inception_enable_foreign_key=0 
#是不是支持外键

inception_enable_identifer_keyword=0 #检查在SQL语句中，是不是有标识符被写成MySQL的关键字，默认值为报警。

inception_enable_not_innodb=0 
#建表指定的存储引擎不为Innodb，不报错

inception_enable_nullable=0 
#创建或者新增列时如果列为NULL，不报错

inception_enable_orderby_rand=0 
#order by rand时是不是报错

inception_enable_partition_table=0 
#是不是支持分区表

inception_enable_select_star=0 
#Select*时是不是要报错

inception_enable_sql_statistic=1 
#设置是不是支持统计Inception执行过的语句中，各种语句分别占多大比例，如果打开这个参数，则每次执行的情况都会在备份数据库实例中的inception库的statistic表中以一条记录存储这次操作的统计情况，每次操作对应一条记录，这条记录中含有的信息是各种类型的语句执行次数情况。

inception_max_char_length=16 
#当char类型的长度大于这个值时，就提示将其转换为VARCHAR

inception_max_key_parts=5 
#一个索引中，列的最大个数，超过这个数目则报错

inception_max_keys=16 
#一个表中，最大的索引数目，超过这个数则报错

inception_max_update_rows=10000 #在一个修改语句中，预计影响的最大行数，超过这个数就报错

inception_merge_alter_table=1 
#在多个改同一个表的语句出现是，报错，提示合成一个

#
###inception 支持 OSC 参数
#

inception_osc_bin_dir=/data/temp #用于指定pt-online-schema-change脚本的位置，不可修改，在配置文件中设置

inception_osc_check_interval=5 
#对应OSC参数--check-interval，意义是Sleep time between checks for --max-lag.

inception_osc_chunk_size=1000 
#对应OSC参数--chunk-size

inception_osc_chunk_size_limit=4 
#对应OSC参数--chunk-size-limit

inception_osc_chunk_time=0.1 
#对应OSC参数--chunk-time

inception_osc_critical_thread_connected=1000 #对应参数--critical-load中的thread_connected部分

inception_osc_critical_thread_running=80 #对应参数--critical-load中的thread_running部分

inception_osc_drop_new_table=1 
#对应参数--[no]drop-new-table

inception_osc_drop_old_table=1 
#对应参数--[no]drop-old-table

inception_osc_max_lag=3 
#对应参数--max-lag

inception_osc_max_thread_connected=1000 #对应参数--max-load中的thread_connected部分

inception_osc_max_thread_running=80 
#对应参数--max-load中的thread_running部分

inception_osc_min_table_size=0
# 这个参数实际上是一个OSC的开关，如果设置为0，则全部ALTER语句都走OSC，如果设置为非0，则当这个表占用空间大小大于这个值时才使用OSC方式。单位为M，这个表大小的计算方式是通过语句："select (DATA_LENGTH + INDEX_LENGTH)/1024/1024 from information_schema.tables where table_schema = 'dbname' and table_name = 'tablename'"来实现的

inception_osc_on=1 #一个全局的OSC开关，默认是打开的，如果想要关闭则设置为OFF，这样就会直接修改

inception_osc_print_none=1 
#用来设置在Inception返回结果集中，对于原来OSC在执行过程的标准输出信息是不是要打印到结果集对应的错误信息列中，如果设置为1，就不打印，如果设置为0，就打印。而如果出现错误了，则都会打印

inception_osc_print_sql=1 
#对应参数--print

#inception_user 
#这个用户名在配置之后，在连接Inception的选项中可以不指定user，这样线上数据库的用户名及密码就可以不暴露了，可以做为临时使用的一种方式，但这个用户现在只能是用来审核，也就是说，即使在选项中指定--enable-execute，也不能执行，这个是只能用来审核的帐号。

#inception_password 
#与上面的参数是一对，这个参数对应的是选项中的password，设置这个参数之后，可以在选项中不指定password

inception_read_only=0 
#设置当前Inception服务器是不是只读的，这是为了防止一些人具有修改权限的帐号时，通过Inception误修改一些数据，如果inception_read_only设置为ON，则即使开了enable-execute，同时又有执行权限，也不会去执行，审核完成即返回

#
###备份服务器信息
#

inception_remote_system_password=123456
inception_remote_system_user=root
inception_remote_backup_port=3306
inception_remote_backup_host=192.168.1.54
inception_support_charset=utf8 
#表示在建表或者建库时支持的字符集，如果需要多个，则用逗号分隔，影响的范围是建表、设置会话字符集、修改表字符集属性等
```

四、启动
```
$ nohup /usr/local/inception/bin/Inception --defaults-file=/etc/inc.cnf  &`
#建议这种启动方式

$ netstat -tulpn  
#查看是否有6669端口已经启动

$ cd /usr/local/inception/bin
./Inception  --defaults-file=/etc/inc.cnf & 
#后台启动，去掉&变为前台启动

netstat -tulpn  
#查看是否有6669端口已经启动

Inception –port=6669  &  
#后台启动，不过配置是默认的配置。没有使用上边的配置文件


```

五、连接inception服务
```
$ mysql -h127.0.0.1 -uroot -P6669     #链接inception服务

inception get variables;     #显示变量即证明安装inception正常。
```

六、测试
构建python测试脚本，目前只支持python和c、c++编写的程序接口。


inception_test1.py
```
vim inception_test1.py
#!/usr/bin/python
#-\*-coding: utf-8-\*-
import MySQLdb
sql='/*--user=root;--password=123456;--host=127.0.0.1;--execute=1;--port=3306;*/\
inception_magic_start;\
use mysql;\
CREATE TABLE `alifeba_user` (\
                    `ID` int(11) unsigned NOT NULL auto_increment comment"aaa",\
                    `username` varchar(50) NOT NULL Default "" comment"aaa",\
                    `realName` varchar(50) NOT NULL Default "" comment"aaa",\
                    `age` int(11) NOT NULL Default 0 comment"aaa",\
                    PRIMARY KEY (`ID`)\
                    ) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COMMENT="AAAA";\
inception_magic_commit;'
try:
    conn=MySQLdb.connect(host='127.0.0.1',user='root',passwd='',db='',port=6669)
    cur=conn.cursor()
    ret=cur.execute(sql)
    result=cur.fetchall()
    num_fields = len(cur.description)
    field_names = [i[0] for i in cur.description]
    print field_names
    for row in result:
        print row[0], "|",row[1],"|",row[2],"|",row[3],"|",row[4],"|",
        row[5],"|",row[6],"|",row[7],"|",row[8],"|",row[9],"|",row[10]
    cur.close()
    conn.close()
except MySQLdb.Error,e:
     print "Mysql Error %d: %s" % (e.args[0], e.args[1])
```

inception_test2.py
```
vim inception_test2.py
#!/usr/bin/python
#-\*-coding: utf-8-\*-
import MySQLdb
sql='/*--user=root;--password=123456;--host=127.0.0.1;--execute=1;--port=3306;*/\
inception_magic_start;\
use mysql;\
INSERT INTO alifeba_user(username,realName,age) VALUES ("Lucy","RealLucy",18);\
inception_magic_commit;'
try:
    conn=MySQLdb.connect(host='127.0.0.1',user='root',passwd='',db='',port=6669)
    cur=conn.cursor()
    ret=cur.execute(sql)
    result=cur.fetchall()
    num_fields = len(cur.description)
    field_names = [i[0] for i in cur.description]
    print field_names
    for row in result:
        print row[0], "|",row[1],"|",row[2],"|",row[3],"|",row[4],"|",
        row[5],"|",row[6],"|",row[7],"|",row[8],"|",row[9],"|",row[10]
    cur.close()
    conn.close()
except MySQLdb.Error,e:
     print "Mysql Error %d: %s" % (e.args[0], e.args[1])
```

**返回结果**
```
['ID', 'stage', 'errlevel', 'stagestatus', 'errormessage', 'SQL', 'Affected_rows', 'sequence', 'backup_dbname', 'execute_time', 'sqlsha1']
1 | RERUN | 0 | Execute Successfully | None | 
#对应上边use mysql；具体的每个字段的含义参看上边链接中的文档。

2 | EXECUTED | 0 | Execute Successfully Backup successfully | None |  #对应上边的另一语句。

#可以链接192.168.99.205数据库，查看相应的备份数据库。
127_0_0_1_3306_mysql 这个数据库就是备份的数据库，命名规则ip+端口+数据库名（每个数据库都单独有一个）

$_$Inception_backup_information$_$  
这个就是记录的全部对该数据库的操作，内容如下。具体的含义参照官方文档看看就明白了。就是为了记录你的操作和方便你查找回滚的操作。

opid_time: 1495357758_4_1  ##标识你的一个操作语句，用这个标识到 alifeba_user表中查找此次对应的所有操作（此次可能对应对个操作，1495357758_4_2 ..）
start_binlog_file: 
 start_binlog_pos: 0
  end_binlog_file: 
   end_binlog_pos: 0
    sql_statement: CREATE TABLE `alifeba_user` (
                    `ID` int(11) unsigned NOT NULL auto_increment  comment"aaa",
                    `username` varchar(50) NOT NULL Default "" comment"aaa",
                    `realName` varchar(50) NOT NULL Default "" comment"aaa",
                    `age` int(11) NOT NULL Default 0 comment"aaa",
                    PRIMARY KEY (`ID`)
                    ) ENGINE=INNODB DEFAULT CHARSET=utf8 COMMENT="AAAA"
             host: 127.0.0.1
           dbname: mysql
        tablename: alifeba_user
             port: 3306
             time: 2017-05-21 17:09:18
             type: CREATETABLE

 alifeba_user        
 #对该表的所有操作都在这里边，备份这。可以用来回滚。通过上边的opid_time可以找到此次所做的所有操作备份代码。进行回滚
```
