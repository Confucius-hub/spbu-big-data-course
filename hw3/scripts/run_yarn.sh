#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

run_id="$(date +%Y%m%d_%H%M%S)"
docker compose exec client bash /workspace/scripts/build_conda_env.sh

docker compose exec client spark-submit \
  --master yarn \
  --deploy-mode client \
  --driver-memory 2g \
  --executor-memory 2g \
  --executor-cores 1 \
  --num-executors 2 \
  --conf spark.sql.shuffle.partitions=64 \
  --conf spark.yarn.dist.archives=hdfs:///user/spark/envs/hw3-pyspark-conda.tar.gz#environment \
  --conf spark.pyspark.python=./environment/bin/python \
  --conf spark.executorEnv.PYSPARK_PYTHON=./environment/bin/python \
  --conf spark.yarn.appMasterEnv.PYSPARK_PYTHON=./environment/bin/python \
  /workspace/jobs/github_events_job.py \
  --input hdfs:///datasets/github_events_parquet \
  --output "hdfs:///results/github_events/yarn_${run_id}" \
  --mode yarn \
  --metrics "/workspace/results/yarn_${run_id}.json"
