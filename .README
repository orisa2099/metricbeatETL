# Metricbeat → Logstash → PostgreSQL ETL Pipeline

## Overview

This project implements an **end‑to‑end observability ETL pipeline** that collects system metrics from a host machine using **Metricbeat**, transports them through **Logstash**, and persists them into **PostgreSQL** for long‑term storage, analysis, and reporting.

The goal is to demonstrate how infrastructure metrics (memory, network, CPU, etc.) can be transformed from raw events into structured relational data suitable for analytics, dashboards, and historical trend analysis — without relying on Elasticsearch.

---

## Architecture

```
+-------------+        +-----------+        +-------------+
|             |        |           |        |             |
|  Metricbeat +------->+ Logstash  +------->+ PostgreSQL  |
|             |  Beats |  (ETL)    |  JDBC  |  Metrics DB |
+-------------+        +-----------+        +-------------+
                                  \
                                   +----> pgAdmin (UI)
```

### Components

* **Metricbeat**

  * Runs as a system service on the host (Windows/Linux)
  * Collects system metrics such as:

    * Memory usage
    * Network I/O
    * CPU statistics
  * Sends events to Logstash via the Beats protocol

* **Logstash**

  * Acts as the ETL engine
  * Receives Metricbeat events
  * Filters and transforms metrics
  * Writes structured records into PostgreSQL using JDBC

* **PostgreSQL**

  * Stores metrics in relational form
  * Enables SQL queries, aggregations, and long‑term retention

* **pgAdmin**

  * Web‑based PostgreSQL management UI
  * Used to inspect tables, validate inserts, and query data

---

## Project Structure

```
metricbeatETL/
├── docker-compose.yml
├── logstash/
│   ├── pipeline/
│   │   └── metricbeat.conf
│   └── jdbc/
│       └── postgresql-42.7.2.jar
├── postgres/
│   └── init.sql
└── README.md
```

---

## Data Flow Explained

1. **Metricbeat collects metrics** every 10 seconds from the host system
2. Metrics are sent to Logstash on port `5044`
3. Logstash parses incoming events
4. Metrics are filtered by dataset (e.g. `system.network`)
5. Selected fields are extracted and converted to numeric values
6. Each metric is inserted as a row in PostgreSQL

Each metric sample is stored independently, enabling flexible aggregation later.

---

## Database Schema

Example table used for metric storage:

```sql
CREATE SCHEMA IF NOT EXISTS metricbeat;

CREATE TABLE IF NOT EXISTS metricbeat.metricbeat_events (
    id BIGSERIAL PRIMARY KEY,
    event_time TIMESTAMP NOT NULL,
    host_name TEXT,
    event_module TEXT,
    metricset_name TEXT,
    event_dataset TEXT,
    raw_event JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE INDEX idx_metricbeat_event_time
  ON metricbeat.metricbeat_events(event_time);

CREATE INDEX idx_metricbeat_host
  ON metricbeat.metricbeat_events(host_name);

CREATE INDEX idx_metricbeat_dataset
  ON metricbeat.metricbeat_events(event_dataset);
```


## How to Run

1. Start PostgreSQL, Logstash, and pgAdmin:

```bash
docker-compose up -d
```

2. Install and start Metricbeat on the host
3. Verify events are received:

```bash
docker logs logstash --tail 50
```

4. Check data in PostgreSQL:

```sql
SELECT * FROM metricbeat.metric_samples LIMIT 10
```

---


## Learning Outcomes

This project demonstrates:

* Real‑world ETL design for observability data
* Docker‑based Logstash deployment
* Metricbeat internals and datasets
* JDBC ingestion patterns
* SQL‑first monitoring architectures

---

## Author

Built as a hands‑on learning project to understand metrics pipelines beyond the Elastic Stack, with a focus on scalability, clarity, and production‑style debugging.
