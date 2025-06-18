#!/bin/bash
# Quick API test for Screenpipe

echo "Testing Screenpipe API..."
echo ""

# Test 1: Basic health check
echo "1. Health Check:"
curl -s http://localhost:3030/health | jq . || echo "Failed to get health status"
echo ""

# Test 2: Search test
echo "2. Search Test (recent content):"
curl -s 'http://localhost:3030/search?limit=5' | jq '.data[].content.text' 2>/dev/null || echo "No search results"
echo ""

# Test 3: Check if recording
echo "3. Recording Status:"
curl -s http://localhost:3030/health | jq '.frame_status, .audio_status' 2>/dev/null || echo "Cannot determine recording status"
echo ""

# Test 4: Port check
echo "4. Port 3030 Status:"
lsof -i :3030 | grep LISTEN || echo "Port 3030 not in use"
