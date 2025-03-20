import json
import requests
import os

GITHUB_REPO = "Nazrath10R/Github-Examples/"
GITHUB_WORKFLOW = "ml_prediction_workflow.yml"
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")

def lambda_handler(event, context):
    print("🚀 Lambda triggered!")
    
    url = f"https://api.github.com/repos/{GITHUB_REPO}/actions/workflows/{GITHUB_WORKFLOW}/dispatches"
    headers = {
        "Authorization": f"Bearer {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }
    payload = {"ref": "main"}

    response = requests.post(url, headers=headers, json=payload)
    print(f"📡 GitHub API Response: {response.status_code} - {response.text}")

    return {"statusCode": response.status_code, "body": response.text}
