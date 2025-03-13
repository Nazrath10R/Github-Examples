aws lambda add-permission \
    --function-name s3_trigger_github \
    --statement-id AllowEventBridgeInvoke \
    --action "lambda:InvokeFunction" \
    --principal events.amazonaws.com \
    --source-arn arn:aws:events:eu-west-2:879381246381:rule/S3FileUploadRule



aws lambda invoke \
    --function-name s3_trigger_github \
    --log-type Tail \
    --payload "$(echo -n '{"detail": {"bucket": {"name": "bucket-for-github-action-nn"}, "object": {"key": "example.csv"}}}' | base64)" \
    response.json


aws lambda invoke \
    --function-name s3_trigger_github \
    --log-type Tail \
    --payload "$(echo -n '{"detail": {"bucket": {"name": "bucket-for-github-action-nn"}, "object": {"key": "example.csv"}}}' | base64)" \
    response.json
