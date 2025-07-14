
check: lint

lint:
	shellcheck -P .githooks .buildkite/*sh
	shfmt -d .githooks/*

format:
	shfmt -w .githooks/*
	shfmt -w .buildkite/*sh
