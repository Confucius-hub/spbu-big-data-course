# BigData HW2

This folder contains the second BigData homework notebook.

Main file:

- `HW2_full.ipynb` - Jupyter notebook with ClickHouse setup checks,
  generated user logs, SPU calculation, sorting-key benchmark, plots, and the
  C++ binding extension for HW1.

Supporting files:

- `requirements.txt` - Python packages used by the notebook.
- `cpp_binding/` - standalone copy of the C++ binding source from the notebook.

## What Is Covered

- ClickHouse tables with the same user log data:
  - `events_sorted` with `ORDER BY (user_id, event_time)`.
  - `events_unsorted` with `ORDER BY tuple()`.
- Data generation up to at least 100 GiB of uncompressed ClickHouse data.
- SPU calculation where a session starts after a gap of 1800 seconds.
- Benchmark of an aggregation query with and without a useful sorting key.
- A small `pybind11` C++ extension added to the HW1-style benchmark.

## Notes For Reproducibility

The notebook is written to avoid loading the 100 GiB dataset into Python memory.
Data is generated and stored inside ClickHouse in small insert batches. For a
quick smoke test, lower `TARGET_GIB_PER_TABLE` in the settings cell, then return
it to `50` for the final run.

The notebook expects `clickhouse-client` to be available and ClickHouse to be
running locally.
