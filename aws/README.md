# AWS Three-Tier Architecture — Steps 1–15

Author: Anuradha Iyer
Date: 2026-09-22

This project builds an AWS three-tier architecture end to end, from IAM user setup through Systems Manager configuration.

## Resource discovery
Scripts discover resources created in earlier steps using AWS tags and names. They do not require manually entered VPC IDs, subnet IDs, security-group IDs, instance IDs, or AMI IDs.

Default region: `ap-south-1`
Override with:
- Bash: `export AWS_REGION=ap-south-1`
- PowerShell: `$env:AWS_REGION="ap-south-1"`

Expected Step 5 tags:
- Project=aws-three-tier
- Environment=dev
- ManagedBy=aws-cli
- Name values such as `aws-three-tier-vpc`, `aws-three-tier-web-sg`, `aws-three-tier-app-sg`, `aws-three-tier-db-sg`, `aws-three-tier-web-instance`, and `aws-three-tier-app-instance`.

Run Steps 1–15 in order.

## Cost warning
EC2, NAT Gateway, Application Load Balancer, RDS, EFS, Auto Scaling and CloudWatch resources can incur AWS charges. Delete resources after the lab when they are no longer needed.

## Step map
1 IAM User Setup
2 VPC Setup
3 EC2 Launch (Ubuntu and Windows variants)
4 S3 Bucket Security
5 Three-Tier Architecture Setup (Ubuntu bash / Windows PowerShell)
6 EBS Volume Attach
7 EFS
8 Application Load Balancer
9 Auto Scaling
10 RDS
11 DynamoDB
12 Lambda
13 CloudFormation
14 CloudWatch
15 Systems Manager

## File Index

| Step | Bash | PowerShell | Additional |
|---|---|---|---|
| 1 | [aws-step1-create-user.sh](aws-step1-create-user.sh) | [aws-step1-create-user.ps1](aws-step1-create-user.ps1) | |
| 2 | [aws-step2-setup-vpc.sh](aws-step2-setup-vpc.sh) | [aws-step2-setup-vpc.ps1](aws-step2-setup-vpc.ps1) | |
| 3 (Ubuntu EC2) | [aws-step3-launch-ubuntu-ec2.sh](aws-step3-launch-ubuntu-ec2.sh) | [aws-step3-launch-ubuntu-ec2.ps1](aws-step3-launch-ubuntu-ec2.ps1) | |
| 3 (Windows EC2) | [aws-step3-launch-windows-ec2.sh](aws-step3-launch-windows-ec2.sh) | [aws-step3-launch-windows-ec2.ps1](aws-step3-launch-windows-ec2.ps1) | |
| 4 | [aws-step4-secure-s3.sh](aws-step4-secure-s3.sh) | [aws-step4-secure-s3.ps1](aws-step4-secure-s3.ps1) | |
| 5 | [aws-step5-setup-3-tier-architecture-ubuntu-ec2.sh](aws-step5-setup-3-tier-architecture-ubuntu-ec2.sh) | [aws-step5-setup-3-tier-architecture-windows-ec2.ps1](aws-step5-setup-3-tier-architecture-windows-ec2.ps1) | |
| 6 | [aws-step6-attach-ebs.sh](aws-step6-attach-ebs.sh) | [aws-step6-attach-ebs.ps1](aws-step6-attach-ebs.ps1) | |
| 7 | [aws-step7-create-efs.sh](aws-step7-create-efs.sh) | [aws-step7-create-efs.ps1](aws-step7-create-efs.ps1) | |
| 8 | [aws-step8-create-elb.sh](aws-step8-create-elb.sh) | [aws-step8-create-elb.ps1](aws-step8-create-elb.ps1) | |
| 9 | [aws-step9-create-autoscaling.sh](aws-step9-create-autoscaling.sh) | [aws-step9-create-autoscaling.ps1](aws-step9-create-autoscaling.ps1) | |
| 10 | [aws-step10-create-rds.sh](aws-step10-create-rds.sh) | [aws-step10-create-rds.ps1](aws-step10-create-rds.ps1) | |
| 11 | [aws-step11-create-dynamodb.sh](aws-step11-create-dynamodb.sh) | [aws-step11-create-dynamodb.ps1](aws-step11-create-dynamodb.ps1) | |
| 12 | [aws-step12-create-lambda.sh](aws-step12-create-lambda.sh) | [aws-step12-create-lambda.ps1](aws-step12-create-lambda.ps1) | [aws-step12-lambda-function.py](aws-step12-lambda-function.py) |
| 13 | [aws-step13-deploy-cloudformation.sh](aws-step13-deploy-cloudformation.sh) | [aws-step13-deploy-cloudformation.ps1](aws-step13-deploy-cloudformation.ps1) | [aws-step13-cloudformation-template.yaml](aws-step13-cloudformation-template.yaml) |
| 14 | [aws-step14-create-cloudwatch.sh](aws-step14-create-cloudwatch.sh) | [aws-step14-create-cloudwatch.ps1](aws-step14-create-cloudwatch.ps1) | |
| 15 | [aws-step15-systems-manager.sh](aws-step15-systems-manager.sh) | [aws-step15-systems-manager.ps1](aws-step15-systems-manager.ps1) | |