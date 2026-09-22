# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 7 - Create Amazon EFS and mount targets for the private application tier.
# ============================================================

$ErrorActionPreference = "Stop"
$Region = if ($env:AWS_REGION) { $env:AWS_REGION } else { "ap-south-1" }
$ProjectName = "aws-three-tier"
$VpcName = "aws-three-tier-vpc"
$AppSgName = "aws-three-tier-app-sg"
$SubnetAN = "aws-three-tier-app-subnet-a"
$SubnetBN = "aws-three-tier-app-subnet-b"
$FsName = "aws-three-tier-efs"

$VpcId = aws ec2 describe-vpcs --region $Region --filters "Name=tag:Name,Values=$VpcName" "Name=tag:Project,Values=$ProjectName" --query "Vpcs[0].VpcId" --output text
$AppSgId = aws ec2 describe-security-groups --region $Region --filters "Name=group-name,Values=$AppSgName" "Name=vpc-id,Values=$VpcId" --query "SecurityGroups[0].GroupId" --output text
$SubnetA = aws ec2 describe-subnets --region $Region --filters "Name=tag:Name,Values=$SubnetAN" "Name=vpc-id,Values=$VpcId" --query "Subnets[0].SubnetId" --output text
$SubnetB = aws ec2 describe-subnets --region $Region --filters "Name=tag:Name,Values=$SubnetBN" "Name=vpc-id,Values=$VpcId" --query "Subnets[0].SubnetId" --output text
foreach ($x in @(@("VpcId",$VpcId),@("AppSgId",$AppSgId),@("SubnetA",$SubnetA),@("SubnetB",$SubnetB))) { if ([string]::IsNullOrWhiteSpace($x[1]) -or $x[1] -eq "None") { throw "Required resource $($x[0]) was not found." } }

$FsId = aws efs describe-file-systems --region $Region --query "FileSystems[?Name=='$FsName'].FileSystemId | [0]" --output text
if ([string]::IsNullOrWhiteSpace($FsId) -or $FsId -eq "None") {
    $FsId = aws efs create-file-system --region $Region --encrypted --tags "Key=Name,Value=$FsName" "Key=Project,Value=$ProjectName" "Key=Environment,Value=dev" "Key=ManagedBy,Value=aws-cli" --query "FileSystemId" --output text
    aws efs wait file-system-available --region $Region --file-system-id $FsId
}
foreach ($SubnetId in @($SubnetA,$SubnetB)) {
    $Existing = aws efs describe-mount-targets --region $Region --file-system-id $FsId --query "MountTargets[?SubnetId=='$SubnetId'].MountTargetId | [0]" --output text
    if ([string]::IsNullOrWhiteSpace($Existing) -or $Existing -eq "None") {
        aws efs create-mount-target --region $Region --file-system-id $FsId --subnet-id $SubnetId --security-groups $AppSgId
    }
}
Write-Host "EFS ready: $FsId"
