
check: lint

lint:
	shellcheck -P .githooks .buildkite/*sh
	shfmt -d .githooks/*
	shfmt -d bin/check-env

format:
	shfmt -w .githooks/*
	shfmt -w .buildkite/*sh
	shfmt -w tests/test-svmkit
	shfmt -w bin/check-env

.env-checked: bin/check-env
	./bin/check-env
	touch .env-checked

include .env-checked
