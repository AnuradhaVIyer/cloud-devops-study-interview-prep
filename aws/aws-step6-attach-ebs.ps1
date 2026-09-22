# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 6 - Create and attach an encrypted EBS
#              gp3 volume to the existing 3-tier EC2 instance.
# ============================================================

$ErrorActionPreference = "Stop"

$REGION = if ($env:AWS_REGION) { $env:AWS_REGION } else { "ap-south-1" }

$PROJECT = "aws-three-tier"
$ENVIRONMENT = "dev"
$INSTANCE_NAME = "aws-three-tier-web-instance"
$VOLUME_NAME = "aws-three-tier-ebs-data"

Write-Host "============================================================"
Write-Host "AWS Three-Tier Architecture - Step 6: Attach EBS"
Write-Host "============================================================"
Write-Host "Region       : $REGION"
Write-Host "Project      : $PROJECT"
Write-Host "Environment  : $ENVIRONMENT"
Write-Host "Instance     : $INSTANCE_NAME"
Write-Host "EBS Volume   : $VOLUME_NAME"
Write-Host "============================================================"

# ------------------------------------------------------------
# Step 1 - Discover the EC2 instance created in Step 5
# ------------------------------------------------------------

$INSTANCE_ID = aws ec2 describe-instances `
    --region $REGION `
    --filters `
        "Name=tag:Name,Values=$INSTANCE_NAME" `
        "Name=instance-state-name,Values=pending,running,stopped" `
    --query "Reservations[].Instances[0].InstanceId" `
    --output text

if ([string]::IsNullOrWhiteSpace($INSTANCE_ID) -or $INSTANCE_ID -eq "None") {
    Write-Error "EC2 instance '$INSTANCE_NAME' was not found. Run Step 5 first."
    exit 1
}

Write-Host "EC2 Instance ID: $INSTANCE_ID"

# ------------------------------------------------------------
# Step 2 - Discover Availability Zone
# ------------------------------------------------------------

$AZ = aws ec2 describe-instances `
    --instance-ids $INSTANCE_ID `
    --region $REGION `
    --query "Reservations[0].Instances[0].Placement.AvailabilityZone" `
    --output text

Write-Host "Availability Zone: $AZ"

# ------------------------------------------------------------
# Step 3 - Check whether the EBS volume already exists
# ------------------------------------------------------------

$EXISTING_VOLUME_ID = aws ec2 describe-volumes `
    --region $REGION `
    --filters `
        "Name=tag:Name,Values=$VOLUME_NAME" `
        "Name=availability-zone,Values=$AZ" `
    --query "Volumes[0].VolumeId" `
    --output text

if (-not [string]::IsNullOrWhiteSpace($EXISTING_VOLUME_ID) -and $EXISTING_VOLUME_ID -ne "None") {

    $VOLUME_ID = $EXISTING_VOLUME_ID

    Write-Host "Existing EBS volume found: $VOLUME_ID"

}
else {

    # --------------------------------------------------------
    # Step 4 - Create encrypted gp3 EBS volume
    # --------------------------------------------------------

    Write-Host "Creating new 5-GB encrypted gp3 EBS volume..."

    $VOLUME_ID = aws ec2 create-volume `
        --availability-zone $AZ `
        --size 5 `
        --volume-type gp3 `
        --encrypted `
        --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=$VOLUME_NAME},{Key=Project,Value=$PROJECT},{Key=Environment,Value=$ENVIRONMENT},{Key=ManagedBy,Value=aws-cli}]" `
        --region $REGION `
        --query "VolumeId" `
        --output text

    Write-Host "Created EBS volume: $VOLUME_ID"

    # --------------------------------------------------------
    # Step 5 - Wait for EBS volume
    # --------------------------------------------------------

    aws ec2 wait volume-available `
        --volume-ids $VOLUME_ID `
        --region $REGION

    Write-Host "EBS volume is now available."
}

# ------------------------------------------------------------
# Step 6 - Check whether the volume is already attached
# ------------------------------------------------------------

$ATTACHED_INSTANCE_ID = aws ec2 describe-volumes `
    --volume-ids $VOLUME_ID `
    --region $REGION `
    --query "Volumes[0].Attachments[0].InstanceId" `
    --output text

if ($ATTACHED_INSTANCE_ID -eq $INSTANCE_ID) {

    Write-Host "EBS volume $VOLUME_ID is already attached to $INSTANCE_ID."

}
elseif (-not [string]::IsNullOrWhiteSpace($ATTACHED_INSTANCE_ID) -and $ATTACHED_INSTANCE_ID -ne "None") {

    Write-Error "EBS volume $VOLUME_ID is already attached to another instance: $ATTACHED_INSTANCE_ID"
    exit 1

}
else {

    # --------------------------------------------------------
    # Step 7 - Attach EBS volume
    # --------------------------------------------------------

    Write-Host "Attaching $VOLUME_ID to $INSTANCE_ID..."

    aws ec2 attach-volume `
        --volume-id $VOLUME_ID `
        --instance-id $INSTANCE_ID `
        --device /dev/sdf `
        --region $REGION

    aws ec2 wait volume-in-use `
        --volume-ids $VOLUME_ID `
        --region $REGION

    Write-Host "EBS volume successfully attached."
}

# ------------------------------------------------------------
# Step 8 - Display final configuration
# ------------------------------------------------------------

Write-Host ""
Write-Host "============================================================"
Write-Host "EBS Configuration"
Write-Host "============================================================"

aws ec2 describe-volumes `
    --volume-ids $VOLUME_ID `
    --region $REGION `
    --query "Volumes[0].{VolumeId:VolumeId,Size:Size,Type:VolumeType,Encrypted:Encrypted,State:State,AZ:AvailabilityZone,Attachments:Attachments}" `
    --output table

Write-Host ""
Write-Host "============================================================"
Write-Host "Inside the Linux EC2 instance"
Write-Host "============================================================"
Write-Host ""
Write-Host "1. Identify the attached device:"
Write-Host ""
Write-Host "   lsblk"
Write-Host ""
Write-Host "2. Confirm the new EBS device before formatting it."
Write-Host ""
Write-Host "3. Format it as XFS (ONLY if it is a new/empty volume):"
Write-Host ""
Write-Host "   sudo mkfs -t xfs /dev/nvme1n1"
Write-Host ""
Write-Host "4. Create the mount point:"
Write-Host ""
Write-Host "   sudo mkdir -p /data"
Write-Host ""
Write-Host "5. Mount the EBS volume:"
Write-Host ""
Write-Host "   sudo mount /dev/nvme1n1 /data"
Write-Host ""
Write-Host "6. Verify:"
Write-Host ""
Write-Host "   df -h"
Write-Host ""
Write-Host "IMPORTANT: The Linux device name may differ from /dev/nvme1n1."
Write-Host "Always verify with lsblk before running mkfs."
Write-Host ""
Write-Host "Step 6 completed successfully."