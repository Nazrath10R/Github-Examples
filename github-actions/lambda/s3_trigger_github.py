import json
import boto3
import requests
import os

GITHUB_REPO = "Nazrath10R/Github-Examples"
GITHUB_TOKEN = os.environ["GITHUB_TOKEN"]
GITHUB_WORKFLOW = "s3_fetch_process.yml"

def lambda_handler(event, context):
    # Extract S3 bucket and file details
    s3_info = event['Records'][0]['s3']
    bucket_name = s3_info['bucket']['name']
    object_key = s3_info['object']['key']

    # Trigger GitHub Actions workflow
    url = f"https://api.github.com/repos/{GITHUB_REPO}/actions/workflows/{GITHUB_WORKFLOW}/dispatches"
    headers = {"Authorization": f"Bearer {GITHUB_TOKEN}", "Accept": "application/vnd.github.v3+json"}
    payload = {"ref": "main", "inputs": {"bucket": bucket_name, "file": object_key}}

    response = requests.post(url, headers=headers, json=payload)

    return {
        "statusCode": response.status_code,
        "body": response.text
    }
