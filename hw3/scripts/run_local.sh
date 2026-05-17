#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

run_id="$(date +%Y%m%d_%H%M%S)"
docker compose exec client spark-submit \
  --master 'local[*]' \
  --driver-memory 4g \
  --conf spark.sql.shuffle.partitions=64 \
  /workspace/jobs/github_events_job.py \
  --input hdfs:///datasets/github_events_parquet \
  --output "hdfs:///results/github_events/local_${run_id}" \
  --mode local \
  --metrics "/workspace/results/local_${run_id}.json"
