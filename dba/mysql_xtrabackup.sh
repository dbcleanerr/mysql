#!/bin/bash
#
set -Eeuo pipefail
# 此脚本只适用于mysql8版本,早先的5.6,5.7版本不能混用(会由tools变量做安装包检测)
# 从 Percona XtraBackup 8.0.34-29 开始，使用 qpress/QuickLZ 压缩备份已被弃用，并可能在未来版本中删除。官方建议使用LZ4或 Zstandard (ZSTD) 压缩算法

# crontab设置:(每天0点全备,其他时间每隔两小时一次增量)
# 0 0 * * * /home/backups/mysqlXtraBackup.sh full
# 0 2-22/2 * * * /home/backups/mysqlXtraBackup.sh incr
# 定时删除7天前的备份数据
# 0 6 * * * find /data/backups/mysql/old/ -mtime +7 -type f -delete
# 备份用户创建及权限配置(密码随机生成`openssl rand -base64 12 | cut -b 1-12`)
# mysql> CREATE USER 'bkpuser'@'127.0.0.1' IDENTIFIED BY 'welcome';
# mysql> GRANT BACKUP_ADMIN, PROCESS, RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'bkpuser'@'127.0.0.1';
# mysql> GRANT SELECT ON performance_schema.log_status TO 'bkpuser'@'127.0.0.1';
# mysql> GRANT SELECT ON performance_schema.replication_group_members to 'bkpuser'@'127.0.0.1';
# 下面这行在mysql8.0.24版本及后续版本才有
# mysql> GRANT SELECT ON performance_schema.keyring_component_status TO bkpuser@'127.0.0.1';
# mysql> FLUSH PRIVILEGES;

# 备份相关基础路径(必填!!!)
BACKUPDIR=/dbbackup
# 全量备份目录
Full=$BACKUPDIR/full
# 增量备份目录
Incr=$BACKUPDIR/incr
# 备份归档路径
Old=$BACKUPDIR/old
# 日志路径
baklog=$BACKUPDIR/backup.log
# 日期信息,用于区分当天备份用于归档
# TODAY=$(date +%Y%m%d%H%M)
YESTERDAY=$(date -d"yesterday" +%Y%m%d)

# Mysql实例相关信息(必填!!!)
MYSQL=/home/mysql/bin/mysql
MYSQLADMIN=/home/mysql/bin/mysqladmin
DB_HOST='localhost' # 填写localhost时,会尝试使用socket连接
DB_PORT=3306 # 这里没有用到,需要的话,在备份命令也加上端口参数
DB_USER='bkpuser'
DB_PASS='fp9esYgBh/e8'
DB_SOCK=/var/lib/mysql/mysql.sock
DB_CONF=/etc/my.cnf
XTRABACKUP=/usr/local/percona-xtrabackup-8.0.35/bin/xtrabackup

# 备份必备工具检查(压缩备份需要zstd)
tools="zstd pigz"
# Check packages before proceeding
for i in $tools; do
  if ! [[ $(rpm -qa $i) =~ ${i} ]]; then
    echo -e " Needed package $i not found.\n Pre check failed !!!"
    exit 1
  fi
done

# mysql 运行状态监测
if [ -z "$($MYSQLADMIN --host=$DB_HOST --socket=${DB_SOCK} --user=$DB_USER --password=$DB_PASS --port=$DB_PORT status | grep 'Uptime')" ]; then
  echo -e "HALTED: MySQL does not appear to be running or incorrect username and password"
  exit 1
fi

# 备份用户名密码监测 # 好像有点多余...
if ! $(echo 'exit' | $MYSQL -s --host=$DB_HOST --socket=${DB_SOCK} --user=$DB_USER --password=$DB_PASS --port=$DB_PORT); then
  echo -e "HALTED: Supplied mysql username or password appears to be incorrect (not copied here for security, see script)."
  exit 1
fi

####################################################
#归档备份函数(全量时自动触发)
####################################################
function Xtr_tar_backup() {
# if [ ! -d "${Old}" ]; then
72 # mkdir ${Old}
73 # fi74 for i in $Full $Incr $Old; do
75 if [ ! -d $i ]; then
76 mkdir -pv $i
77 fi
78 done
79 # 压缩上传前一天的备份
80 echo "压缩前一天的备份，移动到${Old}"
81 cd $BACKUPDIR
82 tar --use-compress-program=pigz -cvpf $YESTERDAY.tar.gz ./full/ ./incr/
83 #scp -P 8022 $YESTERDAY.tar.gz root@192.168.10.46:/data/backup/mysql/
84 mv $YESTERDAY.tar.gz $Old
85 if [ $? = 0 ]; then
86 rm -rf $Full $Incr
87 echo "Tar old backup succeed" | tee -a ${baklog} 2>&1
88 else
89 echo "Error with old backup." | tee -a ${baklog} 2>&1
90 fi
91 }
92
93 ####################################################
94 #全量备份函数(手动触发)
95 ####################################################
96 function Xtr_full_backup() {
97 if [ ! -d "${Full}" ]; then
98 mkdir ${Full}
99 fi
100 Xtr_tar_backup
101 # 第一步 创建本次的备份目录
102 FullBakTime=$(date +%Y%m%d-%H%M%S)
103 mkdir -p ${Full}/${FullBakTime}
104 FullBakDir=${Full}/${FullBakTime}
105 # 第二步 开始全量备份
106 echo -e "备份时间: ${FullBakTime}\n" | tee -a ${baklog} 2>&1
107 echo -e "本次全量备份目录为 ${FullBakDir}\n" | tee -a ${baklog} 2>&1
$XTRABACKUP --defaults-file=${DB_CONF} --host=${DB_HOST} --port=$DB_PORT --
user=${DB_USER} --password=${DB_PASS} --socket=${DB_SOCK} --backup --galera-info --
compress --compress-threads=4 --target-dir=${FullBakDir}
108
109 dirStorage=$(du -sh ${FullBakDir})
110 echo -e "本次备份数据 ${dirStorage}\n" | tee -a ${baklog} 2>&1
111 echo -e "备份完成...\n\n\n" | tee -a ${baklog} 2>&1112 exit 0
113 }
114
115 ####################################################
116 #增量备份函数(手动触发)
117 ####################################################
118 function Xtr_incr_backup() {
119 # 第一步 获取上一次全量备份和增量备份信息
120 if [ ! -d "${Incr}" ]; then
121 mkdir ${Incr}
122 fi
123 LATEST_INCR=$(find $Incr -mindepth 1 -maxdepth 1 -type d | sort -nr | head -1)
124 LATEST_FULL=$(find $Full -mindepth 1 -maxdepth 1 -type d | sort -nr | head -1)
125 if [ ! $LATEST_FULL ]; then
126 echo "xtrabackup_info does not exist. Please make sure full backup exist."
127 exit 1
128 fi
129 echo "LATEST_INCR=$LATEST_INCR"
130 if [ ! -d "${Incr}" ]; then
131 mkdir ${Incr}
132 fi
133 # 判断上一次的备份路径,如果增量备份路径为空,则使用全量备份路径为--incremental-basedir
134 if [ ! $LATEST_INCR ]; then
135 CompliteLatestFullDir=$LATEST_FULL
136 else
137 CompliteLatestFullDir=$LATEST_INCR
138 fi
139 # 第二步 创建备份目录
140 IncrBakTime=$(date +%Y%m%d-%H%M%S)
141 mkdir -p ${Incr}/${IncrBakTime}
142 IncrBakDir=${Incr}/${IncrBakTime}
143 # 第三步 开始增量备份
144 echo -e "日期: ${IncrBakTime}\n" | tee -a ${baklog} 2>&1
echo -e "本次备份为基于上一次备份${CompliteLatestFullDir}的增量备份\n" | tee -a
${baklog} 2>&1
145
146 echo -e "本次增量备份目录为: ${IncrBakDir}\n" | tee -a ${baklog} 2>&1
$XTRABACKUP --defaults-file=${DB_CONF} --host=${DB_HOST} --port=$DB_PORT --
user=${DB_USER} --password=${DB_PASS} --socket=${DB_SOCK} --backup --galera-info --
compress --compress-threads=4 --parallel=4 --target-dir=${IncrBakDir} --incrementalbasedir=${CompliteLatestFullDir}
147
148 dirStorage=$(du -sh ${IncrBakDir})149 echo -e "本次备份数据 ${dirStorage}\n" | tee -a ${baklog} 2>&1
150 echo -e "备份完成...\n\n\n" | tee -a ${baklog} 2>&1
151 exit 0
152 }
153
154 ####################################################
155 #主体备份函数
156 ####################################################
157 function printInfo() {
158 echo "Your choice is $1"
159 }
160 case $1 in
161 "full")
162 echo "Your choice is $1"
163 Xtr_full_backup
164 ;;
165 "incr")
166 echo "Your choice is $1"
167 Xtr_incr_backup
168 ;;
169 *)
170 echo -e "No parameters specified!\nFor example:\n$0 full\n$0 incr"
171 ;;
172 esac
173 exit 0