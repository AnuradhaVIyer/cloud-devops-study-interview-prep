# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 14 - Create CloudWatch monitoring and an EC2 CPU alarm for the web instance.
# ============================================================

$ErrorActionPreference="Stop"; $Region=if($env:AWS_REGION){$env:AWS_REGION}else{"ap-south-1"}; $InstanceName="aws-three-tier-web-instance"; $Alarm="aws-three-tier-web-high-cpu"
$InstanceId=aws ec2 describe-instances --region $Region --filters "Name=tag:Name,Values=$InstanceName" --query "Reservations[0].Instances[0].InstanceId" --output text
if([string]::IsNullOrWhiteSpace($InstanceId) -or $InstanceId -eq "None"){throw "Web EC2 instance not found."}
aws cloudwatch put-metric-alarm --region $Region --alarm-name $Alarm --alarm-description "High CPU on three-tier web instance" --namespace AWS/EC2 --metric-name CPUUtilization --dimensions "Name=InstanceId,Value=$InstanceId" --statistic Average --period 300 --evaluation-periods 2 --threshold 70 --comparison-operator GreaterThanOrEqualToThreshold --treat-missing-data notBreaching
$Body="{`"widgets`":[{`"type`":`"metric`",`"x`":0,`"y`":0,`"width`":12,`"height`":6,`"properties`":{`"metrics`":[[`"AWS/EC2`",`"CPUUtilization`",`"InstanceId`",`"$InstanceId`"]],`"period`":300,`"stat`":`"Average`",`"region`":`"$Region`",`"title`":`"Web EC2 CPU`"}}]}"
aws cloudwatch put-dashboard --region $Region --dashboard-name "aws-three-tier-dashboard" --dashboard-body $Body
Write-Host "CloudWatch alarm and dashboard created."
