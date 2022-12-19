docker-compose exec -T ksqldb-cli ksql http://ksqldb-server:8088 <<-EOF
    show topics;

    set 'commit.interval.ms'='2000';
    set 'cache.max.bytes.buffering'='10000000';
    set 'auto.offset.reset'='earliest';
    set 'ksql.streams.replication.factor'='1';

    CREATE STREAM users_src WITH (KAFKA_TOPIC='demo.company.users', VALUE_FORMAT='AVRO',KEY_FORMAT='JSON', WRAP_SINGLE_VALUE=false);

    CREATE OR REPLACE STREAM users_src_new WITH (
    KAFKA_TOPIC='USERS_SRC_NEW', PARTITIONS=1, REPLICAS=1,
    VALUE_FORMAT='AVRO',KEY_FORMAT='JSON'
)   AS
    select EXTRACTJSONFIELD(ROWVAL, '$.operationType') AS operationType,EXTRACTJSONFIELD(ROWVAL, '$.documentKey._id') AS _id, CAST(EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.user_id') AS INTEGER) AS user_id,EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.first_name') AS first_name,EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.last_name') AS last_name,EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.email') AS email,EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.gender') AS gender,EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.address') AS address,EXTRACTJSONFIELD(ROWVAL, '$.ns.db') AS database_name, EXTRACTJSONFIELD(ROWVAL, '$.ns.coll') AS collection_name, rowtime AS time from users_src emit changes;

    CREATE STREAM users_src_rekey WITH (PARTITIONS=1) AS \ select * from users_src_new partition by user_id;

    CREATE TABLE users_tbl (USER_ID INTEGER PRIMARY KEY, OPERATIONTYPE STRING,_ID STRING,FIRST_NAME STRING,LAST_NAME STRING,EMAIL STRING,GENDER STRING, ADDRESS STRING,DATABASE_NAME STRING,COLLECTION_NAME STRING, TIME BIGINT)\ WITH (KAFKA_TOPIC='USERS_SRC_REKEY', VALUE_FORMAT='AVRO',KEY_FORMAT='JSON');




    CREATE STREAM roles_src WITH (KAFKA_TOPIC='demo.company.roles', VALUE_FORMAT='AVRO',KEY_FORMAT='JSON', WRAP_SINGLE_VALUE=false);

    CREATE OR REPLACE STREAM roles_src_new WITH (    KAFKA_TOPIC='ROLES_SRC_NEW', PARTITIONS=1, REPLICAS=1, VALUE_FORMAT='AVRO',KEY_FORMAT='JSON'
)   AS
    select EXTRACTJSONFIELD(ROWVAL, '$.operationType') AS operationType, EXTRACTJSONFIELD(ROWVAL, '$.documentKey._id') AS _id, CAST(EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.user_id') AS INTEGER) AS user_id,EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.roles') AS roles, EXTRACTJSONFIELD(ROWVAL, '$.ns.db') AS database_name, EXTRACTJSONFIELD(ROWVAL, '$.ns.coll') AS collection_name, rowtime AS time from roles_src emit changes;

    CREATE STREAM roles_src_rekey WITH (PARTITIONS=1) AS \ select * from roles_src_new partition by user_id;

    CREATE TABLE roles_tbl (USER_ID INTEGER PRIMARY KEY, OPERATIONTYPE STRING,_ID STRING, ROLES STRING,DATABASE_NAME STRING,COLLECTION_NAME STRING,TIME BIGINT)\ WITH (KAFKA_TOPIC='ROLES_SRC_REKEY', VALUE_FORMAT='AVRO',KEY_FORMAT='JSON');




    CREATE TABLE class_boost WITH(KAFKA_TOPIC='demo.class.class_boost',VALUE_FORMAT='AVRO',KEY_FORMAT='JSON') AS SELECT U.USER_ID as USER_ID, U.OPERATIONTYPE AS OT_USER, U._ID AS _IDU, U.FIRST_NAME, U.LAST_NAME, U.EMAIL, U.GENDER, U.ADDRESS, U.TIME AS USERS_TIME, R.OPERATIONTYPE AS OT_ROLE, R._ID AS _IDR,R.ROLES AS ROLES, R.TIME AS ROLES_TIME FROM USERS_TBL U INNER JOIN ROLES_TBL R ON U.USER_ID = R.USER_ID;

    # CREATE TABLE course_sub WITH(KAFKA_TOPIC='demo.class.class_boost', value_format='avro',KEY_FORMAT='JSON') AS select * from role_tbl;

    # select _ID,USER_ID,MAX(TIME) AS TIME FROM users_src_new GROUP BY _ID, USER_ID EMIT CHANGES;

    # select u.user_id, u.operationtype as ot_user, u._id as _idu, u.first_name, u.last_name, u.email, u.gender, u.address, u.time as users_time, r.operationtype as ot_role, r._id as _idr,r.roles as roles, r.time as roles_time from users_tbl u inner join roles_tbl r on u.user_id = r.user_id emit changes;

EOF
