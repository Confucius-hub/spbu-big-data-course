#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

docker compose up -d --build
docker compose exec client bash /workspace/scripts/init_hdfs.sh

echo
echo "Stack is ready:"
echo "  HDFS NameNode UI:   http://localhost:9870"
echo "  YARN UI:            http://localhost:8088"
echo "  MapReduce History:  http://localhost:19888"
echo "  Zeppelin:           http://localhost:8890"
echo "  HiveServer2 JDBC:   jdbc:hive2://localhost:10000"
