from __future__ import annotations

import argparse
import json
import time
from pathlib import Path

from pyspark.sql import DataFrame, SparkSession, Window
from pyspark.sql import functions as F


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--mode", choices=["local", "yarn"], required=True)
    parser.add_argument("--metrics", required=True)
    parser.add_argument("--delta-minutes", type=int, default=30)
    parser.add_argument("--compute-sessions", action="store_true")
    return parser.parse_args()


def required_columns(frame: DataFrame) -> DataFrame:
    columns = [
        "event_type",
        "actor_login",
        "repo_name",
        "repo_id",
        "created_at",
        "updated_at",
        "action",
    ]
    missing = [column for column in columns if column not in frame.columns]
    if missing:
        raise ValueError(f"Missing expected columns: {missing}")
    return frame.select(*columns)


def write_frame(frame: DataFrame, path: str, fmt: str = "parquet") -> None:
    frame.write.mode("overwrite").format(fmt).save(path)


def compute_sessions(events: DataFrame, delta_seconds: int) -> DataFrame:
    user_window = Window.partitionBy("actor_login").orderBy("created_at")
    with_gaps = (
        events.where(F.col("actor_login") != "")
        .select("actor_login", "created_at", "repo_name", "event_type")
        .withColumn("previous_created_at", F.lag("created_at").over(user_window))
        .withColumn(
            "gap_seconds",
            F.unix_timestamp("created_at") - F.unix_timestamp("previous_created_at"),
        )
        .withColumn(
            "is_new_session",
            F.when(
                F.col("previous_created_at").isNull()
                | (F.col("gap_seconds") > delta_seconds),
                F.lit(1),
            ).otherwise(F.lit(0)),
        )
    )
    return (
        with_gaps.groupBy("actor_login")
        .agg(
            F.sum("is_new_session").alias("spu"),
            F.count("*").alias("total_events"),
            F.countDistinct("repo_name").alias("unique_repositories"),
            F.min("created_at").alias("first_event"),
            F.max("created_at").alias("last_event"),
        )
        .orderBy(F.desc("spu"), F.desc("total_events"))
    )


def main() -> None:
    args = parse_args()
    started = time.perf_counter()

    spark = (
        SparkSession.builder.appName(f"HW3 GitHub Events {args.mode}")
        .enableHiveSupport()
        .getOrCreate()
    )
    spark.sparkContext.setLogLevel("WARN")

    raw = spark.read.parquet(args.input)
    events = required_columns(raw).persist()

    total_events = events.count()
    distinct_users = events.select("actor_login").where("actor_login != ''").distinct().count()
    distinct_repositories = events.select("repo_name").where("repo_name != ''").distinct().count()

    summary = spark.createDataFrame(
        [
            {
                "mode": args.mode,
                "total_events": total_events,
                "distinct_users": distinct_users,
                "distinct_repositories": distinct_repositories,
                "delta_minutes": args.delta_minutes,
            }
        ]
    )
    event_types = events.groupBy("event_type").count().orderBy(F.desc("count"))
    daily_events = (
        events.groupBy(F.to_date("created_at").alias("event_date"))
        .agg(F.count("*").alias("events"))
        .orderBy("event_date")
    )
    repo_activity = (
        events.groupBy("repo_name")
        .agg(
            F.count("*").alias("events"),
            F.countDistinct("actor_login").alias("active_users"),
        )
        .orderBy(F.desc("events"))
        .limit(100)
    )

    write_frame(summary, f"{args.output}/summary")
    write_frame(event_types, f"{args.output}/event_types")
    write_frame(daily_events, f"{args.output}/daily_events")
    write_frame(repo_activity, f"{args.output}/top_repositories")

    if args.compute_sessions:
        sessions = compute_sessions(events, args.delta_minutes * 60)
        session_distribution = (
            sessions.groupBy("spu")
            .agg(F.count("*").alias("users"))
            .orderBy("spu")
        )
        write_frame(sessions.limit(1000), f"{args.output}/top_user_sessions")
        write_frame(session_distribution, f"{args.output}/session_distribution")

    elapsed = time.perf_counter() - started
    metrics = {
        "mode": args.mode,
        "input": args.input,
        "output": args.output,
        "elapsed_seconds": round(elapsed, 3),
        "total_events": int(total_events),
        "distinct_users": int(distinct_users),
        "distinct_repositories": int(distinct_repositories),
        "delta_minutes": args.delta_minutes,
        "compute_sessions": bool(args.compute_sessions),
        "spark_master": spark.sparkContext.master,
        "spark_app_id": spark.sparkContext.applicationId,
    }
    metrics_path = Path(args.metrics)
    metrics_path.parent.mkdir(parents=True, exist_ok=True)
    metrics_path.write_text(json.dumps(metrics, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(metrics, ensure_ascii=False, indent=2))

    events.unpersist()
    spark.stop()


if __name__ == "__main__":
    main()
