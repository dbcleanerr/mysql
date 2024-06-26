```mysql
-- 建表
mysql> create table t01
    -> (
    ->     id     int auto_increment primary key,
    ->     detail json
    -> );
Query OK, 0 rows affected (0.01 sec)

-- 插入数据
mysql> insert into t01(detail)
    -> values('{"name":"张三丰","age":20,"address":"beijing"}');
Query OK, 1 row affected (0.01 sec)

mysql> insert into t01(detail)
    -> values('{"name":"土行孙","age":18,"address":"shanghai"}');
Query OK, 1 row affected (0.00 sec)

-- 查询数据
mysql> select id,
    ->        detail ->'$.name',
    ->        detail ->>'$.name'
    ->   from t01;
+----+-------------------+--------------------+
| id | detail ->'$.name' | detail ->>'$.name' |
+----+-------------------+--------------------+
|  1 | "张三丰"          | 张三丰             |
|  2 | "土行孙"          | 土行孙             |
+----+-------------------+--------------------+
2 rows in set (0.00 sec)
              
-- 格式化输出
mysql> select id, json_pretty(detail) as json from t01 ;
+----+-----------------------------------------------------------------+
| id | json                                                            |
+----+-----------------------------------------------------------------+
|  1 | {
  "age": 20,
  "name": "张三丰",
  "address": "beijing"
}     |
|  2 | {
  "age": 18,
  "name": "土行孙",
  "address": "shanghai"
}    |
+----+-----------------------------------------------------------------+
2 rows in set (0.00 sec)
              
-- 更新，有就更新，没有就新增
mysql> select id,
    ->        detail,
    ->        json_set(json_set(detail, '$.phone','135'), '$.address','nanjing') as detail2
    ->   from t01 where id = 1 ;
+----+--------------------------------------------------------+------------------------------------------------------------------------+
| id | detail                                                 | detail2                                                                |
+----+--------------------------------------------------------+------------------------------------------------------------------------+
|  1 | {"age": 20, "name": "张三丰", "address": "beijing"}    | {"age": 20, "name": "张三丰", "phone": "135", "address": "nanjing"}    |
+----+--------------------------------------------------------+------------------------------------------------------------------------+
1 row in set (0.00 sec)
             
-- 新增, 只新增，不更新
mysql> select id,
    ->        detail,
    ->        json_insert(detail, '$.address', 'nanjing') as detail2
    ->   from t01 where id = 1 ;
+----+--------------------------------------------------------+--------------------------------------------------------+
| id | detail                                                 | detail2                                                |
+----+--------------------------------------------------------+--------------------------------------------------------+
|  1 | {"age": 20, "name": "张三丰", "address": "beijing"}    | {"age": 20, "name": "张三丰", "address": "beijing"}    |
+----+--------------------------------------------------------+--------------------------------------------------------+
1 row in set (0.00 sec)

mysql>
mysql>
mysql> select id,
    ->        detail,
    ->        json_insert(detail, '$.phone', '135') as detail2
    ->   from t01 where id = 1 ;
+----+--------------------------------------------------------+------------------------------------------------------------------------+
| id | detail                                                 | detail2                                                                |
+----+--------------------------------------------------------+------------------------------------------------------------------------+
|  1 | {"age": 20, "name": "张三丰", "address": "beijing"}    | {"age": 20, "name": "张三丰", "phone": "135", "address": "beijing"}    |
+----+--------------------------------------------------------+------------------------------------------------------------------------+
1 row in set (0.00 sec)
             
-- 只替换，不新增
mysql> select id,
    ->        detail,
    ->        json_replace(detail, '$.address', 'nanjing') as detail2
    ->   from t01 where id = 1 ;
+----+--------------------------------------------------------+--------------------------------------------------------+
| id | detail                                                 | detail2                                                |
+----+--------------------------------------------------------+--------------------------------------------------------+
|  1 | {"age": 20, "name": "张三丰", "address": "beijing"}    | {"age": 20, "name": "张三丰", "address": "nanjing"}    |
+----+--------------------------------------------------------+--------------------------------------------------------+
1 row in set (0.00 sec)
             
-- 删除
mysql> select id,
    ->        detail,
    ->        json_remove(detail, '$.address') as detail2
    ->   from t01 where id = 1 ;
+----+--------------------------------------------------------+----------------------------------+
| id | detail                                                 | detail2                          |
+----+--------------------------------------------------------+----------------------------------+
|  1 | {"age": 20, "name": "张三丰", "address": "beijing"}    | {"age": 20, "name": "张三丰"}    |
+----+--------------------------------------------------------+----------------------------------+
1 row in set (0.00 sec)
```