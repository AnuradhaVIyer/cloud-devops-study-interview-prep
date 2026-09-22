#!/usr/bin/env bash
set -euo pipefail
# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 8 - Create an internet-facing Application Load Balancer and target group for the web tier.
# ============================================================

REGION="${AWS_REGION:-ap-south-1}"
PROJECT_NAME="${PROJECT_NAME:-aws-three-tier}"
VPC_NAME="${VPC_NAME:-aws-three-tier-vpc}"
WEB_SG_NAME="${WEB_SG_NAME:-aws-three-tier-web-sg}"
ALB_SG_NAME="${ALB_SG_NAME:-aws-three-tier-alb-sg}"
WEB_SUBNET_A="${WEB_SUBNET_A_NAME:-aws-three-tier-web-subnet-a}"
WEB_SUBNET_B="${WEB_SUBNET_B_NAME:-aws-three-tier-web-subnet-b}"
WEB_INSTANCE_NAME="${WEB_INSTANCE_NAME:-aws-three-tier-web-instance}"
ALB_NAME="${ALB_NAME:-aws-three-tier-alb}"
TG_NAME="${TG_NAME:-aws-three-tier-web-tg}"

VPC_ID=$(aws ec2 describe-vpcs --region "$REGION" --filters "Name=tag:Name,Values=$VPC_NAME" "Name=tag:Project,Values=$PROJECT_NAME" --query 'Vpcs[0].VpcId' --output text)
WEB_SG_ID=$(aws ec2 describe-security-groups --region "$REGION" --filters "Name=group-name,Values=$WEB_SG_NAME" "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[0].GroupId' --output text)
SUBNET_A=$(aws ec2 describe-subnets --region "$REGION" --filters "Name=tag:Name,Values=$WEB_SUBNET_A" --query 'Subnets[0].SubnetId' --output text)
SUBNET_B=$(aws ec2 describe-subnets --region "$REGION" --filters "Name=tag:Name,Values=$WEB_SUBNET_B" --query 'Subnets[0].SubnetId' --output text)
INSTANCE_ID=$(aws ec2 describe-instances --region "$REGION" --filters "Name=tag:Name,Values=$WEB_INSTANCE_NAME" "Name=instance-state-name,Values=running" --query 'Reservations[0].Instances[0].InstanceId' --output text)

for x in VPC_ID WEB_SG_ID SUBNET_A SUBNET_B INSTANCE_ID; do [[ -n "${!x}" && "${!x}" != "None" ]] || { echo "ERROR: $x not found."; exit 1; }; done

ALB_SG_ID=$(aws ec2 describe-security-groups --region "$REGION" --filters "Name=group-name,Values=$ALB_SG_NAME" "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[0].GroupId' --output text)
if [[ -z "$ALB_SG_ID" || "$ALB_SG_ID" == "None" ]]; then
  ALB_SG_ID=$(aws ec2 create-security-group --region "$REGION" --group-name "$ALB_SG_NAME" --description "ALB security group for $PROJECT_NAME" --vpc-id "$VPC_ID" --query GroupId --output text)
  aws ec2 create-tags --region "$REGION" --resources "$ALB_SG_ID" --tags "Key=Name,Value=$ALB_SG_NAME" "Key=Project,Value=$PROJECT_NAME" "Key=Environment,Value=dev" "Key=ManagedBy,Value=aws-cli"
  aws ec2 authorize-security-group-ingress --region "$REGION" --group-id "$ALB_SG_ID" --ip-permissions 'IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges=[{CidrIp=0.0.0.0/0,Description="HTTP"}]'
fi

# Web instances accept HTTP only from the ALB security group.
aws ec2 authorize-security-group-ingress --region "$REGION" --group-id "$WEB_SG_ID" --protocol tcp --port 80 --source-group "$ALB_SG_ID" 2>/dev/null || true

TG_ARN=$(aws elbv2 describe-target-groups --region "$REGION" --names "$TG_NAME" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || true)
if [[ -z "$TG_ARN" || "$TG_ARN" == "None" ]]; then
  TG_ARN=$(aws elbv2 create-target-group --region "$REGION" --name "$TG_NAME" --protocol HTTP --port 80 --vpc-id "$VPC_ID" --target-type instance --health-check-path / --query 'TargetGroups[0].TargetGroupArn' --output text)
fi
aws elbv2 register-targets --region "$REGION" --target-group-arn "$TG_ARN" --targets "Id=$INSTANCE_ID" || true

ALB_ARN=$(aws elbv2 describe-load-balancers --region "$REGION" --names "$ALB_NAME" --query 'LoadBalancers[0].LoadBalancerArn' --output text 2>/dev/null || true)
if [[ -z "$ALB_ARN" || "$ALB_ARN" == "None" ]]; then
  ALB_ARN=$(aws elbv2 create-load-balancer --region "$REGION" --name "$ALB_NAME" --subnets "$SUBNET_A" "$SUBNET_B" --security-groups "$ALB_SG_ID" --scheme internet-facing --type application --query 'LoadBalancers[0].LoadBalancerArn' --output text)
  aws elbv2 wait load-balancer-available --region "$REGION" --load-balancer-arns "$ALB_ARN"
fi

LISTENER_ARN=$(aws elbv2 describe-listeners --region "$REGION" --load-balancer-arn "$ALB_ARN" --query 'Listeners[?Port==`80`].ListenerArn | [0]' --output text)
if [[ -z "$LISTENER_ARN" || "$LISTENER_ARN" == "None" ]]; then
  aws elbv2 create-listener --region "$REGION" --load-balancer-arn "$ALB_ARN" --protocol HTTP --port 80 --default-actions "Type=forward,TargetGroupArn=$TG_ARN" >/dev/null
fi

echo "ALB ready: $(aws elbv2 describe-load-balancers --region "$REGION" --load-balancer-arns "$ALB_ARN" --query 'LoadBalancers[0].DNSName' --output text)"
