# Author: Anuradha Iyer
# Date: 2026-08-15
# Description: Step 2 - Create VPC, Public Subnet, Internet Gateway, and Route Table

# 2.1 Create VPC
$vpcJson = aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=dev-vpc}]" --profile dev-profile | ConvertFrom-Json
$vpcId = $vpcJson.Vpc.VpcId
Write-Host "VPC Created: $vpcId"

# 2.2 Create Public Subnet
$subnetJson = aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.1.0/24 --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=dev-public-subnet}]" --profile dev-profile | ConvertFrom-Json
$subnetId = $subnetJson.Subnet.SubnetId
Write-Host "Subnet Created: $subnetId"

# Enable Auto-assign Public IP
aws ec2 modify-subnet-attribute --subnet-id $subnetId --map-public-ip-on-launch --profile dev-profile

# 2.3 Create and Attach Internet Gateway
$igwJson = aws ec2 create-internet-gateway --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=dev-igw}]" --profile dev-profile | ConvertFrom-Json
$igwId = $igwJson.InternetGateway.InternetGatewayId
Write-Host "IGW Created: $igwId"

aws ec2 attach-internet-gateway --vpc-id $vpcId --internet-gateway-id $igwId --profile dev-profile

# 2.4 Create Route Table, Add Route, and Associate Subnet
$rtJson = aws ec2 create-route-table --vpc-id $vpcId --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=dev-public-rt}]" --profile dev-profile | ConvertFrom-Json
$rtId = $rtJson.RouteTable.RouteTableId
Write-Host "Route Table Created: $rtId"

aws ec2 create-route --route-table-id $rtId --destination-cidr-block 0.0.0.0/0 --gateway-id $igwId --profile dev-profile
aws ec2 associate-route-table --subnet-id $subnetId --route-table-id $rtId --profile dev-profile

Write-Host "Step 2 Complete! Networking components set up successfully." -ForegroundColor Green