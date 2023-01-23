#!/bin/bash
set -euo pipefail

PROJECT_ID=${PROJECT_ID?"Missing PROJECT_ID"}
REGION=${REGION?"Missing REGION"}

#delete function
echo "deleting hello-function"
gcloud functions delete hello-function \
    --region "$REGION" \
    --project "$PROJECT_ID"

echo "deleting caller-function"
gcloud functions delete caller-function \
    --region "$REGION" \
    --project "$PROJECT_ID"

#delete service accounts
echo "deleting hello-sa"
gcloud iam service-accounts delete "hello-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
    --project "$PROJECT_ID"

echo "deleting caller-sa"
gcloud iam service-accounts delete "caller-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
    --project "$PROJECT_ID"
