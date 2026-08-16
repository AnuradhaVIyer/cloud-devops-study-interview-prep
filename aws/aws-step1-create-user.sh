#!/usr/bin/env bash
# Author: Anuradha Iyer
# Date: 2026-08-15
# Description: Step 1 - Create IAM User, Access Keys, and Configure AWS CLI Profile

# Read credentials from environment variables set before running
USERNAME="${DEV_USER_NAME}"
PASSWORD="${DEV_USER_PASSWORD}"

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Please set DEV_USER_NAME and DEV_USER_PASSWORD environment variables first."
    exit 1
fi

# 1. Create IAM User
aws iam create-user --user-name "$USERNAME"

# 2. Create Console Login Profile
aws iam create-login-profile --user-name "$USERNAME" --password "$PASSWORD" --password-reset-required

# 3. Attach Managed Policy
aws iam attach-user-policy --user-name "$USERNAME" --policy-arn "arn:aws:iam::aws:policy/AmazonEC2FullAccess"

# 4. Generate Access Keys
KEYS=$(aws iam create-access-key --user-name "$USERNAME" --query 'AccessKey.[AccessKeyId,SecretAccessKey]' --output text)
ACCESS_KEY=$(echo $KEYS | awk '{print $1}')
SECRET_KEY=$(echo $KEYS | awk '{print $2}')

# 5. Configure Local AWS Profile
aws configure set aws_access_key_id "$ACCESS_KEY" --profile dev-profile
aws configure set aws_secret_access_key "$SECRET_KEY" --profile dev-profile
aws configure set region us-east-1 --profile dev-profile

echo "Step 1 Complete! User $USERNAME created and profile 'dev-profile' configured."