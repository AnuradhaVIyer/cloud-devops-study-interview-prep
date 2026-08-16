#!/usr/bin/env bash
# Author: Anuradha Iyer
# Date: 2026-08-16
# Description: Step 3 (Windows) - Create Security Group, Key Pair, and Launch Windows EC2 Instance

# Get VPC and Subnet created in Step 2 by Tag
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=dev-vpc" --query "Vpcs[0].VpcId" --output text --profile dev-profile)
SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=dev-public-subnet" --query "Subnets[0].SubnetId" --output text --profile dev-profile)

# 3.1 Create Security Group
SG_ID=$(aws ec2 create-security-group --group-name dev-windows-sg --description "Dev Windows Security Group" --vpc-id "$VPC_ID" --profile dev-profile --query "GroupId" --output text)

# 3.2 Add Ingress Rules (RDP Port 3389 & HTTP Port 80)
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 3389 --cidr 0.0.0.0/0 --profile dev-profile
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0 --profile dev-profile

# 3.3 Create Key Pair
aws ec2 create-key-pair --key-name dev-key --query "KeyMaterial" --output text --profile dev-profile > dev-key.pem
chmod 400 dev-key.pem

# 3.4 Get Latest Windows Server 2022 AMI ID
AMI_ID=$(aws ssm get-parameters --names "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base" --query "Parameters[0].Value" --output text --profile dev-profile)

# 3.5 Launch Windows EC2 Instance
INSTANCE_ID=$(aws ec2 run-instances --image-id "$AMI_ID" --count 1 --instance-type t3.micro --key-name dev-key --security-group-ids "$SG_ID" --subnet-id "$SUBNET_ID" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=dev-windows-ec2}]" --profile dev-profile --query "Instances[0].InstanceId" --output text)

echo "Waiting for instance to reach running state..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --profile dev-profile

PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].PublicIpAddress" --output text --profile dev-profile)

echo "Waiting 4 minutes for Windows to initialize and generate the password..."
sleep 240

PASSWORD=$(aws ec2 get-password-data --instance-id "$INSTANCE_ID" --priv-launch-key dev-key.pem --query "PasswordData" --output text --profile dev-profile)

echo "Step 3 Complete! Windows Server Instance Launched."
echo "Instance ID : $INSTANCE_ID"
echo "Public IP   : $PUBLIC_IP"
echo "Username    : Administrator"
echo "Password    : $PASSWORD"
echo "Connect via : Remote Desktop Connection (mstsc) to $PUBLIC_IP"