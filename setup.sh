#!/bin/bash
set -euo pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
PROJECT_ID=${PROJECT_ID?"Missing PROJECT_ID"}
REGION=${REGION?"Missing REGION"}

HELLO_SERVICE_ACCOUNT="hello-sa"
CALLER_SERVICE_ACCOUNT="caller-sa"

gcloud config set project "$PROJECT_ID"

#Create service accounts

if gcloud iam service-accounts describe "${HELLO_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" --project "$PROJECT_ID" > /dev/null 2>&1;
then
   echo "$HELLO_SERVICE_ACCOUNT already exists"
else
   echo "creating $HELLO_SERVICE_ACCOUNT service account"
   gcloud iam service-accounts create "$HELLO_SERVICE_ACCOUNT" \
    --display-name "Hello function service account" \
    --project "$PROJECT_ID"
fi

if gcloud iam service-accounts describe "${CALLER_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" --project "$PROJECT_ID" > /dev/null 2>&1;
then
   echo "$CALLER_SERVICE_ACCOUNT already exists"
else
   echo "creating $CALLER_SERVICE_ACCOUNT service account"
   gcloud iam service-accounts create "$CALLER_SERVICE_ACCOUNT" \
    --display-name "Caller function service account" \
    --project "$PROJECT_ID"
fi

#Deploy functions
echo "deploying hello"
cd "$SCRIPTPATH"/function-hello
gcloud functions deploy hello-function \
    --entry-point functions.HelloWorld \
    --runtime java17 \
    --trigger-http \
    --memory 512MB \
    --region "$REGION" \
    --project "$PROJECT_ID" \
    --service-account "${HELLO_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --quiet

FUNCTION_URL=$(gcloud functions describe hello-function --region "$REGION" --format json | jq -r '.httpsTrigger.url')

echo "deploying caller"
cd "$SCRIPTPATH"/function-caller
gcloud functions deploy caller-function \
    --entry-point functions.SendHttpRequest \
    --runtime java17 \
    --trigger-http \
    --memory 512MB \
    --region "$REGION" \
    --project "$PROJECT_ID" \
    --service-account "${CALLER_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --set-env-vars FUNCTION_URL="$FUNCTION_URL" \
    --quiet

#Add permissions
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member "serviceAccount:${HELLO_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role "roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member "serviceAccount:${CALLER_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role "roles/cloudfunctions.invoker"
