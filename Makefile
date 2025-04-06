# .PHONY: clean data lint requirements sync_data_to_s3 sync_data_from_s3

#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PROFILE = default
PROJECT_NAME = finhub-data
PYTHON_INTERPRETER = python3
PYTHON_VERSION = 3.11

ENV_REQUIREMENTS := ./scripts/requirements.txt
PROJECT_REQUIREMENTS:= requirements.txt

CONDA_EXE := $(shell which conda)
HAS_CONDA := $(shell command -v conda 2> /dev/null)

#################################################################################
# COMMANDS                                                                      #
#################################################################################

check_conda:
ifeq ($(HAS_CONDA),)
	@echo "Conda not found! Please install Miniconda or Anaconda first."
	@exit 1
else
	@echo "Conda found at: $(HAS_CONDA)"
endif




## Make Dataset
data: requirements
	$(PYTHON_INTERPRETER) src/data/make_dataset.py data/raw data/processed

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## Lint using flake8
lint:
	flake8 src
## Upload Data to S3
#sync_data_to_s3:
#ifeq (default,$(PROFILE))
#	aws s3 sync data/ s3://$(BUCKET)/data/
#else
#	aws s3 sync data/ s3://$(BUCKET)/data/ --profile $(PROFILE)
#endif

## Download Data from S3
#sync_data_from_s3:
#ifeq (default,$(PROFILE))
#	aws s3 sync s3://$(BUCKET)/data/ data/
#else
#	aws s3 sync s3://$(BUCKET)/data/ data/ --profile $(PROFILE)
#endif

## Set up python interpreter environment
create_environment: check_conda
	@echo ">>> Creating conda environment: $(PROJECT_NAME)"
	@$(CONDA_EXE) create --yes --name $(PROJECT_NAME) python=$(PYTHON_VERSION) openjdk -c conda-forge

	@echo ">>> Setting JAVA_HOME activation hook"
	@bash -c 'eval "$$($(CONDA_EXE) shell.bash hook)" && \
	conda activate $(PROJECT_NAME) && \
	mkdir -p $$CONDA_PREFIX/etc/conda/activate.d && \
	echo "export JAVA_HOME=$$CONDA_PREFIX/lib/jvm" > $$CONDA_PREFIX/etc/conda/activate.d/env_vars.sh'

	@echo ">>> JAVA_HOME will be automatically set on environment activation."

## Install Python Dependencies
install_requirements:
	@echo ">>> Install python dependencies: $(PROJECT_NAME)"
	@bash -c 'eval "$$($(CONDA_EXE) shell.bash hook)" && \
	conda activate $(PROJECT_NAME) && \
	$(PYTHON_INTERPRETER) -m pip install -U pip setuptools wheel && \
	$(PYTHON_INTERPRETER) -m pip install -r $(ENV_REQUIREMENTS) && \
	$(PYTHON_INTERPRETER) -m pip install -r $(PROJECT_REQUIREMENTS)'

## Test python environment is setup correctly
test_environment:
	@echo ">>> Verifying Conda environment: $(PROJECT_NAME)"
	@bash -c 'eval "$$($(CONDA_EXE) shell.bash hook)" && \
	conda activate $(PROJECT_NAME) && \
	echo ">>> Python version:" && \
	python --version && \
	echo ">>> Java version:" && \
	java -version && \
	echo ">>> Spark version:" && \
	spark-submit --version'

#################################################################################
# PROJECT RULES                                                                 #
#################################################################################



#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

