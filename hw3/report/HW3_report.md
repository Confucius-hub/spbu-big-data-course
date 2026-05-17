# Домашняя работа 3: AI-сервисы и Spark/HDFS/YARN/Hive/Zeppelin

## 1. Цель работы

Цель работы — проверить современные AI-инструменты для разработки и развернуть
локальную BigData-среду в Docker:

- HDFS для хранения датасета;
- YARN для эмуляции кластера;
- Spark для обработки данных;
- Hive для SQL-таблицы поверх HDFS;
- Zeppelin для интерактивной работы;
- conda-pack для запуска PySpark job в режиме `--master yarn`.

## 2. AI-сервисы

Проверены Cursor, Claude Code, VSCode с AI-плагинами и локальная Gemma через
Ollama. Детальный отчет находится в файле:

```text
ai_services/ai_services_report.md
```

Краткий вывод:

| Инструмент | Интернет/API | Итог |
|---|---|---|
| Cursor | Да, облачный сервис; web search при явном запросе | Хорошо работает с кодовой базой и актуальной информацией |
| Claude Code | Да, Anthropic cloud/API | Удобен как terminal coding agent |
| VSCode + AI-плагины | Да, GitHub Copilot/cloud | Хорош для автодополнения и агентских правок |
| Gemma/Ollama | Нет после загрузки модели | Полностью локальный режим, но без проверки свежих фактов |

## 3. Spark-инфраструктура

Стенд собирается через `docker-compose.yml`. В составе:

| Сервис | Роль | UI/порт |
|---|---|---|
| `namenode` | HDFS NameNode | http://localhost:9870 |
| `datanode1`, `datanode2` | HDFS DataNode | internal |
| `resourcemanager` | YARN ResourceManager | http://localhost:8088 |
| `nodemanager1`, `nodemanager2` | YARN workers | internal |
| `historyserver` | MapReduce/Spark history | http://localhost:19888 |
| `hive-metastore` | Hive Metastore | thrift://localhost:9083 |
| `hive-server2` | Hive SQL endpoint | jdbc:hive2://localhost:10000 |
| `zeppelin` | Notebook UI | http://localhost:8890 |
| `client` | Spark/HDFS/Hive client | Docker exec target |

## 4. Датасет

Используется реальный датасет GitHub Events из публичного S3:

```text
https://datasets-documentation.s3.eu-west-3.amazonaws.com/github_issues/subset/
```

Загружаются четыре Parquet-файла:

- `github_events_2024.parquet`;
- `github_events_2023.parquet`;
- `github_events_2022.parquet`;
- `github_events_2021.parquet`.

Суммарный размер сжатых Parquet-файлов больше 50 GB. Данные загружаются в HDFS:

```text
hdfs:///datasets/github_events_parquet
```

Основные признаки:

| Поле | Описание |
|---|---|
| `event_type` | тип события GitHub |
| `actor_login` | пользователь GitHub |
| `repo_name` | репозиторий |
| `repo_id` | идентификатор репозитория |
| `created_at` | время события |
| `updated_at` | время обновления |
| `action` | действие внутри события |

## 5. Обработка данных

Spark job находится в:

```text
jobs/github_events_job.py
```

Он читает весь датасет из HDFS и выполняет:

- подсчет общего числа событий;
- подсчет уникальных пользователей;
- подсчет уникальных репозиториев;
- агрегацию по типам событий;
- дневную динамику событий;
- топ репозиториев;
- запись результатов обратно в HDFS.

В коде также оставлена опциональная тяжелая ветка `--compute-sessions`: расчет
sessions per user по `actor_login` и `created_at` с `delta = 30 минут`. Для
обязательного сравнения `local[*]` и `yarn` она выключена, чтобы оба режима
гарантированно обработали весь датасет на локальной Docker-инфраструктуре.

## 6. Запуск

### Старт стека

```bash
bash scripts/start_stack.sh
```

### Загрузка датасета в HDFS

```bash
docker compose exec client bash /workspace/scripts/load_github_events_to_hdfs.sh
```

### Hive external table

```bash
bash scripts/run_hive_setup.sh
```

### Локальный режим Spark

```bash
bash scripts/run_local.sh
```

Внутри используется:

```bash
spark-submit --master local[*]
```

### Кластерный режим Spark/YARN

```bash
bash scripts/run_yarn.sh
```

Внутри используется:

```bash
spark-submit --master yarn --deploy-mode client
```

Для `yarn` создается conda-pack архив и передается executor-ам через:

```text
spark.yarn.dist.archives=hdfs:///user/spark/envs/hw3-pyspark-conda.tar.gz#environment
```

## 7. Результаты

После запуска в папке `results/` появляются JSON-файлы:

```text
results/local_*.json
results/yarn_*.json
```

Формат метрик:

| Поле | Значение |
|---|---|
| `mode` | `local` или `yarn` |
| `elapsed_seconds` | wall-time Spark job |
| `total_events` | количество обработанных событий |
| `distinct_users` | количество уникальных пользователей |
| `distinct_repositories` | количество уникальных репозиториев |
| `spark_master` | фактический master |
| `spark_app_id` | ID Spark-приложения |

Таблица для финального сравнения заполняется после фактического запуска:

| Режим | Время, сек | События | Пользователи | Репозитории |
|---|---:|---:|---:|---:|
| `local[*]` | см. `results/local_*.json` | см. JSON | см. JSON | см. JSON |
| `yarn` | см. `results/yarn_*.json` | см. JSON | см. JSON | см. JSON |

Для автоматической генерации таблицы после прогона:

```bash
python3 scripts/render_results_table.py
```

Результат сохраняется в:

```text
report/spark_results_table.md
```

## 8. Вывод

В работе подготовлен локальный Docker-стенд, который эмулирует BigData-кластер:
HDFS хранит датасет, YARN управляет ресурсами, Spark выполняет обработку,
Hive предоставляет SQL-таблицу поверх HDFS, Zeppelin дает notebook-интерфейс.

Один и тот же Spark job запускается в двух режимах:

- `--master local[*]` — локальный режим внутри client-контейнера;
- `--master yarn` — кластерный режим через YARN с conda-pack окружением.

Это закрывает требование сравнить локальную обработку и обработку на
эмулированном кластере.

## Источники

- Apache Spark Docker image overview: https://hub.docker.com/_/spark
- Spark Standalone/YARN documentation: https://spark.apache.org/docs/3.5.3/
- Apache Zeppelin Spark interpreter: https://zeppelin.apache.org/docs/latest/interpreter/spark.html
- Google Gemma with Ollama: https://ai.google.dev/gemma/docs/integrations/ollama
- VSCode Copilot tools: https://code.visualstudio.com/docs/copilot/concepts/tools
