#!/usr/bin/env bash
set -euo pipefail
# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 12 - Create an IAM execution role and Lambda function that writes to the Step 11 DynamoDB table.
# ============================================================

REGION="${AWS_REGION:-ap-south-1}"; PROJECT="aws-three-tier"; TABLE="aws-three-tier-app-metadata"; FUNCTION="aws-three-tier-dynamodb-writer"; ROLE="aws-three-tier-lambda-role"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZIP="/tmp/$FUNCTION.zip"

if ! aws dynamodb describe-table --region "$REGION" --table-name "$TABLE" >/dev/null 2>&1; then echo "ERROR: Step 11 DynamoDB table not found."; exit 1; fi

ROLE_ARN=$(aws iam get-role --role-name "$ROLE" --query 'Role.Arn' --output text 2>/dev/null || true)
if [[ -z "$ROLE_ARN" || "$ROLE_ARN" == "None" ]]; then
  cat > /tmp/trust-lambda.json <<'EOF'
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"lambda.amazonaws.com"},"Action":"sts:AssumeRole"}]}
EOF
  ROLE_ARN=$(aws iam create-role --role-name "$ROLE" --assume-role-policy-document file:///tmp/trust-lambda.json --query 'Role.Arn' --output text)
  aws iam attach-role-policy --role-name "$ROLE" --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
  cat > /tmp/lambda-ddb-policy.json <<EOF
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["dynamodb:PutItem"],"Resource":"$(aws dynamodb describe-table --region "$REGION" --table-name "$TABLE" --query 'Table.TableArn' --output text)"}]}
EOF
  aws iam put-role-policy --role-name "$ROLE" --policy-name "DynamoDBWritePolicy" --policy-document file:///tmp/lambda-ddb-policy.json
fi

cd "$SCRIPT_DIR"
rm -f "$ZIP"
zip -j "$ZIP" "$SCRIPT_DIR/aws-step12-lambda-function.py" >/dev/null
EXISTS=$(aws lambda get-function --region "$REGION" --function-name "$FUNCTION" --query 'Configuration.FunctionArn' --output text 2>/dev/null || true)
if [[ -z "$EXISTS" || "$EXISTS" == "None" ]]; then
  sleep 10
  aws lambda create-function --region "$REGION" --function-name "$FUNCTION" --runtime python3.12 --handler aws-step12-lambda-function.lambda_handler --role "$ROLE_ARN" --zip-file "fileb://$ZIP" --environment "Variables={TABLE_NAME=$TABLE}" --tags "Project=$PROJECT,Environment=dev,ManagedBy=aws-cli"
else
  aws lambda update-function-code --region "$REGION" --function-name "$FUNCTION" --zip-file "fileb://$ZIP"
fi
aws lambda get-function --region "$REGION" --function-name "$FUNCTION" --query 'Configuration.[FunctionName,Runtime,FunctionArn]' --output table
