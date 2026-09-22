#!/usr/bin/env bash
set -euo pipefail
# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 15 - Enable AWS Systems Manager access for project EC2 instances using an IAM instance profile.
# ============================================================

REGION="${AWS_REGION:-ap-south-1}"; PROJECT="aws-three-tier"; PROFILE="aws-three-tier-ssm-profile"; ROLE="aws-three-tier-ssm-role"

ROLE_ARN=$(aws iam get-role --role-name "$ROLE" --query 'Role.Arn' --output text 2>/dev/null || true)
if [[ -z "$ROLE_ARN" || "$ROLE_ARN" == "None" ]]; then
  cat >/tmp/trust-ec2.json <<'EOF'
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}
EOF
  ROLE_ARN=$(aws iam create-role --role-name "$ROLE" --assume-role-policy-document file:///tmp/trust-ec2.json --query 'Role.Arn' --output text)
  aws iam attach-role-policy --role-name "$ROLE" --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
fi

PROFILE_EXISTS=$(aws iam get-instance-profile --instance-profile-name "$PROFILE" --query 'InstanceProfile.InstanceProfileName' --output text 2>/dev/null || true)
if [[ -z "$PROFILE_EXISTS" || "$PROFILE_EXISTS" == "None" ]]; then
  aws iam create-instance-profile --instance-profile-name "$PROFILE"
  aws iam add-role-to-instance-profile --instance-profile-name "$PROFILE" --role-name "$ROLE"
  sleep 10
fi

IDS=$(aws ec2 describe-instances --region "$REGION" --filters "Name=tag:Project,Values=$PROJECT" "Name=instance-state-name,Values=pending,running,stopping,stopped" --query 'Reservations[].Instances[].InstanceId' --output text)
[[ -n "$IDS" ]] || { echo "ERROR: No project EC2 instances found."; exit 1; }

for ID in $IDS; do
  PROFILE=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$ID" --query 'Reservations[0].Instances[0].IamInstanceProfile.Arn' --output text)
  if [[ -z "$PROFILE" || "$PROFILE" == "None" ]]; then
    aws ec2 associate-iam-instance-profile --region "$REGION" --instance-id "$ID" --iam-instance-profile Name=aws-three-tier-ssm-profile
    echo "Associated SSM profile with $ID"
  else
    echo "$ID already has an instance profile."
  fi
done
echo "Verify managed-node status with: aws ssm describe-instance-information --region $REGION"
