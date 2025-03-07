#!/bin/bash

# Define Variables
ROLE_NAME="LambdaExecutionRole"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:123456789012:secret:GitHub_Actions_Token"

# Attach SecretsManager Read Policy
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/SecretsManagerReadWrite

# Allow Lambda to access Secrets Manager
aws secretsmanager put-resource-policy \
    --secret-id $SECRET_ARN \
    --resource-policy '{
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {"AWS": "arn:aws:iam::123456789012:role/LambdaExecutionRole"},
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "*"
        }]
    }'

echo "✅ Lambda Permission to Access Secrets Granted"
