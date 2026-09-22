#!/usr/bin/env bash
set -euo pipefail
# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 13 - Deploy the CloudFormation demonstration stack from the local YAML template.
# ============================================================

REGION="${AWS_REGION:-ap-south-1}"; STACK="aws-three-tier-cfn-demo"; DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$DIR/aws-step13-cloudformation-template.yaml"
[[ -f "$TEMPLATE" ]] || { echo "ERROR: CloudFormation template not found: $TEMPLATE"; exit 1; }
aws cloudformation deploy --region "$REGION" --stack-name "$STACK" --template-file "$TEMPLATE" --capabilities CAPABILITY_IAM
aws cloudformation describe-stacks --region "$REGION" --stack-name "$STACK" --query 'Stacks[0].[StackName,StackStatus]' --output table
