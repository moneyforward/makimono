#!/bin/bash

build_config() {
  cat<<EOF | DOLLAR=$ envsubst
{
  "connector.class": "io.debezium.connector.mysql.MySqlConnector",
  "tasks.max": 1,
  "topic.creation.default.replication.factor": 1,
  "topic.creation.default.partitions": 10,
  "topic.creation.default.compression.type": "zstd",
  "database.hostname": "makimono-db",
  "database.port": "3306",
  "database.user": "root",
  "database.password": "password",
  "database.dbname": "makimono_db",
  "database.server.name": "Makimono.SYS.DBServer",
  "database.history.kafka.bootstrap.servers": "kafka:9092",
  "database.history.kafka.topic": "Makimono.SYS.SchemaChange",
  "database.history.store.only.captured.tables.ddl": "true",
  "database.history.consumer.group.id": "Makimono.Group.Debezium.Consumer",
  "database.history.producer.group.id": "Makimono.Group.Debezium.Producer",
  "include.schema.changes": "false",
  "event.deserialization.failure.handling.mode": "fail",
  "table.include.list": "makimono_db.outbox_events",
  "transforms": "outbox",
  "transforms.outbox.type": "io.debezium.transforms.outbox.EventRouter",
  "transforms.outbox.table.op.invalid.behavior": "fatal",
  "transforms.outbox.table.field.event.id": "id",
  "transforms.outbox.table.field.event.key": "tenant_uid",
  "transforms.outbox.table.field.event.payload": "payload",
  "transforms.outbox.table.fields.additional.placement": "tenant_uid:header:x-mfc-tenant-id,trace_id:header:x-datadog-trace-id,span_id:header:x-datadog-parent-id",
  "transforms.outbox.route.by.field": "aggregate_type",
  "transforms.outbox.route.topic.replacement": "Makimono.CDC.\${DOLLAR}{routedByValue}",
  "value.converter": "io.debezium.converters.ByteBufferConverter",
  "value.converter.schemas.enable": "false",
  "value.converter.delegate.converter.type": "org.apache.kafka.connect.json.JsonConverter",
  "value.converter.delegate.converter.type.schemas.enable": "false",
  "key.converter": "org.apache.kafka.connect.storage.StringConverter",
  "key.converter.schemas.enable": "false",
  "snapshot.mode": "when_needed"
}
EOF
}

base_endpoint=http://localhost:8083
connector_name=makimono

case $1 in
  update)
    config=$(build_config)
    curl -X PUT --header 'Content-Type: application/json' -d "${config}" ${base_endpoint}/connectors/${connector_name}/config
    ;;
  create)
    config='{"name": "makimono", "config":'
    config+=$(build_config)
    config+='}'
    curl -X POST --header 'Content-Type: application/json' -d "${config}" ${base_endpoint}/connectors
    ;;
  *)
    echo please pass a cmd
esac
