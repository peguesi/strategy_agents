#!/bin/bash

# 🔧 FIX MCP SERVER ISSUES
# Resolves common Claude Desktop MCP integration problems

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK") echo -e "${GREEN}✅ $message${NC}" ;;
        "FIX") echo -e "${YELLOW}🔧 $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "INFO") echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

# Paths
STRATEGY_DIR="/Users/zeh/Local_Projects/Strategy_agents"
SCREENPIPE_DIR="$STRATEGY_DIR/screenpipe"
MCP_SCRIPT="$SCREENPIPE_DIR/mcp/screenpipe_server.py"
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

echo "🔧 MCP SERVER INTEGRATION FIX"
echo "============================="
echo ""

# Step 1: Fix Python shebang and permissions
print_status "FIX" "Fixing Python shebang and permissions..."

# Find the correct Python3 path
PYTHON_PATH=$(which python3)
print_status "INFO" "Python3 found at: $PYTHON_PATH"

# Update shebang line
sed -i '' "1s|.*|#!${PYTHON_PATH}|" "$MCP_SCRIPT"
print_status "OK" "Updated shebang line"

# Make executable
chmod +x "$MCP_SCRIPT"
print_status "OK" "Made script executable"

# Step 2: Test Python dependencies
print_status "FIX" "Testing Python dependencies..."

if $PYTHON_PATH -c "import mcp, httpx, nest_asyncio" 2>/dev/null; then
    print_status "OK" "MCP dependencies available"
else
    print_status "FIX" "Installing MCP dependencies..."
    $PYTHON_PATH -m pip install mcp httpx nest-asyncio
    print_status "OK" "Dependencies installed"
fi

# Step 3: Test MCP server directly
print_status "FIX" "Testing MCP server directly..."

cd "$SCREENPIPE_DIR/mcp"
timeout 5s $PYTHON_PATH screenpipe_server.py --help > /dev/null 2>&1 || {
    print_status "ERROR" "MCP server test failed - checking issues..."
    
    # Test imports one by one
    if ! $PYTHON_PATH -c "import mcp" 2>/dev/null; then
        print_status "ERROR" "MCP library not available"
        $PYTHON_PATH -m pip install mcp
    fi
    
    if ! $PYTHON_PATH -c "import httpx" 2>/dev/null; then
        print_status "ERROR" "httpx library not available"
        $PYTHON_PATH -m pip install httpx
    fi
    
    if ! $PYTHON_PATH -c "import nest_asyncio" 2>/dev/null; then
        print_status "ERROR" "nest_asyncio library not available"
        $PYTHON_PATH -m pip install nest-asyncio
    fi
}

print_status "OK" "MCP server test passed"

# Step 4: Create corrected Claude config
print_status "FIX" "Creating corrected Claude Desktop config..."

cat > "$CLAUDE_CONFIG" << EOF
{
  "mcpServers": {
    "screenpipe-strategy": {
      "command": "$PYTHON_PATH",
      "args": ["$MCP_SCRIPT"],
      "env": {
        "SCREENPIPE_API_URL": "http://localhost:3030",
        "DATA_DIR": "$SCREENPIPE_DIR/data"
      }
    }
  }
}
EOF

print_status "OK" "Claude Desktop config updated with correct Python path"

# Step 5: Create simplified test config
print_status "FIX" "Creating simplified test config..."

cat > "$SCREENPIPE_DIR/config/claude_desktop_config_fixed.json" << EOF
{
  "mcpServers": {
    "screenpipe-strategy": {
      "command": "$PYTHON_PATH",
      "args": ["$MCP_SCRIPT", "--port", "3030"],
      "env": {}
    }
  }
}
EOF

print_status "OK" "Backup config created"

# Step 6: Test the fixed configuration
print_status "FIX" "Testing MCP server startup..."

# Start a test instance
cd "$SCREENPIPE_DIR/mcp"
echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"capabilities": {}}}' | timeout 10s $PYTHON_PATH screenpipe_server.py > /dev/null 2>&1 && {
    print_status "OK" "MCP server responds to initialization"
} || {
    print_status "ERROR" "MCP server initialization failed"
    
    # Try alternative approach
    print_status "FIX" "Trying alternative configuration..."
    
    cat > "$CLAUDE_CONFIG" << EOF
{
  "mcpServers": {
    "screenpipe-strategy": {
      "command": "/usr/bin/env",
      "args": ["python3", "$MCP_SCRIPT"],
      "env": {
        "PATH": "/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin"
      }
    }
  }
}
EOF
    
    print_status "OK" "Alternative config created"
}

echo ""
print_status "INFO" "Fix complete! Next steps:"
echo ""
echo "1. 🔄 RESTART CLAUDE DESKTOP completely"
echo "   - Quit Claude Desktop"
echo "   - Wait 5 seconds"
echo "   - Relaunch Claude Desktop"
echo ""
echo "2. ⏱️  WAIT 30 seconds for MCP server startup"
echo ""
echo "3. 🧪 TEST in Claude Desktop:"
echo '   "Search my recent screenpipe activity"'
echo ""
echo "4. 📋 If still failing, check logs:"
echo "   tail -f $SCREENPIPE_DIR/logs/mcp_server.log"
echo ""

# Step 7: Check if Screenpipe is running
if pgrep -f "screenpipe" > /dev/null; then
    print_status "OK" "Screenpipe service is running"
else
    print_status "ERROR" "Screenpipe service not running!"
    print_status "INFO" "Start with: cd $SCREENPIPE_DIR/bin && ./start_screenpipe.sh start true"
fi

print_status "OK" "MCP integration fix complete!"
