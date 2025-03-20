
# aws lambda invoke \
#     --function-name s3_trigger_github \
#     --log-type Tail \
#     --payload "$(echo -n '{"detail": {"bucket": {"name": "bucket-for-github-action-nn"}, "object": {"key": "example.csv"}}}' | base64)" \
#     response.json

# create s3 bucket
aws s3 mb s3://bucket-for-ml-predictions-nn

# set up folder structure
aws s3api put-object --bucket bucket-for-ml-predictions-nn --key models/
aws s3api put-object --bucket bucket-for-ml-predictions-nn --key data/
aws s3api put-object --bucket bucket-for-ml-predictions-nn --key data/dataset_1/

# list all files across all folders in the bucket
aws s3 ls s3://bucket-for-ml-predictions-nn --recursive

# create iam role for lambda
aws iam create-role \
    --role-name LambdaS3MLRole \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": { "Service": "lambda.amazonaws.com" },
                "Action": "sts:AssumeRole"
            }
        ]
    }'

# attach required policies
aws iam put-role-policy \
    --role-name LambdaS3MLRole \
    --policy-name S3ReadAccess \
    --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": ["s3:GetObject"],
                "Resource": [
                    "arn:aws:s3:::bucket-for-ml-predictions-nn/models/*",
                    "arn:aws:s3:::bucket-for-ml-predictions-nn/data/*"
                ]
            }
        ]
    }'

# allow Lambda to Write to CloudWatch Logs
aws iam attach-role-policy \
    --role-name LambdaS3MLRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole


# aws iam list-attached-role-policies --role-name LambdaS3MLRole
# aws iam get-role-policy --role-name LambdaS3MLRole --policy-name S3ReadAccess


# create a lambda function
mkdir lambda_ml && cd lambda_ml
pip install requests -t .
# put python script in lambda_ml folder
zip -r ../lambda_ml_function.zip .


aws lambda create-function \
    --function-name trigger_ml_workflow \
    --runtime python3.9 \
    --role arn:aws:iam::879381246381:role/LambdaS3MLRole \
    --handler lambda_function.lambda_handler \
    --timeout 30 \
    --memory-size 128 \
    --zip-file fileb://lambda_ml_function.zip

# get my token and pass it to lambda
personal_access_token=$(sed -n '2p' /mnt/c/Users/naz/Documents/'personal access token')

aws lambda update-function-configuration \
    --function-name trigger_ml_workflow \
    --environment "Variables={GITHUB_TOKEN=$personal_access_token}"

aws lambda get-function-configuration --function-name trigger_ml_workflow

