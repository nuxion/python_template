define USAGE
Super awesome hand-crafted build system ⚙️

Commands:
	setup     Install dependencies, dev included
	lock      Generate requirements.txt
	test      Run tests
	lint      Run linting tests
	run       Run docker image with --rm flag but mounted dirs.
	release   Publish docker image based on some variables
	docker    Build the docker image
	tag    	  Make a git tab using poetry information

endef

export USAGE
.EXPORT_ALL_VARIABLES:
VERSION := $(shell git describe --tags)
BUILD := $(shell git rev-parse --short HEAD)
PROJECTNAME := $(shell basename "$(PWD)")
PACKAGE_DIR = $(shell basename "$(PWD)")
DOCKERID = $(shell echo "nuxion")
REGISTRY := registry.nyc1.algorinfo


help:
	@echo "$$USAGE"

.PHONY: startenv
startenv:
	poetry shell
	docker-compose start 
	alembic upgrade head

lock:
	poetry export -f requirements.txt --output requirements.txt --without-hashes

.PHONY: lint
lint:
	echo "Running pylint...\n"
	pylint --disable=R,C,W $(PACKAGE_DIR)
	# echo "Running isort...\n"
	# isort --check $(PACKAGE_DIR)
	# echo "Running mypy...\n"
	# mypy $(PACKAGE_DIR)

.PHONY: test
test:
	PYTHONPATH=$(PWD) pytest tests/

.PHONY: setup
setup:
	poetry install --dev

.PHONY: run
run:
	docker run --rm -p 127.0.0.1:8100:8000 -p 127.0.0.1:8110:8001 ${DOCKERID}/${PROJECTNAME}

.PHONY: docker
docker:
	docker build -t ${DOCKERID}/${PROJECTNAME} .

.PHONY: release
release:
	docker tag ${DOCKERID}/${PROJECTNAME} ${REGISTRY}/${DOCKERID}/${PROJECTNAME}:$(VERSION)
	docker push ${REGISTRY}/${DOCKERID}/${PROJECTNAME}:$(VERSION)

.PHONY: redis-cli
redis-cli:
	docker-compose exec redis redis-cli

.PHONY: tag
tag:
	#poetry version prealese
	git tag -a $(shell poetry version --short) -m "$(shell git log -1 --pretty=%B | head -n 1)"
