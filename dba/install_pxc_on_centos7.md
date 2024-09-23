```text
> ICYW027 $RFV2wsx2024!  X!hynAz7fI
https://10.50.74.41/login
ICYW012
E4=u$_wh|wIh

10.50.138.233
10.50.138.234
10.50.138.235

appadmin Sadmin123!
```

### 割接操作日志

#### 更改密码

```text
log_error_suppression_list=MY-013360
set global log_error_suppression_list='MY-013360';
```

```mysql
-- 2024-09-20 15:28:00
-- clustercheck
ALTER USER 'clustercheckuser'@'localhost' IDENTIFIED BY '7hP039V6';

-- pxc_repl
-- 2024-09-20 15:30:00
create user 'pxc_repl'@'10.50.%.%' identified with mysql_native_password by 'O5HeP3KJ';
grant replication slave on *.* to 'pxc_repl'@'10.50.%.%';
flush privileges;

select user, host, plugin, account_locked, password_expired
  from mysql.user
 where user in ('clustercheckuser', 'pxc_repl');

(ics_admin@localhost) [(none)]> select user, host, plugin, account_locked, password_expired
    ->   from mysql.user
    ->  where user in ('clustercheckuser', 'pxc_repl');
+------------------+-----------+-----------------------+----------------+------------------+
| user             | host      | plugin                | account_locked | password_expired |
+------------------+-----------+-----------------------+----------------+------------------+
| pxc_repl         | 10.50.%.% | mysql_native_password | N              | N                |
| clustercheckuser | localhost | caching_sha2_password | N              | N                |
+------------------+-----------+-----------------------+----------------+------------------+
2 rows in set (0.07 sec)
```

#### 停应用

#### 杀aliyundun

> 第3台，2024-09-20 21:06:00

#### 主库备份数据

```mysql
SELECT table_schema, table_name, column_name, data_type, column_type
  FROM information_schema.columns
 WHERE column_type =  'tinyint(1)'
   AND table_schema in ('intelligent_construction', 'scaffold', 'tb');


select table_schema, table_name, TABLE_COLLATION
  from information_schema.tables
 where table_schema in ('intelligent_construction', 'scaffold', 'tb')
   AND TABLE_COLLATION like 'utf8mb3%';

SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, EXTRA
  FROM INFORMATION_SCHEMA.COLUMNS
 where table_schema in ('intelligent_construction', 'scaffold', 'tb')
   AND lower(COLUMN_TYPE) LIKE '%zerofill%';
  
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, EXTRA
  FROM INFORMATION_SCHEMA.COLUMNS
 where table_schema in ('intelligent_construction', 'scaffold', 'tb')
   AND lower(COLUMN_TYPE) LIKE '%int(%';


SELECT TABLE_SCHEMA, TABLE_NAME 
  FROM information_schema.tables 
 WHERE TABLE_TYPE = 'BASE TABLE' 
   AND TABLE_SCHEMA NOT IN ('information_schema', 'performance_schema', 'mysql', 'sys') 
   AND TABLE_NAME NOT IN (
    SELECT DISTINCT TABLE_NAME 
      FROM information_schema.KEY_COLUMN_USAGE 
     WHERE TABLE_SCHEMA = tables.TABLE_SCHEMA 
       AND CONSTRAINT_NAME = 'PRIMARY'
);
```

```shell
nohup mysqldump -uics_admin -pwelcome \
          --skip-add-locks \
          --lock-all-tables \
          --socket=/data/mysql/mysql.sock \
          --add-drop-database \
          --add-drop-table \
          --databases scaffold tb intelligent_construction \
          --ignore-table=intelligent_construction.rn_project_worker_identify \
          --ignore-table=intelligent_construction.ics_file \
          --ignore-table=intelligent_construction.mt_rn_project_worker_identify \
          --ignore-table=intelligent_construction.ics_device_up_payload \
           >  /data/backup/a/20240920_1.sql 2> /data/backup/a/20240920_1.log &
           
           
nohup mysqldump -uics_admin -pwelcome \
          --skip-add-locks \
          --lock-all-tables \
          --socket=/data/mysql/mysql.sock \
          --add-drop-table \
          intelligent_construction rn_project_worker_identify \
           >  /data/backup/a/20240920_2.sql 2> /data/backup/a/20240920_2.log &
           
nohup mysqldump -uics_admin -pwelcome \
          --skip-add-locks \
          --lock-all-tables \
          --socket=/data/mysql/mysql.sock \
          --add-drop-table \
          intelligent_construction ics_file mt_rn_project_worker_identify  \
           >  /data/backup/a/20240920_3.sql 2> /data/backup/a/20240920_3.log &
```

```text
-- 1
(ics_admin@localhost) [(none)]> show master status;
+---------------+-----------+--------------+------------------+-------------------+
| File          | Position  | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+---------------+-----------+--------------+------------------+-------------------+
| binlog.001860 | 807088539 |              |                  |                   |
+---------------+-----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)

-- 2
mysql> show master status;
+---------------+-----------+--------------+------------------+-------------------+
| File          | Position  | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+---------------+-----------+--------------+------------------+-------------------+
| binlog.001852 | 818693999 |              |                  |                   |
+---------------+-----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)

-- 3
mysql> show master status;
+---------------+-----------+--------------+------------------+-------------------+
| File          | Position  | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+---------------+-----------+--------------+------------------+-------------------+
| binlog.001861 | 779452571 |              |                  |                   |
+---------------+-----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)


```

#### `pxc`导入数据

```text
select name, space_type, file_size, allocated_size
  from information_schema.innodb_tablespaces
 order by file_size;
 
show table status from intelligent_construction;
show index from t01;
 
 
analyze local table db01.t01, db01.t02;

-- 分析表
mysqlcheck -uics_admin -p --analyze --socket=/data/mysql/mysql.sock --all-databases
mysqlcheck -uics_admin -p --analyze --socket=/data/mysql/mysql.sock --databases scaffold tb intelligent_construction


-- 全局只读锁
flush tables with read lock;
set global super_read_only=on;

-- 查看binlog
show master status;

-- 执行
-- 加日志
-- 单独表的，要指定数据库



--
alter table tt modify col01 tinyint;
```



### Install Percona XtraDB Cluster on CentOS 7







#### 创建用户，数据库

```mysql
-- 重命名root
rename user 'root'@'localhost' to 'ics_admin'@'localhost';

-- 创建业务用户

-- 创建数据库
```







### 安装与配置 `proxySQL2`

#### 在`pxc1`节点创建`proxysql`用户



#### 安装 `proxysql2`

```shell
yum localinstall -y /tools/rpm/proxysql/*.rpm
systemctl status proxysql
systemctl enable proxysql
systemctl start proxysql
```

#### 配置 `proxysql2`

```mysql
-- 配置文件
/etc/proxysql.cnf

-- 日志文件和sqlite文件
/var/lib/proxysql

-- mysql -u admin -padmin -h 127.0.0.1 -P 6032 --prompt 'admin> '

-- 检查版本
select version();

-- 检查用户
select current_user();

insert into mysql_servers (hostgroup_id, hostname, port) 
values (10, '192.168.1.45', 3306),
       (10, '192.168.1.46', 3306),
       (10, '192.168.1.47', 3306);


LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;

select *
  from mysql_servers;

set mysql-monitor_username='proxysql';
set mysql-monitor_password='welcome';
-- 下面命令等价于
-- update global_variables set variable_value='proxysql' where variable_name='mysql-monitor_username';
-- update global_variables set variable_value='welcome' where variable_name='mysql-monitor_password';

-- load variables
load mysql variables to runtime;
save mysql variables to disk;

-- 查看
select * 
  from monitor.mysql_server_connect_log 
  order by time_start_us desc
  limit 10;

select * 
  from monitor.mysql_server_ping_log
  order by time_start_us desc
  limit 6;

-- create proxysql client user
-- 不同的分组可以有不同的权限，资源，读写分离之类的。指定节点。
insert into mysql_users (username, password, default_hostgroup) values ('sbuser', 'sbpass', 10);
load mysql users to runtime;
save mysql users to disk;

-- transaction_persistent: 1
-- 当它的值为1时，表示事务持久化，开启事务后，一个连接路由到同一个节点。


select * from stats_mysql_query_digest;

```

#### `proxySQL2`常用命令
```mysql
proxysql start;
proxysql stop;
```






#### Percona Toolkit

```shell
# 安装
yum localinstall -y /tools/rpm/pt/*.rpm

# 类似于iostat命令，不过它比iostat输出的更加详细一点
pt-diskstats --interval=1 --iterations=10 --devices-regex=sda --show-timestamps

# iops
pt-diskstats --group-by sample --devices-regex sda --columns-regex io_s

# 分析慢查询日志
pt-query-digest --since=12h /var/log/mysql_slow.log
```


```shell

```


```text
在Percona XtraDB Cluster (PXC) 中，systemctl start mysql@bootstrap.service 和 systemctl start mysqld 的区别主要在于启动方式和目的。

systemctl start mysql@bootstrap.service:

这个命令用于启动一个特殊的MySQL实例，通常用于集群的初始化或引导（bootstrap）过程。
当你启动一个PXC节点时，使用mysql@bootstrap.service可以确保该节点以引导模式启动，这意味着它会创建一个新的集群或作为集群的第一个节点启动。
引导模式会执行一些特殊的初始化步骤，例如创建必要的系统表、配置集群等。
这个命令通常在第一次启动PXC节点或需要重新初始化集群时使用。
systemctl start mysqld:

这个命令用于启动一个普通的MySQL实例，不涉及特殊的引导过程。
当你启动一个PXC节点时，使用mysqld服务会以普通模式启动，这意味着它会尝试加入一个已经存在的集群，而不是创建一个新的集群。
这个命令通常在节点已经初始化并且只需要正常启动时使用。
总结来说，mysql@bootstrap.service 用于初始化或引导一个新的PXC集群，而 mysqld 用于启动一个已经初始化过的PXC节点并加入现有集群。
```


#### 同步方式

- SST: State Snapshot Transfer，全量同步，`XtraBackup`和`mysqldump`和`rsync`，推荐`XtraBackup`
- IST: Incremental State Transfer，增量同步，只有`XtraBackup`

```mysql
show status like 'wsrep_local_state_comment';
```



```mysql
SELECT 
    table_name AS `Table`, 
    round(((data_length + index_length) / 1024 / 1024), 2) `Size in MB` 
FROM 
    information_schema.TABLES 
WHERE 
    table_schema = 'db01' 
    AND table_name = 'sbtest1';

```


```mysql
-- 更改密码

```


/var/lib/mysql//innobackup.backup.log


```text
在Percona XtraDB Cluster (PXC)中，State Snapshot Transfer (SST) 是一种用于在集群节点之间传输完整数据集的机制。
SST的主要目的是在新的节点加入集群或现有节点重新加入集群时，将完整的数据集从一个节点（捐赠者）传输到另一个节点（接收者）。

SST的工作原理
SST的工作原理可以概括为以下几个步骤：

选择捐赠者：

当一个新的节点加入集群时，它会向集群发送一个SST请求。
集群会选择一个捐赠者节点来提供完整的数据集。捐赠者节点通常是集群中数据最新的节点。
准备数据：

捐赠者节点会准备一个完整的数据快照，这个快照包含了当前数据库的所有数据。
数据准备的方式通常是使用XtraBackup工具进行物理备份。
传输数据：

捐赠者节点将准备好的数据快照通过网络传输到接收者节点。
传输方式可以是直接的文件传输，也可以是通过网络协议（如TCP）进行传输。
应用数据：

接收者节点接收到数据快照后，会应用这些数据，将其恢复到本地数据库中。
这个过程包括解压数据、应用日志等步骤，以确保数据的一致性和完整性。
完成SST：

一旦数据应用完成，接收者节点会通知集群SST过程已经完成。
接收者节点现在拥有与捐赠者节点相同的数据集，可以开始参与集群的复制和同步过程。
SST的实现方式
在PXC中，SST通常使用Percona XtraBackup工具来实现。具体步骤如下：

捐赠者节点：

使用XtraBackup工具创建一个全量备份。
将备份文件打包并通过网络传输到接收者节点。
接收者节点：

接收备份文件并解压。
应用备份文件中的数据和日志，恢复数据库。
SST的优缺点
优点：
完整性：SST确保接收者节点获得完整的数据集，避免了数据不一致的问题。
快速恢复：对于新加入的节点，SST可以快速提供完整的数据集，使其能够迅速加入集群。
缺点：
资源消耗：SST过程会消耗大量的网络带宽和磁盘I/O资源。
时间消耗：对于大数据集，SST过程可能需要较长时间才能完成。
结论
SST在PXC中是一个关键的机制，用于在节点加入或重新加入集群时传输完整的数据集。SST的工作原理涉及捐赠者节点准备数据、
传输数据到接收者节点，并由接收者节点应用数据。通过这种方式，PXC确保了集群中所有节点数据的一致性和完整性。
```


```text
在Percona XtraDB Cluster (PXC)中，Incremental State Transfer (IST) 是一种用于在集群节点之间传输增量数据的机制。
IST的主要目的是在节点重新加入集群时，减少数据传输量，从而加快节点同步速度。

IST的工作原理
IST的工作原理可以概括为以下几个步骤：

确定数据差距：

当一个节点重新加入集群时，它会向集群发送一个IST请求。
集群会确定该节点与集群中最新数据之间的差距，即该节点缺少的事务日志（Write-Set）。
选择捐赠者：

集群会选择一个捐赠者节点来提供增量数据。捐赠者节点通常是集群中数据最新的节点。
传输增量数据：

捐赠者节点会将缺少的事务日志（Write-Set）通过网络传输到接收者节点。
传输方式可以是直接的网络传输，通常是通过TCP协议进行。
应用增量数据：

接收者节点接收到增量数据后，会应用这些事务日志（Write-Set），将其应用到本地数据库中。
这个过程包括解析事务日志、应用变更等步骤，以确保数据的一致性和完整性。
完成IST：

一旦增量数据应用完成，接收者节点会通知集群IST过程已经完成。
接收者节点现在拥有与捐赠者节点相同的数据集，可以开始参与集群的复制和同步过程。
IST的实现方式
在PXC中，IST通常通过以下方式实现：

捐赠者节点：

确定接收者节点缺少的事务日志（Write-Set）。
将这些事务日志通过网络传输到接收者节点。
接收者节点：

接收事务日志并应用这些日志，更新本地数据库。
IST的优缺点
优点：
减少数据传输量：IST只传输缺少的增量数据，减少了网络带宽和磁盘I/O资源的消耗。
加快同步速度：对于重新加入集群的节点，IST可以快速提供增量数据，使其能够迅速同步到最新状态。
缺点：
复杂性：IST的实现相对复杂，需要精确确定数据差距并传输增量数据。
依赖性：IST依赖于事务日志的完整性和可用性，如果事务日志丢失或损坏，可能会影响IST的正常进行。
结论
IST在PXC中是一个重要的机制，用于在节点重新加入集群时传输增量数据，从而减少数据传输量并加快同步速度。IST的工作原理涉及确定数据差距、选择捐赠者、传输增量数据、应用增量数据等步骤。通过这种方式，PXC确保了集群中节点数据的一致性和快速同步。
```

```mysql
SHOW GLOBAL STATUS LIKE 'wsrep_%';

-- wsrep_local_recv_queue：接收队列的长度，如果不为零，说明仍在接收IST。
-- wsrep_local_state_comment：显示节点当前状态（如 Synced、Joining 等） 。


-- wsrep_last_applied ：最后一次应用的事务ID。
-- wsrep_last_committed：最后一次提交的事务ID。
-- wsrep_monitor_status (L/A/C)：The status of the local monitor (local and replicating actions), apply monitor (apply actions of write-set), and commit monitor (commit actions of write sets). In the value of this variable, each monitor (L: Local, A: Apply, C: Commit) is represented as a last_entered, and last_left pair:
-- wsrep_replicated : Total number of writesets sent to other nodes.
-- wsrep_replicated_bytes : Total size of replicated writesets. 
-- wsrep_repl_keys : Total number of keys replicated.
-- wsrep_repl_keys_bytes : Total size (in bytes) of keys replicated.
-- wsrep_repl_data_bytes : Total size (in bytes) of data replicated.
-- wsrep_received : Total number of writesets received from other nodes.
-- wsrep_received_bytes : Total size of received writesets.
-- wsrep_local_commits : Number of writesets commited on the node.
-- wsrep_local_cert_failures : Number of writesets that failed the certification test.
-- wsrep_local_replays : Number of transaction replays due to asymmetric lock granularity.
-- wsrep_local_send_queue : Current length of the send queue (that is, the number of writesets waiting to be sent).
-- wsrep_local_recv_queue : Current length of the receive queue (that is, the number of writesets waiting to be applied).
-- wsrep_local_state : The local state of the node (1:joining, 2:Donor/Desynced,3:Joined,4:Synced).
-- wsrep_open_connections
-- wsrep_open_transactions
-- wsrep_ist_receive_status
-- wsrep_connected : This variable shows if the node is connected to the cluster
-- wsrep_ready : This variable shows if node is ready to accept queries.
-- wsrep_thread_count : The number of threads used for applying writesets.
-- 

    
-- 重要
-- wsrep_connected : 节点是否连接到集群。
-- wsrep_ready : 节点是否准备好接受查询。
-- wsrep_local_send_queue : 发送队列的长度
-- wsrep_local_recv_queue : 接收队列的长度
-- wsrep_cluster_size : 集群中节点的数量
-- wsrep_cluster_weight : 不知道为啥值总和 wsrep_cluster_size 一样。
    
-- wsrep_monitor_status : 
wsrep_monitor_status 是一个用于监控 Percona XtraDB Cluster (PXC) 状态的变量，
它提供了关于
本地监控器（local and replicating actions）
应用监控器（apply actions of write-set）
提交监控器（commit actions of write sets）的状态信息。

每个监控器（L: Local, A: Apply, C: Commit）都表示为一个 last_entered 和 last_left 的对。

wsrep_monitor_status (L/A/C)   
[ (last_entered_L, last_left_L), 
(last_entered_A, last_left_A),
(last_entered_C, last_left_C) ]

last_entered_L 和 last_left_L 表示本地事务或写集最近进入和离开队列的序列号。
last_entered_A 和 last_left_A 表示应用事务或写集最近进入和离开队列的序列号。
last_entered_C 和 last_left_C 表示提交事务或写集最近进入和离开队列的序列号。



wsrep_local_cert_failures 是一个计数器，用于统计节点在接收到写集时失败的认证测试的次数。
wsrep_local_bf_aborts 是一个计数器，用于统计节点在接收到写集时由于不一致性导致的回滚的次数。
wsrep_local_commits 是一个计数器，用于统计节点在接收到写集时成功提交的写集的数量。
wsrep_local_replays 是一个计数器，用于统计节点在接收到写集时由于不一致性导致的事务重放的次数。




-- 检查IST
mysql> show global status like 'wsrep_ist_receive%';
+---------------------------------+------------------------------------------+
| Variable_name                   | Value                                    |
+---------------------------------+------------------------------------------+
| wsrep_ist_receive_status        | 92% complete, received seqno 51 of 38-52 |
| wsrep_ist_receive_seqno_start   | 38                                       |
| wsrep_ist_receive_seqno_current | 51                                       |
| wsrep_ist_receive_seqno_end     | 52                                       |
+---------------------------------+------------------------------------------+
4 rows in set (0.00 sec)
              
-- 检查REP
mysql> show global status like 'wsrep_repl%';
+------------------------+----------+
| Variable_name          | Value    |
+------------------------+----------+
| wsrep_replicated       | 40       |
| wsrep_replicated_bytes | 54682000 |
| wsrep_repl_keys        | 2097260  |
| wsrep_repl_keys_bytes  | 16779128 |
| wsrep_repl_data_bytes  | 4743949  |
| wsrep_repl_other_bytes | 0        |
+------------------------+----------+
6 rows in set (0.01 sec)
              
-- 检查loc
mysql> show global status like 'wsrep_local%';
+----------------------------+--------------------------------------+
| Variable_name              | Value                                |
+----------------------------+--------------------------------------+
| wsrep_local_state_uuid     | 3055ddfa-651e-11ef-8acc-ff8ae116e70f |
| wsrep_local_commits        | 36                                   |
| wsrep_local_cert_failures  | 0                                    |
| wsrep_local_replays        | 0                                    |
| wsrep_local_send_queue     | 0                                    |
| wsrep_local_send_queue_max | 2                                    |
| wsrep_local_send_queue_min | 0                                    |
| wsrep_local_send_queue_avg | 0.0185185                            |
| wsrep_local_recv_queue     | 0                                    |
| wsrep_local_recv_queue_max | 1                                    |
| wsrep_local_recv_queue_min | 0                                    |
| wsrep_local_recv_queue_avg | 0                                    |
| wsrep_local_cached_downto  | 1                                    |
| wsrep_local_state          | 4                                    |
| wsrep_local_state_comment  | Synced                               |
| wsrep_local_bf_aborts      | 0                                    |
| wsrep_local_index          | 1                                    |
+----------------------------+--------------------------------------+
17 rows in set (0.00 sec)
               
-- 检查集群
mysql> show global status like 'wsrep_cluster%';
+----------------------------+--------------------------------------+
| Variable_name              | Value                                |
+----------------------------+--------------------------------------+
| wsrep_cluster_weight       | 2                                    |
| wsrep_cluster_capabilities |                                      |
| wsrep_cluster_conf_id      | 8                                    |
| wsrep_cluster_size         | 2                                    |
| wsrep_cluster_state_uuid   | 3055ddfa-651e-11ef-8acc-ff8ae116e70f |
| wsrep_cluster_status       | Primary                              |
+----------------------------+--------------------------------------+
6 rows in set (0.00 sec)
```


### `percona XtraBackup`

#### 安装

```shell
curl -fsSL https://www.percona.com/get/pmm | /bin/bash
```


```text
在Percona XtraDB Cluster (PXC)中，grastate.dat 和 gvwstate.dat 是两个重要的配置文件，它们用于记录集群的状态和配置信息。以下是这两个文件的详细解释：

grastate.dat
grastate.dat 文件位于PXC节点的数据目录中（通常是 /var/lib/mysql/），用于记录Galera集群的状态信息。这个文件在节点启动和关闭时会被更新，以确保集群状态的一致性。

主要内容
seqno: 记录节点最后一次成功提交的事务序列号（seqno）。这个值用于在节点重新加入集群时确定数据的一致性状态。
safe_to_bootstrap: 一个布尔值，指示在集群首次启动时是否可以安全地引导节点。如果设置为1，表示可以安全引导；如果设置为0，表示不能安全引导。


gvwstate.dat 文件也位于PXC节点的数据目录中，用于记录当前的Primary Component（主组件）的状态信息。这个文件在Primary Component发生变化时会被更新。

主要内容
view_id: 记录当前Primary Component的视图ID，包括UUID、视图编号和节点ID。
primary: 一个布尔值，指示当前节点是否属于Primary Component。
members: 记录当前Primary Component中的成员列表，包括每个成员的UUID和地址。
```


#### 新增节点

```shell
装软件，启库，停库，改配置，启库

```

```shell
--show-warnings
mysql -uics_admin -p --show-warnings --tee=/tmp/a.log
sed -i.bak '/LOCK/d' scaffold.sql


-- =================================intelligent_construction =================================
Warning 
utf8mb3_unicode_ci    'utf8mb3_unicode_ci' is a collation of the deprecated character set UTF8MB3. Please consider using UTF8MB4 with an appropriate collation instead.
tinyint(1)             Warning (Code 1681): Integer display width is deprecated and will be removed in a future release.


-- ================================= scaffold =================================
Warning (Code 1287): 'utf8mb3' is deprecated and will be removed in a future release. Please use utf8mb4 instead
Warning (Code 3778): 'utf8mb3_general_ci' is a collation of the deprecated character set UTF8MB3. Please consider using UTF8MB4 with an appropriate collation instead.

Warning (Code 1681): Integer display width is deprecated and will be removed in a future release.


Warning (Code 1681): The ZEROFILL attribute is deprecated and will be removed in a future release. Use the LPAD function to zero-pad numbers, or store the formatted numbers in a CHAR column.

-- ================================== tb =======================================
Warning (Code 1681): The ZEROFILL attribute is deprecated and will be removed in a future release. Use the LPAD function to zero-pad numbers, or store the formatted numbers in a CHAR column.
Warning (Code 1681): Integer display width is deprecated and will be removed in a future release.


建用户过期时间

-- Warning (Code 1681): Integer display width is deprecated and will be removed in a future release.
SELECT table_schema,table_name, column_name, data_type, column_type
FROM information_schema.columns
WHERE column_type =  'tinyint(1)'
  AND table_schema in ('intelligent_construction', 'scaffold', 'tb');

-- Warning (Code 1287): 'utf8mb3' is deprecated and will be removed in a future release. Please use utf8mb4 instead
-- Warning (Code 3778): 'utf8mb3_general_ci' is a collation of the deprecated character set UTF8MB3. Please consider using UTF8MB4 with an appropriate collation instead.  
select table_schema,table_name, TABLE_COLLATION
  from information_schema.tables
  where table_schema in ('intelligent_construction', 'scaffold', 'tb')
   AND TABLE_COLLATION like 'utf8mb3%';
   
   
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, EXTRA
FROM INFORMATION_SCHEMA.COLUMNS
where table_schema in ('intelligent_construction', 'scaffold', 'tb')
  AND lower(COLUMN_TYPE) LIKE '%zerofill%';
  
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, EXTRA
FROM INFORMATION_SCHEMA.COLUMNS
where table_schema in ('intelligent_construction', 'scaffold', 'tb')
  AND lower(COLUMN_TYPE) LIKE '%int(%';

  
  
+--------------------------+-----------------------------------+------------------------+-----------+-------------+
| TABLE_SCHEMA             | TABLE_NAME                        | COLUMN_NAME            | DATA_TYPE | COLUMN_TYPE |
+--------------------------+-----------------------------------+------------------------+-----------+-------------+
| intelligent_construction | QRTZ_FIRED_TRIGGERS               | IS_NONCONCURRENT       | tinyint   | tinyint(1)  |
| intelligent_construction | QRTZ_FIRED_TRIGGERS               | REQUESTS_RECOVERY      | tinyint   | tinyint(1)  |
| intelligent_construction | QRTZ_JOB_DETAILS                  | IS_DURABLE             | tinyint   | tinyint(1)  |
| intelligent_construction | QRTZ_JOB_DETAILS                  | IS_NONCONCURRENT       | tinyint   | tinyint(1)  |
| intelligent_construction | QRTZ_JOB_DETAILS                  | IS_UPDATE_DATA         | tinyint   | tinyint(1)  |
| intelligent_construction | QRTZ_JOB_DETAILS                  | REQUESTS_RECOVERY      | tinyint   | tinyint(1)  |
| intelligent_construction | QRTZ_SIMPROP_TRIGGERS             | BOOL_PROP_1            | tinyint   | tinyint(1)  |
| intelligent_construction | QRTZ_SIMPROP_TRIGGERS             | BOOL_PROP_2            | tinyint   | tinyint(1)  |
| intelligent_construction | ext_award                         | is_deleted             | tinyint   | tinyint(1)  |
| intelligent_construction | ext_standard_curing_room_realtime | is_deleted             | tinyint   | tinyint(1)  |
| intelligent_construction | ext_standard_curing_room_record   | is_deleted             | tinyint   | tinyint(1)  |
| intelligent_construction | ext_worker_daily_report_record    | daily_report_result    | tinyint   | tinyint(1)  |
| intelligent_construction | ext_worker_daily_report_record    | is_quarantined         | tinyint   | tinyint(1)  |
| intelligent_construction | ext_worker_daily_report_record    | is_visit_risk_area     | tinyint   | tinyint(1)  |
| intelligent_construction | ext_worker_health_code_record     | is_manual              | tinyint   | tinyint(1)  |
| intelligent_construction | ics_sync_receive                  | is_deleted             | tinyint   | tinyint(1)  |
| intelligent_construction | qm_inspect_record                 | is_change_overtime     | tinyint   | tinyint(1)  |
| intelligent_construction | serv_so_contractor_result         | is_effective           | tinyint   | tinyint(1)  |
| intelligent_construction | serv_so_officer_result            | is_effective           | tinyint   | tinyint(1)  |
| intelligent_construction | serv_so_officer_result            | is_paid                | tinyint   | tinyint(1)  |
| intelligent_construction | serv_so_officer_result            | is_perform_duty        | tinyint   | tinyint(1)  |
| intelligent_construction | serv_so_subcontractor_result      | is_effective           | tinyint   | tinyint(1)  |
| intelligent_construction | sm_inspect_record                 | is_change_overtime     | tinyint   | tinyint(1)  |
| intelligent_construction | system_data                       | IsFreeze               | tinyint   | tinyint(1)  |
| intelligent_construction | system_dictionary                 | CanbeDelete            | tinyint   | tinyint(1)  |
| intelligent_construction | system_dictionary                 | IsFreeze               | tinyint   | tinyint(1)  |
| intelligent_construction | system_district                   | IsFreeze               | tinyint   | tinyint(1)  |
| intelligent_construction | system_group                      | IsFreeze               | tinyint   | tinyint(1)  |
| intelligent_construction | system_menu                       | CanbeDelete            | tinyint   | tinyint(1)  |
| intelligent_construction | system_menu                       | HaveDataPermission     | tinyint   | tinyint(1)  |
| intelligent_construction | system_menu                       | HaveFieldPermission    | tinyint   | tinyint(1)  |
| intelligent_construction | system_menu                       | HaveFunctionPermission | tinyint   | tinyint(1)  |
| intelligent_construction | system_menu                       | HaveMenuPermission     | tinyint   | tinyint(1)  |
| intelligent_construction | system_menu                       | IsFreeze               | tinyint   | tinyint(1)  |
| intelligent_construction | system_menubutton                 | IsFreeze               | tinyint   | tinyint(1)  |
| intelligent_construction | system_menubutton                 | ShowGrid               | tinyint   | tinyint(1)  |
| intelligent_construction | system_mobilemenu                 | HaveDataPermission     | tinyint   | tinyint(1)  |
| intelligent_construction | system_mobilemenu                 | HaveFieldPermission    | tinyint   | tinyint(1)  |
| intelligent_construction | system_mobilemenu                 | HaveFunctionPermission | tinyint   | tinyint(1)  |
| intelligent_construction | system_mobilemenu                 | HaveMenuPermission     | tinyint   | tinyint(1)  |
| intelligent_construction | system_mobilemenu                 | IsFreeze               | tinyint   | tinyint(1)  |
| intelligent_construction | system_mobilemenubutton           | IsFreeze               | tinyint   | tinyint(1)  |
| intelligent_construction | system_post                       | IsFreeze               | tinyint   | tinyint(1)  |
| intelligent_construction | system_role                       | CanbeDelete            | tinyint   | tinyint(1)  |
| intelligent_construction | system_role                       | IsFreeze               | tinyint   | tinyint(1)  |
| intelligent_construction | system_subsystem                  | IsFreeze               | tinyint   | tinyint(1)  |
| intelligent_construction | system_userinfo                   | IsAdmin                | tinyint   | tinyint(1)  |
| intelligent_construction | system_userinfo                   | IsFreeze               | tinyint   | tinyint(1)  |
| intelligent_construction | upms_permission                   | hidden                 | tinyint   | tinyint(1)  |
| intelligent_construction | vms_device_monitor                | is_deleted             | tinyint   | tinyint(1)  |
| tb                       | sys_role                          | dept_check_strictly    | tinyint   | tinyint(1)  |
| tb                       | sys_role                          | menu_check_strictly    | tinyint   | tinyint(1)  |
+--------------------------+-----------------------------------+------------------------+-----------+-------------+

+--------------------------+-------------------------------+--------------------+
| TABLE_SCHEMA             | TABLE_NAME                    | TABLE_COLLATION    |
+--------------------------+-------------------------------+--------------------+
| intelligent_construction | system_exceptionlog           | utf8mb3_unicode_ci |
| intelligent_construction | test_zjw                      | utf8mb3_general_ci |
| scaffold                 | tb_category                   | utf8mb3_general_ci |
| scaffold                 | tb_manufacturer               | utf8mb3_general_ci |
| scaffold                 | tb_material_specs             | utf8mb3_general_ci |
| scaffold                 | tb_materials_plan             | utf8mb3_general_ci |
| scaffold                 | tb_materials_return           | utf8mb3_general_ci |
| scaffold                 | tb_project_inout_detail       | utf8mb3_general_ci |
| scaffold                 | tb_project_inout_detail_log   | utf8mb3_general_ci |
| scaffold                 | tb_projects                   | utf8mb3_general_ci |
| scaffold                 | tb_projects_inout             | utf8mb3_general_ci |
| scaffold                 | tb_projects_plan              | utf8mb3_general_ci |
| scaffold                 | tb_realtime_order             | utf8mb3_general_ci |
| scaffold                 | tb_realtime_order_audit       | utf8mb3_general_ci |
| scaffold                 | tb_realtime_order_detail      | utf8mb3_general_ci |
| scaffold                 | tb_realtime_order_sure        | utf8mb3_general_ci |
| scaffold                 | tb_rental_type                | utf8mb3_general_ci |
| scaffold                 | tb_rental_units               | utf8mb3_general_ci |
| scaffold                 | tb_warehouse_access           | utf8mb3_general_ci |
| scaffold                 | tb_warehouse_detail           | utf8mb3_general_ci |
| scaffold                 | tb_warehouse_detail_log       | utf8mb3_general_ci |
| scaffold                 | tb_warehouse_rental           | utf8mb3_general_ci |
| scaffold                 | ums_admin                     | utf8mb3_general_ci |
| scaffold                 | ums_admin_login_log           | utf8mb3_general_ci |
| scaffold                 | ums_admin_permission_relation | utf8mb3_general_ci |
| scaffold                 | ums_admin_role_relation       | utf8mb3_general_ci |
| scaffold                 | ums_menu                      | utf8mb3_general_ci |
| scaffold                 | ums_organization_belongs      | utf8mb3_general_ci |
| scaffold                 | ums_permission                | utf8mb3_general_ci |
| scaffold                 | ums_resource                  | utf8mb3_general_ci |
| scaffold                 | ums_resource_category         | utf8mb3_general_ci |
| scaffold                 | ums_role                      | utf8mb3_general_ci |
| scaffold                 | ums_role_menu_relation        | utf8mb3_general_ci |
| scaffold                 | ums_role_permission_relation  | utf8mb3_general_ci |
| scaffold                 | ums_role_resource_relation    | utf8mb3_general_ci |
| scaffold                 | web_log                       | utf8mb3_general_ci |
+--------------------------+-------------------------------+--------------------+

+--------------+-------------------+-------------+--------------------------+-------+
| TABLE_SCHEMA | TABLE_NAME        | COLUMN_NAME | COLUMN_TYPE              | EXTRA |
+--------------+-------------------+-------------+--------------------------+-------+
| scaffold     | tb_category       | flag        | int(1) unsigned zerofill |       |
| tb           | material_category | flag        | int(1) unsigned zerofill |       |
+--------------+-------------------+-------------+--------------------------+-------+

-- 


```



```mysql
show open tables from mysql where in_use > 0;


alter table users modify column username varchar(50) null;

create index idx_username on users(username);


SELECT table_name AS                                          `Table`,
       round(((data_length) / 1024 / 1024), 2)                `table_size`,
       round(((index_length) / 1024 / 1024), 2)               `index_size`,
       round(((data_length + index_length) / 1024 / 1024), 2) `total_size`
FROM information_schema.TABLES
WHERE table_schema = 'intelligent_construction'
group by table_name;


select name,space_type,fs_block_size,file_size,autoextend_size,state from innodb_tablespaces ;

    AND table_name = 'your_table_name';
CopyInsert
将 your_database_name 替换为你的数据库名称，将 your_table_name 替换为你的表名称。

查看数据库大小
```


#### `binlog`

```text
在MySQL中，二进制日志（Binary Log，简称binlog）是一个非常重要的组件，它记录了数据库中所有更改数据的语句（如INSERT、UPDATE、DELETE等），
主要用于数据恢复、主从复制和审计等场景。

主要功能
数据恢复：通过回放binlog，可以将数据库恢复到某个特定的时间点。
主从复制：在主从复制架构中，主服务器将binlog发送给从服务器，从服务器通过回放binlog来同步主服务器的数据。
审计：通过分析binlog，可以了解数据库中发生的所有更改操作，用于审计和合规性检查。

配置
要启用binlog，需要在MySQL配置文件（通常是 my.cnf 或 my.ini）中进行配置。以下是一些常见的配置项：

[mysqld]
log-bin=/path/to/binlog/files/mysql-bin
server-id=1
binlog_format=ROW
expire_logs_days=7

log-bin：指定binlog文件的存储路径和前缀。
server-id：在主从复制中，每个服务器需要有一个唯一的ID。
binlog_format：指定binlog的格式，可以是 ROW、STATEMENT 或 MIXED。
ROW：记录每一行的更改。
STATEMENT：记录SQL语句。
MIXED：混合使用 ROW 和 STATEMENT。
expire_logs_days：指定binlog文件的过期天数，自动删除过期的binlog文件。


-- 查看binlog
SHOW MASTER STATUS;

SHOW BINARY LOGS;
SHOW BINLOG EVENTS IN 'binlog.000026' limit 20;


mysqlbinlog /path/to/binlog/files/mysql-bin.000001


SHOW EFFECTIVE GRANTS;

FLUSH TABLE_STATISTICS;

SHOW TABLE STATUS ;

```

```mysql
 DDL日志 (DDL Log)
DDL日志记录了数据定义语言（DDL）操作，如CREATE、ALTER、DROP等。这个日志在MySQL 8.0中引入，用于跟踪和恢复DDL操作。

配置项： DDL日志通常不需要手动配置，MySQL会自动管理。


事务日志（也称为重做日志或InnoDB日志）记录了InnoDB存储引擎的事务操作，用于确保事务的持久性和崩溃恢复。

配置项：

[mysqld]
innodb_log_file_size=50M
innodb_log_files_in_group=2
innodb_log_group_home_dir=/var/lib/mysql/


[mysqld]
ddl_log_enabled=ON
CopyInsert
2. 配置DDL日志文件路径
你可以指定DDL日志文件的路径和名称。如果没有指定，MySQL会使用默认路径和名称。

[mysqld]
ddl_log_file=/var/lib/mysql/ddl_log.log
```


```shell
ls -l /dev/mapper
```


```text
wsrep_flow_control_paused 是 Percona XtraDB Cluster (PXC) 中的一个状态变量，用于指示集群中节点的流控制状态。流控制（Flow Control）是 PXC 中的一种机制，用于平衡集群中各个节点的负载，防止某个节点因为处理速度过慢而成为瓶颈，从而影响整个集群的性能和稳定性。

作用
wsrep_flow_control_paused 的值表示节点在流控制机制下暂停的时间比例。具体来说，它的值范围是 0 到 1，其中：

0 表示节点没有因为流控制而暂停。
1 表示节点完全处于暂停状态。
当 wsrep_flow_control_paused 的值接近 1 时，说明节点因为处理速度跟不上其他节点，导致频繁暂停，这可能会影响集群的整体性能。

监控和优化
通过监控 wsrep_flow_control_paused 的值，可以及时发现集群中的性能瓶颈，并采取相应的优化措施。以下是一些常见的优化方法：

增加资源：如果某个节点的硬件资源（如 CPU、内存、磁盘 I/O）不足，可以考虑增加该节点的资源配置。
优化查询：检查并优化慢查询，减少节点的处理负载。
调整流控制参数：可以调整 PXC 的流控制参数，如 wsrep_fc_limit 和 wsrep_fc_factor，以更好地适应集群的负载情况。
增加节点：如果集群的负载较高，可以考虑增加新的节点，以分担现有节点的负载。
示例查询
你可以使用以下 SQL 查询来查看 wsrep_flow_control_paused 的值：

SHOW GLOBAL STATUS LIKE 'wsrep_flow_control_paused';
CopyInsert
输出可能如下：

+----------------------------+--------+
| Variable_name              | Value  |
+----------------------------+--------+
| wsrep_flow_control_paused  | 0.0000 |
+----------------------------+--------+
CopyInsert
解释
Variable_name: wsrep_flow_control_paused
Value: 表示节点在流控制机制下暂停的时间比例。
通过定期监控 wsrep_flow_control_paused 的值，并采取相应的优化措施，可以确保 PXC 集群的高性能和稳定性。
```

```text
3）检测复制的健康状态



mysql> show status like 'wsrep_flow_control_paused';



通过检查变量wsrep_flow_control_paused的值，
可以确认有多少slave延迟在拖慢整个集群的，从而查看复制的健康状态。这个值越接近0.0越好，
优化的方法主要通过增加配置文件中wsrep_slave_threads的值，或者将复制很慢的节点剔除出集群。
wsrep_slave_threads取值可以参考wsrep_cert_deps_distance，wsrep_cert_deps_distance表示并发事务处理数的均值，
wsrep_slave_threads的值不应该比wsrep_cert_deps_distance高很多。    (wsrep_applier_threads)


4）检测网络慢的问题



mysql> show status like 'wsrep_local_send_queue_avg';



通过检查变量wsrep_local_send_queue_avg的值，可以检测网络状态。如果此变量的值偏高，说明网络连接可能是瓶颈。造成此情况的原因可能出现在物理层或操作系统层的配置上。


1、打开复制引擎的调试信息-wsrep_debug



在运行过程中，可以通过set global wsrep_debug = 'ON'；来动态地打开wsrep的调试信息（调试信息会输入到错误日志中），可以帮助复制引擎定位问题。


1）监控集群的一致性



mysql>show status like 'wsrep_cluster_state_uuid';



通过检查变量wsrep_cluster_state_uuid的值，确认此节点是否属于正确的集群。该变量的值在集群的各个节点中必须相同，如果某个节点出现不同的值，说明此节点没有连接到集群中。



mysql>show status like 'wsrep_cluster_conf_id';



通过检查变量wsrep_cluster_conf_id的值，用于查看集群发生变化的总数，同时确认此节点是否属于主集群。该变量的值在集群的各个节点中必须相同，如果某个节点出现不同的值，说明此节点脱离集群了，需要检查网络连接等将其恢复到一致的状态。



mysql>show status like 'wsrep_cluster_size';



通过检查变量wsrep_cluster_size的值，查看集群节点的总数。



mysql> show status like 'wsrep_cluster_status';



通过检查变量wsrep_cluster_status的值，查看节点的状态是否为Primary，若不为Primary，表示集群部分节点不可用，甚至可能是集群出现了脑裂。



如果所有节点的状态都不为Primary，就需要重置仲裁，如果不能重置仲裁，就需要手动重启。



第一步，关闭所有节点



第二步，重启各个节点，重启过程中可以参考wsrep_last_committed的值确定主节点。



注：手动重启的缺点是会造成缓存丢失，从而不能做IST。



2）监控节点状态



mysql> show status like 'wsrep_ready';



通过检查变量wsrep_ready的值，查看该节点的状态是否可以正常使用SQL语句。如果为ON，表示正常，若为OFF，需进一步检查wsrep_connected的值。



mysql> show status like 'wsrep_connected';



如果此变量的值为OFF，说明该节点还没有加入到任何一个集群组件中，这很可能是因为配置文件问题，例如wsrep_cluster_address或者wsrep_cluster_name值设置错误，也可以通过查看错误日志进一步定位原因。



如果节点连接没有问题，但wsrep_ready的值还为OFF，检查wsrep_local_state_comment的值。



mysql> show status like 'wsrep_local_state_comment';



当节点的状态为Primary时，wsrep_local_state_comment的值一般为Joining, Waiting for SST, Joined, Synced或者Donor，如果wsrep_ready为OFF，并且wsrep_local_state_comment的值为Joining, Waiting for SST, Joined其中一个，说明此节点正在执行同步。



当节点的状态不为Primary时，wsrep_local_state_comment的值应该为Initialized。任何其他状态都是短暂的或临时的。


https://zhuanlan.zhihu.com/p/679494969
```


```text

innodb_flush_method=O_DIRECT
set global foreign_key_checks=off;
set global max_allowed_packet=671088640;
```


```shell
select * from performance_schema.pxc_cluster_view;
```



```text
[root@mysql-02 etc]# cat /var/lib/mysql/grastate.dat
# GALERA saved state
version: 2.1
uuid:    b097fc61-69d8-11ef-beef-b71208f38786
seqno:   -1
safe_to_bootstrap: 0
```

- `version`：表示`Galera`集群的版本号。
- `uuid`：表示`Galera`集群的唯一标识符。
- `seqno`：表示`Galera`集群中最后一次提交的事务序列号。运行中，正常关闭`Galera`集群时，`seqno`的值为`-1`。
- `safe_to_bootstrap`：表示`Galera`集群是否可以安全引导。集群最后一个关闭的为`1`，其它为`0`。

```shell
awk 'NR>=175436 && NR<242348' b.sql > b1.sql
awk 'NR>=19091 && NR<99482' b.sql > b2.sql



sed -i -e '30,1082d' -e '19809,33311d' -e '/^LOCK TABLES/d' -e '/^UNLOCK TABLES/d' a.sql
set sql_log_bin=off;
mysql -uics_admin -p --show-warnings --tee=/tmp/20240915.log


--
sed -i '1,962d' aa.sql
```



```mysql
show master logs;
purge binary logs to 'log_name';
purge BINARY logs before '2024-09-04 12:00:00';
```






#### 用户

```mysql
create user 'sbuser'@'10.50.%.%' identified with mysql_native_password BY '*138DD22E166357A46C6701892C5BB314770E8438';
grant all on *.* to'sbuser'@'10.50.%.%';
flush privileges;

drop user 'sbuser'@'%';

CREATE USER 'zs_read'@'10.50.%' IDENTIFIED BY PASSWORD '*6A888EA5153B88285D0937CFC9D5F215D212363D';


*138DD22E166357A46C6701892C5BB314770E8438


insert into mysql.user
select * from user where host like '10.50.%.%';



ALTER USER 'ics_api'@'%' IDENTIFIED WITH mysql_native_password BY 'your_password';
```


```shell
# 查看进程号
pgrep mysqld

# 查看线程数
cat /proc/27293/status | grep -i threads
```





### 从库

```mysql
-- 主库启用`binlog`和设置server_id
select @@log_bin,@@server_id;

-- 在主库上创建复制用户
create user 'pxc_repl'@'192.168.%.%' identified with mysql_native_password by 'pxc_repl_password';
grant replication slave on *.* to 'pxc_repl'@'192.168.%.%';
flush privileges;

show grants for 'pxc_repl'@'192.168.%.%';

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



```mysql

-- rn_project_worker_allocation     2673030
-- rn_corp_worker                   1783686
-- ics_worker                       1459237
-- alter table ics_worker add fulltext(name);
-- create index idx_work_id on rn_project_worker_allocation(worker_id); 
-- alter table rn_project_worker_allocation add key(worker_id);
-- select * from ics_worker where MATCH(name) AGAINST('*仇仕*' IN BOOLEAN MODE);
{{ics_api}}/api/v1.0/projectworker/queryUnreceiveProjectWorkerSelect
select DISTINCT t1.`id`,concat(t1.`name`,'【',INSERT(t1.id_number, 1, 14, '******' ),'】') as name,'' as idnumber 
from rn_project_worker_allocation t 
LEFT JOIN rn_corp_worker t2 ON t2.corp_id=t.corp_id AND t2.worker_id=t.worker_id
INNER JOIN ics_worker t1 on t.worker_id=t1.id 
where t.is_deleted=0 and (t1.name like '%仇仕%' or t1.id_number like '%仇仕%')
LIMIT 0,10;

select DISTINCT t1.`id`,concat(t1.`name`,'【',INSERT(t1.id_number, 1, 14, '******' ),'】') as name,'' as idnumber
from rn_project_worker_allocation t
         LEFT JOIN rn_corp_worker t2 ON t2.corp_id=t.corp_id AND t2.worker_id=t.worker_id
         INNER JOIN ics_worker t1 on t.worker_id=t1.id
    where t.is_deleted=0 and MATCH(t1.name) AGAINST('*仇仕*' IN BOOLEAN MODE)
LIMIT 0,10;


{{ics_api}}/api/v1.0/projectworker/SaveManagerEmployeeEntry
{{ics_api}}/api/v1.0/projectworker/SaveManagerEmployeeExit
UPDATE `rn_project_worker_ext`
SET `Access_Status`=0,`Access_Sync_Time`=timestamp('2024-08-31 08:09:28.358291'),`modified_on`=timestamp('2024-08-31 08:09:28.358291')
,`Worker_Operation_Status`=3,`Worker_Operation_Msg`=''
,`exit_date`=timestamp('2024-08-31 08:09:28.358291')
WHERE id='6e18b9f2-0174-4cbf-bfd5-51551c16c2dd';

{{ics_api}}/api/v1.0/Analysis/GetLearningCompliance
select  ip.name as projectName,count(distinct rpw.worker_id) as total,count(distinct scpw.worker_id) as pass
from ics_project ip
left join rn_project_worker rpw on ip.id = rpw.project_id
left join se_course_project_worker scpw on rpw.project_id = scpw.project_id and scpw.worker_id = rpw.worker_id
WHERE scpw.is_deleted=0 and DATE_FORMAT(scpw.created_on, '%Y-%m-%d')>='2024-08-01' and DATE_FORMAT(scpw.created_on, '%Y-%m-%d')<='2024-08-31'  and scpw.project_id in ('3f45ed92-b3eb-40f1-8045-ff90c9441a42')  or scpw.id is null 
group by ip.id
order by count(distinct scpw.worker_id) desc,count(distinct rpw.worker_id) asc
limit 10;

{{ics_api}}/api/v1.0/ProjectWorkerIdentify/Paging
SELECT t1.id,t1.worker_id AS workerId,t.worker_name AS workerName,t1.`time` AS attendanceTime,t1.direction,t1.from_area_name AS fromAreaName,t1.to_area_name AS toAreaName,t1.temperature AS temperature
,t1.file_id AS 'FileId'
,t.corp_name AS corpName,t.team_name AS teamName,t2.name AS projectName
FROM rn_project_worker_identify t1
LEFT JOIN rn_project_worker t ON t.project_id=t1.project_id AND t.worker_id=t1.worker_id
LEFT JOIN ics_project t2 ON t2.id=t1.project_id
where 1=1 and t.project_id='667c2385-65ac-49a6-be1a-fdba906334fa' and t1.time >= timestamp('2024-08-18 00:00:00') and t1.time <= timestamp('2024-08-20 00:00:00') 
ORDER BY t1.`time` DESC
LIMIT 400,100;

{{ics_api}}/api/v1.0/RnProject/GetList
SELECT t.*,i.worker_name AS name,i.team_name,i.corp_name,i.work_type_name,i.corp_id,i.team_id
FROM rn_project_worker_identify t
LEFT JOIN rn_project_worker i ON i.project_id=t.project_id AND i.worker_id =t.worker_id
where 1=1 and t.project_id = '12362484-1e37-4f45-a744-63a6e41b9b79' 
ORDER BY t.time DESC
LIMIT 0,10;

参建单位(专业分包)-项目人员查询
{{ics_api}}/api/v1.0/Corporation/QueryProjectWorkPaging
SELECT rcw.id,rcw.corp_id AS corpId,rcw.team_id AS teamId,rcw.worker_id AS workerId
,rcw.role,rcw.work_type_code AS workTypeCode,rcw.work_type_name AS workTypeName
,iw.name AS workerName,iw.id_number AS idNumber,iw.gender,iw.birthday,iw.phone
,rct.name AS teamName
,rpwa.project_id AS projectId,rpwa.`status`,rpwa.entry_exit_status AS entryExitStatus
,rpc.parent_corp_name AS ParentCorpName
,rpc.corp_name AS corpName
,ip.name AS projectName
FROM rn_corp_worker rcw
INNER JOIN ics_worker iw ON iw.id=rcw.worker_id
INNER JOIN rn_corp_team rct ON rct.id=rcw.team_id
INNER JOIN rn_project_worker_allocation rpwa ON rpwa.corp_id=rcw.corp_id AND rpwa.worker_id=rcw.worker_id
INNER JOIN rn_project_corp rpc ON rpc.id=rpwa.project_corp_id
INNER JOIN ics_project ip ON ip.id=rpwa.project_id
where rcw.is_deleted=0 and iw.is_deleted=0 and rct.is_deleted=0 and rpwa.is_deleted=0 and rpc.is_deleted=0 and ip.is_deleted=0 and rpc.parent_corp_id='99df7cec-20c0-4d17-8bf5-9435c1114369' 
ORDER BY rpwa.project_id,rpwa.corp_id,rpwa.created_on DESC
LIMIT 0,10;
```

```mysql
-- 只能指定的表进行复制
replicate_wild_do_table=db02.sbtest1
replicate_wild_do_table=db02.sbtest2
```


```text
1. 主库正常停库，通过ist后，备库能正常追上。
2. 主库非正常停库，通过ist后，备库能正常追上。
3. sst的情况，binlog会丢失，重新生成，生成规律还没找到。
```


```text
-- 全局读锁
FLUSH TABLES WITH READ LOCK;
unlock tables;

mysqldump --lock-all-tables
```


### 模拟`wsrep_ready=off`

```shell
# mysql执行iptables
vim /etc/sudoers

mysql ALL=(ALL) NOPASSWD: /sbin/iptables

mysql    ALL = NOPASSWD: /sbin/iptables

# =========================== node1 ===========================#


# iptables
chmod u+s /usr/sbin/xtables-multi

```

```shell
Swap:
swapoff  -a


[root@mysql-04 ~]# free -g
              total        used        free      shared  buff/cache   available
Mem:              7           6           0           0           0           0
Swap:             0           0           0
[root@mysql-04 ~]# free -g
              total        used        free      shared  buff/cache   available
Mem:              7           7           0           0           0           0
Swap:             0           0           0
[root@mysql-04 ~]# free -g
              total        used        free      shared  buff/cache   available
Mem:              7           1           5           0           0           5
Swap:             0           0           0
[root@mysql-04 ~]# systemctl status mysql
Unit mysql.service could not be found.
[root@mysql-04 ~]# systemctl status mysqld
● mysqld.service - MySQL Server
   Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
   Active: activating (start) since Fri 2024-09-13 14:10:44 CST; 19s ago
     Docs: man:mysqld(8)
           http://dev.mysql.com/doc/refman/en/using-systemd.html
  Process: 11104 ExecStartPre=/usr/bin/mysqld_pre_systemd (code=exited, status=0/SUCCESS)
 Main PID: 11128 (mysqld)
   Status: "Server startup in progress"
   CGroup: /system.slice/mysqld.service
           └─11128 /usr/sbin/mysqld

Sep 13 14:10:44 mysql-04 systemd[1]: Starting MySQL Server...

[274272.750038] Out of memory: Kill process 10666 (mysqld) score 955 or sacrifice child
[274272.750136] Killed process 10666 (mysqld), UID 27, total-vm:14025996kB, anon-rss:7633856kB, file-rss:0kB, shmem-rss:0kB


[root@mysql-04 ~]# sysctl vm.overcommit_memory
vm.overcommit_memory = 0

vm.overcommit_memory = 0：
默认值：内核使用启发式算法来决定是否允许内存过度分配。
行为：内核会根据可用内存和交换空间的大小来决定是否允许进程申请更多的内存。如果内核认为系统内存不足，可能会拒绝某些内存分配请求。
适用场景：适用于大多数通用场景，系统会根据实际情况动态调整内存分配策略。


vm.overcommit_memory = 1：
行为：内核总是允许内存过度分配，即允许进程申请超过物理内存和交换空间总和的内存。
优点：可以最大化利用系统资源，允许进程申请更多的内存。
缺点：可能导致系统在内存不足时崩溃，因为内核无法满足所有内存分配请求。
适用场景：适用于内存需求较大的应用场景，如数据库服务器、虚拟化环境等。

vm.overcommit_memory = 2：
行为：内核禁止内存过度分配，即不允许进程申请超过物理内存和交换空间总和的内存。
优点：可以防止系统因内存不足而崩溃，确保系统稳定性。
缺点：可能会导致某些内存分配请求被拒绝，影响应用性能。
适用场景：适用于对内存使用有严格要求的场景，如实时系统、嵌入式系统等。


/etc/sysctl.conf

vm.overcommit_memory = 2
vm.overcommit_ratio = 80
vm.swappiness = 10


vm.overcommit_memory = 2
vm.overcommit_ratio = 80

sysctl -p




-- 永远不杀
# Start main service
ExecStart=/usr/sbin/mysqld $MYSQLD_OPTS
OOMScoreAdjust=-1000


原理差不多是这样的。

1。一个进程需要内存的时候，会向操作系统申请，操作系统不会给他说没有（当然这个应该也可以设置，一般是在数据库层就设置了，估计操作系统层也有）。
2。OS会去执行一个oom kill的操作，他会根据一定的规则 ，一个评分规则 去kill指定的规则，就算把这个打的最低分，和操作系统最底层的服务一个级别，但他还是一直在申请 内存
3。OS一直杀评分比他高的，但是他还在申请 ，就像池子放一样，放的水多，出的水少，不可能不溢出的。
4。最终把OS自己的进程都杀光了， 就重启了。


[root@mysql-04 ~]# pgrep mysqld
1379
[root@mysql-04 ~]# ps -T -p 1379



```

### 内存

#### 全局

- `innodb_buffer_pool_size` 定义用于缓存 InnoDB 数据和索引的缓冲池的大小，可用内存的 60% 到 80%。
- `innodb_log_buffer_size` 定义 InnoDB 日志缓冲区的大小，建议设置为 XX。
- `tmp_table_size`
- `max_heap_table_size`

#### 会话级

- `sort_buffer_size` : 排序操作的缓冲区大小。
- `join_buffer_size`
- `bulk_insert_buffer_size`

```text
在Linux系统中，OOM（Out of Memory）机制是用来防止系统因内存耗尽而崩溃的一种保护机制。当系统内存不足时，OOM Killer会选择并终止一些进程以释放内存资源。因此，完全禁止OOM Killer的操作是不建议的，因为这可能导致系统不稳定。

不过，你可以通过一些方式来降低OOM Killer的影响，或者提高某些进程被杀死的概率。以下是一些方法：

1. 调整进程的OOM优先级
你可以通过设置oom_score_adj值来对特定进程的OOM优先级进行调整。使用以下命令可以降低某个进程被杀死的概率：

echo -1000 > /proc/<pid>/oom_score_adj
CopyInsert
<pid>是你想要保护的进程的进程ID。
这个值的范围是从-1000（最不可能被杀死）到 +1000（最可能被杀死）。
2. 设置 vm.overcommit_memory 参数
可以通过调整Linux内核的内存过度分配设置来改变OOM的行为：

echo 2 > /proc/sys/vm/overcommit_memory
CopyInsert
0：表示根据当前内存的情况和进程的申请进行适度过度分配。
1：表示总是允许过度分配（不检查）。
2：表示不允许过度分配，只有在确保足够内存的情况下才能分配。
3. 使用 cgroups 进行资源限制
通过cgroups（控制组）可以限制特定组的资源使用，包括内存。这种方式可以保护关键应用不被OOM Killer终止：

cgcreate -g memory:/mygroup
echo 512M > /sys/fs/cgroup/memory/mygroup/memory.limit_in_bytes
CopyInsert
4. 调整 OOM Killer 的行为
你可以调整一些系统级参数来改变OOM Killer的行为，例如：

echo 0 > /proc/sys/kernel/panic_on_oom
CopyInsert
设置此值为0可以防止系统在OOM情况下无意中崩溃。

注意
虽然上述措施可以帮助管理OOM Killer的行为，但完全禁止它可能导致不可预见的后果，尤其是在内存资源非常紧张的情况下。建议做好服务的监控与报警，并合理设置系统的内存资源配置，以应对高负载情况下的内存管理问题。
```



```text
在Percona XtraDB Cluster（PXC）中，数据的同步机制是通过Galera库实现的。Galera 是一个多主复制插件，允许多个节点并行地执行写入操作，并确保数据在这些节点之间保持一致。下面是有关数据同步过程的详细说明：

数据同步机制
写操作和事务： 当一个节点执行写操作（如 INSERT、UPDATE 或 DELETE）时，该操作首先在本地节点上执行，并且事务在本地提交。

wsrep API 调用： 在事务提交后，节点使用 wsrep API（写时复制保证）将该写操作的信息（包括更改记录）发送到集群中的其他节点。这些信息通常被称为“更改集”（change set）。

并行复制：

当写操作被提交并发送到其他节点时，这个过程是并行的，所有相关节点都会接收这个更改集。
Galera 允许多个节点同时进行写操作，支持节点间的并行复制，提高了性能。
增量状态传输（IST）和全量状态传输（SST）：

IST（Incremental State Transfer）：用于在节点重新加入集群时，快速同步自节点上次状态以来所做的更改。
SST（State Snapshot Transfer）：当新节点加入集群时，可能需要进行全量数据同步，以便获得当前集群的完整数据。
确认机制：

每个节点在接收到更改集后，将这个更改应用到其本地数据中。数据同步的成功与否会通过一个确认机制进行核对，以确保所有节点的数据一致性。
只有当大多数节点确认接收到该更改后，事务才被认为是成功的并最终生效。
主要优势
数据一致性：Galera 确保数据在所有节点之间保持强一致性，这样每个节点都能看到相同的数据状态。
故障转移能力：由于每个节点都是主节点，任何节点的故障不会影响系统的整体可用性。
高可用性和负载均衡：多个节点可以同时处理写入请求，提高了系统的可用性和性能。
通过这些机制，PXC 中的写数据操作能够迅速且有效地同步到集群中的其他节点，确保数据的一致性和高可用性。
```

```mysql
create table t01(col01 int AUTO_INCREMENT PRIMARY KEY, col02 varchar(10));

DELIMITER //
CREATE PROCEDURE create_t01()
BEGIN
    insert into t01(col02) values('a');
END //
DELIMITER ;

CREATE USER 'u01'@'%' IDENTIFIED BY 'welcome';
grant execute on procedure create_t01 to 'u01'@'%';
grant SHOW_ROUTINE on *.* to 'u01'@'%';
FLUSH PRIVILEGES;
```