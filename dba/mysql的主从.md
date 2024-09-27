### MySQL主从配置

```mysql
-- 主库启用`binlog`和设置server_id
select @@log_bin,@@server_id;

-- 在主库上创建复制用户
create user 'repl'@'192.168.%.%' identified by 'pxc_repl_password';
grant replication slave on *.* to 'repl'@'192.168.%.%';
flush privileges;

show grants for 'repl'@'192.168.%.%';

-- 从库设置唯一的server_id
select @@server_id;

-- 主库备份
-- --single-transaction   # 对事务表，以repeatable read方式备份，避免备份过程中数据变化，不锁表
-- --source-data=2        # 添加 MASTER_LOG_FILE和MASTER_LOG_POS
mysqldump -uroot -p --single-transaction --source-data=2 --databases db01 db02 > ~/db.sql

xtrabackup -uroot -p --backup --target-dir=/backup/test --datadir=/var/lib/mysql --databases='db01 db02'
-- xtrabackup -uroot -p --backup --target-dir=/backup/test --datadir=/var/lib/mysql
xtrabackup --prepare --target-dir=/backup/test


-- 从库恢复数据
systemctl stop mysqld
xtrabackup --copy-back --databases='db1 db2' --target-dir=/backup/test --datadir=/tmp/aa
-- cp -r db01 /var/lib/mysql
-- cp -r db02 /var/lib/mysql
               
-- xtrabackup --copy-back  --target-dir=/backup/test --datadir=/var/lib/mysql


CHANGE REPLICATION SOURCE TO SOURCE_HOST='192.168.1.45',
    SOURCE_USER='pxc_repl',
    SOURCE_PASSWORD='pxc_repl_password',
    SOURCE_PORT = 38809,
    SOURCE_LOG_FILE='binlog.000013', SOURCE_LOG_POS=157;

mysql -h192.168.1.45 -upxc_repl -ppxc_repl_password -P38809

start replica;
stop replica;
show replica status;

RESET replica ALL;
```