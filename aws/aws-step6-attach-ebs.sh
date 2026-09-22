#!/bin/bash

# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 6 - Create and attach an encrypted EBS
#              gp3 volume to the existing 3-tier EC2 instance.
# ============================================================

set -euo pipefail

REGION="${AWS_REGION:-ap-south-1}"

PROJECT="aws-three-tier"
ENVIRONMENT="dev"
INSTANCE_NAME="aws-three-tier-web-instance"
VOLUME_NAME="aws-three-tier-ebs-data"

echo "============================================================"
echo "AWS Three-Tier Architecture - Step 6: Attach EBS"
echo "============================================================"
echo "Region       : $REGION"
echo "Project      : $PROJECT"
echo "Environment  : $ENVIRONMENT"
echo "Instance     : $INSTANCE_NAME"
echo "EBS Volume   : $VOLUME_NAME"
echo "============================================================"

# ------------------------------------------------------------
# Step 1 - Discover the EC2 instance created in Step 5
# ------------------------------------------------------------

INSTANCE_ID=$(aws ec2 describe-instances \
    --region "$REGION" \
    --filters \
        "Name=tag:Name,Values=$INSTANCE_NAME" \
        "Name=instance-state-name,Values=pending,running,stopped" \
    --query 'Reservations[].Instances[0].InstanceId' \
    --output text)

if [[ -z "$INSTANCE_ID" || "$INSTANCE_ID" == "None" ]]; then
    echo "ERROR: EC2 instance '$INSTANCE_NAME' was not found."
    echo "Run Step 5 first."
    exit 1
fi

echo "EC2 Instance ID: $INSTANCE_ID"

# ------------------------------------------------------------
# Step 2 - Discover Availability Zone
# ------------------------------------------------------------

AZ=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --region "$REGION" \
    --query 'Reservations[0].Instances[0].Placement.AvailabilityZone' \
    --output text)

echo "Availability Zone: $AZ"

# ------------------------------------------------------------
# Step 3 - Check whether the EBS volume already exists
# ------------------------------------------------------------

EXISTING_VOLUME_ID=$(aws ec2 describe-volumes \
    --region "$REGION" \
    --filters \
        "Name=tag:Name,Values=$VOLUME_NAME" \
        "Name=availability-zone,Values=$AZ" \
    --query 'Volumes[0].VolumeId' \
    --output text)

if [[ -n "$EXISTING_VOLUME_ID" && "$EXISTING_VOLUME_ID" != "None" ]]; then

    VOLUME_ID="$EXISTING_VOLUME_ID"

    echo "Existing EBS volume found: $VOLUME_ID"

else

    # --------------------------------------------------------
    # Step 4 - Create encrypted gp3 EBS volume
    # --------------------------------------------------------

    echo "Creating new 5-GB encrypted gp3 EBS volume..."

    VOLUME_ID=$(aws ec2 create-volume \
        --availability-zone "$AZ" \
        --size 5 \
        --volume-type gp3 \
        --encrypted \
        --tag-specifications \
            "ResourceType=volume,Tags=[
                {Key=Name,Value=$VOLUME_NAME},
                {Key=Project,Value=$PROJECT},
                {Key=Environment,Value=$ENVIRONMENT},
                {Key=ManagedBy,Value=aws-cli}
            ]" \
        --region "$REGION" \
        --query 'VolumeId' \
        --output text)

    echo "Created EBS volume: $VOLUME_ID"

    # --------------------------------------------------------
    # Step 5 - Wait for EBS volume
    # --------------------------------------------------------

    aws ec2 wait volume-available \
        --volume-ids "$VOLUME_ID" \
        --region "$REGION"

    echo "EBS volume is now available."
fi

# ------------------------------------------------------------
# Step 6 - Check whether the volume is already attached
# ------------------------------------------------------------

ATTACHED_INSTANCE_ID=$(aws ec2 describe-volumes \
    --volume-ids "$VOLUME_ID" \
    --region "$REGION" \
    --query 'Volumes[0].Attachments[0].InstanceId' \
    --output text)

if [[ "$ATTACHED_INSTANCE_ID" == "$INSTANCE_ID" ]]; then

    echo "EBS volume $VOLUME_ID is already attached to $INSTANCE_ID."

elif [[ -n "$ATTACHED_INSTANCE_ID" && "$ATTACHED_INSTANCE_ID" != "None" ]]; then

    echo "ERROR: EBS volume $VOLUME_ID is already attached to another instance:"
    echo "$ATTACHED_INSTANCE_ID"
    exit 1

else

    # --------------------------------------------------------
    # Step 7 - Attach EBS volume
    # --------------------------------------------------------

    echo "Attaching $VOLUME_ID to $INSTANCE_ID..."

    aws ec2 attach-volume \
        --volume-id "$VOLUME_ID" \
        --instance-id "$INSTANCE_ID" \
        --device /dev/sdf \
        --region "$REGION"

    aws ec2 wait volume-in-use \
        --volume-ids "$VOLUME_ID" \
        --region "$REGION"

    echo "EBS volume successfully attached."
fi

# ------------------------------------------------------------
# Step 8 - Display final configuration
# ------------------------------------------------------------

echo
echo "============================================================"
echo "EBS Configuration"
echo "============================================================"

aws ec2 describe-volumes \
    --volume-ids "$VOLUME_ID" \
    --region "$REGION" \
    --query 'Volumes[0].{
        VolumeId:VolumeId,
        Size:Size,
        Type:VolumeType,
        Encrypted:Encrypted,
        State:State,
        AZ:AvailabilityZone,
        Attachments:Attachments
    }' \
    --output table

echo
echo "============================================================"
echo "Inside the Linux EC2 instance"
echo "============================================================"
echo
echo "1. Identify the attached device:"
echo
echo "   lsblk"
echo
echo "2. Confirm the new EBS device before formatting it."
echo
echo "3. Format it as XFS (ONLY if it is a new/empty volume):"
echo
echo "   sudo mkfs -t xfs /dev/nvme1n1"
echo
echo "4. Create the mount point:"
echo
echo "   sudo mkdir -p /data"
echo
echo "5. Mount the EBS volume:"
echo
echo "   sudo mount /dev/nvme1n1 /data"
echo
echo "6. Verify:"
echo
echo "   df -h"
echo
echo "IMPORTANT: The Linux device name may differ from /dev/nvme1n1."
echo "Always verify with lsblk before running mkfs."
echo
echo "Step 6 completed successfully."