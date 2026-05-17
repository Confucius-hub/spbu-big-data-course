# BigData HW3 - AI services and Spark cluster in Docker

This repository contains a reproducible homework package for BigData HW3.

## What is included

- AI services report: `ai_services/ai_services_report.md`
- Hadoop HDFS + YARN cluster in Docker
- Spark 3.5.3
- Hive Metastore + HiveServer2
- Zeppelin
- Real 50+ GB GitHub Events dataset loaded to HDFS
- Spark job run in two modes:
  - `--master local[*]`
  - `--master yarn` with conda-pack
- Guard check that fails if HDFS dataset size is below 50 GiB

## Quick start

Start Docker Desktop first. Then run:

```bash
bash scripts/start_stack.sh
docker compose exec client bash /workspace/scripts/load_github_events_to_hdfs.sh
bash scripts/run_hive_setup.sh
bash scripts/run_local.sh
bash scripts/run_yarn.sh
```

Or run everything:

```bash
bash scripts/run_all.sh
```

## UI

- HDFS NameNode: http://localhost:9870
- YARN ResourceManager: http://localhost:8088
- MapReduce History Server: http://localhost:19888
- Zeppelin: http://localhost:8890
- HiveServer2 JDBC: `jdbc:hive2://localhost:10000`

## Dataset

The dataset is real GitHub Events data from public S3:

```text
https://datasets-documentation.s3.eu-west-3.amazonaws.com/github_issues/subset/
```

The loader uploads four yearly Parquet files into:

```text
hdfs:///datasets/github_events_parquet
```

## Results

Spark job metrics are written to:

```text
results/local_*.json
results/yarn_*.json
```

Generate a compact Markdown table from the latest metrics:

```bash
python3 scripts/render_results_table.py
```

`scripts/run_all.sh` runs this command automatically after both Spark modes.

Detailed report:

```text
report/HW3_report.md
```

## Stop

```bash
bash scripts/stop_stack.sh
```

Remove containers and Docker volumes:

```bash
bash scripts/clean_stack.sh
```
