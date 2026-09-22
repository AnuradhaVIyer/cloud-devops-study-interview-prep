# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 11 - Create a DynamoDB table for application metadata with on-demand capacity.
# ============================================================

$ErrorActionPreference="Stop"; $Region=if($env:AWS_REGION){$env:AWS_REGION}else{"ap-south-1"}; $Table="aws-three-tier-app-metadata"
aws dynamodb describe-table --region $Region --table-name $Table *> $null
if($LASTEXITCODE -ne 0){
  aws dynamodb create-table --region $Region --table-name $Table --attribute-definitions AttributeName=Id,AttributeType=S --key-schema AttributeName=Id,KeyType=HASH --billing-mode PAY_PER_REQUEST --tags "Key=Project,Value=aws-three-tier" "Key=Environment,Value=dev" "Key=ManagedBy,Value=aws-cli"
  aws dynamodb wait table-exists --region $Region --table-name $Table
}
aws dynamodb describe-table --region $Region --table-name $Table --query "Table.[TableName,TableStatus,TableArn]" --output table
