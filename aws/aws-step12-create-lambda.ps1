# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 12 - Create an IAM execution role and Lambda function that writes to the Step 11 DynamoDB table.
# ============================================================

$ErrorActionPreference="Stop"; $Region=if($env:AWS_REGION){$env:AWS_REGION}else{"ap-south-1"}; $Project="aws-three-tier"; $Table="aws-three-tier-app-metadata"; $Function="aws-three-tier-dynamodb-writer"; $Role="aws-three-tier-lambda-role"
$ScriptDir=Split-Path -Parent $MyInvocation.MyCommand.Path; $Zip=Join-Path $env:TEMP "$Function.zip"
aws dynamodb describe-table --region $Region --table-name $Table *> $null
if($LASTEXITCODE -ne 0){throw "Step 11 DynamoDB table not found."}

$RoleArn=aws iam get-role --role-name $Role --query "Role.Arn" --output text 2>$null
if([string]::IsNullOrWhiteSpace($RoleArn) -or $RoleArn -eq "None"){
  $Trust='{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"lambda.amazonaws.com"},"Action":"sts:AssumeRole"}]}'
  $TrustFile=Join-Path $env:TEMP "trust-lambda.json"; Set-Content $TrustFile $Trust
  $RoleArn=aws iam create-role --role-name $Role --assume-role-policy-document "file://$TrustFile" --query "Role.Arn" --output text
  aws iam attach-role-policy --role-name $Role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
  $Arn=aws dynamodb describe-table --region $Region --table-name $Table --query "Table.TableArn" --output text
  $Policy='{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["dynamodb:PutItem"],"Resource":"'+$Arn+'"}]}'
  $PolicyFile=Join-Path $env:TEMP "lambda-ddb-policy.json"; Set-Content $PolicyFile $Policy
  aws iam put-role-policy --role-name $Role --policy-name DynamoDBWritePolicy --policy-document "file://$PolicyFile"
}
Compress-Archive -Path (Join-Path $ScriptDir "aws-step12-lambda-function.py") -DestinationPath $Zip -Force
$Exists=aws lambda get-function --region $Region --function-name $Function --query "Configuration.FunctionArn" --output text 2>$null
if([string]::IsNullOrWhiteSpace($Exists) -or $Exists -eq "None"){
  Start-Sleep -Seconds 10
  aws lambda create-function --region $Region --function-name $Function --runtime python3.12 --handler "aws-step12-lambda-function.lambda_handler" --role $RoleArn --zip-file "fileb://$Zip" --environment "Variables={TABLE_NAME=$Table}" --tags "Project=$Project,Environment=dev,ManagedBy=aws-cli"
}else{aws lambda update-function-code --region $Region --function-name $Function --zip-file "fileb://$Zip"}
aws lambda get-function --region $Region --function-name $Function --query "Configuration.[FunctionName,Runtime,FunctionArn]" --output table
