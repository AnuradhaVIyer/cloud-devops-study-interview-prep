# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 15 - Enable AWS Systems Manager access for project EC2 instances using an IAM instance profile.
# ============================================================

$ErrorActionPreference="Stop"; $Region=if($env:AWS_REGION){$env:AWS_REGION}else{"ap-south-1"}; $Project="aws-three-tier"; $Profile="aws-three-tier-ssm-profile"; $Role="aws-three-tier-ssm-role"
$RoleArn=aws iam get-role --role-name $Role --query "Role.Arn" --output text 2>$null
if([string]::IsNullOrWhiteSpace($RoleArn) -or $RoleArn -eq "None"){
  $Trust='{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}'
  $f=Join-Path $env:TEMP "trust-ec2.json"; Set-Content $f $Trust
  $RoleArn=aws iam create-role --role-name $Role --assume-role-policy-document "file://$f" --query "Role.Arn" --output text
  aws iam attach-role-policy --role-name $Role --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
}
$Exists=aws iam get-instance-profile --instance-profile-name $Profile --query "InstanceProfile.InstanceProfileName" --output text 2>$null
if([string]::IsNullOrWhiteSpace($Exists) -or $Exists -eq "None"){aws iam create-instance-profile --instance-profile-name $Profile; aws iam add-role-to-instance-profile --instance-profile-name $Profile --role-name $Role; Start-Sleep 10}
$Ids=(aws ec2 describe-instances --region $Region --filters "Name=tag:Project,Values=$Project" "Name=instance-state-name,Values=pending,running,stopping,stopped" --query "Reservations[].Instances[].InstanceId" --output text) -split "\s+"
if($Ids.Count -eq 0 -or [string]::IsNullOrWhiteSpace($Ids[0])){throw "No project EC2 instances found."}
foreach($Id in $Ids){
  $Arn=aws ec2 describe-instances --region $Region --instance-ids $Id --query "Reservations[0].Instances[0].IamInstanceProfile.Arn" --output text
  if([string]::IsNullOrWhiteSpace($Arn) -or $Arn -eq "None"){aws ec2 associate-iam-instance-profile --region $Region --instance-id $Id --iam-instance-profile Name=$Profile; Write-Host "Associated SSM profile with $Id"}else{Write-Host "$Id already has an instance profile."}
}
aws ssm describe-instance-information --region $Region --query "InstanceInformationList[].[InstanceId,PingStatus,PlatformName]" --output table
