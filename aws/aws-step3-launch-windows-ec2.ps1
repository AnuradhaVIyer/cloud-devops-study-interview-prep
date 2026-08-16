# Author: Anuradha Iyer
# Date: 2026-08-16
# Description: Step 3 (Windows) - Create Security Group, Key Pair, and Launch Windows EC2 Instance

# Get VPC and Subnet created in Step 2 by Tag
$vpcId = aws ec2 describe-vpcs --filters "Name=tag:Name,Values=dev-vpc" --query "Vpcs[0].VpcId" --output text --profile dev-profile
$subnetId = aws ec2 describe-subnets --filters "Name=tag:Name,Values=dev-public-subnet" --query "Subnets[0].SubnetId" --output text --profile dev-profile

# 3.1 Create Security Group
$sgJson = aws ec2 create-security-group --group-name dev-windows-sg --description "Dev Windows Security Group" --vpc-id $vpcId --profile dev-profile | ConvertFrom-Json
$sgId = $sgJson.GroupId

# 3.2 Add Ingress Rules (RDP Port 3389 & HTTP Port 80)
aws ec2 authorize-security-group-ingress --group-id $sgId --protocol tcp --port 3389 --cidr 0.0.0.0/0 --profile dev-profile
aws ec2 authorize-security-group-ingress --group-id $sgId --protocol tcp --port 80 --cidr 0.0.0.0/0 --profile dev-profile

# 3.3 Create Key Pair
$keyMaterial = aws ec2 create-key-pair --key-name dev-key --query "KeyMaterial" --output text --profile dev-profile
Set-Content -Path ".\dev-key.pem" -Value $keyMaterial

# 3.4 Get Latest Windows Server 2022 AMI ID
$amiId = aws ssm get-parameters --names "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base" --query "Parameters[0].Value" --output text --profile dev-profile

# 3.5 Launch Windows EC2 Instance
$instanceJson = aws ec2 run-instances --image-id $amiId --count 1 --instance-type t3.micro --key-name dev-key --security-group-ids $sgId --subnet-id $subnetId --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=dev-windows-ec2}]" --profile dev-profile | ConvertFrom-Json
$instanceId = $instanceJson.Instances[0].InstanceId

Write-Host "Waiting for instance to reach running state..."
aws ec2 wait instance-running --instance-ids $instanceId --profile dev-profile

$publicIp = aws ec2 describe-instances --instance-ids $instanceId --query "Reservations[0].Instances[0].PublicIpAddress" --output text --profile dev-profile

Write-Host "Waiting 4 minutes for Windows to initialize and generate the password..."
Start-Sleep -Seconds 240

$password = aws ec2 get-password-data --instance-id $instanceId --priv-launch-key .\dev-key.pem --query "PasswordData" --output text --profile dev-profile

Write-Host "Step 3 Complete! Windows Server Instance Launched." -ForegroundColor Green
Write-Host "Instance ID : $instanceId"
Write-Host "Public IP   : $publicIp"
Write-Host "Username    : Administrator"
Write-Host "Password    : $password"
Write-Host "Connect via : Remote Desktop Connection (mstsc) to $publicIp"