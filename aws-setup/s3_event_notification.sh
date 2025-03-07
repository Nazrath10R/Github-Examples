#!/bin/bash

# Define Variables
BUCKET_NAME="bucket-for-github-action-nn"

# Apply S3 Event Notification
aws s3api put-bucket-notification-configuration \
    --bucket $BUCKET_NAME \
    --notification-configuration '{
      "EventBridgeConfiguration": {}
    }'

echo "✅ S3 Event Notification Created for bucket: $BUCKET_NAME"