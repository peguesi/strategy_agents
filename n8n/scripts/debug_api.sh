#!/bin/bash

# n8n API Debug Script
# Tests different endpoints to understand the API structure

set -e

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
    if [ "$N8N_PROTOCOL" = "https" ]; then
        N8N_PORT="443"
    else
        N8N_PORT="80"
    fi
else
    N8N_HOST="${N8N_HOST:-localhost}"
    N8N_PORT="${N8N_PORT:-5678}"
    N8N_PROTOCOL="${N8N_PROTOCOL:-http}"
fi

BASE_URL="${N8N_PROTOCOL}://${N8N_HOST}:${N8N_PORT}"

echo "=== n8n API Debug ==="
echo "Base URL: $BASE_URL"
echo "API Key: ${N8N_API_KEY:0:20}..."
echo ""

# Test different endpoints
endpoints=(
    "/rest/workflows"
    "/api/v1/workflows"
    "/rest/projects" 
    "/rest/projects/gjT9DPhFVCNv6O14"
    "/rest/projects/gjT9DPhFVCNv6O14/workflows"
    "/webhook-test/workflows"
)

for endpoint in "${endpoints[@]}"; do
    echo "=== Testing: $endpoint ==="
    
    # Try both authentication methods
    for auth_method in "bearer" "api-key"; do
        echo "  Auth method: $auth_method"
        
        if [ "$auth_method" = "bearer" ] && [ -n "${N8N_API_KEY}" ]; then
            response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -H "Authorization: Bearer ${N8N_API_KEY}" "${BASE_URL}${endpoint}" 2>/dev/null)
        elif [ "$auth_method" = "api-key" ] && [ -n "${N8N_API_KEY}" ]; then
            response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -H "X-N8N-API-KEY: ${N8N_API_KEY}" "${BASE_URL}${endpoint}" 2>/dev/null)
        else
            response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "${BASE_URL}${endpoint}" 2>/dev/null)
        fi
        
        http_code=$(echo "$response" | tail -n1 | cut -d':' -f2)
        body=$(echo "$response" | sed '$d')
        
        echo "  HTTP Code: $http_code"
        if [ "$http_code" = "200" ]; then
            echo "  ✅ Success with $auth_method!"
            echo "  Response:"
            echo "$body" | jq '.' 2>/dev/null || echo "$body"
            echo "  SUCCESS_ENDPOINT: $endpoint"
            echo "  SUCCESS_AUTH: $auth_method"
        elif [ "$http_code" = "401" ]; then
            echo "  ❌ Unauthorized with $auth_method"
        else
            echo "  ❌ HTTP $http_code with $auth_method"
            if [ ${#body} -lt 200 ]; then
                echo "  Response: $body"
            fi
        fi
        echo ""
    done
    echo ""
done

# Test the specific URL format you mentioned
echo "=== Testing specific folder structure ==="
PROJECT_ID="gjT9DPhFVCNv6O14"
FOLDER_ID="kS5jDvfTZcGenYpJ"

folder_endpoints=(
    "/rest/projects/${PROJECT_ID}/folders/${FOLDER_ID}/workflows"
    "/api/v1/projects/${PROJECT_ID}/folders/${FOLDER_ID}/workflows"
    "/rest/folders/${FOLDER_ID}/workflows"
)

for endpoint in "${folder_endpoints[@]}"; do
    echo "Testing: $endpoint"
    
    if [ -n "${N8N_API_KEY}" ]; then
        response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -H "Authorization: Bearer ${N8N_API_KEY}" "${BASE_URL}${endpoint}" 2>/dev/null)
    else
        response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "${BASE_URL}${endpoint}" 2>/dev/null)
    fi
    
    http_code=$(echo "$response" | tail -n1 | cut -d':' -f2)
    body=$(echo "$response" | sed '$d')
    
    echo "HTTP Code: $http_code"
    if [ "$http_code" = "200" ]; then
        echo "✅ Found the right endpoint!"
        echo "Response:"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
        break
    else
        echo "❌ HTTP $http_code"
    fi
    echo ""
done
