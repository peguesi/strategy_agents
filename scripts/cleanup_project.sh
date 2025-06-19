#!/bin/bash

# Clean up Strategy_agents project - remove unnecessary scripts and organize

echo "🧹 Cleaning up Strategy_agents project..."
cd /Users/zeh/Local_Projects/Strategy_agents

echo "📋 BEFORE cleanup:"
echo "Root directory files:"
ls -1 *.sh *.md | grep -v README.md | head -10

echo ""
echo "🗑️ Removing temporary setup scripts..."

# Remove temporary GitHub setup scripts (no longer needed)
rm -f complete_github_setup.sh
rm -f fix_github_sync.sh  
rm -f make_executable.sh
rm -f push_to_github.sh
rm -f resolve_conflict.sh
rm -f setup_github_remote.sh
rm -f setup_sync.sh
rm -f test_export.sh

echo "✅ Removed GitHub setup scripts"

# Remove temporary n8n debug scripts
rm -f n8n/scripts/debug_api.sh
rm -f n8n/scripts/test_raw.sh
rm -f n8n/scripts/raw.log

echo "✅ Removed n8n debug scripts"

# Keep only essential documentation
echo ""
echo "📚 Organizing documentation..."

# Move the comprehensive setup guide to docs folder
mkdir -p docs
mv N8N_SYNC_SETUP.md docs/ 2>/dev/null

echo "✅ Moved documentation to docs/"

echo ""
echo "📋 AFTER cleanup - Essential files remaining:"
echo ""
echo "🔧 Core Scripts:"
echo "  ./setup.sh                           # Main project setup"
echo "  ./n8n/scripts/sync_workflows.sh      # n8n workflow sync (main tool)"
echo "  ./n8n/scripts/quick_export.sh        # Quick workflow export"
echo ""

echo "📚 Documentation:"
echo "  ./README.md                          # Main project documentation"
echo "  ./docs/N8N_SYNC_SETUP.md            # Detailed n8n setup guide"
echo ""

echo "⚙️ Configuration:"
echo "  ./.env                               # Environment variables"
echo "  ./.github/workflows/n8n-sync.yml    # Automated GitHub backup"
echo "  ./n8n/credentials/api_key.txt        # n8n API key (secure)"
echo ""

echo "📁 Project Structure:"
echo "  ./n8n/workflows/                     # Your synced workflows"
echo "  ./linear/                            # Linear integration"
echo "  ./screenpipe/                        # Screenpipe integration" 
echo "  ./mcp/                               # MCP implementations"
echo ""

echo "🎯 Quick Commands:"
echo "  ./n8n/scripts/sync_workflows.sh status    # Check workflow status"
echo "  ./n8n/scripts/sync_workflows.sh sync      # Full sync with GitHub"
echo "  ./n8n/scripts/sync_workflows.sh pull      # Pull from n8n only"
echo ""

# Show current workflow status
if [ -f "n8n/scripts/sync_workflows.sh" ]; then
    echo "📊 Current Workflow Status:"
    ./n8n/scripts/sync_workflows.sh status | tail -10
fi

echo ""
echo "✨ Project cleanup complete!"
echo "🎯 Your Strategy_agents project is now organized and ready for strategic work."
