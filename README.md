# GCP function-function auth

A very simple GCP Function to function authentication example.

Using cloud functions gen1.

General requirements

- GCP project.
- Cloud functions API enabled.
- Permissions to create GCP functions and create service accounts.

Setup script requirements

- gcloud cli
- jq

Using the setup script

```bash
PROJECT_ID=example-project REGION=europe-west1 ./setup.sh
```

Using the cleanup script

```bash
PROJECT_ID=example-project REGION=europe-west1 ./cleanup.sh
```
