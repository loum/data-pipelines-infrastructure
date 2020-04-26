include makester/makefiles/makester.mk
include makester/makefiles/python-venv.mk
include makester/makefiles/docker.mk
include makester/makefiles/compose.mk
include makester/makefiles/k8s.mk

# Set upstream DAG package dependency.
DATA_PIPELINES_DAG_VERSION = 0.0.0
DATA_PIPELINES_DAG_REPO = git+https://github.com/loum/data-pipelines-dags.git@$(DATA_PIPELINES_DAG_VERSION)
export PYTHON_MAJOR_MINOR_VERSION = 3.6
export SITE_PACKAGES_NAME = data_pipelines_dags
export DATA_PIPELINES_IMAGE = $(MAKESTER__SERVICE_NAME):$(HASH)

# Image versionion follows the format "<airflow-version>-<data-pipeline-dags-tag>-<image-release-number>"
MAKESTER__VERSION = 1.10.10-$(DATA_PIPELINES_DAG_VERSION)
MAKESTER__RELEASE_NUMBER = 1

init: makester-requirements

env.mk: Makefile
	-@$(PYTHON) makester/utils/templatester.py\
 --quiet\
 --write\
 --mapping data-pipelines-infrastructure/files/mappings/celery-executor.json\
 data-pipelines-infrastructure/files/envfile.j2 > $@

-include env.mk
VARS = $(shell sed -ne 's/ *\#.*$$//; /./ s/=.*$$// p' env.mk)

export:
	$(foreach v,$(VARS),$(eval $(shell echo export $(v)="$($(v))")))

MAKESTER__SERVICE_NAME = $(MAKESTER__PROJECT_NAME)

MAKESTER__BUILD_COMMAND = $(DOCKER) build\
 --build-arg DATA_PIPELINES_DAG_REPO=${DATA_PIPELINES_DAG_REPO}\
 --build-arg PYTHON_MAJOR_MINOR_VERSION=${PYTHON_MAJOR_MINOR_VERSION}\
 --build-arg SITE_PACKAGES_NAME=${SITE_PACKAGES_NAME}\
 -t $(MAKESTER__SERVICE_NAME):$(HASH) .

backoff:
	@$(PYTHON) makester/scripts/backoff -d "Airflow web UI" -p $(AIRFLOW__WEBSERVER__WEB_SERVER_PORT) localhost

k8s-manifests-clean:
	$(shell which rm) -fr ./k8s/manifests/* 2>/dev/null || true
	$(MAKE) -s local-build-config > ${MAKESTER__COMPOSE_K8S_EPHEMERAL} 2>/dev/null || true

k8s-manifests: MAKESTER__COMPOSE_K8S_EPHEMERAL = docker-compose-k8s-ephemeral.yml
k8s-manifests: k8s-manifests-clean konvert

compose-run: export
	@MAKESTER__SERVICE_NAME=$(MAKESTER__SERVICE_NAME) HASH=$(HASH)\
 $(DOCKER_COMPOSE) --project-directory $(MAKESTER__SERVICE_NAME)\
 $(COMPOSE_FILES) $(COMPOSE_CMD)

start-airflow-db: COMPOSE_CMD = up postgres
init-airflow-db: COMPOSE_CMD = up init-db
local-build-config: COMPOSE_CMD = config
local-build-airflow: COMPOSE_CMD = up --scale init-db=0 -d
local-build-down: COMPOSE_CMD = down -v

local-build-up: build-image
	$(MAKE) init-airflow-db
	$(MAKE) local-build-airflow
	$(MAKE) backoff

k8s-build-up: mk-start mk-docker-env-export build-image k8s-manifests kube-apply kube-get

k8s-build-down: mk-docker-env-export kube-del mk-del

SE_COMPOSE_FILES = -f $(MAKESTER__SERVICE_NAME)/docker-compose-celery.yml
start-airflow-db local-build-config init-airflow-db local-build-airflow local-build-down: COMPOSE_FILES = $(SE_COMPOSE_FILES)
CELERY_EXECUTOR_COMPOSE_FILES = -f $(MAKESTER__SERVICE_NAME)/docker-compose-celery.yml
start-airflow-db local-build-config init-airflow-db local-build-airflow local-build-down: COMPOSE_FILES = $(CELERY_EXECUTOR_COMPOSE_FILES)
start-airflow-db local-build-config init-airflow-db local-build-airflow local-build-down: compose-run

help: base-help python-venv-help docker-help compose-help k8s-help
	@echo "(Makefile)\n\
  init                 Build the local Python-based virtual environment\n\
  k8s-manifests        Genereate the K8s manifests from the local \"MAKESTER__COMPOSE_K8S_EPHEMERAL\" file\n\
  local-build-config   Display local Data Workflow docker-compose configuration (Airflow Sequential Executor)\n\
  local-build-up       Create local Data Workflow infrastructure and intialisation (Airflow Sequential Executor)\n\
  local-build-down     Destroy local Data Workflow infrastructure (Airflow Sequential Executor)\n\
  k8s-build-up         Create local Data Workflow infrastructure and intialisation on k8s (Airflow Celery Executor)\n\
  k8s-build-down       Destroy local Data Workflow infrastructure on k8s (Airflow Celery Executor)\n"

.PHONY: help env.mk
