# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 9 - Create an Auto Scaling group from the existing web EC2 image and attach it to the ALB target group.
# ============================================================

$ErrorActionPreference = "Stop"
$Region = if ($env:AWS_REGION) { $env:AWS_REGION } else { "ap-south-1" }
$Project="aws-three-tier"; $VpcName="aws-three-tier-vpc"; $WebSgName="aws-three-tier-web-sg"; $InstanceName="aws-three-tier-web-instance"
$TgName="aws-three-tier-web-tg"; $AsgName="aws-three-tier-web-asg"; $LtName="aws-three-tier-web-lt"

$VpcId=aws ec2 describe-vpcs --region $Region --filters "Name=tag:Name,Values=$VpcName" "Name=tag:Project,Values=$Project" --query "Vpcs[0].VpcId" --output text
$InstanceId=aws ec2 describe-instances --region $Region --filters "Name=tag:Name,Values=$InstanceName" --query "Reservations[0].Instances[0].InstanceId" --output text
$WebSgId=aws ec2 describe-security-groups --region $Region --filters "Name=group-name,Values=$WebSgName" "Name=vpc-id,Values=$VpcId" --query "SecurityGroups[0].GroupId" --output text
foreach($x in @(@("VpcId",$VpcId),@("InstanceId",$InstanceId),@("WebSgId",$WebSgId))){if([string]::IsNullOrWhiteSpace($x[1]) -or $x[1] -eq "None"){throw "$($x[0]) not found."}}

$AmiId=aws ec2 describe-instances --region $Region --instance-ids $InstanceId --query "Reservations[0].Instances[0].ImageId" --output text
$InstanceType=aws ec2 describe-instances --region $Region --instance-ids $InstanceId --query "Reservations[0].Instances[0].InstanceType" --output text
$KeyName=aws ec2 describe-instances --region $Region --instance-ids $InstanceId --query "Reservations[0].Instances[0].KeyName" --output text
$TgArn=aws elbv2 describe-target-groups --region $Region --names $TgName --query "TargetGroups[0].TargetGroupArn" --output text
$Subnets=(aws ec2 describe-subnets --region $Region --filters "Name=vpc-id,Values=$VpcId" "Name=tag:Tier,Values=web" --query "Subnets[].SubnetId" --output text) -split "\s+"
if([string]::IsNullOrWhiteSpace($TgArn) -or $TgArn -eq "None" -or $Subnets.Count -lt 2){throw "ALB target group or at least two web subnets missing."}

$LtId=aws ec2 describe-launch-templates --region $Region --launch-template-names $LtName --query "LaunchTemplates[0].LaunchTemplateId" --output text 2>$null
if([string]::IsNullOrWhiteSpace($LtId) -or $LtId -eq "None"){
    $Data = @{ImageId=$AmiId;InstanceType=$InstanceType;SecurityGroupIds=@($WebSgId);KeyName=$KeyName} | ConvertTo-Json -Compress
    $tmp=[IO.Path]::GetTempFileName(); Set-Content -Path $tmp -Value $Data
    $LtId=aws ec2 create-launch-template --region $Region --launch-template-name $LtName --version-description "Created from Step 5 web instance" --launch-template-data "file://$tmp" --query "LaunchTemplate.LaunchTemplateId" --output text
    Remove-Item $tmp -Force
}

$Exists=aws autoscaling describe-auto-scaling-groups --region $Region --auto-scaling-group-names $AsgName --query "AutoScalingGroups[0].AutoScalingGroupName" --output text 2>$null
$SubnetCsv=$Subnets -join ","
if([string]::IsNullOrWhiteSpace($Exists) -or $Exists -eq "None"){
    aws autoscaling create-auto-scaling-group --region $Region --auto-scaling-group-name $AsgName --launch-template "LaunchTemplateId=$LtId,Version=`$Latest" --min-size 1 --max-size 3 --desired-capacity 2 --vpc-zone-identifier $SubnetCsv --target-group-arns $TgArn
    aws autoscaling create-or-update-tags --region $Region --tags "ResourceId=$AsgName,ResourceType=auto-scaling-group,Key=Project,Value=$Project,PropagateAtLaunch=true" "ResourceId=$AsgName,ResourceType=auto-scaling-group,Key=Name,Value=aws-three-tier-asg-instance,PropagateAtLaunch=true"
}else{
    aws autoscaling update-auto-scaling-group --region $Region --auto-scaling-group-name $AsgName --min-size 1 --max-size 3 --desired-capacity 2 --vpc-zone-identifier $SubnetCsv --target-group-arns $TgArn
}
Write-Host "Auto Scaling group ready: $AsgName"
