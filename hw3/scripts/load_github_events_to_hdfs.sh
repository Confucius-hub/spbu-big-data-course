#!/usr/bin/env bash
set -euo pipefail

target_dir="${1:-/datasets/github_events_parquet}"
local_dir="${LOCAL_DATA_DIR:-/workspace/data}"
min_dataset_bytes="${MIN_DATASET_BYTES:-53687091200}"
mkdir -p "${local_dir}"

declare -a labels=(
  "github_events_2024"
  "github_events_2023"
  "github_events_2022"
  "github_events_2021"
)

declare -a urls=(
  "https://datasets-documentation.s3.eu-west-3.amazonaws.com/github_issues/subset/github_events_2024.parquet"
  "https://datasets-documentation.s3.eu-west-3.amazonaws.com/github_issues/subset/github_events_2023.parquet"
  "https://datasets-documentation.s3.eu-west-3.amazonaws.com/github_issues/subset/github_events_2022.parquet"
  "https://datasets-documentation.s3.eu-west-3.amazonaws.com/github_issues/subset/github_events_2021.parquet"
)

hdfs dfs -mkdir -p "${target_dir}"

for index in "${!labels[@]}"; do
  label="${labels[$index]}"
  url="${urls[$index]}"
  hdfs_path="${target_dir}/${label}.parquet"
  local_path="${local_dir}/${label}.parquet"

  if hdfs dfs -test -e "${hdfs_path}"; then
    echo "${hdfs_path} already exists, skipping."
    continue
  fi

  echo "Downloading ${label}..."
  curl -L --retry 10 --retry-delay 10 --fail "${url}" -o "${local_path}"

  echo "Uploading ${label} to HDFS..."
  hdfs dfs -put -f "${local_path}" "${hdfs_path}"
  rm -f "${local_path}"

  echo "Current HDFS dataset size:"
  hdfs dfs -du -h -s "${target_dir}"
done

echo "Final HDFS dataset size:"
hdfs dfs -du -h -s "${target_dir}"
hdfs dfs -ls -h "${target_dir}"

actual_bytes="$(hdfs dfs -du -s "${target_dir}" | awk '{print $1}')"
if [ "${actual_bytes}" -lt "${min_dataset_bytes}" ]; then
  echo "Dataset is too small: ${actual_bytes} bytes, expected at least ${min_dataset_bytes}" >&2
  exit 1
fi

echo "Requirement satisfied: HDFS dataset size is at least 50 GiB."
