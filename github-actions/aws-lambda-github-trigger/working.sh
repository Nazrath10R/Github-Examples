aws ssm get-parameter \
    --name "/github/token" \
    --with-decryption \
    --region eu-west-2

dos2unix lambda/run.sh lambda/bootstrap lambda/build.sh
zip lambda-bash-custom-runtime.zip bootstrap run.sh
unzip -l lambda-bash-custom-runtime.zip
# Should show bootstrap and run.sh at the root

aws lambda update-function-code \
  --function-name TriggerGitHubActions \
  --zip-file fileb://lambda-bash-custom-runtime.zip \
  --region eu-west-2

aws lambda invoke \
    --function-name TriggerGitHubActions \
    --payload '{"hello":"world"}' \
    --cli-binary-format raw-in-base64-out \
    --region eu-west-2 \
    out.json
cat out.json



aws logs tail /aws/lambda/TriggerGitHubActions --follow --region eu-west-2
