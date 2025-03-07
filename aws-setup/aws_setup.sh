# install aws cli
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install

# /usr/local/bin/aws --version

mkdir aws-setup
cd aws-setup

aws configure

aws lambda list-functions --region eu-west-2 --query "Functions[*].FunctionArn"


aws lambda create-function \
    --function-name trigger-github-actions \
    --runtime python3.9 \
    --role arn:aws:iam::879381246381:role/LambdaExecutionRole \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://lambda_function.zip \
    --region eu-west-2
