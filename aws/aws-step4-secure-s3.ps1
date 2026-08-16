# Author: Anuradha Iyer
# Date: 2026-08-16
# Description: Step 4 - Create and Secure S3 Bucket

# Step 1: Define Environment Variables
$BucketName = "my-secure-bucket-name-12345"
$Region = "us-east-1"
$AwsProfile = "dev-profile"
$LogTargetBucket = "my-central-s3-logs-bucket"

# Step 2: Create the S3 Bucket
if ($Region -eq "us-east-1") {
    aws s3api create-bucket --bucket $BucketName --region $Region --profile $AwsProfile
} else {
    aws s3api create-bucket --bucket $BucketName --region $Region --create-bucket-configuration LocationConstraint=$Region --profile $AwsProfile
}

# Step 3: Enforce Object Ownership (Disable ACLs)
aws s3api put-bucket-ownership-controls --bucket $BucketName --ownership-controls "Rules=[{ObjectOwnership=BucketOwnerEnforced}]" --profile $AwsProfile

# Step 4: Enable Block Public Access
aws s3api put-public-access-block --bucket $BucketName --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" --profile $AwsProfile

# Step 5: Enable Bucket Versioning
aws s3api put-bucket-versioning --bucket $BucketName --versioning-configuration Status=Enabled --profile $AwsProfile

# Step 6: Configure Default Encryption at Rest (SSE-S3)
$encryptionJson = @"
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
"@
Set-Content -Path "encryption.json" -Value $encryptionJson
aws s3api put-bucket-encryption --bucket $BucketName --server-side-encryption-configuration file://encryption.json --profile $AwsProfile

# Step 7: Enforce Encryption in Transit (HTTPS / TLS Only)
$bucketPolicyJson = @"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnforceTLSRequestsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::$BucketName",
        "arn:aws:s3:::$BucketName/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
"@
Set-Content -Path "bucket-policy.json" -Value $bucketPolicyJson
aws s3api put-bucket-policy --bucket $BucketName --policy file://bucket-policy.json --profile $AwsProfile

# Step 8: Enable Server Access Logging
$loggingJson = @"
{
  "LoggingEnabled": {
    "TargetBucket": "$LogTargetBucket",
    "TargetPrefix": "s3-access-logs/$BucketName/"
  }
}
"@
Set-Content -Path "logging.json" -Value $loggingJson
aws s3api put-bucket-logging --bucket $BucketName --bucket-logging-status file://logging.json --profile $AwsProfile

# Step 9: Security Verification
Write-Host "`n--- Verifying S3 Security Configuration ---" -ForegroundColor Green

Write-Host "`n1. Public Access Block:" -ForegroundColor Yellow
aws s3api get-public-access-block --bucket $BucketName --profile $AwsProfile

Write-Host "`n2. Object Ownership Controls:" -ForegroundColor Yellow
aws s3api get-bucket-ownership-controls --bucket $BucketName --profile $AwsProfile

Write-Host "`n3. Versioning Status:" -ForegroundColor Yellow
aws s3api get-bucket-versioning --bucket $BucketName --profile $AwsProfile

Write-Host "`n4. Default Encryption:" -ForegroundColor Yellow
aws s3api get-bucket-encryption --bucket $BucketName --profile $AwsProfile

Write-Host "`n5. Bucket Policy:" -ForegroundColor Yellow
aws s3api get-bucket-policy --bucket $BucketName --profile $AwsProfile