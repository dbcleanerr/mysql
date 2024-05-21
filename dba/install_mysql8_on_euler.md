#### 修改`yum`源

> 修改完好像还是不快，太慢了。

```shell
sed -i 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' /etc/yum.repos.d/openEuler.repo
yum clean all
yum makecache
```

#### 安装MySQL 8

[下载yum源](http://dev.mysql.com/downloads/repo/yum)

```shell
# 关闭selinux
sestatus
vi /etc/selinux/config


# 安装MySQL 8
yum localinstall mysql84-community-release-el8-1.noarch.rpm
yum repolist enabled | grep mysql

yum install mysql-server
rpm -qa | grep -i 'mysql*8*'

systemctl enable mysqld
systemctl start mysqld
```

#### 修改临时密码

```shell
grep "temporary password" /var/log/mysqld.log

mysql -uroot -h localhost -p

alter user 'root'@'localhost' identified by 'Welcome_1234'
```

#### 安装`MySQL Shell`

```shell

```

#### 常规操作

```mysql
-- 创建数据库
create database db01;

-- 查看数据目录
show variables like 'datadir';

-- 创建用户
create user 'u01'@'%' identified by 'Welcome_1234';
grant all privileges on db01.* to 'u01'@'%';
flush privileges;
show grants for 'u01'@'%';


# 创建导入导出目录
mkdir -p /data/csv
chown -R mysql:mysql /data
# /etc/my.cnf
secure-file-priv=/data/csv


mysql> show variables like 'secure_file_priv';
+------------------+------------+
| Variable_name    | Value      |
+------------------+------------+
| secure_file_priv | /data/csv/ |
+------------------+------------+
1 row in set (0.00 sec)

select 
    * into outfile 
    '/data/csv/t01.csv'
    fields terminated by ','
    optionally enclosed by '"'
    lines terminated by '\n'
from t01 ;

load data infile '/data/csv/t01.csv' 
    into table t01
    fields terminated by ','
    optionally enclosed by '"'
    lines terminated by '\n';

load data infile '/data/csv/t01.csv'
    ignore into table t01
    fields terminated by ','
    optionally enclosed by '"'
    lines terminated by '\n';

load data infile '/data/csv/t01.csv'
    replace into table t01
    fields terminated by ','
    optionally enclosed by '"'
    lines terminated by '\n';

```

#### 修改参数

```mysql
-- persist, 会保留在 数据目录/mysqld-auto.cnf
set persist slow_query_log=on;
set persist long_query_time=1;
```