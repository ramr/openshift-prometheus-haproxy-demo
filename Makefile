#! /usr/bin/env make

IMAGE_NAME = "ramr/origin-haproxy-exporter-test"


all:	build

build:
	@echo "  - Building docker image $(IMAGE_NAME) ... "
	docker build -t $(IMAGE_NAME) ./

run:	
	docker run -dit $(IMAGE_NAME)
