#!/bin/bash

# ============================================================
# Author: Anuradha Iyer
# Date: 2026-09-21
# Description:
# Create AWS 3-Tier Architecture using AWS CLI
#
# Components:
#   VPC
#   2 Public Subnets
#   2 Private App Subnets
#   2 Private DB Subnets
#   Internet Gateway
#   NAT Gateway
#   Route Tables
#   Security Groups
#   Key Pair
#   EC2 Web/App instances
#   S3 Bucket
#   RDS MySQL
#
# WARNING:
# This script creates billable AWS resources.
# Run cleanup-3tier.sh when finished.
# ============================================================

set -e

# ------------------------------------------------------------
# VARIABLES
# ------------------------------------------------------------

REGION="ap-south-1"
AZ1="ap-south-1a"
AZ2="ap-south-1b"

PROJECT="three-tier-demo"

VPC_CIDR="10.0.0.0/16"

PUBLIC_SUBNET1_CIDR="10.0.1.0/24"
PUBLIC_SUBNET2_CIDR="10.0.2.0/24"

APP_SUBNET1_CIDR="10.0.11.0/24"
APP_SUBNET2_CIDR="10.0.12.0/24"

DB_SUBNET1_CIDR="10.0.21.0/24"
DB_SUBNET2_CIDR="10.0.22.0/24"

KEY_NAME="${PROJECT}-key"
KEY_FILE="${KEY_NAME}.pem"

S3_BUCKET="${PROJECT}-$(aws sts get-caller-identity \
    --query Account \
    --output text)-$(date +%s)"

DB_NAME="appdb"
DB_USERNAME="admin"

# Generate a random DB password
DB_PASSWORD="$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 20)"

# ------------------------------------------------------------
# FUNCTIONS
# ------------------------------------------------------------

log() {
    echo
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}

# ------------------------------------------------------------
# CHECK AWS CLI
# ------------------------------------------------------------

log "Checking AWS CLI"

aws --version

ACCOUNT_ID=$(aws sts get-caller-identity \
    --query Account \
    --output text)

echo "AWS Account: $ACCOUNT_ID"
echo "Region: $REGION"

# ------------------------------------------------------------
# VPC
# ------------------------------------------------------------

log "Creating VPC"

VPC_ID=$(aws ec2 create-vpc \
    --cidr-block "$VPC_CIDR" \
    --region "$REGION" \
    --query 'Vpc.VpcId' \
    --output text)

echo "VPC ID: $VPC_ID"

aws ec2 create-tags \
    --resources "$VPC_ID" \
    --tags Key=Name,Value="${PROJECT}-vpc"

# Enable DNS
aws ec2 modify-vpc-attribute \
    --vpc-id "$VPC_ID" \
    --enable-dns-support '{"Value":true}'

aws ec2 modify-vpc-attribute \
    --vpc-id "$VPC_ID" \
    --enable-dns-hostnames '{"Value":true}'

# ------------------------------------------------------------
# PUBLIC SUBNET 1
# ------------------------------------------------------------

log "Creating Public Subnet 1"

PUBLIC_SUBNET1_ID=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
    --cidr-block "$PUBLIC_SUBNET1_CIDR" \
    --availability-zone "$AZ1" \
    --query 'Subnet.SubnetId' \
    --output text)

aws ec2 create-tags \
    --resources "$PUBLIC_SUBNET1_ID" \
    --tags Key=Name,Value="${PROJECT}-public-1"

# ------------------------------------------------------------
# PUBLIC SUBNET 2
# ------------------------------------------------------------

log "Creating Public Subnet 2"

PUBLIC_SUBNET2_ID=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
    --cidr-block "$PUBLIC_SUBNET2_CIDR" \
    --availability-zone "$AZ2" \
    --query 'Subnet.SubnetId' \
    --output text)

aws ec2 create-tags \
    --resources "$PUBLIC_SUBNET2_ID" \
    --tags Key=Name,Value="${PROJECT}-public-2"

# ------------------------------------------------------------
# APP SUBNET 1
# ------------------------------------------------------------

log "Creating Private App Subnet 1"

APP_SUBNET1_ID=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
    --cidr-block "$APP_SUBNET1_CIDR" \
    --availability-zone "$AZ1" \
    --query 'Subnet.SubnetId' \
    --output text)

aws ec2 create-tags \
    --resources "$APP_SUBNET1_ID" \
    --tags Key=Name,Value="${PROJECT}-app-1"

# ------------------------------------------------------------
# APP SUBNET 2
# ------------------------------------------------------------

log "Creating Private App Subnet 2"

APP_SUBNET2_ID=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
    --cidr-block "$APP_SUBNET2_CIDR" \
    --availability-zone "$AZ2" \
    --query 'Subnet.SubnetId' \
    --output text)

aws ec2 create-tags \
    --resources "$APP_SUBNET2_ID" \
    --tags Key=Name,Value="${PROJECT}-app-2"

# ------------------------------------------------------------
# DB SUBNET 1
# ------------------------------------------------------------

log "Creating Private DB Subnet 1"

DB_SUBNET1_ID=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
    --cidr-block "$DB_SUBNET1_CIDR" \
    --availability-zone "$AZ1" \
    --query 'Subnet.SubnetId' \
    --output text)

aws ec2 create-tags \
    --resources "$DB_SUBNET1_ID" \
    --tags Key=Name,Value="${PROJECT}-db-1"

# ------------------------------------------------------------
# DB SUBNET 2
# ------------------------------------------------------------

log "Creating Private DB Subnet 2"

DB_SUBNET2_ID=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
    --cidr-block "$DB_SUBNET2_CIDR" \
    --availability-zone "$AZ2" \
    --query 'Subnet.SubnetId' \
    --output text)

aws ec2 create-tags \
    --resources "$DB_SUBNET2_ID" \
    --tags Key=Name,Value="${PROJECT}-db-2"

# ------------------------------------------------------------
# INTERNET GATEWAY
# ------------------------------------------------------------

log "Creating Internet Gateway"

IGW_ID=$(aws ec2 create-internet-gateway \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)

aws ec2 create-tags \
    --resources "$IGW_ID" \
    --tags Key=Name,Value="${PROJECT}-igw"

aws ec2 attach-internet-gateway \
    --internet-gateway-id "$IGW_ID" \
    --vpc-id "$VPC_ID"

# ------------------------------------------------------------
# PUBLIC ROUTE TABLE
# ------------------------------------------------------------

log "Creating Public Route Table"

PUBLIC_RT_ID=$(aws ec2 create-route-table \
    --vpc-id "$VPC_ID" \
    --query 'RouteTable.RouteTableId' \
    --output text)

aws ec2 create-tags \
    --resources "$PUBLIC_RT_ID" \
    --tags Key=Name,Value="${PROJECT}-public-rt"

aws ec2 create-route \
    --route-table-id "$PUBLIC_RT_ID" \
    --destination-cidr-block "0.0.0.0/0" \
    --gateway-id "$IGW_ID"

aws ec2 associate-route-table \
    --route-table-id "$PUBLIC_RT_ID" \
    --subnet-id "$PUBLIC_SUBNET1_ID"

aws ec2 associate-route-table \
    --route-table-id "$PUBLIC_RT_ID" \
    --subnet-id "$PUBLIC_SUBNET2_ID"

# ------------------------------------------------------------
# ENABLE PUBLIC IP ON PUBLIC SUBNETS
# ------------------------------------------------------------

aws ec2 modify-subnet-attribute \
    --subnet-id "$PUBLIC_SUBNET1_ID" \
    --map-public-ip-on-launch

aws ec2 modify-subnet-attribute \
    --subnet-id "$PUBLIC_SUBNET2_ID" \
    --map-public-ip-on-launch

# ------------------------------------------------------------
# ELASTIC IP FOR NAT
# ------------------------------------------------------------

log "Allocating Elastic IP"

EIP_ALLOC_ID=$(aws ec2 allocate-address \
    --domain vpc \
    --query 'AllocationId' \
    --output text)

# ------------------------------------------------------------
# NAT GATEWAY
# ------------------------------------------------------------

log "Creating NAT Gateway"

NAT_GW_ID=$(aws ec2 create-nat-gateway \
    --subnet-id "$PUBLIC_SUBNET1_ID" \
    --allocation-id "$EIP_ALLOC_ID" \
    --query 'NatGateway.NatGatewayId' \
    --output text)

echo "NAT Gateway: $NAT_GW_ID"

log "Waiting for NAT Gateway"

aws ec2 wait nat-gateway-available \
    --nat-gateway-ids "$NAT_GW_ID"

# ------------------------------------------------------------
# PRIVATE APP ROUTE TABLE
# ------------------------------------------------------------

log "Creating Private App Route Table"

APP_RT_ID=$(aws ec2 create-route-table \
    --vpc-id "$VPC_ID" \
    --query 'RouteTable.RouteTableId' \
    --output text)

aws ec2 create-tags \
    --resources "$APP_RT_ID" \
    --tags Key=Name,Value="${PROJECT}-app-rt"

aws ec2 create-route \
    --route-table-id "$APP_RT_ID" \
    --destination-cidr-block "0.0.0.0/0" \
    --nat-gateway-id "$NAT_GW_ID"

aws ec2 associate-route-table \
    --route-table-id "$APP_RT_ID" \
    --subnet-id "$APP_SUBNET1_ID"

aws ec2 associate-route-table \
    --route-table-id "$APP_RT_ID" \
    --subnet-id "$APP_SUBNET2_ID"

# ------------------------------------------------------------
# DB ROUTE TABLE
# ------------------------------------------------------------

log "Creating DB Route Table"

DB_RT_ID=$(aws ec2 create-route-table \
    --vpc-id "$VPC_ID" \
    --query 'RouteTable.RouteTableId' \
    --output text)

aws ec2 create-tags \
    --resources "$DB_RT_ID" \
    --tags Key=Name,Value="${PROJECT}-db-rt"

aws ec2 associate-route-table \
    --route-table-id "$DB_RT_ID" \
    --subnet-id "$DB_SUBNET1_ID"

aws ec2 associate-route-table \
    --route-table-id "$DB_RT_ID" \
    --subnet-id "$DB_SUBNET2_ID"

# ------------------------------------------------------------
# SECURITY GROUP - WEB
# ------------------------------------------------------------

log "Creating Web Security Group"

WEB_SG_ID=$(aws ec2 create-security-group \
    --group-name "${PROJECT}-web-sg" \
    --description "Web tier security group" \
    --vpc-id "$VPC_ID" \
    --query 'GroupId' \
    --output text)

aws ec2 authorize-security-group-ingress \
    --group-id "$WEB_SG_ID" \
    --protocol tcp \
    --port 22 \
    --cidr "0.0.0.0/0"

aws ec2 authorize-security-group-ingress \
    --group-id "$WEB_SG_ID" \
    --protocol tcp \
    --port 80 \
    --cidr "0.0.0.0/0"

# ------------------------------------------------------------
# SECURITY GROUP - APP
# ------------------------------------------------------------

log "Creating App Security Group"

APP_SG_ID=$(aws ec2 create-security-group \
    --group-name "${PROJECT}-app-sg" \
    --description "Application tier security group" \
    --vpc-id "$VPC_ID" \
    --query 'GroupId' \
    --output text)

aws ec2 authorize-security-group-ingress \
    --group-id "$APP_SG_ID" \
    --protocol tcp \
    --port 8080 \
    --source-group "$WEB_SG_ID"

# ------------------------------------------------------------
# SECURITY GROUP - DB
# ------------------------------------------------------------

log "Creating DB Security Group"

DB_SG_ID=$(aws ec2 create-security-group \
    --group-name "${PROJECT}-db-sg" \
    --description "Database security group" \
    --vpc-id "$VPC_ID" \
    --query 'GroupId' \
    --output text)

aws ec2 authorize-security-group-ingress \
    --group-id "$DB_SG_ID" \
    --protocol tcp \
    --port 3306 \
    --source-group "$APP_SG_ID"

# ------------------------------------------------------------
# KEY PAIR
# ------------------------------------------------------------

log "Creating EC2 Key Pair"

aws ec2 create-key-pair \
    --key-name "$KEY_NAME" \
    --query 'KeyMaterial' \
    --output text > "$KEY_FILE"

chmod 400 "$KEY_FILE"

# ------------------------------------------------------------
# FIND AMAZON LINUX 2023 AMI
# ------------------------------------------------------------

log "Finding Latest Amazon Linux 2023 AMI"

AMI_ID=$(aws ssm get-parameter \
    --name "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64" \
    --region "$REGION" \
    --query "Parameter.Value" \
    --output text)

echo "AMI ID: $AMI_ID"

# ------------------------------------------------------------
# WEB EC2
# ------------------------------------------------------------

log "Launching Web EC2"

WEB_INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "t3.micro" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$WEB_SG_ID" \
    --subnet-id "$PUBLIC_SUBNET1_ID" \
    --associate-public-ip-address \
    --tag-specifications \
    "ResourceType=instance,Tags=[{Key=Name,Value=${PROJECT}-web}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

# ------------------------------------------------------------
# APP EC2
# ------------------------------------------------------------

log "Launching App EC2"

APP_INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "t3.micro" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$APP_SG_ID" \
    --subnet-id "$APP_SUBNET1_ID" \
    --tag-specifications \
    "ResourceType=instance,Tags=[{Key=Name,Value=${PROJECT}-app}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

# ------------------------------------------------------------
# WAIT FOR INSTANCES
# ------------------------------------------------------------

log "Waiting for EC2 Instances"

aws ec2 wait instance-running \
    --instance-ids "$WEB_INSTANCE_ID" "$APP_INSTANCE_ID"

# ------------------------------------------------------------
# S3
# ------------------------------------------------------------

log "Creating S3 Bucket"

if [ "$REGION" = "us-east-1" ]; then
    aws s3api create-bucket \
        --bucket "$S3_BUCKET" \
        --region "$REGION"
else
    aws s3api create-bucket \
        --bucket "$S3_BUCKET" \
        --region "$REGION" \
        --create-bucket-configuration \
        LocationConstraint="$REGION"
fi

aws s3api put-bucket-versioning \
    --bucket "$S3_BUCKET" \
    --versioning-configuration Status=Enabled

# ------------------------------------------------------------
# RDS SUBNET GROUP
# ------------------------------------------------------------

log "Creating RDS Subnet Group"

aws rds create-db-subnet-group \
    --db-subnet-group-name "${PROJECT}-db-subnet-group" \
    --db-subnet-group-description "3-tier DB subnet group" \
    --subnet-ids "$DB_SUBNET1_ID" "$DB_SUBNET2_ID"

# ------------------------------------------------------------
# RDS MYSQL
# ------------------------------------------------------------

log "Creating RDS MySQL"

aws rds create-db-instance \
    --db-instance-identifier "${PROJECT}-mysql" \
    --db-instance-class "db.t3.micro" \
    --engine "mysql" \
    --allocated-storage 20 \
    --master-username "$DB_USERNAME" \
    --master-user-password "$DB_PASSWORD" \
    --db-name "$DB_NAME" \
    --vpc-security-group-ids "$DB_SG_ID" \
    --db-subnet-group-name "${PROJECT}-db-subnet-group" \
    --backup-retention-period 1 \
    --no-publicly-accessible \
    --no-multi-az

# ------------------------------------------------------------
# OUTPUT
# ------------------------------------------------------------

log "GETTING RESOURCE INFORMATION"

WEB_PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$WEB_INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

APP_PRIVATE_IP=$(aws ec2 describe-instances \
    --instance-ids "$APP_INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text)

echo
echo "============================================================"
echo "3-TIER ARCHITECTURE CREATED"
echo "============================================================"
echo
echo "VPC ID:              $VPC_ID"
echo
echo "Public Subnet 1:     $PUBLIC_SUBNET1_ID"
echo "Public Subnet 2:     $PUBLIC_SUBNET2_ID"
echo
echo "App Subnet 1:        $APP_SUBNET1_ID"
echo "App Subnet 2:        $APP_SUBNET2_ID"
echo
echo "DB Subnet 1:         $DB_SUBNET1_ID"
echo "DB Subnet 2:         $DB_SUBNET2_ID"
echo
echo "Internet Gateway:    $IGW_ID"
echo "NAT Gateway:         $NAT_GW_ID"
echo
echo "Web SG:              $WEB_SG_ID"
echo "App SG:              $APP_SG_ID"
echo "DB SG:               $DB_SG_ID"
echo
echo "Web Instance:        $WEB_INSTANCE_ID"
echo "Web Public IP:       $WEB_PUBLIC_IP"
echo
echo "App Instance:        $APP_INSTANCE_ID"
echo "App Private IP:      $APP_PRIVATE_IP"
echo
echo "S3 Bucket:           $S3_BUCKET"
echo
echo "RDS:                 ${PROJECT}-mysql"
echo "DB Username:         $DB_USERNAME"
echo "DB Password:         $DB_PASSWORD"
echo
echo "SSH Key:             $KEY_FILE"
echo
echo "============================================================"
echo "SAVE THESE VALUES!"
echo "============================================================"