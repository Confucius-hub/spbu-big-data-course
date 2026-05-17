FROM eclipse-temurin:11-jdk-jammy

ARG HADOOP_VERSION=3.3.6
ARG SPARK_VERSION=3.5.3
ARG HIVE_VERSION=3.1.3
ARG ZEPPELIN_VERSION=0.12.0

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/opt/java/openjdk
ENV HADOOP_HOME=/opt/hadoop
ENV SPARK_HOME=/opt/spark
ENV HIVE_HOME=/opt/hive
ENV ZEPPELIN_HOME=/opt/zeppelin
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
ENV YARN_CONF_DIR=/opt/hadoop/etc/hadoop
ENV HIVE_CONF_DIR=/opt/hive/conf
ENV SPARK_CONF_DIR=/opt/spark/conf
ENV PATH=/opt/conda/bin:/opt/hadoop/bin:/opt/hadoop/sbin:/opt/spark/bin:/opt/hive/bin:/opt/zeppelin/bin:${PATH}

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    iproute2 \
    netcat-openbsd \
    procps \
    python3 \
    python3-pip \
    rsync \
    tini \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    arch="$(uname -m)"; \
    case "${arch}" in \
      x86_64) conda_arch="x86_64" ;; \
      aarch64|arm64) conda_arch="aarch64" ;; \
      *) echo "Unsupported architecture: ${arch}" && exit 1 ;; \
    esac; \
    curl -fsSL "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-${conda_arch}.sh" \
      -o /tmp/miniconda.sh; \
    bash /tmp/miniconda.sh -b -p /opt/conda; \
    rm /tmp/miniconda.sh; \
    conda clean -afy

RUN set -eux; \
    curl -fsSL "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
      | tar -xz -C /opt; \
    ln -s "/opt/hadoop-${HADOOP_VERSION}" "${HADOOP_HOME}"; \
    curl -fsSL "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz" \
      | tar -xz -C /opt; \
    ln -s "/opt/spark-${SPARK_VERSION}-bin-hadoop3" "${SPARK_HOME}"; \
    curl -fsSL "https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz" \
      | tar -xz -C /opt; \
    ln -s "/opt/apache-hive-${HIVE_VERSION}-bin" "${HIVE_HOME}"; \
    curl -fsSL "https://archive.apache.org/dist/zeppelin/zeppelin-${ZEPPELIN_VERSION}/zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz" \
      | tar -xz -C /opt; \
    ln -s "/opt/zeppelin-${ZEPPELIN_VERSION}-bin-all" "${ZEPPELIN_HOME}"

RUN set -eux; \
    rm -f "${HIVE_HOME}"/lib/guava-*.jar; \
    cp "${HADOOP_HOME}"/share/hadoop/common/lib/guava-*.jar "${HIVE_HOME}/lib/"; \
    curl -fsSL "https://jdbc.postgresql.org/download/postgresql-42.7.4.jar" \
      -o "${HIVE_HOME}/lib/postgresql-42.7.4.jar"; \
    mkdir -p /hadoop/dfs/name /hadoop/dfs/data /hadoop/yarn/local /hadoop/yarn/logs \
      /spark-events /workspace /tmp/hive

COPY docker/entrypoint.sh /usr/local/bin/hw3-entrypoint.sh
RUN chmod +x /usr/local/bin/hw3-entrypoint.sh

WORKDIR /workspace
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/hw3-entrypoint.sh"]
