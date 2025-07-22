#!/bin/bash

set -e

echo "Logging in to ECR..."
aws ecr get-login-password --region "${AWS_DEFAULT_REGION}" | docker login --username AWS --password-stdin "${REPOSITORY_URI}"

echo "Fetching existing task definition for family ${TASK_DEFINITION_NAME}..."
TASK_DEFINITION=$(aws ecs describe-task-definition \
  --task-definition "${TASK_DEFINITION_NAME}" \
  --region "${AWS_DEFAULT_REGION}")

# Extract and update container image
NEW_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq --arg IMAGE "${REPOSITORY_URI}:${IMAGE_TAG}" '
  .taskDefinition
  | .containerDefinitions[0].image = $IMAGE
  | del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy)
')

# Register new revision
echo "Registering new task definition revision..."
NEW_TASK_INFO=$(aws ecs register-task-definition \
  --region "${AWS_DEFAULT_REGION}" \
  --cli-input-json "$NEW_TASK_DEFINITION")

NEW_REVISION=$(echo $NEW_TASK_INFO | jq '.taskDefinition.revision')
echo "New Revision: $NEW_REVISION"

# Update ECS service
echo "Updating ECS service..."
aws ecs update-service \
  --cluster "${CLUSTER_NAME}" \
  --service "${SERVICE_NAME}" \
  --task-definition "${TASK_DEFINITION_NAME}:${NEW_REVISION}" \
  --desired-count "${DESIRED_COUNT}" \
  --region "${AWS_DEFAULT_REGION}"

echo "Deployment complete!"
