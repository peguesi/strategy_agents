#!/usr/bin/env python3
"""
Simple n8n workflow fetcher using the working API configuration
"""
import requests

def fetch_workflows():
    """Fetch workflows from n8n using the correct authentication"""
    
    # Configuration from environment variables
    import os
    n8n_url = os.getenv('N8N_URL', 'https://n8n-agent-gdctd7f5e6e0a5br.eastus2-01.azurewebsites.net')
    api_key = os.getenv('N8N_API_KEY')
    
    if not api_key:
        print("❌ Error: N8N_API_KEY environment variable is required")
        return []
    
    headers = {
        "X-N8N-API-KEY": api_key,
        "Content-Type": "application/json",
        "Accept": "application/json"
    }
    
    try:
        print("🔍 Fetching workflows from n8n...")
        response = requests.get(f"{n8n_url}/api/v1/workflows", headers=headers, timeout=10)
        
        if response.status_code == 200:
            workflows = response.json()
            print(f"✅ Successfully connected to n8n!")
            print(f"📋 Found {len(workflows.get('data', []))} workflows:")
            
            for workflow in workflows.get('data', []):
                status = "🟢 Active" if workflow.get('active') else "🔴 Inactive"
                print(f"  • {workflow.get('name', 'Unnamed')} - {status}")
                print(f"    ID: {workflow.get('id')}")
                print(f"    Updated: {workflow.get('updatedAt')}")
                print()
            
            return workflows.get('data', [])
            
        else:
            print(f"❌ API Error: {response.status_code}")
            print(f"Response: {response.text}")
            return []
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return []

if __name__ == "__main__":
    workflows = fetch_workflows()
