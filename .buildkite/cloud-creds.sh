#!/bin/bash
set -euo pipefail

echo "INFO: Setting up environment for cloud: ${CLOUD:-unspecified}"

# Always required
PULUMI_ACCESS_TOKEN="$(buildkite-agent secret get PULUMI_ACCESS_TOKEN)"
export PULUMI_ACCESS_TOKEN

case "${CLOUD:-}" in
aws)
	AWS_ACCESS_KEY_ID="$(buildkite-agent secret get AWS_ACCESS_KEY_ID)"
	AWS_SECRET_ACCESS_KEY="$(buildkite-agent secret get AWS_SECRET_ACCESS_KEY)"
	export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
	;;

gcp)
	: "${GOOGLE_PROJECT:=svmkit}"
	: "${GOOGLE_REGION:=us-central1}"
	: "${GOOGLE_ZONE:=${GOOGLE_REGION}-a}"

	GCP_SA_KEY="$(buildkite-agent secret get GCP_SA_KEY)"
	mkdir -p /secrets
	echo "$GCP_SA_KEY" >/secrets/sa-key.json
	chmod 600 /secrets/sa-key.json
	GOOGLE_APPLICATION_CREDENTIALS=/secrets/sa-key.json
	gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
	gcloud config set project "$GOOGLE_PROJECT"
	export GOOGLE_PROJECT \
		GOOGLE_REGION \
		GOOGLE_ZONE \
		GOOGLE_APPLICATION_CREDENTIALS
	;;

*)
	echo "ERROR: Unsupported or missing CLOUD environment variable: '${CLOUD:-}'"
	exit 1
	;;
esac
