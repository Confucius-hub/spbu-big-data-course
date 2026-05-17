#!/usr/bin/env bash
set -euo pipefail

env_dir="/workspace/.conda_envs/hw3-pyspark"
archive_path="/workspace/data/hw3-pyspark-conda.tar.gz"
hdfs_archive="hdfs:///user/spark/envs/hw3-pyspark-conda.tar.gz"

if [ ! -d "${env_dir}" ]; then
  conda create -y -p "${env_dir}" -c conda-forge \
    python=3.10 \
    pandas \
    pyarrow \
    conda-pack
fi

conda run -p "${env_dir}" conda-pack -p "${env_dir}" -o "${archive_path}" --force
hdfs dfs -mkdir -p /user/spark/envs
hdfs dfs -put -f "${archive_path}" /user/spark/envs/hw3-pyspark-conda.tar.gz

echo "Conda-pack archive uploaded to ${hdfs_archive}"
hdfs dfs -ls -h /user/spark/envs
