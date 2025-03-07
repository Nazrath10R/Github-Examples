#!/bin/bash

# aws iam create-role \
#     --role-name EventBridgeInvokeLambdaRole \
#     --assume-role-policy-document file://eventbridge-lambda-policy.json \
#     --region eu-west-2

# aws iam attach-role-policy \
#     --role-name EventBridgeInvokeLambdaRole \
#     --policy-arn arn:aws:iam::aws:policy/AWSLambdaInvokeFullAccess

# Define Variables
RULE_NAME="TriggerGitHubActions"
BUCKET_NAME="bucket-for-github-action-nn"
LAMBDA_ARN="arn:aws:lambda:eu-west-2:123456789012:function:trigger-github-actions"

# Create EventBridge Rule
aws events put-rule \
    --name $RULE_NAME \
    --event-pattern '{
      "source": ["aws.s3"],
      "detail-type": ["Object Created"],
      "detail": {
        "bucket": {
          "name": ["'"$BUCKET_NAME"'"]
        },
        "object": {
          "key": [{
            "prefix": "data/"
          }]
        }
      }
    }' \
    --region eu-west-2

# Attach Lambda as Target
aws events put-targets --rule $RULE_NAME --targets "Id"="1","Arn"="$LAMBDA_ARN","RoleArn"="arn:aws:iam::879381246381:role/EventBridgeInvokeLambdaRole"

echo "✅ AWS EventBridge Rule Created: $RULE_NAME"