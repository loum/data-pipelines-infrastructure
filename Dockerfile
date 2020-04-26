ARG PYTHON_MAJOR_MINOR_VERSION="3.6"
ARG PYTHON_BASE_IMAGE="python:${PYTHON_MAJOR_MINOR_VERSION}-slim-buster"

ARG APACHE_AIRFLOW_VERSION="1.10.10-python${PYTHON_MAJOR_MINOR_VERSION}"

FROM "${PYTHON_BASE_IMAGE}" as builder

RUN apt-get update && apt-get install -y --no-install-recommends git
RUN python -m pip install --no-cache-dir --upgrade pip --user

ARG DATA_PIPELINES_DAG_REPO
RUN python -m pip install --no-cache-dir ${DATA_PIPELINES_DAG_REPO} --user &&\
 find /root/.local/ -name '*.pyc' -print0 | xargs -0 rm -r &&\
 find /root/.local/ -type d -name '__pycache__' -print0 | xargs -0 rm -r

FROM apache/airflow:${APACHE_AIRFLOW_VERSION}

ARG PYTHON_MAJOR_MINOR_VERSION
ARG SITE_PACKAGES_NAME
COPY --from=builder --chown=airflow:airflow\
 /root/.local/lib/python${PYTHON_MAJOR_MINOR_VERSION}/site-packages/${SITE_PACKAGES_NAME}/\
 /home/airflow/.local/lib/python${PYTHON_MAJOR_MINOR_VERSION}/site-packages/${SITE_PACKAGES_NAME}/
