#!/usr/bin/env python3
import requests
import os
import json
from dotenv import load_dotenv

load_dotenv()

api_key = os.getenv('N8N_API_KEY')
base_url = 'https://n8n-agent-gdctd7f5e6e0a5br.eastus2-01.azurewebsites.net/api/v1'
headers = {'X-N8N-API-KEY': api_key}

# Check credentials
print("=== EXISTING CREDENTIALS ===")
response = requests.get(f'{base_url}/credentials', headers=headers)
if response.status_code == 200:
    creds = response.json().get('data', [])
    for cred in creds:
        print(f"• {cred.get('name', 'Unknown')} ({cred.get('type', 'Unknown')})")
else:
    print(f"Error fetching credentials: {response.status_code}")

# Check working workflow credentials
print("\n=== WORKING WORKFLOW CREDENTIALS ===")
response = requests.get(f'{base_url}/workflows/2gJTTUqDkKeR2ClL', headers=headers)
if response.status_code == 200:
    workflow = response.json()
    for node in workflow.get('nodes', []):
        if 'credentials' in node:
            print(f"Node: {node['name']}")
            for cred_type, cred_info in node['credentials'].items():
                print(f"  {cred_type}: {cred_info}")
