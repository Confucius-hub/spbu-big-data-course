#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

bash scripts/start_stack.sh
docker compose exec client bash /workspace/scripts/load_github_events_to_hdfs.sh
bash scripts/run_hive_setup.sh
bash scripts/run_local.sh
bash scripts/run_yarn.sh
python3 scripts/render_results_table.py
bash scripts/status.sh
