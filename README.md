# Big Data Course — Homework

## Домашние задания

### ДЗ 1 — Бенчмарк форматов хранения данных
Датасет Amazon Reviews (Books, 18.7 GB). Сохранение в 7 форматов (CSV, TSV, JSON, JSONL, Parquet, ORC, SQLite) с замером cpu-time и wall-time. SQL-запросы через DuckDB, Polars, SQLAlchemy, PyArrow, Raw Python, Raw Python + Numba/ThreadPool. Бенчмарк JSON-парсеров (json, orjson, ujson).

**Решение:** [hw1/ДЗ_1.ipynb](hw1/ДЗ_1.ipynb)

### ДЗ 3 — AI-сервисы и Spark/HDFS/YARN/Hive/Zeppelin
Отчет по Cursor, Claude Code, VSCode AI-плагинам и локальной Gemma/Ollama:
проверка, используют ли инструменты интернет/API. Локальный BigData-стенд в
Docker: HDFS, YARN, Spark, Hive Metastore/HiveServer2 и Zeppelin. Реальный
датасет GitHub Events из публичного S3 загружается в HDFS объемом минимум
50 GiB. Один Spark job запускается в двух режимах: `--master local[*]` и
`--master yarn` с conda-pack окружением; результаты сравнения сохраняются в
`results/*.json` и `report/spark_results_table.md`.

**Решение:** [hw3/README.md](hw3/README.md)
