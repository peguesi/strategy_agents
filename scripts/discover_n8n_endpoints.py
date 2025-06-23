#!/usr/bin/env python3
import asyncio
import httpx
import json

async def discover_n8n_endpoints():
    url = "https://n8n-agent-gdctd7f5e6e0a5br.eastus2-01.azurewebsites.net"
    api_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI3MWM2ZjRiNC00ZTIwLTQ4YjUtODkyMi02NzUxNjMxMzJkZmEiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzUwMDc5MjQwfQ.1Tf5YHdlDrMObOM8fOw1bE19ltNfgo3ZVMJCITJejVs"
    
    headers = {
        'X-N8N-API-KEY': api_key,
        'Content-Type': 'application/json'
    }
    
    print("🔍 Discovering n8n API endpoints...")
    print()
    
    async with httpx.AsyncClient(timeout=30) as client:
        try:
            # First get a workflow to test with
            response = await client.get(f'{url}/api/v1/workflows', headers=headers)
            workflows = response.json().get("data", [])
            test_workflow = workflows[0] if workflows else None
            
            if not test_workflow:
                print("❌ No workflows found to test with")
                return
                
            wf_id = test_workflow["id"]
            wf_name = test_workflow["name"]
            print(f"Testing with workflow: {wf_name} ({wf_id})")
            print()
            
            # Test various endpoint patterns found in n8n docs and GitHub issues
            test_endpoints = [
                # Execution endpoints
                ("POST", f"workflows/{wf_id}/activate", {}),
                ("POST", f"workflows/{wf_id}/run", {}),
                ("POST", f"workflows/{wf_id}/execute", {}),
                ("POST", f"workflows/{wf_id}/trigger", {}),
                ("POST", f"workflows/run", {"workflowId": wf_id}),
                ("POST", f"executions/run", {"workflowId": wf_id}),
                ("POST", f"executions", {"workflowId": wf_id}),
                
                # Information endpoints
                ("GET", f"workflows/{wf_id}/executions", None),
                ("GET", f"workflows/{wf_id}/activity", None),
                ("GET", f"executions/active", None),
                ("GET", f"executions", None),
                
                # Other endpoints
                ("GET", "credentials", None),
                ("GET", "nodes", None),
                ("GET", "node-types", None),
                ("GET", "active", None),
                ("GET", "health", None),
                ("GET", "metrics", None),
            ]
            
            working_endpoints = []
            
            for method, endpoint, data in test_endpoints:
                try:
                    if method == "GET":
                        response = await client.get(f'{url}/api/v1/{endpoint}', headers=headers)
                    else:
                        response = await client.post(f'{url}/api/v1/{endpoint}', headers=headers, json=data or {})
                    
                    status_emoji = "✅" if response.status_code < 400 else "❌"
                    print(f"{status_emoji} {method} /api/v1/{endpoint} -> {response.status_code}")
                    
                    if response.status_code < 400:
                        working_endpoints.append((method, endpoint, response.status_code))
                        
                        # For successful executions, show the response
                        if "execute" in endpoint or "run" in endpoint or "trigger" in endpoint:
                            try:
                                result = response.json()
                                print(f"   🎯 Execution started: {result.get('id', 'No ID')}")
                            except:
                                print(f"   📄 Response: {response.text[:100]}")
                    else:
                        print(f"      {response.text[:100]}")
                        
                except Exception as e:
                    print(f"❌ {method} /api/v1/{endpoint} -> Exception: {str(e)[:50]}")
                    
            print()
            print("🎯 WORKING ENDPOINTS SUMMARY:")
            print("=" * 40)
            for method, endpoint, status in working_endpoints:
                print(f"✅ {method} /api/v1/{endpoint} ({status})")
            
            # Test manual trigger if we found a working execution endpoint
            working_exec_endpoints = [(m,e,s) for m,e,s in working_endpoints if any(x in e for x in ['execute', 'run', 'trigger', 'activate'])]
            if working_exec_endpoints:
                print()
                print("🚀 Testing manual execution...")
                method, endpoint, _ = working_exec_endpoints[0]
                
                if "activate" in endpoint:
                    print(f"   Skipping activation test (would change workflow state)")
                else:
                    try:
                        if method == "POST":
                            if endpoint == "executions" or "run" in endpoint:
                                exec_data = {"workflowId": wf_id}
                            else:
                                exec_data = {}
                            response = await client.post(f'{url}/api/v1/{endpoint}', headers=headers, json=exec_data)
                            print(f"   Execution response: {response.status_code}")
                            if response.status_code < 400:
                                result = response.json()
                                print(f"   🎯 Success! Execution ID: {result.get('id', 'Unknown')}")
                            else:
                                print(f"   ❌ {response.text[:100]}")
                    except Exception as e:
                        print(f"   ❌ Exception: {e}")
                        
        except Exception as e:
            print(f"❌ Discovery failed: {e}")

if __name__ == "__main__":
    asyncio.run(discover_n8n_endpoints())
