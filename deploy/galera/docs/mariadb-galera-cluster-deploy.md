## MariaDB Galera Cluster Deploy For Ansible    

### 规划说明：
| 节点   | IP地址         |角色           |
| ------ | ------------- |---------------|
| node1  | 192.168.0.124 |MySQL 主节点   |
| node2  | 192.168.0.125 |MySQL 从节点   |
| node3  | 192.168.0.126 |MySQL 从节点   |
| deploy | 192.168.0.127 |ansible部署节点|    

### 安装说明
一、下载MariaDB二进制安装包    
`$ wget http://`    

二、安装ansible    
`$ yum install ansible`    

三、ansible配置主机ssh免密访问    
为了避免Ansible下发指令时输入目标主机密码，通过证书签名达到SSH无密码是一个好的方案，通过ssh-keygen与ssh-copy-id来实现快速证书的生成及公钥下发，其中ssh-keygen生成一对密钥，ssh-copy-id来下发生成的公钥。    

1.执行ssh-keygen -t rsa 生成密钥对   
```
$ ssh-keygen -t rsa       # 在部署节点上执行
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
c8:98:58:09:f2:e4:76:d7:86:51:fb:fd:5a:9f:e1:ba root@node5
The key's randomart image is:
+--[ RSA 2048]----+
|. o   ...        |
| = . . + .       |
|  + + o +        |
| . + = o . .     |
|  . o o S . .    |
|             .   |
|              o. |
|             o..o|
|            .Eoo.|
+-----------------+
```
这时当前用户home目录下面会生成一对密钥，id_rsa 为私钥，id_rsa.pub 为公钥。    

> 特别说明，要不要对私钥设置口令（passphrase），如果担心私钥的安全，可以设置一个。没有特殊需求直接Enter，为空。

2.通过ssh-copy-id进行传输公钥    
```
$ ssh-copy-id -i /root/.ssh/id_rsa.pub root@192.168.0.124
The authenticity of host '192.168.0.124 (192.168.0.124)' can't be established.
ECDSA key fingerprint is 4f:7d:b8:16:32:55:ef:91:67:3e:47:f1:e4:42:3d:b8.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@192.168.0.124's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'root@192.168.0.124'"
and check to make sure that only the key(s) you wanted were added.

# 在其他节点上重复此操作

```

