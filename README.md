# Big Data Course — Homework

## Домашние задания

### ДЗ 1 — Бенчмарк форматов хранения данных
Датасет Amazon Reviews (Books, 18.7 GB). Сохранение в 7 форматов (CSV, TSV, JSON, JSONL, Parquet, ORC, SQLite) с замером cpu-time и wall-time. SQL-запросы через DuckDB, Polars, SQLAlchemy, PyArrow, Raw Python, Raw Python + Numba/ThreadPool. Бенчмарк JSON-парсеров (json, orjson, ujson).

**Решение:** [hw1/ДЗ_1.ipynb](hw1/ДЗ_1.ipynb)

### ДЗ 2 — ClickHouse, SPU и C++ binding
К первой домашней работе добавлен C++ binding через `pybind11`. Для BigData-части используется ClickHouse: созданы две таблицы пользовательских логов с одинаковой схемой, но разными sorting key (`events_sorted` и `events_unsorted`). Данные генерируются внутри ClickHouse небольшими батчами до объёма не меньше 100 GiB в несжатом виде. Для логов считается SPU (sessions per user) при `delta = 1800` секунд, строится график распределения SPU и сравнивается время агрегирующего запроса для таблицы с sorting key и без него.

**Основное решение:** [hw2/HW2_full.ipynb](hw2/HW2_full.ipynb)

**Инструкция и описание файлов:** [hw2/README.md](hw2/README.md)

**C++ binding:** [hw2/cpp_binding/hw1_cpp.cpp](hw2/cpp_binding/hw1_cpp.cpp)

**Зависимости:** [hw2/requirements.txt](hw2/requirements.txt)
