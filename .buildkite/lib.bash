#!/usr/bin/env bash

# shellcheck disable=SC1091 # this will be in our PATH at runtime
source opsh
source "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/git.opsh"
source "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/buildkite.opsh"

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
	GCP_SA_KEY_FILE="$(temp::file)"
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

get-pipeline-pulumi-svmkit() {
    local outdir
    outdir=$1 ; shift

    bk::group "Searching for pipeline build of pulumi-svmkit"
    buildkite-agent artifact search pulumi-artifacts.tgz || return 1

    log::info "Downloading Pulumi SDK and provider plugin artifacts"
    buildkite-agent artifact download pulumi-artifacts.tgz "$outdir"
    ( cd "$outdir" && tar zxf pulumi-artifacts.tgz )
    return 0
}

pulumi-install-and-run() {
    local prefix

    prefix=()
    if get-pipeline-pulumi-svmkit .. ; then
        log::info "Using a pipeline build of pulumi-svmkit"
        prefix+=(with-local-pulumi-svmkit ../pulumi-svmkit)
    else
        log::info "Using the released pulumi-svmkit"
        pulumi install
    fi

    "${prefix[@]}" "$@"
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
