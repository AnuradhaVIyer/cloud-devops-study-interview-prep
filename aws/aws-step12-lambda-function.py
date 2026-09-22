# ============================================================
# Author:      Anuradha Iyer
# Date:        2026-09-22
# Description: Step 12 - Lambda handler that writes an application event to DynamoDB.
# ============================================================

import json
import os
import boto3

table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])

def lambda_handler(event, context):
    item_id = event.get("id") or context.aws_request_id
    item = {
        "Id": str(item_id),
        "Event": json.dumps(event, default=str),
    }
    table.put_item(Item=item)
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Event stored", "id": item["Id"]})
    }
