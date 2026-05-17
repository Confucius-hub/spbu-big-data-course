#!/usr/bin/env bash
set -euo pipefail

role="${SERVICE_ROLE:-client}"

export HADOOP_ROOT_LOGGER="${HADOOP_ROOT_LOGGER:-INFO,console}"
export HADOOP_OPTS="${HADOOP_OPTS:-} -Djava.net.preferIPv4Stack=true"
export SPARK_NO_DAEMONIZE=true
export ZEPPELIN_ADDR="${ZEPPELIN_ADDR:-0.0.0.0}"

wait_for_port() {
  local host="$1"
  local port="$2"
  local name="$3"
  for _ in $(seq 1 120); do
    if nc -z "$host" "$port"; then
      echo "${name} is available at ${host}:${port}"
      return 0
    fi
    sleep 2
  done
  echo "Timeout waiting for ${name} at ${host}:${port}" >&2
  return 1
}

case "$role" in
  namenode)
    if [ ! -d /hadoop/dfs/name/current ]; then
      hdfs namenode -format -force -nonInteractive
    fi
    exec hdfs namenode
    ;;
  datanode)
    wait_for_port namenode 9000 namenode
    exec hdfs datanode
    ;;
  resourcemanager)
    wait_for_port namenode 9000 namenode
    exec yarn resourcemanager
    ;;
  nodemanager)
    wait_for_port resourcemanager 8032 resourcemanager
    exec yarn nodemanager
    ;;
  historyserver)
    wait_for_port namenode 9000 namenode
    exec mapred historyserver
    ;;
  hive-metastore)
    wait_for_port postgres 5432 postgres
    wait_for_port namenode 9000 namenode
    if ! schematool -dbType postgres -info >/tmp/hive_schema_info.log 2>&1; then
      schematool -dbType postgres -initSchema
    fi
    exec hive --service metastore
    ;;
  hive-server2)
    wait_for_port hive-metastore 9083 hive-metastore
    exec hiveserver2
    ;;
  zeppelin)
    wait_for_port resourcemanager 8032 resourcemanager
    exec "${ZEPPELIN_HOME}/bin/zeppelin.sh"
    ;;
  client)
    exec sleep infinity
    ;;
  *)
    exec "$@"
    ;;
esac
