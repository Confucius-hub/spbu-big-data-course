from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RESULTS_DIR = ROOT / "results"
OUTPUT_PATH = ROOT / "report" / "spark_results_table.md"


def latest_metric(mode: str) -> dict[str, object] | None:
    files = sorted(RESULTS_DIR.glob(f"{mode}_*.json"))
    if not files:
        return None
    return json.loads(files[-1].read_text(encoding="utf-8"))


def format_row(mode: str, metric: dict[str, object] | None) -> str:
    if metric is None:
        return f"| `{mode}` | not run | - | - | - | - |"
    return (
        f"| `{mode}` | {metric['elapsed_seconds']} | "
        f"{metric['total_events']} | {metric['distinct_users']} | "
        f"{metric['distinct_repositories']} | `{metric['spark_app_id']}` |"
    )


def main() -> None:
    rows = [
        "# Spark benchmark results",
        "",
        "| Mode | Time, sec | Events | Users | Repositories | Spark app id |",
        "|---|---:|---:|---:|---:|---|",
        format_row("local", latest_metric("local")),
        format_row("yarn", latest_metric("yarn")),
        "",
    ]
    OUTPUT_PATH.write_text("\n".join(rows), encoding="utf-8")
    print(f"Written {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
