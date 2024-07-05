.PHONY: clean clean-test clean-pyc clean-build help autopep8
.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"




help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)


IMAGE_TAG := test
DEVICE := cuda

lint:
	pytype

flake8:
	python3 -m flake8 persia

format:
	python3 -m black --config pyproject.toml

pytest:
	pytest

all: lint flake8 format

build_dev_pip:
	USE_CUDA=1 pip3 install -e . --prefix=~/.local/

build_ci_image:
	DOCKER_BUILDKIT=1 docker build --build-arg DEVICE=cuda \
	-t persia-ci:$(IMAGE_TAG) --target builder .

build_dev_image:
	IMAGE_TAG=dev make build_cuda_runtime_image

build_cuda_runtime_image:
	DOCKER_BUILDKIT=1 docker build --build-arg DEVICE=cuda \
	-t persia-cuda-runtime:$(IMAGE_TAG) --target runtime .

build_cpu_runtime_image:
	DOCKER_BUILDKIT=1 docker build --build-arg DEVICE=cpu --build-arg BASE_IMAGE="ubuntu:20.04" \
	-t persia-cpu-runtime:$(IMAGE_TAG) --target runtime .

build_runtime_image: build_cuda_runtime_image build_cpu_runtime_image

build_all_image: build_ci_image build_cuda_runtime_image build_cpu_runtime_image

dist: clean ## 构建并分发(本地)
	python -m build

install: dist ## 重新安装
	pip uninstall --yes persia
	pip install ./dist/persia*whl
#	 pip install --force-reinstall persia

clean: clean-build clean-pyc clean-test ## 删除所有的build/test/coverage/Python临时文件

clean-build: ## 删除编译生成的临时文件
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc:			## 删除pyc/pyo/__pycache__等临时文件
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test:			## 删除test/coverage临时文件
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache
	find . -name .performance_analysis -exec rm -rf {} +
