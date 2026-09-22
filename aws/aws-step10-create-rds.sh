#!/usr/bin/env bash
set -euo pipefail
# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 10 - Create an encrypted Amazon RDS MySQL database in private database subnets using managed credentials.
# ============================================================

REGION="${AWS_REGION:-ap-south-1}"; PROJECT="aws-three-tier"; VPC_NAME="aws-three-tier-vpc"
DB_SG_NAME="aws-three-tier-db-sg"; SUBNET_A="aws-three-tier-db-subnet-a"; SUBNET_B="aws-three-tier-db-subnet-b"
DB_SUBNET_GROUP="aws-three-tier-db-subnet-group"; DB_ID="aws-three-tier-mysql"; ENGINE="mysql"

VPC_ID=$(aws ec2 describe-vpcs --region "$REGION" --filters "Name=tag:Name,Values=$VPC_NAME" --query 'Vpcs[0].VpcId' --output text)
DB_SG_ID=$(aws ec2 describe-security-groups --region "$REGION" --filters "Name=group-name,Values=$DB_SG_NAME" "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[0].GroupId' --output text)
S1=$(aws ec2 describe-subnets --region "$REGION" --filters "Name=tag:Name,Values=$SUBNET_A" --query 'Subnets[0].SubnetId' --output text)
S2=$(aws ec2 describe-subnets --region "$REGION" --filters "Name=tag:Name,Values=$SUBNET_B" --query 'Subnets[0].SubnetId' --output text)
for x in VPC_ID DB_SG_ID S1 S2; do [[ -n "${!x}" && "${!x}" != "None" ]] || { echo "ERROR: $x not found."; exit 1; }; done

GROUP_EXISTS=$(aws rds describe-db-subnet-groups --region "$REGION" --db-subnet-group-name "$DB_SUBNET_GROUP" --query 'DBSubnetGroups[0].DBSubnetGroupName' --output text 2>/dev/null || true)
if [[ -z "$GROUP_EXISTS" || "$GROUP_EXISTS" == "None" ]]; then
  aws rds create-db-subnet-group --region "$REGION" --db-subnet-group-name "$DB_SUBNET_GROUP" --db-subnet-group-description "Private DB subnets for $PROJECT" --subnet-ids "$S1" "$S2" --tags "Key=Project,Value=$PROJECT" "Key=ManagedBy,Value=aws-cli"
fi

DB_EXISTS=$(aws rds describe-db-instances --region "$REGION" --db-instance-identifier "$DB_ID" --query 'DBInstances[0].DBInstanceIdentifier' --output text 2>/dev/null || true)
if [[ -z "$DB_EXISTS" || "$DB_EXISTS" == "None" ]]; then
  aws rds create-db-instance --region "$REGION" --db-instance-identifier "$DB_ID" --engine "$ENGINE" --db-instance-class db.t4g.micro --allocated-storage 20 --storage-type gp3 --storage-encrypted --db-name appdb --master-username adminuser --manage-master-user-password --vpc-security-group-ids "$DB_SG_ID" --db-subnet-group-name "$DB_SUBNET_GROUP" --backup-retention-period 7 --no-publicly-accessible --tags "Key=Project,Value=$PROJECT" "Key=Environment,Value=dev" "Key=ManagedBy,Value=aws-cli"
fi
echo "RDS creation/status:"
aws rds describe-db-instances --region "$REGION" --db-instance-identifier "$DB_ID" --query 'DBInstances[0].[DBInstanceStatus,Endpoint.Address,Endpoint.Port]' --output table
