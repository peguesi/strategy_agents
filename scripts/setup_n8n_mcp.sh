#!/bin/bash
chmod +x "$0"

echo "🔄 Setting up n8n MCP Server for Complete Workflow Control..."
echo "=============================================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 Pre-flight checks:${NC}"

# Check if n8n is running
if curl -s http://localhost:5678/api/v1/workflows > /dev/null 2>&1; then
    echo -e "${GREEN}✅ n8n is running on port 5678${NC}"
else
    echo -e "${YELLOW}⚠️ n8n not responding on port 5678${NC}"
    echo -e "${BLUE}To start n8n manually: n8n start${NC}"
fi

# Check n8n MCP server file
if [ -f "/Users/zeh/Local_Projects/Strategy_agents/mcp/n8n/n8n_mcp_server.py" ]; then
    echo -e "${GREEN}✅ n8n MCP server file exists${NC}"
    chmod +x "/Users/zeh/Local_Projects/Strategy_agents/mcp/n8n/n8n_mcp_server.py"
else
    echo -e "${RED}❌ n8n MCP server file not found${NC}"
    exit 1
fi

# Check Claude Desktop config
if [ -f ~/.config/claude-desktop/config.json ]; then
    echo -e "${GREEN}✅ Claude Desktop config exists${NC}"
    
    if grep -q "n8n-workflow" ~/.config/claude-desktop/config.json; then
        echo -e "${GREEN}✅ n8n MCP server configured in Claude Desktop${NC}"
    else
        echo -e "${YELLOW}⚠️ n8n MCP server not found in Claude config${NC}"
    fi
else
    echo -e "${RED}❌ Claude Desktop config not found${NC}"
fi

echo ""
echo -e "${BLUE}🎯 Available n8n MCP Tools:${NC}"
echo ""
echo "📋 **Workflow Management:**"
echo "  • list-workflows - List all workflows with status"
echo "  • get-workflow - Get detailed workflow information"
echo "  • activate-workflow - Enable workflow execution"
echo "  • deactivate-workflow - Disable workflow execution"
echo "  • export-workflow - Backup workflow configuration"
echo ""
echo "⚡ **Execution Control:**"
echo "  • execute-workflow - Manually trigger workflow"
echo "  • list-executions - View recent execution history"
echo "  • get-execution - Get detailed execution info"
echo "  • stop-execution - Cancel running execution"
echo ""
echo "📊 **Analytics & Optimization:**"
echo "  • analyze-workflow-performance - Performance analysis"
echo "  • funnel-analysis - Conversion funnel optimization"
echo "  • get-system-health - n8n system status"

echo ""
echo -e "${BLUE}🧪 Test Commands for Claude:${NC}"
echo ""
echo -e "${YELLOW}1. Workflow Management:${NC}"
echo '   "List all my n8n workflows"'
echo '   "Show me details about the Strategic PM Agent workflow"'
echo '   "Activate the lead generation workflow"'
echo ""
echo -e "${YELLOW}2. Execution Control:${NC}"
echo '   "Execute the client onboarding workflow manually"'
echo '   "Show me recent execution history"'
echo '   "Check the system health of n8n"'
echo ""
echo -e "${YELLOW}3. Funnel Optimization:${NC}"
echo '   "Analyze performance of the revenue funnel workflows"'
echo '   "Export the Strategic PM Agent workflow for backup"'

echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "1. 🔄 Restart Claude Desktop to load n8n MCP server"
echo "2. 🖥️ Ensure n8n is running on localhost:5678"
echo "3. 🧪 Test workflow management commands in Claude"
echo ""
echo -e "${GREEN}🚀 n8n MCP Server ready for complete workflow control!${NC}"
