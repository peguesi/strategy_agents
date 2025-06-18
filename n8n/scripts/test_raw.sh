#!/bin/bash

# Simple test to see exactly what the n8n API returns

# Load environment variables
if [ -f "$(dirname "$0")/../../.env" ]; then
    set -a
    source "$(dirname "$0")/../../.env"
    set +a
fi

# Parse N8N_URL
if [ -n "${N8N_URL}" ]; then
    N8N_PROTOCOL=$(echo "$N8N_URL" | cut -d':' -f1)
    N8N_HOST=$(echo "$N8N_URL" | cut -d'/' -f3 | cut -d':' -f1)
    N8N_PORT="443"
else
    echo "No N8N_URL found"
    exit 1
fi

BASE_URL="${N8N_PROTOCOL}://${N8N_HOST}:${N8N_PORT}"

echo "=== Raw API Response Test ==="
echo "URL: ${BASE_URL}/api/v1/workflows"
echo "API Key: ${N8N_API_KEY:0:20}..."
echo ""

# Get the raw response
echo "=== Full Response ==="
response=$(curl -s -H "X-N8N-API-KEY: ${N8N_API_KEY}" "${BASE_URL}/api/v1/workflows")
echo "$response"
echo ""

echo "=== Parsed with jq ==="
echo "$response" | jq '.'
echo ""

echo "=== Workflow IDs ==="
echo "$response" | jq -r '.data[]?.id' 2>/dev/null
echo ""

echo "=== Workflow Names ==="
echo "$response" | jq -r '.data[]? | "\(.id): \(.name)"' 2>/dev/null
