#!/bin/bash

# 🛠️ DEPLOY STABLE MCP SERVER
# Switches to the stable version and updates Claude config

echo "🛠️ DEPLOYING STABLE MCP SERVER"
echo "=============================="

# Paths
PYTHON_PATH=$(which python3)
STABLE_SCRIPT="/Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp/screenpipe_server_stable.py"
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

# Make the stable script executable
chmod +x "$STABLE_SCRIPT"
echo "✅ Made stable script executable"

# Test the stable script quickly
echo "🧪 Testing stable MCP server..."
cd /Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp

# Quick syntax check
if $PYTHON_PATH -m py_compile screenpipe_server_stable.py; then
    echo "✅ Stable MCP server syntax is valid"
else
    echo "❌ Syntax error in stable MCP server"
    exit 1
fi

# Update Claude Desktop config to use stable version
echo "🔧 Updating Claude Desktop config..."

cat > "$CLAUDE_CONFIG" << EOF
{
  "mcpServers": {
    "screenpipe-strategy": {
      "command": "$PYTHON_PATH",
      "args": ["$STABLE_SCRIPT"],
      "env": {
        "PYTHONPATH": "/Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp",
        "PYTHONUNBUFFERED": "1"
      }
    }
  }
}
EOF

echo "✅ Claude config updated to use stable server"

# Also create a backup config
cp "$CLAUDE_CONFIG" "/Users/zeh/Local_Projects/Strategy_agents/screenpipe/config/claude_desktop_config_stable.json"
echo "✅ Backup config created"

echo ""
echo "🔄 NEXT STEPS:"
echo "1. QUIT Claude Desktop completely (⌘+Q)"
echo "2. WAIT 5 seconds"
echo "3. RESTART Claude Desktop"
echo "4. WAIT 30 seconds for startup"
echo "5. TEST: 'Test the connection to Screenpipe'"
echo ""
echo "The stable server includes better error handling and logging!"
