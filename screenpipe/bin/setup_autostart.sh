#!/bin/bash

# 🚀 AUTO-START CONFIGURATION
# Sets up Screenpipe to run automatically on macOS startup

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
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "INFO") echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

# Paths
STRATEGY_DIR="/Users/zeh/Local_Projects/Strategy_agents"
SCREENPIPE_DIR="$STRATEGY_DIR/screenpipe"
BIN_DIR="$SCREENPIPE_DIR/bin"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

echo "🚀 STRATEGY AGENTS - AUTO-START SETUP"
echo "====================================="
echo ""

# Create launch agents directory
print_status "INFO" "Creating LaunchAgents directory..."
mkdir -p "$LAUNCH_AGENTS_DIR"

# Create Screenpipe Service Launch Agent
print_status "INFO" "Creating Screenpipe service launch agent..."
cat > "$LAUNCH_AGENTS_DIR/com.strategy.screenpipe.service.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.strategy.screenpipe.service</string>
    <key>Program</key>
    <string>$BIN_DIR/start_screenpipe.sh</string>
    <key>ProgramArguments</key>
    <array>
        <string>$BIN_DIR/start_screenpipe.sh</string>
        <string>start</string>
        <string>true</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    <key>StandardOutPath</key>
    <string>$SCREENPIPE_DIR/logs/launch_service.log</string>
    <key>StandardErrorPath</key>
    <string>$SCREENPIPE_DIR/logs/launch_service_error.log</string>
    <key>WorkingDirectory</key>
    <string>$BIN_DIR</string>
    <key>ThrottleInterval</key>
    <integer>10</integer>
</dict>
</plist>
EOF

# Create Menu Bar App Launch Agent
print_status "INFO" "Creating Menu Bar app launch agent..."
cat > "$LAUNCH_AGENTS_DIR/com.strategy.screenpipe.menubar.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.strategy.screenpipe.menubar</string>
    <key>Program</key>
    <string>/usr/bin/python3</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/python3</string>
        <string>$BIN_DIR/screenpipe_menubar.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$SCREENPIPE_DIR/logs/launch_menubar.log</string>
    <key>StandardErrorPath</key>
    <string>$SCREENPIPE_DIR/logs/launch_menubar_error.log</string>
    <key>WorkingDirectory</key>
    <string>$BIN_DIR</string>
    <key>ProcessType</key>
    <string>Interactive</string>
</dict>
</plist>
EOF

# Set proper permissions
chmod 644 "$LAUNCH_AGENTS_DIR/com.strategy.screenpipe.service.plist"
chmod 644 "$LAUNCH_AGENTS_DIR/com.strategy.screenpipe.menubar.plist"

print_status "OK" "Launch agents created"
echo ""

# Function to load launch agents
load_agents() {
    print_status "INFO" "Loading launch agents..."
    
    # Unload first in case they're already loaded
    launchctl unload "$LAUNCH_AGENTS_DIR/com.strategy.screenpipe.service.plist" 2>/dev/null || true
    launchctl unload "$LAUNCH_AGENTS_DIR/com.strategy.screenpipe.menubar.plist" 2>/dev/null || true
    
    # Load the agents
    if launchctl load "$LAUNCH_AGENTS_DIR/com.strategy.screenpipe.service.plist"; then
        print_status "OK" "Screenpipe service agent loaded"
    else
        print_status "ERROR" "Failed to load service agent"
    fi
    
    if launchctl load "$LAUNCH_AGENTS_DIR/com.strategy.screenpipe.menubar.plist"; then
        print_status "OK" "Menu bar app agent loaded"
    else
        print_status "ERROR" "Failed to load menu bar agent"
    fi
}

# Function to test auto-start
test_autostart() {
    print_status "INFO" "Testing auto-start functionality..."
    
    # Stop any running services
    cd "$BIN_DIR"
    ./start_screenpipe.sh stop 2>/dev/null || true
    pkill -f "screenpipe_menubar.py" 2>/dev/null || true
    
    sleep 5
    
    # Load agents
    load_agents
    
    # Wait for services to start
    print_status "INFO" "Waiting for services to start..."
    sleep 15
    
    # Check if services are running
    if pgrep -f "screenpipe" > /dev/null; then
        print_status "OK" "Screenpipe service auto-started successfully"
    else
        print_status "WARNING" "Screenpipe service did not auto-start"
    fi
    
    if pgrep -f "screenpipe_menubar.py" > /dev/null; then
        print_status "OK" "Menu bar app auto-started successfully"
    else
        print_status "WARNING" "Menu bar app did not auto-start"
    fi
}

# Show menu
echo "Auto-start configuration options:"
echo ""
echo "1) Install and test auto-start (recommended)"
echo "2) Install auto-start only (no testing)"
echo "3) Remove auto-start"
echo "4) Show status"
echo "5) Test existing setup"
echo ""
read -p "Choose option (1-5): " choice

case $choice in
    1)
        print_status "INFO" "Installing and testing auto-start..."
        load_agents
        test_autostart
        ;;
    2)
        print_status "INFO" "Installing auto-start..."
        load_agents
        ;;
    3)
        print_status "INFO" "Removing auto-start..."
        launchctl unload "$LAUNCH_AGENTS_DIR/com.strategy.screenpipe.service.plist" 2>/dev/null || true
        launchctl unload "$LAUNCH_AGENTS_DIR/com.strategy.screenpipe.menubar.plist" 2>/dev/null || true
        rm -f "$LAUNCH_AGENTS_DIR/com.strategy.screenpipe.service.plist"
        rm -f "$LAUNCH_AGENTS_DIR/com.strategy.screenpipe.menubar.plist"
        print_status "OK" "Auto-start removed"
        ;;
    4)
        print_status "INFO" "Checking auto-start status..."
        if [ -f "$LAUNCH_AGENTS_DIR/com.strategy.screenpipe.service.plist" ]; then
            print_status "OK" "Service launch agent installed"
        else
            print_status "WARNING" "Service launch agent not installed"
        fi
        
        if [ -f "$LAUNCH_AGENTS_DIR/com.strategy.screenpipe.menubar.plist" ]; then
            print_status "OK" "Menu bar launch agent installed"
        else
            print_status "WARNING" "Menu bar launch agent not installed"
        fi
        
        # Check if loaded
        if launchctl list | grep -q "com.strategy.screenpipe.service"; then
            print_status "OK" "Service agent loaded and active"
        else
            print_status "WARNING" "Service agent not loaded"
        fi
        
        if launchctl list | grep -q "com.strategy.screenpipe.menubar"; then
            print_status "OK" "Menu bar agent loaded and active"
        else
            print_status "WARNING" "Menu bar agent not loaded"
        fi
        ;;
    5)
        test_autostart
        ;;
    *)
        print_status "ERROR" "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_status "INFO" "Auto-start configuration complete!"
echo ""
print_status "INFO" "Launch agent logs:"
echo "  • Service: $SCREENPIPE_DIR/logs/launch_service.log"
echo "  • Menu Bar: $SCREENPIPE_DIR/logs/launch_menubar.log"
echo ""
print_status "INFO" "To manually control:"
echo "  • launchctl unload ~/Library/LaunchAgents/com.strategy.screenpipe.*.plist"
echo "  • launchctl load ~/Library/LaunchAgents/com.strategy.screenpipe.*.plist"
echo ""
print_status "OK" "Background operation configured!"
