# SVMkit Buildkite Pipelines

This repository contains Buildkite pipelines for building and testing
SVMKit.

Pipeline secrets are handled by [Buildkite Secrets](https://buildkite.com/docs/pipelines/security/secrets/buildkite-secrets)

Environment variable are used to modify execution. The avaiable
variables are described below for each pipeline.

## Secrets Required

Before running any tests, the following secrets need to be provisioned
and then set in the [`Buildkite Secrets API.`](https://buildkite.com/docs/pipelines/security/secrets/buildkite-secrets)

| Service             | Name                    | Description                                                                                                                                                                                            |
| ------------------- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Pulumi              | `PULUMI_ACCESS_TOKEN`   | For details, see the official documentation on [creating a Pulumi access token](https://www.pulumi.com/docs/pulumi-cloud/access-management/access-tokens/).                                            |
| Amazon Web Services | `AWS_ACCESS_KEY_ID`     | AWS ID. For details, see the official documentation on [creating an AWS access key](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys).         |
| Amazon Web Services | `AWS_SECRET_ACCESS_KEY` | AWS Key. For details, see the official documentation on [creating an AWS secret access key](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys). |
| Google Cloud        | `GCP_SA_KEY`            | For details, see the official documentation on [creating a Google Cloud service account key](https://cloud.google.com/iam/docs/keys-create-delete).                                                    |
| Github              | `GITHUB_TOOLING_KEY`    | Needed for private repo access                                                                                                                                                                         |

## Triggering pipelines

To trigger a pipeline, the `buildkite-trigger` script can be used to simplify the process

```
$ ./bin/buildkite-trigger --help
Usage: ./bin/buildkite-trigger [options] PIPELINE

   Trigger buildkite pipeline for a set of local repos.
   Branch information is pulled from local repos specifed in the --repo
   flag and passed as environment variables to buildkite.  The pipline
   needs to support this convention.  Branch info is passed as
   <REPO>_BRANCH environment variables.

Options:
  -E, --env  var=value  Set an environment varible for the pipeline
  -f, --force		Force trigger even if local repos are out of sync
  -h, --help            Show this help message and exit
  -m, --message <msg>   Set the build message (default: "Triggered from script")
  -n, --dry-run         Print the API call instead of triggering the build
  -r, --repo <path>	Include the given repo (can be used multiple times)
```

## Solana Packages (solana-packages.yml)
This pipeline builds Debian packages for the solana project using the
svmkit/build/solana-build script.

### Environment Variable Configuration Options

| Name                   | Required | Description                                 |
|:-----------------------|:---------|:--------------------------------------------|
| `REMOTE`               | Y        | Specify the remote to build. e.g. anza-xyz  |
| `TAG`                  | Y        | The tag to build e.g. v1.2.3                |
| `SVMKIT_BRANCH`        | N        | git@github.com:abklabs/svmkit branch        |
| `PULUMI_SVMKIT_BRANCH` | N        | git@github.com:abklabs/pulumi-svmkit branch |
| `TOOLING_BRANCH`       | N        | git@github.com:abklabs/tooling branch       |
| `SOLANA_LAB_BRANCH`    | N        | git@github.com:abklabs/solana-lab branch    |

## Solana Lab (solana-packages.yml)
This pipeline instantiates a Solana Lab instances
(git@github.com:abklabs/solana-lab) and performs TAP tests defined in
git@github.com:abklabs/solana-lab/test

### Environment Variable Configuration Options
| Name                   | Required | Description                                 |
|:-----------------------|:---------|:--------------------------------------------|
| `SVMKIT_BRANCH`        | N        | git@github.com:abklabs/svmkit branch        |
| `PULUMI_SVMKIT_BRANCH` | N        | git@github.com:abklabs/pulumi-svmkit branch |
| `TOOLING_BRANCH`       | N        | git@github.com:abklabs/tooling branch       |
| `SOLANA_LAB_BRANCH`    | N        | git@github.com:abklabs/solana-lab branch    |
| `PARENT_BUILD_ID`      | N        | Buildkite build id for artifacts            |
| `ARTIFACT_PATTERN`     | N        | Artifacts to download                       |


## SVMKit Examples (svmit-examples.yml)
This pipeline is designed to build SVMKit and the Pulumi provider and
run example cloud instantiations in AWS and GCP.

### `TEST_NAMES`
 * `test-gcp-validator-agave-ts`
 * `test-aws-network-spe-py`
 * `test-gcp-network-spe-ts`
 * `test-aws-validator-agave-ts`
 * `test-aws-validator-fd-ts`
 * `test-aws-validator-xen-ts`
 * `test-gcp-validator-agave-ts`

### Notes on Google Cloud

When creating the secret for `GCP_SA_KEY`
(`GOOGLE_SERVICE_ACCOUNT_KEY`) the service account must have these IAM
roles:
_ roles/serviceusage.serviceUsageViewer
_ roles/compute.viewer
_ roles/compute.instanceAdmin.v1
_ roles/compute.networkAdmin \* roles/compute.securityAdmin

This can be done using the gcloud CLI:

```
PROJECT=my-gcloud-project
SA=svmkit-buildkite@${PROJECT}.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding "$PROJECT" \
  --member="serviceAccount:$SA" \
  --role="roles/serviceusage.serviceUsageViewer"

gcloud projects add-iam-policy-binding "$PROJECT" \
  --member="serviceAccount:$SA" \
  --role="roles/compute.viewer"

gcloud projects add-iam-policy-binding "$PROJECT" \
  --member="serviceAccount:$SA" \
  --role="roles/compute.instanceAdmin.v1"

gcloud projects add-iam-policy-binding "$PROJECT" \
  --member="serviceAccount:$SA" \
  --role="roles/compute.networkAdmin"

gcloud projects add-iam-policy-binding "$PROJECT" \
  --member="serviceAccount:$SA" \
  --role="roles/compute.securityAdmin"
```
