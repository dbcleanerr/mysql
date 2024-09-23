### `xtrabackup`

#### `xtrabackup`工作原理

- `xtrabackup`复制`InnoDB`数据文件，这会导致数据文件不一致。
- `xtrabackup`会在启动时记住日志序列号(LSN)，然后复制数据文件，这需要一段时间，同时，`xtrabackup`运行一个后台进程，用于监视事务日志文件，并从中复制更改

#### 安装

```shell
yum localinstall percona-xtrabackup-80-8.0.33-28.1.el7.x86_64.rpm
```

#### 三个阶段

- 备份阶段 : 将物理文件拷贝到备份目录，并生成备份日志。
- `Prepare`阶段 : 应用`binlog`，将数据文件恢复到一致状态。
- 恢复阶段 ; 将备份文件恢复到数据库目录。

```shell
# --backup : 发起全量备份
# --parallel : 并行备份线程数
# --target-dir : 备份目录
# --compress : 压缩备份文件
xtrabackup --backup \
    -uroot -H127.0.0.1 -P3306 -p \
    --parallel=5 \
    --compress \
    --target-dir=/data/backup/backup_`date +%Y%m%d_%H%M%S`
    
-- backup-my.cnf : 记录Innodb引擎的参数，会在prepare阶段用到。
-- xtrabackup_logfile : 该文件用来保存拷贝的redo log
-- xtrabackup_info : 该文件中，记录备份的详细信息


# prepare阶段
# 之前必须要先解压，会保留解压前的文件(可以指定--remove-original参数)
xtrabackup --decompress --parallel=5 --target-dir=/data/backup/backup_20240905_162555


xtrabackup --backup \
    -uroot -H -P3306 -p \
    --parallel=5 \
    --compress \
    --target-dir=/data/backup/backup_`date +%Y%m%d_%H%M%S`

```