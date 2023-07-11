export CLUSTER ?= dev.srv.uk
export DOCKER_ORG ?= guru
export DOCKER_IMAGE ?= $(DOCKER_ORG)/$(CLUSTER)
export DOCKER_TAG ?= latest
export DOCKER_IMAGE_NAME ?= $(DOCKER_IMAGE):$(DOCKER_TAG)
export DOCKER_BUILD_FLAGS =

## Initialize build-harness, install deps, build docker container, install wrapper script and run shell
all: deps build run
	@exit 0

## Install dependencies (if any)
deps:
	@exit 0

clean:
	@docker image rm $(DOCKER_IMAGE)

## Build docker image
build:
	@docker build -t $(DOCKER_IMAGE) $(DOCKER_BUILD_FLAGS) .

run:
	./start.sh

format:
	command -v pre-commit >/dev/null 2>&1 || { brew install pre-commit; }
	pre-commit run -a
