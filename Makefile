include makester/makefiles/makester.mk
include makester/makefiles/python-venv.mk
include makester/makefiles/compose.mk

init: makester-requirements

env.mk: Makefile
	$(PYTHON) makester/utils/templatester.py\
 --quiet\
 --write\
 --mapping data-pipelines-infrastructure/files/mappings/celery-executor.json\
 data-pipelines-infrastructure/files/envfile.j2 > $@

-include env.mk
VARS = $(shell sed -ne 's/ *\#.*$$//; /./ s/=.*$$// p' env.mk)

export:
	@$(foreach v,$(VARS),$(eval $(shell echo export $(v)="$($(v))")))

reset-env:
	$(shell which rm) env.mk

MAKESTER__SERVICE_NAME = $(MAKESTER__PROJECT_NAME)

backoff:
	@$(PYTHON) makester/scripts/backoff -d "Airflow web UI" -p $(AIRFLOW__WEBSERVER__WEB_SERVER_PORT) localhost

compose-run: env.mk export reset-env
	@MAKESTER__SERVICE_NAME=$(MAKESTER__SERVICE_NAME) HASH=$(HASH)\
 $(DOCKER_COMPOSE) --project-directory $(MAKESTER__SERVICE_NAME)\
 $(COMPOSE_FILES) $(COMPOSE_CMD)

start-airflow-db: COMPOSE_CMD = up postgres
init-airflow-db: COMPOSE_CMD = up init-db
local-build-config: COMPOSE_CMD = config
local-build-airflow: COMPOSE_CMD = up --scale init-db=0 -d
local-build-down: COMPOSE_CMD = down -v

local-build-up:
	$(MAKE) init-airflow-db
	$(MAKE) local-build-airflow
	$(MAKE) backoff
	$(MAKE) reset-env

SE_COMPOSE_FILES = -f $(MAKESTER__SERVICE_NAME)/docker-compose-celery.yml
start-airflow-db local-build-config init-airflow-db local-build-airflow local-build-down: COMPOSE_FILES = $(SE_COMPOSE_FILES)
start-airflow-db local-build-config init-airflow-db local-build-airflow local-build-down: compose-run

help: base-help python-venv-help compose-help
	@echo "(Makefile)\n\
  init                 Build the local Python-based virtual environment\n\
  local-build-config   Display local Data Workflow docker-compose configuration (Airflow Sequential Executor)\n\
  local-build-up       Create local Data Workflow infrastructure and intialisation (Airflow Sequential Executor)\n\
  local-build-down     Destroy local Data Workflow infrastructure (Airflow Sequential Executor)\n"

.PHONY: help
