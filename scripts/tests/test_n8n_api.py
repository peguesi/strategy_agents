#!/usr/bin/env python3
import asyncio
import httpx
import os

async def test_n8n_api():
    # Load from environment
    url = "https://n8n-agent-gdctd7f5e6e0a5br.eastus2-01.azurewebsites.net"
    api_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI3MWM2ZjRiNC00ZTIwLTQ4YjUtODkyMi02NzUxNjMxMzJkZmEiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzUwMDc5MjQwfQ.1Tf5YHdlDrMObOM8fOw1bE19ltNfgo3ZVMJCITJejVs"
    
    headers = {
        'X-N8N-API-KEY': api_key,
        'Content-Type': 'application/json'
    }
    
    print(f'Testing: {url}')
    print(f'API Key: {api_key[:20]}...')
    print()
    
    async with httpx.AsyncClient(timeout=30) as client:
        try:
            # Test workflows endpoint
            print("Testing workflows endpoint...")
            response = await client.get(f'{url}/api/v1/workflows', headers=headers)
            print(f'Workflows status: {response.status_code}')
            if response.status_code == 200:
                data = response.json()
                workflows = data.get("data", [])
                print(f'Found {len(workflows)} workflows')
                for wf in workflows:
                    print(f'  - {wf.get("name")} ({wf.get("id")}) - {"Active" if wf.get("active") else "Inactive"}')
                    
                # Test execution with first workflow
                if workflows:
                    test_wf = workflows[0]
                    wf_id = test_wf["id"]
                    print(f'\\nTesting execution endpoints with workflow: {wf_id}')
                    
                    # Try different execution endpoints
                    exec_endpoints = [
                        f'/api/v1/workflows/{wf_id}/execute',
                        f'/api/v1/workflows/{wf_id}/run', 
                        f'/api/v1/executions',
                        f'/api/v1/workflows/{wf_id}/test'
                    ]
                    
                    for endpoint in exec_endpoints:
                        try:
                            if endpoint == f'/api/v1/executions':
                                exec_data = {"workflowId": wf_id}
                            else:
                                exec_data = {}
                                
                            print(f'Testing: {endpoint}')
                            response = await client.post(f'{url}{endpoint}', headers=headers, json=exec_data)
                            print(f'  Status: {response.status_code}')
                            if response.status_code < 400:
                                print(f'  ✅ SUCCESS!')
                                break
                            else:
                                print(f'  ❌ {response.text[:100]}')
                        except Exception as e:
                            print(f'  ❌ Exception: {e}')
                            
            else:
                print(f'Error: {response.text[:200]}')
                
            print()
            # Test executions endpoint  
            print("Testing executions list endpoint...")
            response = await client.get(f'{url}/api/v1/executions?limit=5', headers=headers)
            print(f'Executions status: {response.status_code}')
            if response.status_code == 200:
                data = response.json()
                execs = data.get("data", [])
                print(f'Found {len(execs)} recent executions')
                for ex in execs:
                    print(f'  - {ex.get("id")[:12]} - {ex.get("status")} - {ex.get("startedAt", "")[:19]}')
            else:
                print(f'Executions error: {response.text[:200]}')
                
        except Exception as e:
            print(f'Connection error: {e}')

if __name__ == "__main__":
    asyncio.run(test_n8n_api())
