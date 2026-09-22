# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 8 - Create an internet-facing Application Load Balancer and target group for the web tier.
# ============================================================

$ErrorActionPreference = "Stop"
$Region = if ($env:AWS_REGION) { $env:AWS_REGION } else { "ap-south-1" }
$Project = "aws-three-tier"; $VpcName = "aws-three-tier-vpc"; $WebSgName = "aws-three-tier-web-sg"; $AlbSgName = "aws-three-tier-alb-sg"
$SubnetAName = "aws-three-tier-web-subnet-a"; $SubnetBName = "aws-three-tier-web-subnet-b"; $InstanceName = "aws-three-tier-web-instance"
$AlbName = "aws-three-tier-alb"; $TgName = "aws-three-tier-web-tg"

$VpcId = aws ec2 describe-vpcs --region $Region --filters "Name=tag:Name,Values=$VpcName" "Name=tag:Project,Values=$Project" --query "Vpcs[0].VpcId" --output text
$WebSgId = aws ec2 describe-security-groups --region $Region --filters "Name=group-name,Values=$WebSgName" "Name=vpc-id,Values=$VpcId" --query "SecurityGroups[0].GroupId" --output text
$SubnetA = aws ec2 describe-subnets --region $Region --filters "Name=tag:Name,Values=$SubnetAName" --query "Subnets[0].SubnetId" --output text
$SubnetB = aws ec2 describe-subnets --region $Region --filters "Name=tag:Name,Values=$SubnetBName" --query "Subnets[0].SubnetId" --output text
$InstanceId = aws ec2 describe-instances --region $Region --filters "Name=tag:Name,Values=$InstanceName" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].InstanceId" --output text
foreach ($x in @(@("VpcId",$VpcId),@("WebSgId",$WebSgId),@("SubnetA",$SubnetA),@("SubnetB",$SubnetB),@("InstanceId",$InstanceId))) { if ([string]::IsNullOrWhiteSpace($x[1]) -or $x[1] -eq "None") { throw "$($x[0]) not found." } }

$AlbSgId = aws ec2 describe-security-groups --region $Region --filters "Name=group-name,Values=$AlbSgName" "Name=vpc-id,Values=$VpcId" --query "SecurityGroups[0].GroupId" --output text
if ([string]::IsNullOrWhiteSpace($AlbSgId) -or $AlbSgId -eq "None") {
    $AlbSgId = aws ec2 create-security-group --region $Region --group-name $AlbSgName --description "ALB security group for $Project" --vpc-id $VpcId --query GroupId --output text
    aws ec2 create-tags --region $Region --resources $AlbSgId --tags "Key=Name,Value=$AlbSgName" "Key=Project,Value=$Project" "Key=Environment,Value=dev" "Key=ManagedBy,Value=aws-cli"
    aws ec2 authorize-security-group-ingress --region $Region --group-id $AlbSgId --protocol tcp --port 80 --cidr 0.0.0.0/0
}
aws ec2 authorize-security-group-ingress --region $Region --group-id $WebSgId --protocol tcp --port 80 --source-group $AlbSgId 2>$null

$TgArn = aws elbv2 describe-target-groups --region $Region --names $TgName --query "TargetGroups[0].TargetGroupArn" --output text 2>$null
if ([string]::IsNullOrWhiteSpace($TgArn) -or $TgArn -eq "None") {
    $TgArn = aws elbv2 create-target-group --region $Region --name $TgName --protocol HTTP --port 80 --vpc-id $VpcId --target-type instance --health-check-path / --query "TargetGroups[0].TargetGroupArn" --output text
}
aws elbv2 register-targets --region $Region --target-group-arn $TgArn --targets "Id=$InstanceId" 2>$null

$AlbArn = aws elbv2 describe-load-balancers --region $Region --names $AlbName --query "LoadBalancers[0].LoadBalancerArn" --output text 2>$null
if ([string]::IsNullOrWhiteSpace($AlbArn) -or $AlbArn -eq "None") {
    $AlbArn = aws elbv2 create-load-balancer --region $Region --name $AlbName --subnets $SubnetA $SubnetB --security-groups $AlbSgId --scheme internet-facing --type application --query "LoadBalancers[0].LoadBalancerArn" --output text
    aws elbv2 wait load-balancer-available --region $Region --load-balancer-arns $AlbArn
}
$ListenerArn = aws elbv2 describe-listeners --region $Region --load-balancer-arn $AlbArn --query 'Listeners[?Port==`80`].ListenerArn | [0]' --output text
if ([string]::IsNullOrWhiteSpace($ListenerArn) -or $ListenerArn -eq "None") {
    aws elbv2 create-listener --region $Region --load-balancer-arn $AlbArn --protocol HTTP --port 80 --default-actions "Type=forward,TargetGroupArn=$TgArn" | Out-Null
}
$Dns = aws elbv2 describe-load-balancers --region $Region --load-balancer-arns $AlbArn --query "LoadBalancers[0].DNSName" --output text
Write-Host "ALB ready: $Dns"
