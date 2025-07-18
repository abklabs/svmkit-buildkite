
check: lint

lint:
	shellcheck -P .githooks .buildkite/*sh
	shfmt -d .githooks/*
	shfmt -d .buildkite/*sh
	shfmt -d tests/test-svmkit


format:
	shfmt -w .githooks/*
	shfmt -w .buildkite/*sh
	shfmt -w tests/test-svmkit

.env-checked: bin/check-env
	./bin/check-env
	touch .env-checked

include .env-checked
