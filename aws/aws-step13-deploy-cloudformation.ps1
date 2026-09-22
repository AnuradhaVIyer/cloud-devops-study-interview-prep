# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 13 - Deploy the CloudFormation demonstration stack from the local YAML template.
# ============================================================

$ErrorActionPreference="Stop"; $Region=if($env:AWS_REGION){$env:AWS_REGION}else{"ap-south-1"}; $Stack="aws-three-tier-cfn-demo"; $Dir=Split-Path -Parent $MyInvocation.MyCommand.Path
$Template=Join-Path $Dir "aws-step13-cloudformation-template.yaml"
if(!(Test-Path $Template)){throw "CloudFormation template not found: $Template"}
aws cloudformation deploy --region $Region --stack-name $Stack --template-file $Template --capabilities CAPABILITY_IAM
aws cloudformation describe-stacks --region $Region --stack-name $Stack --query "Stacks[0].[StackName,StackStatus]" --output table
