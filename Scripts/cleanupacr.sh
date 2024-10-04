#!/bin/bash

# Set the ACR name and login server
ACR_NAME=ACR_NAME # Replace with your ACR name
LOGIN_SERVER=${ACR_NAME}.azurecr.io

# Set the repository name
REPOSITORY_NAME=REPO_NAME # Replace with your repository name

# Set the retention period (7 days)
RETENTION_PERIOD=7

# Get the current date and time
CURRENT_DATE=$(date +"%Y-%m-%dT%H:%M:%SZ")

# Calculate the date 7 days ago
RETENTION_DATE=$(date -d "-$RETENTION_PERIOD days" +"%Y-%m-%dT%H:%M:%SZ")

# Get the list of images older than the retention period
images=$(az acr manifest list-metadata --name $REPOSITORY_NAME --registry $ACR_NAME --orderby time_asc -o tsv --query "[?lastUpdateTime < '$RETENTION_DATE'].[digest, lastUpdateTime]")

# Delete the old images, except the last one
count=0
while IFS=$'\t' read -r digest lastUpdateTime; do
  ((count++))
  if [ $count -eq $(echo "$images" | wc -l) ]; then
    echo "Skipping deletion of last image: $REPOSITORY_NAME@$digest"
  else
    tags=$(az acr repository show-tags -n $ACR_NAME --repository $REPOSITORY_NAME --filter $digest --query "[].name")
    if [ -n "$tags" ]; then
      echo "Deleting image: $REPOSITORY_NAME@$digest with tags: $tags"
    else
      echo "Deleting image: $REPOSITORY_NAME@$digest (no tags)"
    fi
    az acr repository delete -n $ACR_NAME --image $REPOSITORY_NAME@$digest --yes
  fi
done <<< "$images"