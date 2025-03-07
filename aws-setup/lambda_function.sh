#!/bin/bash

# Define Variables
LAMBDA_NAME="trigger-github-actions"
ZIP_FILE="lambda_function.zip"
ROLE_NAME="LambdaExecutionRole"

# Create IAM Role
aws iam create-role --role-name $ROLE_NAME --assume-role-policy-document file://trust-policy.json

# Attach Lambda Execution Policy
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# Create a simple Lambda function
echo 'import json
import urllib3
import os

def lambda_handler(event, context):
    http = urllib3.PoolManager()
    url = "https://api.github.com/repos/your-github-username/your-repo-name/actions/workflows/s3_data_fetch.yaml/dispatches"
    headers = {
        "Accept": "application/vnd.github.v3+json",
        "Authorization": "Bearer " + os.getenv("GITHUB_TOKEN"),
        "Content-Type": "application/json"
    }
    data = json.dumps({"ref": "main"})
    response = http.request("POST", url, body=data, headers=headers)
    return {"statusCode": response.status, "body": response.data.decode("utf-8")}' > lambda_function.py

# Zip the function
zip $ZIP_FILE lambda_function.py

# Deploy Lambda
aws lambda create-function \
    --function-name $LAMBDA_NAME \
    --runtime python3.9 \
    --role arn:aws:iam::123456789012:role/$ROLE_NAME \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://$ZIP_FILE

echo "✅ AWS Lambda Function Created"
