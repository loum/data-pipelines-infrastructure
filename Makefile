include makester/makefiles/base.mk
include makester/makefiles/python-venv.mk
include makester/makefiles/compose.mk

init: makester-requirements

local-build-up: compose-up

local-build-down: compose-down

help: base-help python-venv-help compose-help
	@echo "(Makefile)\n\
  init                 Build the local Python-based virtual environment\n\
  local-build-up:      Create local Data Workflow infrastructure and intialisation\n\
  local-build-down:    Destroy local Data Workflow infrastructure\n"

.PHONY: help
