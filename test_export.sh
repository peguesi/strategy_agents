#!/bin/bash

# Test the n8n API connection and export workflows

N8N_API_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI3MWM2ZjRiNC00ZTIwLTQ4YjUtODkyMi02NzUxNjMxMzJkZmEiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzUwMDc5MjQwfQ.1Tf5YHdlDrMObOM8fOw1bE19ltNfgo3ZVMJCITJejVs"
N8N_API_URL="https://n8n-agent-gdctd7f5e6e0a5br.eastus2-01.azurewebsites.net:443/api/v1"
WORKFLOWS_DIR="/Users/zeh/Local_Projects/Strategy_agents/n8n/workflows"

echo "🔄 Testing n8n API connection..."
mkdir -p "$WORKFLOWS_DIR"

# Test API connection
response=$(curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" "$N8N_API_URL/workflows")

if echo "$response" | jq -e '.data' >/dev/null 2>&1; then
    echo "✅ API connection successful!"
    
    # Export workflows
    echo "$response" | jq -r '.data[] | @json' | \
    while read -r workflow; do
        id=$(echo "$workflow" | jq -r '.id')
        name=$(echo "$workflow" | jq -r '.name')
        safe_name=$(echo "$name" | sed 's/[^a-zA-Z0-9._-]/_/g')
        
        echo "📄 Exporting: $name"
        echo "$workflow" | jq '.' > "$WORKFLOWS_DIR/${safe_name}.json"
    done
    
    echo "✅ Export complete! Files created:"
    ls -la "$WORKFLOWS_DIR"/*.json 2>/dev/null || echo "No JSON files found"
    
else
    echo "❌ API connection failed!"
    echo "Response: $response"
fi
