# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 10 - Create an encrypted Amazon RDS MySQL database in private database subnets using managed credentials.
# ============================================================

$ErrorActionPreference="Stop"
$Region=if($env:AWS_REGION){$env:AWS_REGION}else{"ap-south-1"}; $Project="aws-three-tier"; $VpcName="aws-three-tier-vpc"
$DbSgName="aws-three-tier-db-sg"; $SubA="aws-three-tier-db-subnet-a"; $SubB="aws-three-tier-db-subnet-b"; $Group="aws-three-tier-db-subnet-group"; $DbId="aws-three-tier-mysql"

$VpcId=aws ec2 describe-vpcs --region $Region --filters "Name=tag:Name,Values=$VpcName" --query "Vpcs[0].VpcId" --output text
$DbSg=aws ec2 describe-security-groups --region $Region --filters "Name=group-name,Values=$DbSgName" "Name=vpc-id,Values=$VpcId" --query "SecurityGroups[0].GroupId" --output text
$S1=aws ec2 describe-subnets --region $Region --filters "Name=tag:Name,Values=$SubA" --query "Subnets[0].SubnetId" --output text
$S2=aws ec2 describe-subnets --region $Region --filters "Name=tag:Name,Values=$SubB" --query "Subnets[0].SubnetId" --output text
foreach($x in @(@("VpcId",$VpcId),@("DbSg",$DbSg),@("S1",$S1),@("S2",$S2))){if([string]::IsNullOrWhiteSpace($x[1]) -or $x[1] -eq "None"){throw "$($x[0]) not found."}}

$GroupExists=aws rds describe-db-subnet-groups --region $Region --db-subnet-group-name $Group --query "DBSubnetGroups[0].DBSubnetGroupName" --output text 2>$null
if([string]::IsNullOrWhiteSpace($GroupExists) -or $GroupExists -eq "None"){aws rds create-db-subnet-group --region $Region --db-subnet-group-name $Group --db-subnet-group-description "Private DB subnets for $Project" --subnet-ids $S1 $S2 --tags "Key=Project,Value=$Project" "Key=ManagedBy,Value=aws-cli"}
$DbExists=aws rds describe-db-instances --region $Region --db-instance-identifier $DbId --query "DBInstances[0].DBInstanceIdentifier" --output text 2>$null
if([string]::IsNullOrWhiteSpace($DbExists) -or $DbExists -eq "None"){
    aws rds create-db-instance --region $Region --db-instance-identifier $DbId --engine mysql --db-instance-class db.t4g.micro --allocated-storage 20 --storage-type gp3 --storage-encrypted --db-name appdb --master-username adminuser --manage-master-user-password --vpc-security-group-ids $DbSg --db-subnet-group-name $Group --backup-retention-period 7 --no-publicly-accessible --tags "Key=Project,Value=$Project" "Key=Environment,Value=dev" "Key=ManagedBy,Value=aws-cli"
}
aws rds describe-db-instances --region $Region --db-instance-identifier $DbId --query "DBInstances[0].[DBInstanceStatus,Endpoint.Address,Endpoint.Port]" --output table
