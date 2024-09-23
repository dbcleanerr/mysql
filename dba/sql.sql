SELECT thread_id,
       substring_index(name, '/', -2) AS thread_name,
       if(type = 'BACKGROUND', '*', '') B,
       PROCESSLIST_ID as pid
 FROM performance_schema.threads;