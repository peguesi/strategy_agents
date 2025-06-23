#!/usr/bin/env python3
import asyncio
import httpx
import json

async def test_alternative_execution():
    url = "https://n8n-agent-gdctd7f5e6e0a5br.eastus2-01.azurewebsites.net"
    api_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI3MWM2ZjRiNC00ZTIwLTQ4YjUtODkyMi02NzUxNjMxMzJkZmEiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzUwMDc5MjQwfQ.1Tf5YHdlDrMObOM8fOw1bE19ltNfgo3ZVMJCITJejVs"
    
    headers = {
        'X-N8N-API-KEY': api_key,
        'Content-Type': 'application/json'
    }
    
    print("🔍 Testing alternative execution approaches...")
    print()
    
    async with httpx.AsyncClient(timeout=30) as client:
        try:
            # Get workflows
            response = await client.get(f'{url}/api/v1/workflows', headers=headers)
            workflows = response.json().get("data", [])
            
            # Look for an active workflow with a manual trigger
            active_workflows = [w for w in workflows if w.get("active")]
            if active_workflows:
                test_wf = active_workflows[0]  # Use active workflow
            else:
                test_wf = workflows[0] if workflows else None
                
            if not test_wf:
                print("❌ No workflows found")
                return
                
            wf_id = test_wf["id"]
            wf_name = test_wf["name"]
            is_active = test_wf.get("active", False)
            
            print(f"Testing with: {wf_name} ({wf_id}) - {'ACTIVE' if is_active else 'INACTIVE'}")
            print()
            
            # Get detailed workflow info to understand structure
            response = await client.get(f'{url}/api/v1/workflows/{wf_id}', headers=headers)
            workflow_details = response.json()
            
            nodes = workflow_details.get("nodes", [])
            print(f"Workflow has {len(nodes)} nodes:")
            
            trigger_nodes = []
            for node in nodes:
                node_type = node.get("type", "")
                node_name = node.get("name", "")
                print(f"  - {node_name}: {node_type}")
                
                if "trigger" in node_type.lower() or "webhook" in node_type.lower():
                    trigger_nodes.append(node)
            
            print(f"\\nFound {len(trigger_nodes)} trigger nodes")
            
            # Try webhook-style execution if webhook trigger exists
            webhook_triggers = [n for n in trigger_nodes if "webhook" in n.get("type", "").lower()]
            if webhook_triggers:
                print("\\n🌐 Testing webhook trigger approach...")
                webhook_node = webhook_triggers[0]
                webhook_params = webhook_node.get("parameters", {})
                webhook_id = webhook_params.get("webhookId") or webhook_params.get("path")
                
                if webhook_id:
                    webhook_url = f"{url}/webhook/{webhook_id}"
                    print(f"Trying webhook: {webhook_url}")
                    try:
                        response = await client.post(webhook_url, json={"test": True})
                        print(f"  Webhook response: {response.status_code}")
                        if response.status_code < 400:
                            print(f"  ✅ Webhook execution successful!")
                        else:
                            print(f"  ❌ {response.text[:100]}")
                    except Exception as e:
                        print(f"  ❌ Webhook error: {e}")
            
            # Try different API versions
            print("\\n🔢 Testing different API versions...")
            api_versions = ["v1", "v2", "v3", ""]
            for version in api_versions:
                try:
                    version_path = f"api/{version}/" if version else "api/"
                    test_url = f"{url}/{version_path}workflows/{wf_id}/execute"
                    response = await client.post(test_url, headers=headers, json={})
                    print(f"  {version_path}execute -> {response.status_code}")
                    if response.status_code < 400:
                        print(f"    ✅ Found working endpoint!")
                        break
                except Exception as e:
                    print(f"  {version_path}execute -> Error: {str(e)[:50]}")
            
            # Check if we can manually trigger execution by updating the workflow
            print("\\n⚡ Testing manual execution via workflow update...")
            if not is_active:
                print("  Workflow is inactive, trying to activate first...")
                try:
                    # Try to activate the workflow
                    response = await client.patch(f'{url}/api/v1/workflows/{wf_id}', 
                                                headers=headers, 
                                                json={"active": True})
                    print(f"  Activation attempt: {response.status_code}")
                    if response.status_code < 400:
                        print(f"  ✅ Workflow activated!")
                    else:
                        print(f"  ❌ Activation failed: {response.text[:100]}")
                except Exception as e:
                    print(f"  ❌ Activation error: {e}")
            
            # Try to find execution via different paths
            print("\\n📊 Checking execution methods...")
            
            # Method 1: Check if executions can be created directly
            try:
                exec_data = {
                    "workflowData": workflow_details,
                    "mode": "manual",
                    "startNodes": [],
                    "destinationNode": None,
                    "runData": {}
                }
                response = await client.post(f'{url}/api/v1/executions', headers=headers, json=exec_data)
                print(f"  Direct execution creation: {response.status_code}")
                if response.status_code < 400:
                    result = response.json()
                    print(f"  ✅ Execution created: {result.get('id', 'Unknown')}")
                else:
                    print(f"  ❌ {response.text[:100]}")
            except Exception as e:
                print(f"  Direct execution error: {e}")
            
            # Method 2: Try with different HTTP methods
            for method in ["POST", "PUT", "PATCH"]:
                try:
                    endpoint = f"{url}/api/v1/workflows/{wf_id}"
                    if method == "POST":
                        response = await client.post(endpoint + "/run", headers=headers, json={})
                    elif method == "PUT":
                        response = await client.put(endpoint, headers=headers, json=workflow_details)
                    else:  # PATCH
                        response = await client.patch(endpoint, headers=headers, json={"active": True})
                    
                    print(f"  {method} method: {response.status_code}")
                    if response.status_code < 400 and method == "POST":
                        print(f"    ✅ Execution may have started!")
                except Exception as e:
                    pass
                    
        except Exception as e:
            print(f"❌ Test failed: {e}")

if __name__ == "__main__":
    asyncio.run(test_alternative_execution())
