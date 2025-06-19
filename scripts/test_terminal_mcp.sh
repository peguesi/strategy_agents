#!/bin/bash
chmod +x "$0"

echo "🧪 Testing Enhanced Screenpipe MCP with Terminal Control..."
echo "========================================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 Pre-flight checks:${NC}"

# Check if Screenpipe is running
if curl -s http://localhost:3030/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Screenpipe API is running on port 3030${NC}"
else
    echo -e "${YELLOW}⚠️ Screenpipe API not responding - start Screenpipe first${NC}"
fi

# Check Claude Desktop config
if [ -f ~/.config/claude-desktop/config.json ]; then
    echo -e "${GREEN}✅ Claude Desktop config exists${NC}"
    
    if grep -q "screenpipe-terminal" ~/.config/claude-desktop/config.json; then
        echo -e "${GREEN}✅ Enhanced MCP server configured${NC}"
    else
        echo -e "${YELLOW}⚠️ Enhanced MCP server not found in config${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Claude Desktop config not found${NC}"
fi

# Check if MCP server file exists
if [ -f "/Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp/screenpipe_server_with_terminal.py" ]; then
    echo -e "${GREEN}✅ Enhanced MCP server file exists${NC}"
else
    echo -e "${YELLOW}⚠️ Enhanced MCP server file not found${NC}"
fi

# Check if iTerm2 or Terminal is available
if [ -d "/Applications/iTerm.app" ]; then
    echo -e "${GREEN}✅ iTerm2 is available${NC}"
elif [ -d "/Applications/Utilities/Terminal.app" ]; then
    echo -e "${GREEN}✅ Terminal app is available${NC}"
else
    echo -e "${YELLOW}⚠️ No terminal application found${NC}"
fi

echo ""
echo -e "${BLUE}🎯 Available Terminal Control Features:${NC}"
echo ""
echo "✅ execute-terminal-command - Run commands in active terminal"
echo "✅ send-control-character - Send Ctrl-C, Ctrl-Z, etc."
echo "✅ start-repl - Start Python, Node.js, or other REPLs"
echo "✅ search-content - Search screenpipe recorded content"
echo "✅ analyze-productivity - Analyze work patterns"
echo "✅ find-coding-sessions - Find recent development work"
echo "✅ pixel-control - Mouse and keyboard control"
echo "✅ open-application - Open macOS applications"
echo "✅ open-url - Open URLs in browser"

echo ""
echo -e "${BLUE}🧪 Test Commands for Claude:${NC}"
echo ""
echo -e "${YELLOW}1. Terminal Control:${NC}"
echo '   "Execute this command in my terminal: echo Hello from Claude!"'
echo '   "Run pwd in my terminal and show me the current directory"'
echo '   "Start a Python REPL in my terminal"'
echo '   "Send Ctrl-C to my terminal to stop the current process"'
echo ""
echo -e "${YELLOW}2. Development Workflow:${NC}"
echo '   "Show me my recent coding sessions from the last 4 hours"'
echo '   "Start a Node.js REPL and run console.log(Hello World)"'
echo '   "Execute git status in my terminal"'
echo ""
echo -e "${YELLOW}3. Productivity Analysis:${NC}"
echo '   "Analyze my productivity patterns from the last 6 hours"'
echo '   "Search for recent Linear activity in my screen recordings"'
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "1. 🔄 Restart Claude Desktop to load the new MCP server"
echo "2. 🖥️ Open iTerm2 or Terminal"
echo "3. 🧪 Try the test commands above in Claude"
echo ""
echo -e "${GREEN}🚀 Enhanced MCP Server with Terminal Control is ready!${NC}"
