docker-compose exec -T ksqldb-cli ksql http://ksqldb-server:8088 <<-EOF
    show topics;

    set 'commit.interval.ms'='5000';
    set 'cache.max.bytes.buffering'='10000000';
    set 'auto.offset.reset'='earliest';

    CREATE STREAM resto_src WITH (KAFKA_TOPIC='demo.business.resto', VALUE_FORMAT='AVRO', WRAP_SINGLE_VALUE=false);

    select EXTRACTJSONFIELD(ROWVAL, '$.operationType') AS operationType, EXTRACTJSONFIELD(ROWVAL, '$.documentKey._id') AS _id, EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.address.building') AS building ,EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.address.street') AS street ,
    EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.address.zipcode') AS zipcode ,EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.borough') AS borough, EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.cuisine') AS cuisine, EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.grades') AS grades, EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.name') AS name, EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.restaurant_id') AS restaurant_id, EXTRACTJSONFIELD(ROWVAL, '$.ns.db') AS database_name, EXTRACTJSONFIELD(ROWVAL, '$.ns.coll') AS collection_name, rowtime AS time from resto_src emit changes;

    CREATE OR REPLACE STREAM class_boost WITH (
    kafka_topic = 'demo.class.class_boost',
    VALUE_FORMAT='AVRO'
)   AS
    select EXTRACTJSONFIELD(ROWVAL, '$.operationType') AS operationType, EXTRACTJSONFIELD(ROWVAL, '$.documentKey._id') AS _id, EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.address.building') AS building ,EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.address.street') AS street ,
    EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.address.zipcode') AS zipcode ,EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.borough') AS borough, EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.cuisine') AS cuisine, EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.grades') AS grades, EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.name') AS name, EXTRACTJSONFIELD(ROWVAL, '$.fullDocument.restaurant_id') AS restaurant_id, EXTRACTJSONFIELD(ROWVAL, '$.ns.db') AS database_name, EXTRACTJSONFIELD(ROWVAL, '$.ns.coll') AS collection_name, rowtime AS time from resto_src emit changes;


EOF
