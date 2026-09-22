#!/usr/bin/env bash
set -euo pipefail
# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 11 - Create a DynamoDB table for application metadata with on-demand capacity.
# ============================================================

REGION="${AWS_REGION:-ap-south-1}"; TABLE="${DYNAMODB_TABLE_NAME:-aws-three-tier-app-metadata}"
if ! aws dynamodb describe-table --region "$REGION" --table-name "$TABLE" >/dev/null 2>&1; then
  aws dynamodb create-table --region "$REGION" --table-name "$TABLE" --attribute-definitions AttributeName=Id,AttributeType=S --key-schema AttributeName=Id,KeyType=HASH --billing-mode PAY_PER_REQUEST --tags "Key=Project,Value=aws-three-tier" "Key=Environment,Value=dev" "Key=ManagedBy,Value=aws-cli"
  aws dynamodb wait table-exists --region "$REGION" --table-name "$TABLE"
fi
aws dynamodb describe-table --region "$REGION" --table-name "$TABLE" --query 'Table.[TableName,TableStatus,TableArn]' --output table
