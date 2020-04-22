ARG DATA_PIPELINES_DAG_VERSION=0.0.0
ARG IMAGE_PYTHON_VERSION=3.6
ARG APACHE_AIRFLOW_VERSION="1.10.10-python${IMAGE_PYTHON_VERSION}"

FROM apache/airflow:${APACHE_AIRFLOW_VERSION} as builder

USER root
RUN apt-get update && apt-get install -y --no-install-recommends git

USER airflow
ARG DATA_PIPELINES_DAG_VERSION
RUN pip install --user\
 --no-cache-dir\
 "git+https://github.com/loum/data-pipelines-dags.git@${DATA_PIPELINES_DAG_VERSION}"

FROM apache/airflow:${APACHE_AIRFLOW_VERSION}

ARG IMAGE_PYTHON_VERSION
RUN ls -al "/home/airflow/.local/lib/python${IMAGE_PYTHON_VERSION}/site-packages"

COPY --from=builder --chown=airflow:airflow\
 /home/airflow/.local/lib/python${IMAGE_PYTHON_VERSION}/site-packages/data_pipelines_dags/\
 /home/airflow/.local/lib/python${IMAGE_PYTHON_VERSION}/site-packages/data_pipelines_dags/
