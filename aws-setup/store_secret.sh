#!/bin/bash

# Define Variables
SECRET_NAME="GitHub_Actions_Token"
GITHUB_TOKEN="your-github-token"

# Store GitHub Token in AWS Secrets Manager
aws secretsmanager create-secret \
    --name $SECRET_NAME \
    --secret-string "{\"GITHUB_TOKEN\":\"$GITHUB_TOKEN\"}"

echo "✅ GitHub Token Stored in AWS Secrets Manager"
