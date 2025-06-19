#!/usr/bin/env python3
"""
Quick test script to verify n8n API connection
"""
import requests
import json

# Configuration
N8N_URL = "https://n8n-agent-gdctd7f5e6e0a5br.eastus2-01.azurewebsites.net"
API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI3MWM2ZjRiNC00ZTIwLTQ4YjUtODkyMi02NzUxNjMxMzJkZmEiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzUwMDc5MjQwfQ.1Tf5YHdlDrMObOM8fOw1bE19ltNfgo3ZVMJCITJejVs"

# Headers
headers = {
    "X-N8N-API-KEY": API_KEY,
    "Content-Type": "application/json",
    "Accept": "application/json"
}

def test_connection():
    """Test basic n8n API connection"""
    print("Testing n8n API connection...")
    print(f"URL: {N8N_URL}")
    
    # Test basic connectivity
    try:
        print("\n1. Testing basic connectivity...")
        response = requests.get(f"{N8N_URL}/api/v1/workflows", headers=headers, timeout=10)
        print(f"Status Code: {response.status_code}")
        print(f"Response Headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            workflows = response.json()
            print(f"✅ API Connection Successful!")
            print(f"Found {len(workflows.get('data', []))} workflows")
            
            # List workflows
            for workflow in workflows.get('data', [])[:3]:  # Show first 3
                print(f"  - {workflow.get('name', 'Unnamed')} (ID: {workflow.get('id')}) - {'Active' if workflow.get('active') else 'Inactive'}")
        else:
            print(f"❌ API Error: {response.status_code}")
            print(f"Response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Connection Error: {e}")
    except Exception as e:
        print(f"❌ Unexpected Error: {e}")

if __name__ == "__main__":
    test_connection()
