#!/usr/bin/env bash
set -euo pipefail
# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 7 - Create Amazon EFS and mount targets for the private application tier.
# ============================================================

REGION="${AWS_REGION:-ap-south-1}"
PROJECT_NAME="${PROJECT_NAME:-aws-three-tier}"
VPC_NAME="${VPC_NAME:-aws-three-tier-vpc}"
APP_SG_NAME="${APP_SG_NAME:-aws-three-tier-app-sg}"
SUBNET_A_NAME="${APP_SUBNET_A_NAME:-aws-three-tier-app-subnet-a}"
SUBNET_B_NAME="${APP_SUBNET_B_NAME:-aws-three-tier-app-subnet-b}"
FS_NAME="${EFS_NAME:-aws-three-tier-efs}"

VPC_ID=$(aws ec2 describe-vpcs --region "$REGION" --filters "Name=tag:Name,Values=$VPC_NAME" "Name=tag:Project,Values=$PROJECT_NAME" --query 'Vpcs[0].VpcId' --output text)
APP_SG_ID=$(aws ec2 describe-security-groups --region "$REGION" --filters "Name=group-name,Values=$APP_SG_NAME" "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[0].GroupId' --output text)
SUBNET_A_ID=$(aws ec2 describe-subnets --region "$REGION" --filters "Name=tag:Name,Values=$SUBNET_A_NAME" "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[0].SubnetId' --output text)
SUBNET_B_ID=$(aws ec2 describe-subnets --region "$REGION" --filters "Name=tag:Name,Values=$SUBNET_B_NAME" "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[0].SubnetId' --output text)

for x in VPC_ID APP_SG_ID SUBNET_A_ID SUBNET_B_ID; do
  [[ -n "${!x}" && "${!x}" != "None" ]] || { echo "ERROR: Required Step 5 resource $x was not found."; exit 1; }
done

FS_ID=$(aws efs describe-file-systems --region "$REGION" --query "FileSystems[?Name=='$FS_NAME'].FileSystemId | [0]" --output text)
if [[ -z "$FS_ID" || "$FS_ID" == "None" ]]; then
  FS_ID=$(aws efs create-file-system --region "$REGION" --encrypted --tags "Key=Name,Value=$FS_NAME" "Key=Project,Value=$PROJECT_NAME" "Key=Environment,Value=dev" "Key=ManagedBy,Value=aws-cli" --query 'FileSystemId' --output text)
  aws efs wait file-system-available --region "$REGION" --file-system-id "$FS_ID"
fi

for SUBNET_ID in "$SUBNET_A_ID" "$SUBNET_B_ID"; do
  EXISTING=$(aws efs describe-mount-targets --region "$REGION" --file-system-id "$FS_ID" --query "MountTargets[?SubnetId=='$SUBNET_ID'].MountTargetId | [0]" --output text)
  if [[ -z "$EXISTING" || "$EXISTING" == "None" ]]; then
    aws efs create-mount-target --region "$REGION" --file-system-id "$FS_ID" --subnet-id "$SUBNET_ID" --security-groups "$APP_SG_ID"
  fi
done

echo "EFS ready: $FS_ID"
