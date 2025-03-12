# # 1) Create function (if not exists)
# aws lambda create-function \
#   --function-name "TriggerGitHubActions" \
#   --runtime provided.al2 \
#   --role "arn:aws:iam::879381246381:role/LambdaGitHubTriggerRole" \
#   --handler "bootstrap" \
#   --zip-file "fileb://lambda/lambda-bash-custom-runtime.zip" \
#   --layers "arn:aws:lambda:us-east-1:879381246381:layer:awscli-layer:<VERSION>" \
#   --environment "Variables={GITHUB_TOKEN=<YOUR_GH_TOKEN>}" \
#   --region eu-west-2

# # 2) Or update function code (if function already exists)
# aws lambda update-function-code \
#   --function-name "TriggerGitHubActions" \
#   --zip-file "fileb://lambda/lambda-bash-custom-runtime.zip"

# # 3) (Optional) update function configuration
# aws lambda update-function-configuration \
#   --function-name "TriggerGitHubActions" \
#   --environment "Variables={GITHUB_TOKEN=<YOUR_GH_TOKEN>}"


# aws lambda create-function \
#     --function-name "TriggerGitHubActions" \
#     --runtime provided.al2 \
#     --role "arn:aws:iam::879381246381:role/LambdaGitHubTriggerRole" \
#     --handler "bootstrap" \
#     --zip-file "fileb://lambda-bash-custom-runtime.zip" \
#     --region eu-west-2


# aws lambda invoke \
#     --function-name "TriggerGitHubActions" \
#     --payload '{}' \
#     --cli-binary-format raw-in-base64-out \
#     --region eu-west-2 \
#     out.json

