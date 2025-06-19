#!/bin/bash

# iTerm2 MCP Complete Setup Script
# Part of Strategy Agents MCP Terminal Integration

set -e

echo "🚀 Setting up iTerm2 MCP for Terminal Control..."
echo "================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the right directory
STRATEGY_AGENTS_DIR="/Users/zeh/Local_Projects/Strategy_agents"
if [ ! -d "$STRATEGY_AGENTS_DIR" ]; then
    echo -e "${RED}❌ Strategy agents directory not found at $STRATEGY_AGENTS_DIR${NC}"
    exit 1
fi

cd "$STRATEGY_AGENTS_DIR"

# Create MCP directory structure
echo -e "${BLUE}📁 Creating MCP directory structure...${NC}"
mkdir -p mcp/iterm2
mkdir -p mcp/configs
mkdir -p logs

# Install iTerm2 MCP via smithery
echo -e "${BLUE}📦 Installing iTerm2 MCP via smithery...${NC}"
npx -y @smithery/cli install iterm-mcp --client claude

# Check if installation was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ iTerm2 MCP installed successfully via smithery${NC}"
    
    # Try to find smithery installation
    ITERM_MCP_PATH=""
    if [ -d "$HOME/.smithery" ]; then
        SMITHERY_ITERM=$(find "$HOME/.smithery" -name "*iterm*" -type d 2>/dev/null | head -1)
        if [ -n "$SMITHERY_ITERM" ]; then
            ITERM_MCP_PATH="$SMITHERY_ITERM"
            echo -e "${GREEN}📍 Found iTerm2 MCP at: $ITERM_MCP_PATH${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⚠️ Smithery installation failed, trying alternative approach...${NC}"
    
    # Alternative: Clone from GitHub
    echo -e "${BLUE}📦 Cloning iTerm2 MCP from GitHub...${NC}"
    cd mcp/iterm2
    
    if [ ! -d "iterm-mcp" ]; then
        git clone https://github.com/ferriswheelproject/iterm-mcp.git
        cd iterm-mcp
        
        # Install dependencies
        echo -e "${BLUE}📦 Installing dependencies...${NC}"
        npm install
        
        # Build if needed
        if [ -f "package.json" ] && grep -q "build" package.json; then
            npm run build
        fi
        
        ITERM_MCP_PATH="$STRATEGY_AGENTS_DIR/mcp/iterm2/iterm-mcp"
        echo -e "${GREEN}✅ iTerm2 MCP cloned and built at: $ITERM_MCP_PATH${NC}"
    else
        echo -e "${YELLOW}📁 iTerm2 MCP directory already exists${NC}"
        ITERM_MCP_PATH="$STRATEGY_AGENTS_DIR/mcp/iterm2/iterm-mcp"
    fi
    
    cd "$STRATEGY_AGENTS_DIR"
fi

# Configure Claude Desktop
echo -e "${BLUE}⚙️ Configuring Claude Desktop...${NC}"

CLAUDE_CONFIG_DIR="$HOME/.config/claude-desktop"
CLAUDE_CONFIG_FILE="$CLAUDE_CONFIG_DIR/config.json"

# Check for Claude Desktop config directory
if [ ! -d "$CLAUDE_CONFIG_DIR" ]; then
    echo -e "${BLUE}📁 Creating Claude Desktop config directory...${NC}"
    mkdir -p "$CLAUDE_CONFIG_DIR"
fi

# Backup existing config
if [ -f "$CLAUDE_CONFIG_FILE" ]; then
    echo -e "${YELLOW}📝 Backing up existing Claude Desktop config...${NC}"
    cp "$CLAUDE_CONFIG_FILE" "$CLAUDE_CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
fi

# If we couldn't find the path, ask user
if [ -z "$ITERM_MCP_PATH" ]; then
    echo -e "${YELLOW}❓ iTerm2 MCP path not auto-detected${NC}"
    echo -e "${BLUE}Please check these common locations:${NC}"
    echo "1. ~/.smithery/*iterm*"
    echo "2. $STRATEGY_AGENTS_DIR/mcp/iterm2/iterm-mcp"
    echo ""
    read -p "Enter iTerm2 MCP path (or press Enter to use local): " USER_PATH
    
    if [ -n "$USER_PATH" ]; then
        ITERM_MCP_PATH="$USER_PATH"
    else
        ITERM_MCP_PATH="$STRATEGY_AGENTS_DIR/mcp/iterm2/iterm-mcp"
    fi
fi

# Create the configuration JSON
echo -e "${BLUE}📝 Creating Claude Desktop configuration...${NC}"

cat > "$CLAUDE_CONFIG_FILE" << EOF
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
        "AZURE_SUBSCRIPTION_ID": "$(az account show --query id -o tsv 2>/dev/null || echo 'your-subscription-id')",
        "AZURE_RESOURCE_GROUP": "strategy-agents-rg",
        "AZURE_POSTGRESQL_SERVER": "strategy-agents-db",
        "AZURE_DATABASE_NAME": "strategy_db"
      }
    },
    "iterm2": {
      "command": "node",
      "args": [
        "$ITERM_MCP_PATH/dist/index.js"
      ],
      "env": {
        "ITERM2_MCP_LOG_LEVEL": "info"
      }
    }
  }
}
EOF

echo -e "${GREEN}✅ Claude Desktop configuration created successfully${NC}"

# Save scripts for later use
echo -e "${BLUE}💾 Saving helper scripts...${NC}"

# Create test script
cat > "test_iterm2_mcp.sh" << 'TESTEOF'
#!/bin/bash

echo "🧪 Testing iTerm2 MCP Integration..."
echo "===================================="

# Check if iTerm2 is running
if ! pgrep -x "iTerm2" > /dev/null; then
    echo "⚠️ iTerm2 is not running. Opening iTerm2..."
    open -a iTerm
    sleep 3
fi

echo "✅ iTerm2 is running"
echo ""
echo "🎯 Test in Claude with these commands:"
echo ""
echo "1. \"Execute this command in my terminal: echo 'Hello from Claude!'\""
echo "2. \"Run 'pwd' in my terminal and show me the output\""
echo "3. \"Start a Python REPL in my terminal\""
echo "4. \"Send Ctrl-C to my terminal to stop the current process\""
echo ""
echo "🚀 Ready to test!"
TESTEOF

chmod +x test_iterm2_mcp.sh

echo ""
echo -e "${GREEN}🎯 Setup complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. 🔄 Restart Claude Desktop application"
echo "2. 🖥️ Open iTerm2 (if not already open)"
echo "3. 🧪 Test integration in Claude"
echo ""
echo -e "${BLUE}Commands to try in Claude:${NC}"
echo "• \"Execute this command in my terminal: echo 'Hello from Claude!'\""
echo "• \"Run 'ls -la' in my terminal and show me the output\""
echo "• \"Start a Python REPL in my terminal\""
echo ""
echo -e "${GREEN}🚀 iTerm2 MCP is ready for terminal control!${NC}"
echo ""
echo -e "${BLUE}Run test script: ./test_iterm2_mcp.sh${NC}"
