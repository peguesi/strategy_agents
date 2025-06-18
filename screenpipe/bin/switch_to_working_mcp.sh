#!/bin/bash

# 🎯 SWITCH TO WORKING MCP CONFIG
# Uses the screenpipe-mcp configuration that's already working

echo "🎯 SWITCHING TO WORKING MCP CONFIGURATION"
echo "========================================"

CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
PYTHON_PATH="/Users/zeh/.pyenv/shims/python3"

echo "🔧 Creating working Claude config..."

cat > "$CLAUDE_CONFIG" << 'EOF'
{
  "mcpServers": {
    "screenpipe-mcp": {
      "command": "/Users/zeh/.pyenv/shims/python3",
      "args": ["-c", "from screenpipe_mcp import main; main()"],
      "env": {
        "SCREENPIPE_API_URL": "http://localhost:3030"
      }
    }
  }
}
EOF

echo "✅ Claude config updated to use working screenpipe-mcp"

# Install screenpipe-mcp if needed
echo "📦 Installing screenpipe-mcp package..."
pip3 install screenpipe-mcp

echo ""
echo "🔄 NEXT STEPS:"
echo "1. QUIT Claude Desktop completely (⌘+Q)"
echo "2. WAIT 5 seconds" 
echo "3. RESTART Claude Desktop"
echo "4. TEST: 'Search my recent activity'"
echo ""
echo "This uses the working screenpipe-mcp package instead of our custom server!"
