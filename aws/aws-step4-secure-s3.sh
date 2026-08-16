#!/usr/bin/env bash
# Author: Anuradha Iyer
# Date: 2026-08-16
# Description: Step 4 - Create and Secure S3 Bucket

# Step 1: Define Environment Variables
BUCKET_NAME="my-secure-bucket-name-12345"
REGION="us-east-1"
PROFILE="dev-profile"
LOG_TARGET_BUCKET="my-central-s3-logs-bucket"

# Step 2: Create the S3 Bucket
if [ "$REGION" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" --profile "$PROFILE"
else
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION" --profile "$PROFILE"
fi

# Step 3: Enforce Object Ownership (Disable ACLs)
aws s3api put-bucket-ownership-controls --bucket "$BUCKET_NAME" --ownership-controls "Rules=[{ObjectOwnership=BucketOwnerEnforced}]" --profile "$PROFILE"

# Step 4: Enable Block Public Access
aws s3api put-public-access-block --bucket "$BUCKET_NAME" --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" --profile "$PROFILE"

# Step 5: Enable Bucket Versioning
aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled --profile "$PROFILE"

# Step 6: Configure Default Encryption at Rest (SSE-S3)
cat <<EOF > encryption.json
{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      },
      "BucketKeyEnabled": true
    }
  ]
}
EOF
aws s3api put-bucket-encryption --bucket "$BUCKET_NAME" --server-side-encryption-configuration file://encryption.json --profile "$PROFILE"

# Step 7: Enforce Encryption in Transit (HTTPS / TLS Only)
cat <<EOF > bucket-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnforceTLSRequestsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::$BUCKET_NAME",
        "arn:aws:s3:::$BUCKET_NAME/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
EOF
aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy file://bucket-policy.json --profile "$PROFILE"

# Step 8: Enable Server Access Logging
cat <<EOF > logging.json
{
  "LoggingEnabled": {
    "TargetBucket": "$LOG_TARGET_BUCKET",
    "TargetPrefix": "s3-access-logs/$BUCKET_NAME/"
  }
}
EOF
aws s3api put-bucket-logging --bucket "$BUCKET_NAME" --bucket-logging-status file://logging.json --profile "$PROFILE"

# Step 9: Security Verification
echo -e "\n--- Verifying S3 Security Configuration ---"

echo -e "\n1. Public Access Block:"
aws s3api get-public-access-block --bucket "$BUCKET_NAME" --profile "$PROFILE"

echo -e "\n2. Object Ownership Controls:"
aws s3api get-bucket-ownership-controls --bucket "$BUCKET_NAME" --profile "$PROFILE"

echo -e "\n3. Versioning Status:"
aws s3api get-bucket-versioning --bucket "$BUCKET_NAME" --profile "$PROFILE"

echo -e "\n4. Default Encryption:"
aws s3api get-bucket-encryption --bucket "$BUCKET_NAME" --profile "$PROFILE"

echo -e "\n5. Bucket Policy:"
aws s3api get-bucket-policy --bucket "$BUCKET_NAME" --profile "$PROFILE"