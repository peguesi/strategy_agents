#!/bin/bash

echo "🔄 Restarting Claude Desktop to Apply MCP Server Fixes"
echo "=" * 60

# Check if Claude Desktop is running
if pgrep -f "Claude" > /dev/null; then
    echo "📱 Claude Desktop is running - terminating..."
    pkill -f "Claude"
    sleep 2
    echo "✅ Claude Desktop terminated"
else
    echo "ℹ️  Claude Desktop not running"
fi

# Wait a moment for cleanup
echo "⏳ Waiting for cleanup..."
sleep 3

# Restart Claude Desktop
echo "🚀 Starting Claude Desktop..."
open -a "Claude"

# Wait for startup
echo "⏳ Waiting for Claude Desktop to initialize..."
sleep 5

echo "✅ Claude Desktop restarted!"
echo ""
echo "🧪 Next Steps:"
echo "1. Test terminal command execution"
echo "2. Run validation tests"
echo "3. Update Linear issue status"
