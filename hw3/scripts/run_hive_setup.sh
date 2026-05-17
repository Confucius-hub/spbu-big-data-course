#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

docker compose exec client beeline \
  -u jdbc:hive2://hive-server2:10000/default \
  -n root \
  -f /workspace/hive/create_github_events_table.hql
