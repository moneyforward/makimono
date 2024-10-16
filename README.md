
# 📜 About Makimono

## 📜 Overview / 概要

A log platform that provides storing and managing audit log for the MFC products. <br>
MFCプロダクトへ監査ログの書き込みや管理機能を提供するログ基盤

See / 詳細: [PRD - The Audit Log Platform](https://docs.google.com/document/d/1jQAKMQ5H-S0z8jgcMtdIzGfKwOw6CTCpFf57-de_62U/edit#heading=h.rs216i388j81)

## 📜 Channels / チャンネル一覧

* #makimono_dev
* #service-platform-makimono

## 📜 Members / メンバー

The main developers of this project are part of the ID platform group ( @navis-dev ) <br>
@asao.naoki <br>
@Kingsley /truong.tran.hao <br>
@Henry Helm

## 📜 What does “Makimono” mean?

This → 📜

## Local Docker setup

```
docker compose up -d
```

### Setup Debezium
```
make debezium-create
```

### Update Debezium configs
```
make debezium-update
```

### Create table and some fields
Connect to `makimono_db` container
```bash
docker exec -it makimono-mysql bash  
```

Connect to MySQL
```bash
mysql -u root -p
```

Then enter the password `password`

Finally, run the following SQL
```sql
CREATE TABLE `outbox_events` (
  `id` char(26) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL COMMENT 'ULID',
  `tenant_uid` bigint unsigned NOT NULL,
  `aggregate_type` enum('Makimono.v1') COLLATE utf8mb4_bin NOT NULL,
  `payload` longblob NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_outbox_events_tenants` (`tenant_uid`)
);
```

To Trigger a automated message push to Kafka, we just need to `INSTERT` a record to `outboc_events`. Example SQL:
```sql
INSERT outbox_events (id, tenant_uid, aggregate_type, payload) VALUES (1, 1, 'Makimono.v1', '{"data": "Hello world"}');
```

### Extra: UI view for Kafka topics and messages

Using an open source software [Offset Explorer](https://www.kafkatool.com/features.html)

To connect to existing Kafka cluster, use the following configuration setting

```
Cluster name: Makimono.Client
Bootstrap servers: localhost:19092
Kafka Cluster version: 3.7

Enable Zookeeper access: Checked
Host: localhost
Port: 2181
chroot path: /kafka
```

