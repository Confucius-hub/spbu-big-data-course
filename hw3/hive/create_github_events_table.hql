CREATE DATABASE IF NOT EXISTS hw3;

DROP TABLE IF EXISTS hw3.github_events;

CREATE EXTERNAL TABLE hw3.github_events (
  event_type STRING,
  actor_login STRING,
  repo_name STRING,
  repo_id STRING,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  action STRING
)
STORED AS PARQUET
LOCATION 'hdfs:///datasets/github_events_parquet';

SHOW TABLES IN hw3;

SELECT event_type, count(*) AS events
FROM hw3.github_events
GROUP BY event_type
ORDER BY events DESC
LIMIT 10;
