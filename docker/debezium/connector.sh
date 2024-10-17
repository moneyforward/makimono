#!/bin/bash

build_config() {
  cat<<EOF | DOLLAR=$ envsubst
{
  "connector.class": "io.debezium.connector.mysql.MySqlConnector",
  "tasks.max": "1",
  "database.hostname": "makimono-db",
  "database.port": "3306",
  "database.user": "root",
  "database.password": "password",
  "database.server.id": "1",
  "database.include.list": "makimono_db",
  "table.include.list": "makimono_db.outbox_events",
  "event.processing.failure.handling.mode": "fail",
  "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
  "schema.history.internal.kafka.topic": "Makimono.SYS.SchemaChange",
  "topic.prefix": "Makimono.SYS.SchemaChange",
  "transforms": "outbox",
  "transforms.outbox.type": "io.debezium.transforms.outbox.EventRouter",
  "transforms.outbox.route.by.field": "aggregate_type",
  "transforms.outbox.route.topic.replacement": "Makimono.CDC.\${DOLLAR}{routedByValue}",
  "transforms.outbox.table.field.event.id": "id",
  "transforms.outbox.table.field.event.key": "tenant_uid",
  "transforms.outbox.table.field.event.payload": "payload",
  "transforms.outbox.table.op.invalid.behavior": "fatal",
  "header.converter": "org.apache.kafka.connect.storage.SimpleHeaderConverter",
  "key.converter": "org.apache.kafka.connect.storage.StringConverter",
  "key.converter.schemas.enable": "false",
  "value.converter": "io.debezium.converters.BinaryDataConverter",
  "value.converter.delegate.converter.type": "org.apache.kafka.connect.json.JsonConverter",
  "value.converter.delegate.converter.type.schemas.enable": "false",
  "value.converter.schemas.enable": "false"
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
