#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

docker compose ps
echo
docker compose exec client hdfs dfs -du -h -s /datasets/github_events_parquet || true
echo
docker compose exec client yarn application -list || true
