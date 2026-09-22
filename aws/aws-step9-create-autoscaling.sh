#!/usr/bin/env bash
set -euo pipefail
# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 9 - Create an Auto Scaling group from the existing web EC2 image and attach it to the ALB target group.
# ============================================================

REGION="${AWS_REGION:-ap-south-1}"; PROJECT="aws-three-tier"
VPC_NAME="aws-three-tier-vpc"; WEB_SG_NAME="aws-three-tier-web-sg"; WEB_INSTANCE_NAME="aws-three-tier-web-instance"
TG_NAME="aws-three-tier-web-tg"; ASG_NAME="aws-three-tier-web-asg"; LT_NAME="aws-three-tier-web-lt"

VPC_ID=$(aws ec2 describe-vpcs --region "$REGION" --filters "Name=tag:Name,Values=$VPC_NAME" "Name=tag:Project,Values=$PROJECT" --query 'Vpcs[0].VpcId' --output text)
INSTANCE_ID=$(aws ec2 describe-instances --region "$REGION" --filters "Name=tag:Name,Values=$WEB_INSTANCE_NAME" --query 'Reservations[0].Instances[0].InstanceId' --output text)
WEB_SG_ID=$(aws ec2 describe-security-groups --region "$REGION" --filters "Name=group-name,Values=$WEB_SG_NAME" "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[0].GroupId' --output text)
for x in VPC_ID INSTANCE_ID WEB_SG_ID; do [[ -n "${!x}" && "${!x}" != "None" ]] || { echo "ERROR: $x not found."; exit 1; }; done

AMI_ID=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].ImageId' --output text)
INSTANCE_TYPE=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].InstanceType' --output text)
KEY_NAME=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].KeyName' --output text)
TG_ARN=$(aws elbv2 describe-target-groups --region "$REGION" --names "$TG_NAME" --query 'TargetGroups[0].TargetGroupArn' --output text)
SUBNETS=$(aws ec2 describe-subnets --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Tier,Values=web" --query 'Subnets[].SubnetId' --output text)
[[ -n "$TG_ARN" && "$TG_ARN" != "None" && -n "$SUBNETS" ]] || { echo "ERROR: ALB target group or web subnets missing."; exit 1; }

LT_ID=$(aws ec2 describe-launch-templates --region "$REGION" --launch-template-names "$LT_NAME" --query 'LaunchTemplates[0].LaunchTemplateId' --output text 2>/dev/null || true)
if [[ -z "$LT_ID" || "$LT_ID" == "None" ]]; then
  TMP=$(mktemp)
  cat > "$TMP" <<EOF
{"ImageId":"$AMI_ID","InstanceType":"$INSTANCE_TYPE","SecurityGroupIds":["$WEB_SG_ID"],"KeyName":"$KEY_NAME"}
EOF
  LT_ID=$(aws ec2 create-launch-template --region "$REGION" --launch-template-name "$LT_NAME" --version-description "Created from Step 5 web instance" --launch-template-data "file://$TMP" --query 'LaunchTemplate.LaunchTemplateId' --output text)
  rm -f "$TMP"
fi

ASG_EXISTS=$(aws autoscaling describe-auto-scaling-groups --region "$REGION" --auto-scaling-group-names "$ASG_NAME" --query 'AutoScalingGroups[0].AutoScalingGroupName' --output text 2>/dev/null || true)
if [[ -z "$ASG_EXISTS" || "$ASG_EXISTS" == "None" ]]; then
  aws autoscaling create-auto-scaling-group --region "$REGION" --auto-scaling-group-name "$ASG_NAME" --launch-template "LaunchTemplateId=$LT_ID,Version=\$Latest" --min-size 1 --max-size 3 --desired-capacity 2 --vpc-zone-identifier "$SUBNETS" --target-group-arns "$TG_ARN" --tags "ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=Project,Value=$PROJECT,PropagateAtLaunch=true" "ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=Name,Value=aws-three-tier-asg-instance,PropagateAtLaunch=true"
else
  aws autoscaling update-auto-scaling-group --region "$REGION" --auto-scaling-group-name "$ASG_NAME" --min-size 1 --max-size 3 --desired-capacity 2 --vpc-zone-identifier "$SUBNETS" --target-group-arns "$TG_ARN"
fi

echo "Auto Scaling group ready: $ASG_NAME"
