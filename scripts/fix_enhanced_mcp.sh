#!/bin/bash

echo "🔧 Fixing Enhanced Screenpipe MCP Server..."

# Make the enhanced server executable
chmod +x /Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp/screenpipe_server_with_terminal.py

# Check if Python dependencies are available
echo "📦 Checking Python dependencies..."

python3 -c "
import mcp.server
import mcp.types
import httpx
import nest_asyncio
print('✅ All MCP dependencies available')
" 2>/dev/null && echo "✅ Python dependencies OK" || echo "❌ Missing MCP dependencies"

# Test the enhanced server directly
echo "🧪 Testing enhanced MCP server..."

cd /Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp

# Try to import the server
python3 -c "
import sys
sys.path.append('.')
try:
    import screenpipe_server_with_terminal
    print('✅ Enhanced MCP server imports successfully')
except Exception as e:
    print(f'❌ Import error: {e}')
"

echo ""
echo "🎯 Next steps:"
echo "1. Restart Claude Desktop completely (Cmd+Q then reopen)"
echo "2. Test the terminal commands"
echo "3. If still not working, we'll debug the MCP server startup"
echo ""
echo "🚀 Enhanced MCP server should now be ready!"
