#!/bin/bash

# Obsidian MCP Integration Test Script
echo "🧪 Testing Obsidian MCP Integration..."

# Test if Obsidian Local REST API is running
echo "📡 Testing Obsidian Local REST API connection..."
curl -s -H "Authorization: Bearer 424ed7d81076bca37cd8b410c0047c230760b979088fd42893b5b0dd9982cbd0" \
     http://127.0.0.1:27123/vault/ > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Obsidian REST API is accessible"
else
    echo "❌ Cannot connect to Obsidian REST API"
    echo "   Make sure Obsidian is running with Local REST API plugin enabled"
    exit 1
fi

# Test if MCP server starts properly
echo "🔧 Testing MCP server startup..."
cd /Users/zeh/Local_Projects/Strategy_agents/obsidian/obsidian-mcp-server

# Set environment variables
export OBSIDIAN_API_KEY="424ed7d81076bca37cd8b410c0047c230760b979088fd42893b5b0dd9982cbd0"
export OBSIDIAN_BASE_URL="http://127.0.0.1:27123"
export OBSIDIAN_VERIFY_SSL="false"
export OBSIDIAN_ENABLE_CACHE="true"

# Test server startup (timeout after 5 seconds)
timeout 5s node dist/index.js > /dev/null 2>&1

if [ $? -eq 124 ]; then
    echo "✅ MCP server starts successfully (timed out as expected)"
else
    echo "❌ MCP server failed to start properly"
    echo "   Check the server logs for errors"
    exit 1
fi

echo "🎉 Basic integration test passed!"
echo ""
echo "Next steps:"
echo "1. Restart Claude Desktop (Cmd+Q, then reopen)"
echo "2. Test Obsidian integration in Claude"
echo "3. Try creating a note using the obsidian tools"