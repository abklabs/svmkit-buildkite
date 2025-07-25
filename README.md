# svmkit-buildkite
Buildkite integration for SVMKIt

## Secrets Required
The buildkite pipeline neesd the following secrets provisioned.
Use the Buildkite Secrets API to set.

The appropiate values are set in .buildkite/cloud-creds.sh and source in
the pipeline:
```
    CLOUD=aws  && . .buildkite/cloud-creds.sh
    CLOUD=gcp  && . .buildkite/cloud-creds.sh
```

### Pulumi
  - PULUMI_ACCESS_TOKEN
  
### Amazon Web Services
  - AWS_ACCESS_KEY_ID
  - ASW_SECRET_ACCESS_KEY

### Google Cloud
  -  GCP_SA_KEY

  notes:  Create a Service key, say 'svmkit-buildkite'
  The service-account key needs the following permission set:

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
