# Author: Anuradha Iyer
# Date: 2026-08-15
# Description: Step 1 - Create IAM User, Access Keys, and Configure AWS CLI Profile

# Read credentials from environment variables set before running
$Username = $env:DEV_USER_NAME
$Password = $env:DEV_USER_PASSWORD

if (-not $Username -or -not $Password) {
    Write-Host "Please set DEV_USER_NAME and DEV_USER_PASSWORD environment variables first." -ForegroundColor Red
    exit
}

# 1. Create IAM User
aws iam create-user --user-name $Username

# 2. Create Console Login Profile
aws iam create-login-profile --user-name $Username --password $Password --password-reset-required

# 3. Attach Managed Policy
aws iam attach-user-policy --user-name $Username --policy-arn "arn:aws:iam::aws:policy/AmazonEC2FullAccess"

# 4. Generate Access Keys
$keyJson = aws iam create-access-key --user-name $Username | ConvertFrom-Json
$accessKey = $keyJson.AccessKey.AccessKeyId
$secretKey = $keyJson.AccessKey.SecretAccessKey

# 5. Configure Local AWS Profile
aws configure set aws_access_key_id $accessKey --profile dev-profile
aws configure set aws_secret_access_key $secretKey --profile dev-profile
aws configure set region us-east-1 --profile dev-profile

Write-Host "Step 1 Complete! User $Username created and profile 'dev-profile' configured." -ForegroundColor Green