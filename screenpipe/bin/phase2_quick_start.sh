#!/bin/bash

# 🚀 PHASE 2: QUICK START SCRIPT
# Automates essential setup and testing for Strategy Agents Screenpipe

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "INFO") echo -e "${BLUE}ℹ️  $message${NC}" ;;
        "STEP") echo -e "${BLUE}🔧 $message${NC}" ;;
    esac
}

# Set up paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STRATEGY_DIR="/Users/zeh/Local_Projects/Strategy_agents"
SCREENPIPE_DIR="$STRATEGY_DIR/screenpipe"
BIN_DIR="$SCREENPIPE_DIR/bin"

echo "🚀 STRATEGY AGENTS - PHASE 2 QUICK START"
echo "========================================"
echo ""

# Step 1: Make scripts executable
print_status "STEP" "Making scripts executable..."
cd "$BIN_DIR"
chmod +x *.sh *.py
chmod +x "$SCREENPIPE_DIR/mcp/screenpipe_server.py"
print_status "OK" "Scripts made executable"
echo ""

# Step 2: Check Python dependencies
print_status "STEP" "Checking Python dependencies..."
if python3 -c "import rumps, requests" 2>/dev/null; then
    print_status "OK" "Menu bar dependencies available"
else
    print_status "WARNING" "Installing menu bar dependencies..."
    pip3 install rumps requests
fi

if python3 -c "import mcp, httpx, nest_asyncio" 2>/dev/null; then
    print_status "OK" "MCP dependencies available"
else
    print_status "WARNING" "Installing MCP dependencies..."
    pip3 install mcp httpx nest-asyncio
fi
echo ""

# Step 3: Check if Screenpipe is installed
print_status "STEP" "Checking Screenpipe installation..."
if command -v screenpipe >/dev/null 2>&1; then
    print_status "OK" "Screenpipe installed"
    screenpipe --version
else
    print_status "ERROR" "Screenpipe not installed!"
    print_status "INFO" "Install with: curl -fsSL get.screenpi.pe/cli | sh"
    exit 1
fi
echo ""

# Step 4: Stop any existing Screenpipe
print_status "STEP" "Stopping any existing Screenpipe processes..."
if pgrep -f "screenpipe" > /dev/null; then
    pkill -f "screenpipe" || true
    sleep 3
    print_status "OK" "Stopped existing processes"
else
    print_status "INFO" "No existing processes found"
fi
echo ""

# Step 5: Create necessary directories
print_status "STEP" "Creating necessary directories..."
mkdir -p "$SCREENPIPE_DIR/data"
mkdir -p "$SCREENPIPE_DIR/logs"
print_status "OK" "Directories ready"
echo ""

# Step 6: Start Screenpipe service
print_status "STEP" "Starting Screenpipe service..."
cd "$BIN_DIR"
./start_screenpipe.sh start true

# Wait for startup
print_status "INFO" "Waiting for service to start..."
sleep 10
echo ""

# Step 7: Test service health
print_status "STEP" "Testing service health..."
./health_check.sh summary
echo ""

# Step 8: Test API
print_status "STEP" "Testing API endpoints..."
if curl -s http://localhost:3030/health > /dev/null; then
    print_status "OK" "API responding"
    if command -v jq >/dev/null 2>&1; then
        echo "API Health:"
        curl -s http://localhost:3030/health | jq
    fi
else
    print_status "ERROR" "API not responding"
fi
echo ""

# Step 9: Configure Claude Desktop
print_status "STEP" "Configuring Claude Desktop..."
CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
mkdir -p "$CLAUDE_CONFIG_DIR"

# Backup existing config
if [ -f "$CLAUDE_CONFIG_DIR/claude_desktop_config.json" ]; then
    cp "$CLAUDE_CONFIG_DIR/claude_desktop_config.json" "$CLAUDE_CONFIG_DIR/claude_desktop_config_backup_$(date +%Y%m%d_%H%M%S).json"
    print_status "OK" "Backed up existing Claude config"
fi

# Install new config
cp "$SCREENPIPE_DIR/config/claude_desktop_config.json" "$CLAUDE_CONFIG_DIR/"
print_status "OK" "Claude Desktop configured"
echo ""

# Step 10: Provide next steps
print_status "INFO" "Setup complete! Next steps:"
echo ""
echo "1. 📱 LAUNCH MENU BAR APP:"
echo "   cd $BIN_DIR"
echo "   python3 screenpipe_menubar.py"
echo ""
echo "2. 🔄 RESTART CLAUDE DESKTOP:"
echo "   - Quit Claude Desktop completely"
echo "   - Relaunch Claude Desktop"
echo "   - Test MCP tools: 'Search my recent activity'"
echo ""
echo "3. 🧪 TEST DATA CAPTURE:"
echo "   - Use your computer normally for 5 minutes"
echo "   - Run: curl 'http://localhost:3030/search?limit=10' | jq"
echo ""
echo "4. 📊 MONITOR HEALTH:"
echo "   - Run: ./health_check.sh full"
echo "   - Check logs: ls -la $SCREENPIPE_DIR/logs/"
echo ""
echo "5. 🎯 VALIDATE COMPLETE SETUP:"
echo "   - Follow: $STRATEGY_DIR/PHASE_2_TEST_PLAN.md"
echo ""

print_status "OK" "Phase 2 Quick Start Complete!"
print_status "INFO" "Service running in background on port 3030"
print_status "INFO" "Data directory: $SCREENPIPE_DIR/data"
print_status "INFO" "Logs directory: $SCREENPIPE_DIR/logs"

echo ""
echo "🎉 READY FOR STRATEGIC OPERATIONS!"
