# svmkit-buildkite
Buildkite integration for SVMKIt

## Secrets Required
The following secrets need to be provisioned with the appropriate service
and then set in the [`Buildkite Secrets API.`](https://buildkite.com/docs/pipelines/security/secrets/buildkite-secrets)

The appropiate values are set in [`.buildkite/cloud-creds.sh`](.buildkite/cloud-creds.sh):

### Pulumi
  - PULUMI_ACCESS_TOKEN
  
### Amazon Web Services
  - AWS_ACCESS_KEY_ID
  - ASW_SECRET_ACCESS_KEY

### Google Cloud
  -  GCP_SA_KEY
     A Service Account key—for example, for svmkit-ci-deployer. The service account must have these IAM roles:
	- roles/serviceusage.serviceUsageViewer
	- roles/compute.viewer
	- roles/compute.instanceAdmin.v1
	- roles/compute.networkAdmin
	- roles/compute.securityAdmin


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
