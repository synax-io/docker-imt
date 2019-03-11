REPO ?= synaxio
# infrastructure-management-tools
IMAGE ?= imt
VERSION ?= v0.1.0

.PHONY: build
build:
	docker build --rm --no-cache -t ${REPO}/${IMAGE}:latest -t ${REPO}/${IMAGE}:${VERSION}  . 


