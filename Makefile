ARCH 		?=	amd64
TAG 		?=	svmkit/agent/$(ARCH)
PLATFORMS 	?=	linux/amd64,linux/arm64
BUILD_CONTEXT 	?=	.
DOCKERFILE 	?=	Dockerfile

.PHONY: docker docker-image check lint format

check: lint

lint:
	shellcheck -P .githooks lib/*sh
	shfmt -d .githooks/*
	shfmt -d bin/check-env

format:
	shfmt -w .githooks/*
	shfmt -w .buildkite/*sh
	shfmt -w tests/test-svmkit
	shfmt -w bin/check-env

docker-run: docker-image
	docker run --platform=linux/$(ARCH) $(TAG) start --tags "queue=$(USER)" --token "$(BUILDKITE_API_TOKEN)"

docker-build:
	docker build --platform=linux/$(ARCH) -t $(TAG) -f $(DOCKERFILE) $(BUILD_CONTEXT)

# Buildx multi-platform build (does NOT push by default)
docker-buildx:
	docker buildx build \
		--platform=$(PLATFORMS) \
		-t $(TAG) \
		-f $(DOCKERFILE) \
		$(BUILD_CONTEXT)

# Target to simplify testing
docker-shell:
	docker run --platform=linux/$(ARCH) -it --entrypoint=/bin/bash $(TAG)

.env-checked: bin/check-env
	./bin/check-env
	touch .env-checked

include .env-checked
