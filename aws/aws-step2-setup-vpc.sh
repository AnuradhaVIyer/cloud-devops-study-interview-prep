#!/usr/bin/env bash
# Author: Anuradha Iyer
# Date: 2026-08-15
# Description: Step 2 - Create VPC, Public Subnet, Internet Gateway, and Route Table

# 2.1 Create VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=dev-vpc}]" --profile dev-profile --query 'Vpc.VpcId' --output text)
echo "VPC Created: $VPC_ID"

# 2.2 Create Public Subnet
SUBNET_ID=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block 10.0.1.0/24 --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=dev-public-subnet}]" --profile dev-profile --query 'Subnet.SubnetId' --output text)
echo "Subnet Created: $SUBNET_ID"

# Enable Auto-assign Public IP
aws ec2 modify-subnet-attribute --subnet-id "$SUBNET_ID" --map-public-ip-on-launch --profile dev-profile

# 2.3 Create and Attach Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=dev-igw}]" --profile dev-profile --query 'InternetGateway.InternetGatewayId' --output text)
echo "IGW Created: $IGW_ID"

aws ec2 attach-internet-gateway --vpc-id "$VPC_ID" --internet-gateway-id "$IGW_ID" --profile dev-profile

# 2.4 Create Route Table, Add Route, and Associate Subnet
RT_ID=$(aws ec2 create-route-table --vpc-id "$VPC_ID" --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=dev-public-rt}]" --profile dev-profile --query 'RouteTable.RouteTableId' --output text)
echo "Route Table Created: $RT_ID"

aws ec2 create-route --route-table-id "$RT_ID" --destination-cidr-block 0.0.0.0/0 --gateway-id "$IGW_ID" --profile dev-profile
aws ec2 associate-route-table --subnet-id "$SUBNET_ID" --route-table-id "$RT_ID" --profile dev-profile

echo "Step 2 Complete! Networking components set up successfully."