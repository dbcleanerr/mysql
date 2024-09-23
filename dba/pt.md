### `Percona Toolkit`

#### 安装

```shell
yum localinstall -y /tools/rpm/toolkit/*.rpm
```

#### `pt-config-diff`

```shell
# 二个配置文件的差异
pt-config-diff --report-width 200 /etc/my.cnf /tmp/my.cnf

# 配置文件和数据库的差异
pt-config-diff --report-width 200 /etc/my.cnf u=root p= S=/data/mysql/mysql.sock P=38809
```

pt-mysql-summary --user=root --password=welcome --host=localhost --port=3306
pt-summary
pt-mysql-summary --user=root --password=welcome --port=3306

# 类似于iostat命令，不过它比iostat输出的更加详细一点
pt-diskstats --interval=1 --iterations=10 --devices-regex=sda --show-timestamps

pt-diskstats --interval=1 --iterations=100 --show-timestamps

# iops
pt-diskstats --group-by sample --devices-regex sda --columns-regex io_s

# 分析慢查询日志
pt-query-digest --since=12h /var/log/mysql_slow.log
```