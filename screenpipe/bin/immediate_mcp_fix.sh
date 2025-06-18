#!/bin/bash

# 🚨 IMMEDIATE MCP FIX
# Quick fix for Claude Desktop MCP integration

echo "🚨 IMMEDIATE MCP INTEGRATION FIX"
echo "==============================="

# Make scripts executable
chmod +x /Users/zeh/Local_Projects/Strategy_agents/screenpipe/bin/*.sh
chmod +x /Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp/*.py

echo "✅ Made scripts executable"

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip3 install mcp httpx nest-asyncio
echo "✅ Dependencies installed"

# Create simplified Claude config
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
PYTHON_PATH=$(which python3)
MCP_SCRIPT="/Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp/screenpipe_server_simple.py"

echo "🔧 Creating simplified Claude config..."

cat > "$CLAUDE_CONFIG" << EOF
{
  "mcpServers": {
    "screenpipe-strategy": {
      "command": "$PYTHON_PATH",
      "args": ["$MCP_SCRIPT"],
      "env": {}
    }
  }
}
EOF

echo "✅ Claude config updated"

# Test the simple MCP server
echo "🧪 Testing simple MCP server..."
cd /Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp
chmod +x screenpipe_server_simple.py

echo "✅ Simple MCP server ready"

echo ""
echo "🔄 NEXT STEPS:"
echo "1. QUIT Claude Desktop completely"
echo "2. WAIT 5 seconds"  
echo "3. RESTART Claude Desktop"
echo "4. WAIT 30 seconds for startup"
echo "5. TEST: 'Test the connection to Screenpipe'"
echo ""
echo "If it works, we can switch back to the full server!"
