# ============================================================
# Author: Anuradha Iyer
# Date: 2026-09-21
# Description:Create AWS 3-Tier Architecture using AWS CLI + PowerShell
# ============================================================

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# VARIABLES
# ------------------------------------------------------------

$REGION = "ap-south-1"
$AZ1 = "ap-south-1a"
$AZ2 = "ap-south-1b"

$PROJECT = "three-tier-demo"

$VPC_CIDR = "10.0.0.0/16"

$PUBLIC_SUBNET1_CIDR = "10.0.1.0/24"
$PUBLIC_SUBNET2_CIDR = "10.0.2.0/24"

$APP_SUBNET1_CIDR = "10.0.11.0/24"
$APP_SUBNET2_CIDR = "10.0.12.0/24"

$DB_SUBNET1_CIDR = "10.0.21.0/24"
$DB_SUBNET2_CIDR = "10.0.22.0/24"

$KEY_NAME = "$PROJECT-key"
$KEY_FILE = "$KEY_NAME.pem"

$DB_NAME = "appdb"
$DB_USERNAME = "admin"

function Log-Step {
    param(
        [string]$Message
    )

    Write-Host ""
    Write-Host "============================================================"
    Write-Host $Message
    Write-Host "============================================================"
}

# ------------------------------------------------------------
# AWS CHECK
# ------------------------------------------------------------

Log-Step "Checking AWS CLI"

aws --version

$ACCOUNT_ID = aws sts get-caller-identity `
    --query Account `
    --output text

Write-Host "AWS Account: $ACCOUNT_ID"
Write-Host "Region: $REGION"

# ------------------------------------------------------------
# VPC
# ------------------------------------------------------------

Log-Step "Creating VPC"

$VPC_ID = aws ec2 create-vpc `
    --cidr-block $VPC_CIDR `
    --region $REGION `
    --query "Vpc.VpcId" `
    --output text

Write-Host "VPC ID: $VPC_ID"

aws ec2 create-tags `
    --resources $VPC_ID `
    --tags "Key=Name,Value=$PROJECT-vpc"

aws ec2 modify-vpc-attribute `
    --vpc-id $VPC_ID `
    --enable-dns-support '{"Value":true}'

aws ec2 modify-vpc-attribute `
    --vpc-id $VPC_ID `
    --enable-dns-hostnames '{"Value":true}'

# ------------------------------------------------------------
# PUBLIC SUBNET 1
# ------------------------------------------------------------

Log-Step "Creating Public Subnet 1"

$PUBLIC_SUBNET1_ID = aws ec2 create-subnet `
    --vpc-id $VPC_ID `
    --cidr-block $PUBLIC_SUBNET1_CIDR `
    --availability-zone $AZ1 `
    --query "Subnet.SubnetId" `
    --output text

aws ec2 create-tags `
    --resources $PUBLIC_SUBNET1_ID `
    --tags "Key=Name,Value=$PROJECT-public-1"

# ------------------------------------------------------------
# PUBLIC SUBNET 2
# ------------------------------------------------------------

Log-Step "Creating Public Subnet 2"

$PUBLIC_SUBNET2_ID = aws ec2 create-subnet `
    --vpc-id $VPC_ID `
    --cidr-block $PUBLIC_SUBNET2_CIDR `
    --availability-zone $AZ2 `
    --query "Subnet.SubnetId" `
    --output text

aws ec2 create-tags `
    --resources $PUBLIC_SUBNET2_ID `
    --tags "Key=Name,Value=$PROJECT-public-2"

# ------------------------------------------------------------
# APP SUBNET 1
# ------------------------------------------------------------

Log-Step "Creating Private App Subnet 1"

$APP_SUBNET1_ID = aws ec2 create-subnet `
    --vpc-id $VPC_ID `
    --cidr-block $APP_SUBNET1_CIDR `
    --availability-zone $AZ1 `
    --query "Subnet.SubnetId" `
    --output text

aws ec2 create-tags `
    --resources $APP_SUBNET1_ID `
    --tags "Key=Name,Value=$PROJECT-app-1"

# ------------------------------------------------------------
# APP SUBNET 2
# ------------------------------------------------------------

Log-Step "Creating Private App Subnet 2"

$APP_SUBNET2_ID = aws ec2 create-subnet `
    --vpc-id $VPC_ID `
    --cidr-block $APP_SUBNET2_CIDR `
    --availability-zone $AZ2 `
    --query "Subnet.SubnetId" `
    --output text

aws ec2 create-tags `
    --resources $APP_SUBNET2_ID `
    --tags "Key=Name,Value=$PROJECT-app-2"

# ------------------------------------------------------------
# DB SUBNET 1
# ------------------------------------------------------------

Log-Step "Creating Private DB Subnet 1"

$DB_SUBNET1_ID = aws ec2 create-subnet `
    --vpc-id $VPC_ID `
    --cidr-block $DB_SUBNET1_CIDR `
    --availability-zone $AZ1 `
    --query "Subnet.SubnetId" `
    --output text

aws ec2 create-tags `
    --resources $DB_SUBNET1_ID `
    --tags "Key=Name,Value=$PROJECT-db-1"

# ------------------------------------------------------------
# DB SUBNET 2
# ------------------------------------------------------------

Log-Step "Creating Private DB Subnet 2"

$DB_SUBNET2_ID = aws ec2 create-subnet `
    --vpc-id $VPC_ID `
    --cidr-block $DB_SUBNET2_CIDR `
    --availability-zone $AZ2 `
    --query "Subnet.SubnetId" `
    --output text

aws ec2 create-tags `
    --resources $DB_SUBNET2_ID `
    --tags "Key=Name,Value=$PROJECT-db-2"

# ------------------------------------------------------------
# INTERNET GATEWAY
# ------------------------------------------------------------

Log-Step "Creating Internet Gateway"

$IGW_ID = aws ec2 create-internet-gateway `
    --query "InternetGateway.InternetGatewayId" `
    --output text

aws ec2 create-tags `
    --resources $IGW_ID `
    --tags "Key=Name,Value=$PROJECT-igw"

aws ec2 attach-internet-gateway `
    --internet-gateway-id $IGW_ID `
    --vpc-id $VPC_ID

# ------------------------------------------------------------
# PUBLIC ROUTE TABLE
# ------------------------------------------------------------

Log-Step "Creating Public Route Table"

$PUBLIC_RT_ID = aws ec2 create-route-table `
    --vpc-id $VPC_ID `
    --query "RouteTable.RouteTableId" `
    --output text

aws ec2 create-tags `
    --resources $PUBLIC_RT_ID `
    --tags "Key=Name,Value=$PROJECT-public-rt"

aws ec2 create-route `
    --route-table-id $PUBLIC_RT_ID `
    --destination-cidr-block "0.0.0.0/0" `
    --gateway-id $IGW_ID

aws ec2 associate-route-table `
    --route-table-id $PUBLIC_RT_ID `
    --subnet-id $PUBLIC_SUBNET1_ID

aws ec2 associate-route-table `
    --route-table-id $PUBLIC_RT_ID `
    --subnet-id $PUBLIC_SUBNET2_ID

# ------------------------------------------------------------
# PUBLIC IP
# ------------------------------------------------------------

aws ec2 modify-subnet-attribute `
    --subnet-id $PUBLIC_SUBNET1_ID `
    --map-public-ip-on-launch

aws ec2 modify-subnet-attribute `
    --subnet-id $PUBLIC_SUBNET2_ID `
    --map-public-ip-on-launch

# ------------------------------------------------------------
# ELASTIC IP
# ------------------------------------------------------------

Log-Step "Allocating Elastic IP"

$EIP_ALLOC_ID = aws ec2 allocate-address `
    --domain vpc `
    --query "AllocationId" `
    --output text

# ------------------------------------------------------------
# NAT GATEWAY
# ------------------------------------------------------------

Log-Step "Creating NAT Gateway"

$NAT_GW_ID = aws ec2 create-nat-gateway `
    --subnet-id $PUBLIC_SUBNET1_ID `
    --allocation-id $EIP_ALLOC_ID `
    --query "NatGateway.NatGatewayId" `
    --output text

Write-Host "NAT Gateway: $NAT_GW_ID"

Log-Step "Waiting for NAT Gateway"

aws ec2 wait nat-gateway-available `
    --nat-gateway-ids $NAT_GW_ID

# ------------------------------------------------------------
# APP ROUTE TABLE
# ------------------------------------------------------------

Log-Step "Creating Private App Route Table"

$APP_RT_ID = aws ec2 create-route-table `
    --vpc-id $VPC_ID `
    --query "RouteTable.RouteTableId" `
    --output text

aws ec2 create-tags `
    --resources $APP_RT_ID `
    --tags "Key=Name,Value=$PROJECT-app-rt"

aws ec2 create-route `
    --route-table-id $APP_RT_ID `
    --destination-cidr-block "0.0.0.0/0" `
    --nat-gateway-id $NAT_GW_ID

aws ec2 associate-route-table `
    --route-table-id $APP_RT_ID `
    --subnet-id $APP_SUBNET1_ID

aws ec2 associate-route-table `
    --route-table-id $APP_RT_ID `
    --subnet-id $APP_SUBNET2_ID

# ------------------------------------------------------------
# DB ROUTE TABLE
# ------------------------------------------------------------

Log-Step "Creating DB Route Table"

$DB_RT_ID = aws ec2 create-route-table `
    --vpc-id $VPC_ID `
    --query "RouteTable.RouteTableId" `
    --output text

aws ec2 create-tags `
    --resources $DB_RT_ID `
    --tags "Key=Name,Value=$PROJECT-db-rt"

aws ec2 associate-route-table `
    --route-table-id $DB_RT_ID `
    --subnet-id $DB_SUBNET1_ID

aws ec2 associate-route-table `
    --route-table-id $DB_RT_ID `
    --subnet-id $DB_SUBNET2_ID

# ------------------------------------------------------------
# WEB SECURITY GROUP
# ------------------------------------------------------------

Log-Step "Creating Web Security Group"

$WEB_SG_ID = aws ec2 create-security-group `
    --group-name "$PROJECT-web-sg" `
    --description "Web tier security group" `
    --vpc-id $VPC_ID `
    --query "GroupId" `
    --output text

aws ec2 authorize-security-group-ingress `
    --group-id $WEB_SG_ID `
    --protocol tcp `
    --port 22 `
    --cidr "0.0.0.0/0"

aws ec2 authorize-security-group-ingress `
    --group-id $WEB_SG_ID `
    --protocol tcp `
    --port 80 `
    --cidr "0.0.0.0/0"

# ------------------------------------------------------------
# APP SECURITY GROUP
# ------------------------------------------------------------

Log-Step "Creating App Security Group"

$APP_SG_ID = aws ec2 create-security-group `
    --group-name "$PROJECT-app-sg" `
    --description "Application tier security group" `
    --vpc-id $VPC_ID `
    --query "GroupId" `
    --output text

aws ec2 authorize-security-group-ingress `
    --group-id $APP_SG_ID `
    --protocol tcp `
    --port 8080 `
    --source-group $WEB_SG_ID

# ------------------------------------------------------------
# DB SECURITY GROUP
# ------------------------------------------------------------

Log-Step "Creating DB Security Group"

$DB_SG_ID = aws ec2 create-security-group `
    --group-name "$PROJECT-db-sg" `
    --description "Database security group" `
    --vpc-id $VPC_ID `
    --query "GroupId" `
    --output text

aws ec2 authorize-security-group-ingress `
    --group-id $DB_SG_ID `
    --protocol tcp `
    --port 3306 `
    --source-group $APP_SG_ID

# ------------------------------------------------------------
# KEY PAIR
# ------------------------------------------------------------

Log-Step "Creating EC2 Key Pair"

aws ec2 create-key-pair `
    --key-name $KEY_NAME `
    --query "KeyMaterial" `
    --output text | Out-File -Encoding ascii $KEY_FILE

# ------------------------------------------------------------
# AMI
# ------------------------------------------------------------

Log-Step "Finding Latest Amazon Linux 2023 AMI"

$AMI_ID = aws ssm get-parameter `
    --name "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64" `
    --region $REGION `
    --query "Parameter.Value" `
    --output text

Write-Host "AMI ID: $AMI_ID"

# ------------------------------------------------------------
# WEB EC2
# ------------------------------------------------------------

Log-Step "Launching Web EC2"

$WEB_INSTANCE_ID = aws ec2 run-instances `
    --image-id $AMI_ID `
    --instance-type "t3.micro" `
    --key-name $KEY_NAME `
    --security-group-ids $WEB_SG_ID `
    --subnet-id $PUBLIC_SUBNET1_ID `
    --associate-public-ip-address `
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$PROJECT-web}]" `
    --query "Instances[0].InstanceId" `
    --output text

# ------------------------------------------------------------
# APP EC2
# ------------------------------------------------------------

Log-Step "Launching App EC2"

$APP_INSTANCE_ID = aws ec2 run-instances `
    --image-id $AMI_ID `
    --instance-type "t3.micro" `
    --key-name $KEY_NAME `
    --security-group-ids $APP_SG_ID `
    --subnet-id $APP_SUBNET1_ID `
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$PROJECT-app}]" `
    --query "Instances[0].InstanceId" `
    --output text

# ------------------------------------------------------------
# WAIT
# ------------------------------------------------------------

Log-Step "Waiting for EC2 Instances"

aws ec2 wait instance-running `
    --instance-ids $WEB_INSTANCE_ID, $APP_INSTANCE_ID

# ------------------------------------------------------------
# S3
# ------------------------------------------------------------

Log-Step "Creating S3 Bucket"

$TIMESTAMP = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

$S3_BUCKET = "$PROJECT-$ACCOUNT_ID-$TIMESTAMP"

aws s3api create-bucket `
    --bucket $S3_BUCKET `
    --region $REGION `
    --create-bucket-configuration LocationConstraint=$REGION

aws s3api put-bucket-versioning `
    --bucket $S3_BUCKET `
    --versioning-configuration Status=Enabled

# ------------------------------------------------------------
# RDS SUBNET GROUP
# ------------------------------------------------------------

Log-Step "Creating RDS Subnet Group"

aws rds create-db-subnet-group `
    --db-subnet-group-name "$PROJECT-db-subnet-group" `
    --db-subnet-group-description "3-tier DB subnet group" `
    --subnet-ids $DB_SUBNET1_ID $DB_SUBNET2_ID

# ------------------------------------------------------------
# GENERATE PASSWORD
# ------------------------------------------------------------

$DB_PASSWORD = -join ((48..57) + (65..90) + (97..122) |
    Get-Random -Count 20 |
    ForEach-Object {[char]$_})

# ------------------------------------------------------------
# RDS
# ------------------------------------------------------------

Log-Step "Creating RDS MySQL"

aws rds create-db-instance `
    --db-instance-identifier "$PROJECT-mysql" `
    --db-instance-class "db.t3.micro" `
    --engine "mysql" `
    --allocated-storage 20 `
    --master-username $DB_USERNAME `
    --master-user-password $DB_PASSWORD `
    --db-name $DB_NAME `
    --vpc-security-group-ids $DB_SG_ID `
    --db-subnet-group-name "$PROJECT-db-subnet-group" `
    --backup-retention-period 1 `
    --no-publicly-accessible `
    --no-multi-az

# ------------------------------------------------------------
# GET INFORMATION
# ------------------------------------------------------------

Log-Step "Getting Resource Information"

$WEB_PUBLIC_IP = aws ec2 describe-instances `
    --instance-ids $WEB_INSTANCE_ID `
    --query "Reservations[0].Instances[0].PublicIpAddress" `
    --output text

$APP_PRIVATE_IP = aws ec2 describe-instances `
    --instance-ids $APP_INSTANCE_ID `
    --query "Reservations[0].Instances[0].PrivateIpAddress" `
    --output text

# ------------------------------------------------------------
# OUTPUT
# ------------------------------------------------------------

Write-Host ""
Write-Host "============================================================"
Write-Host "3-TIER ARCHITECTURE CREATED"
Write-Host "============================================================"

Write-Host ""
Write-Host "VPC ID:              $VPC_ID"

Write-Host ""
Write-Host "Public Subnet 1:     $PUBLIC_SUBNET1_ID"
Write-Host "Public Subnet 2:     $PUBLIC_SUBNET2_ID"

Write-Host ""
Write-Host "App Subnet 1:        $APP_SUBNET1_ID"
Write-Host "App Subnet 2:        $APP_SUBNET2_ID"

Write-Host ""
Write-Host "DB Subnet 1:         $DB_SUBNET1_ID"
Write-Host "DB Subnet 2:         $DB_SUBNET2_ID"

Write-Host ""
Write-Host "Internet Gateway:    $IGW_ID"
Write-Host "NAT Gateway:         $NAT_GW_ID"

Write-Host ""
Write-Host "Web SG:              $WEB_SG_ID"
Write-Host "App SG:              $APP_SG_ID"
Write-Host "DB SG:               $DB_SG_ID"

Write-Host ""
Write-Host "Web Instance:        $WEB_INSTANCE_ID"
Write-Host "Web Public IP:       $WEB_PUBLIC_IP"

Write-Host ""
Write-Host "App Instance:        $APP_INSTANCE_ID"
Write-Host "App Private IP:      $APP_PRIVATE_IP"

Write-Host ""
Write-Host "S3 Bucket:           $S3_BUCKET"

Write-Host ""
Write-Host "RDS:                 $PROJECT-mysql"
Write-Host "DB Username:         $DB_USERNAME"
Write-Host "DB Password:         $DB_PASSWORD"

Write-Host ""
Write-Host "SSH Key:             $KEY_FILE"

Write-Host ""
Write-Host "============================================================"
Write-Host "SAVE THESE VALUES!"
Write-Host "============================================================"