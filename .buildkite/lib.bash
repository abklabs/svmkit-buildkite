#!/usr/bin/env bash

# shellcheck disable=SC1091 # this will be in our PATH at runtime
source opsh
source "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/git.opsh"

lib::import ssh

setup-aws-credentials() {
	AWS_ACCESS_KEY_ID="$(buildkite-agent secret get AWS_ACCESS_KEY_ID)"
	AWS_SECRET_ACCESS_KEY="$(buildkite-agent secret get AWS_SECRET_ACCESS_KEY)"
	export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
}

setup-gcp-credentials() {
	: "${GOOGLE_PROJECT:=svmkit}"
	: "${GOOGLE_REGION:=us-central1}"
	: "${GOOGLE_ZONE:=${GOOGLE_REGION}-a}"

	GCP_SA_KEY="$(buildkite-agent secret get GCP_SA_KEY)"
	trap 'rm -f "$GCP_SA_KEY_FILE"' EXIT INT TERM
	GCP_SA_KEY_FILE="$(mktemp /tmp/sa-key-XXXXXX.json)"
	chmod 600 "$GCP_SA_KEY_FILE"
	echo "$GCP_SA_KEY" >"$GCP_SA_KEY_FILE"
	GOOGLE_APPLICATION_CREDENTIALS="$GCP_SA_KEY_FILE"
	gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
	gcloud config set project "$GOOGLE_PROJECT"
	export GOOGLE_PROJECT \
		GOOGLE_REGION \
		GOOGLE_ZONE \
		GOOGLE_APPLICATION_CREDENTIALS
}

# Disable buildkite's default remote rewrite config
git config --global --remove-section 'url.https://github.com/'

ssh::begin

# Configure SSH to ignore host key checking
ssh::config <<EOF
Host *
     UserKnownHostsFile /dev/null
     StrictHostKeyChecking no
     LogLevel quiet
EOF

buildkite-agent secret get GITHUB_TOOLING_KEY | ssh::key::add

PULUMI_ACCESS_TOKEN="$(buildkite-agent secret get PULUMI_ACCESS_TOKEN)"
export PULUMI_ACCESS_TOKEN
