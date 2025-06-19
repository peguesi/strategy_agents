#!/bin/bash

echo "🔍 Diagnosing MCP Server Status..."
echo "=================================="

# Check Claude Desktop config
echo "📋 Claude Desktop Configuration:"
if [ -f ~/.config/claude-desktop/config.json ]; then
    echo "✅ Config file exists"
    if grep -q "screenpipe-terminal" ~/.config/claude-desktop/config.json; then
        echo "✅ Enhanced MCP server configured"
    else
        echo "❌ Enhanced MCP server not found in config"
    fi
else
    echo "❌ No Claude Desktop config found"
fi

# Check enhanced server file
echo ""
echo "📁 Enhanced MCP Server File:"
if [ -f "/Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp/screenpipe_server_with_terminal.py" ]; then
    echo "✅ Enhanced server file exists"
    echo "📊 File size: $(wc -l < /Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp/screenpipe_server_with_terminal.py) lines"
else
    echo "❌ Enhanced server file missing"
fi

# Check if Screenpipe API is running
echo ""
echo "🌐 Screenpipe API Status:"
if curl -s http://localhost:3030/health > /dev/null 2>&1; then
    echo "✅ Screenpipe API responding on port 3030"
else
    echo "❌ Screenpipe API not responding"
fi

# Check Python and MCP dependencies
echo ""
echo "🐍 Python & Dependencies:"
python3 --version
echo -n "MCP library: "
python3 -c "import mcp; print('✅ Available')" 2>/dev/null || echo "❌ Missing"
echo -n "httpx library: "
python3 -c "import httpx; print('✅ Available')" 2>/dev/null || echo "❌ Missing"

# Test enhanced server syntax
echo ""
echo "🧪 Enhanced Server Syntax Check:"
python3 -m py_compile /Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp/screenpipe_server_with_terminal.py 2>/dev/null && echo "✅ Syntax OK" || echo "❌ Syntax errors"

echo ""
echo "🎯 Diagnosis complete!"
echo ""
echo "If enhanced server is not loading:"
echo "1. Restart Claude Desktop (Cmd+Q then reopen)"
echo "2. Check Console.app for Claude Desktop errors"
echo "3. Verify MCP dependencies are installed"
