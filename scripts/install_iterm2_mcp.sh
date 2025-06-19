#!/bin/bash

echo "🚀 Installing iTerm2 MCP for Terminal Control..."

# Create MCP directory
mkdir -p /Users/zeh/Local_Projects/Strategy_agents/mcp/iterm2
cd /Users/zeh/Local_Projects/Strategy_agents/mcp/iterm2

# Try smithery installation first
echo "📦 Trying smithery installation..."
npx -y @smithery/cli install iterm-mcp --client claude

# If smithery fails, try manual installation
if [ $? -ne 0 ]; then
    echo "⚠️ Smithery failed, trying manual installation..."
    
    # Clone the repository
    git clone https://github.com/ferriswheelproject/iterm-mcp.git
    cd iterm-mcp
    
    # Install dependencies
    npm install
    
    # Build if needed
    if grep -q "build" package.json; then
        npm run build
    fi
    
    echo "✅ Manual installation complete"
    
    # Add to Claude config
    cd /Users/zeh/Local_Projects/Strategy_agents
    
    # Create updated config with iTerm2
    cat > ~/.config/claude-desktop/config.json << 'EOF'
{
  "mcpServers": {
    "screenpipe": {
      "command": "python",
      "args": [
        "/Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp/screenpipe_server.py"
      ],
      "env": {
        "SCREENPIPE_API_URL": "http://localhost:3030"
      }
    },
    "azure-postgresql": {
      "command": "python", 
      "args": [
        "/Users/zeh/Local_Projects/Strategy_agents/mcp/azure-postgresql/src/azure_postgresql_mcp/server.py"
      ],
      "env": {
        "AZURE_SUBSCRIPTION_ID": "your-subscription-id",
        "AZURE_RESOURCE_GROUP": "strategy-agents-rg",
        "AZURE_POSTGRESQL_SERVER": "strategy-agents-db",
        "AZURE_DATABASE_NAME": "strategy_db"
      }
    },
    "iterm2": {
      "command": "node",
      "args": [
        "/Users/zeh/Local_Projects/Strategy_agents/mcp/iterm2/iterm-mcp/dist/index.js"
      ],
      "env": {
        "ITERM2_MCP_LOG_LEVEL": "info"
      }
    }
  }
}
EOF

    echo "✅ Claude Desktop configuration updated"
else
    echo "✅ Smithery installation successful"
    
    # Find smithery installation path
    SMITHERY_PATH=$(find ~/.smithery -name "*iterm*" -type d 2>/dev/null | head -1)
    
    if [ -n "$SMITHERY_PATH" ]; then
        echo "📍 Found smithery installation at: $SMITHERY_PATH"
        
        # Update config with smithery path
        cat > ~/.config/claude-desktop/config.json << EOF
{
  "mcpServers": {
    "screenpipe": {
      "command": "python",
      "args": [
        "/Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp/screenpipe_server.py"
      ],
      "env": {
        "SCREENPIPE_API_URL": "http://localhost:3030"
      }
    },
    "azure-postgresql": {
      "command": "python", 
      "args": [
        "/Users/zeh/Local_Projects/Strategy_agents/mcp/azure-postgresql/src/azure_postgresql_mcp/server.py"
      ],
      "env": {
        "AZURE_SUBSCRIPTION_ID": "your-subscription-id",
        "AZURE_RESOURCE_GROUP": "strategy-agents-rg",
        "AZURE_POSTGRESQL_SERVER": "strategy-agents-db",
        "AZURE_DATABASE_NAME": "strategy_db"
      }
    },
    "iterm2": {
      "command": "node",
      "args": [
        "$SMITHERY_PATH/index.js"
      ],
      "env": {
        "ITERM2_MCP_LOG_LEVEL": "info"
      }
    }
  }
}
EOF
        echo "✅ Configuration updated with smithery path"
    fi
fi

echo ""
echo "🎯 Installation complete!"
echo ""
echo "Next steps:"
echo "1. 🔄 Restart Claude Desktop"
echo "2. 🖥️ Open iTerm2"
echo "3. 🧪 Test with command: 'Execute this command in my terminal: echo Hello from Claude!'"
echo ""
echo "🚀 Terminal control ready!"
