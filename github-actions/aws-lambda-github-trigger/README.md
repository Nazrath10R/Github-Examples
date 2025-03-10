# AWS Lambda to GitHub Actions Trigger

## Overview
This project sets up an AWS Lambda function that triggers a GitHub Actions workflow using an HTTP request. 
It uses the `provided.al2` custom runtime for a Bash-based Lambda.

## Directory Structure
- `lambda/`: Contains the Lambda's `bootstrap` and `run.sh` scripts, plus a `build.sh` packaging script.
- `layer/`: Scripts to build and publish an AWS CLI layer (optional).
- `cloudformation/`: Contains the IAM role setup for the Lambda (optional).
- `.github/workflows/`: The GitHub Actions workflow file.

## Setup Guide
1. Deploy IAM role ...
2. Build AWS CLI layer ...
3. Build and Deploy Lambda ...
4. Configure environment variables ...
5. Verify in CloudWatch logs ...
