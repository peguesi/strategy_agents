#!/bin/bash

# Quick workflow export script
# Exports current workflows from n8n to local files

N8N_API_URL="https://n8n-agent-gdctd7f5e6e0a5br.eastus2-01.azurewebsites.net:443/api/v1"
WORKFLOWS_DIR="/Users/zeh/Local_Projects/Strategy_agents/n8n/workflows"

# Get API key from environment variable
if [ -z "$N8N_API_KEY" ]; then
    echo "❌ Error: N8N_API_KEY environment variable is required"
    echo "Please set it in your .env file or export it:"
    echo "export N8N_API_KEY='your_api_key_here'"
    exit 1
fi

echo "🔄 Exporting workflows from n8n..."
mkdir -p "$WORKFLOWS_DIR"

# Fetch and save workflows
curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" \
    "$N8N_API_URL/workflows" | \
    jq -r '.data[] | @json' | \
    while read -r workflow; do
        id=$(echo "$workflow" | jq -r '.id')
        name=$(echo "$workflow" | jq -r '.name')
        safe_name=$(echo "$name" | sed 's/[^a-zA-Z0-9._-]/_/g')
        
        echo "📄 Exporting: $name"
        echo "$workflow" | jq '.' > "$WORKFLOWS_DIR/${safe_name}.json"
    done

echo "✅ Export complete! Workflows saved to: $WORKFLOWS_DIR"
echo "📁 Files created:"
ls -la "$WORKFLOWS_DIR"/*.json 2>/dev/null || echo "No workflows found"
