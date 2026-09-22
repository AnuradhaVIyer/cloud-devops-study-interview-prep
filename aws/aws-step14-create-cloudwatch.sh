#!/usr/bin/env bash
set -euo pipefail
# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 14 - Create CloudWatch monitoring and an EC2 CPU alarm for the web instance.
# ============================================================

REGION="${AWS_REGION:-ap-south-1}"; INSTANCE_NAME="aws-three-tier-web-instance"; ALARM="aws-three-tier-web-high-cpu"
INSTANCE_ID=$(aws ec2 describe-instances --region "$REGION" --filters "Name=tag:Name,Values=$INSTANCE_NAME" --query 'Reservations[0].Instances[0].InstanceId' --output text)
[[ -n "$INSTANCE_ID" && "$INSTANCE_ID" != "None" ]] || { echo "ERROR: Web EC2 instance not found."; exit 1; }

aws cloudwatch put-metric-alarm --region "$REGION" --alarm-name "$ALARM" --alarm-description "High CPU on three-tier web instance" --namespace AWS/EC2 --metric-name CPUUtilization --dimensions "Name=InstanceId,Value=$INSTANCE_ID" --statistic Average --period 300 --evaluation-periods 2 --threshold 70 --comparison-operator GreaterThanOrEqualToThreshold --treat-missing-data notBreaching
aws cloudwatch put-dashboard --region "$REGION" --dashboard-name "aws-three-tier-dashboard" --dashboard-body "{\"widgets\":[{\"type\":\"metric\",\"x\":0,\"y\":0,\"width\":12,\"height\":6,\"properties\":{\"metrics\":[[\"AWS/EC2\",\"CPUUtilization\",\"InstanceId\",\"$INSTANCE_ID\"]],\"period\":300,\"stat\":\"Average\",\"region\":\"$REGION\",\"title\":\"Web EC2 CPU\"}}]}"
echo "CloudWatch alarm and dashboard created."
