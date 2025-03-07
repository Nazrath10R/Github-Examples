import json
import requests
import os

GITHUB_REPO = "your-username/your-repo-name"
GITHUB_WORKFLOW = "s3_data_fetch.yaml"  # Your GitHub Actions workflow file
GITHUB_TOKEN = os.environ['GITHUB_TOKEN']  # Stored in AWS Secrets Manager

def lambda_handler(event, context):
    print("Event received:", json.dumps(event, indent=2))

    if "Records" in event:
        for record in event["Records"]:
            bucket_name = record["s3"]["bucket"]["name"]
            object_key = record["s3"]["object"]["key"]
            print(f"New file uploaded: s3://{bucket_name}/{object_key}")

            # Trigger GitHub Actions
            github_api_url = f"https://api.github.com/repos/{GITHUB_REPO}/actions/workflows/{GITHUB_WORKFLOW}/dispatches"
            headers = {
                "Accept": "application/vnd.github.v3+json",
                "Authorization": f"Bearer {GITHUB_TOKEN}"
            }
            data = {
                "ref": "main",
                "inputs": {
                    "bucket": bucket_name,
                    "file": object_key
                }
            }

            response = requests.post(github_api_url, headers=headers, json=data)
            print(f"GitHub Actions trigger response: {response.status_code} {response.text}")

    return {
        "statusCode": 200,
        "body": json.dumps("Event processed and GitHub Actions triggered successfully!")
    }
