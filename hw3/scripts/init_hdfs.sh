#!/usr/bin/env bash
set -euo pipefail

echo "Waiting for HDFS..."
for _ in $(seq 1 120); do
  if hdfs dfs -ls / >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

hdfs dfs -mkdir -p /tmp
hdfs dfs -mkdir -p /spark-history
hdfs dfs -mkdir -p /user/spark/envs
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -mkdir -p /datasets/github_events_parquet
hdfs dfs -mkdir -p /results/github_events
hdfs dfs -chmod -R 777 /tmp /spark-history /user /datasets /results

echo "HDFS directories:"
hdfs dfs -ls /
