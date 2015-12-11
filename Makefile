#! /usr/bin/env make

IMAGE_NAME = "ramr/openshift-prometheus-test"


all:	build

build:
	@echo "  - Building docker image $(IMAGE_NAME) ... "
	docker build -t $(IMAGE_NAME) ./

run:	
	@echo "  - Starting docker container for image $(IMAGE_NAME) ... "
	docker run -p 0.0.0.0:9999:9090 -dit $(IMAGE_NAME)
