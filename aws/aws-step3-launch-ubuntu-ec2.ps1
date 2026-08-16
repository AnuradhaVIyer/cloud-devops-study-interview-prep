# Author: Anuradha Iyer
# Date: 2026-08-15
# Description: Step 3 - Create Security Group, Key Pair, and Launch EC2 Instance

# Get VPC and Subnet created in Step 2 by Tag
$vpcId = aws ec2 describe-vpcs --filters "Name=tag:Name,Values=dev-vpc" --query "Vpcs[0].VpcId" --output text --profile dev-profile
$subnetId = aws ec2 describe-subnets --filters "Name=tag:Name,Values=dev-public-subnet" --query "Subnets[0].SubnetId" --output text --profile dev-profile

# 3.1 Create Security Group
$sgJson = aws ec2 create-security-group --group-name dev-sg --description "Dev Security Group" --vpc-id $vpcId --profile dev-profile | ConvertFrom-Json
$sgId = $sgJson.GroupId

# 3.2 Add Ingress Rules (SSH Port 22 & HTTP Port 80)
aws ec2 authorize-security-group-ingress --group-id $sgId --protocol tcp --port 22 --cidr 0.0.0.0/0 --profile dev-profile
aws ec2 authorize-security-group-ingress --group-id $sgId --protocol tcp --port 80 --cidr 0.0.0.0/0 --profile dev-profile

# 3.3 Create Key Pair
$keyMaterial = aws ec2 create-key-pair --key-name dev-key --query "KeyMaterial" --output text --profile dev-profile
Set-Content -Path ".\dev-key.pem" -Value $keyMaterial

# 3.4 Get Latest Amazon Linux 2023 AMI ID
$amiId = aws ssm get-parameters --names "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64" --query "Parameters[0].Value" --output text --profile dev-profile

# 3.5 Launch EC2 Instance
$instanceJson = aws ec2 run-instances --image-id $amiId --count 1 --instance-type t2.micro --key-name dev-key --security-group-ids $sgId --subnet-id $subnetId --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=dev-ec2}]" --profile dev-profile | ConvertFrom-Json
$instanceId = $instanceJson.Instances[0].InstanceId

Write-Host "Waiting for instance to run..."
aws ec2 wait instance-running --instance-ids $instanceId --profile dev-profile

$publicIp = aws ec2 describe-instances --instance-ids $instanceId --query "Reservations[0].Instances[0].PublicIpAddress" --output text --profile dev-profile

Write-Host "Step 3 Complete! EC2 Instance Launched." -ForegroundColor Green
Write-Host "Instance ID: $instanceId"
Write-Host "Public IP: $publicIp"
Write-Host "Connect via: ssh -i .\dev-key.pem ec2-user@$publicIp"