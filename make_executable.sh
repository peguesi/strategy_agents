#!/bin/bash

# Make all scripts executable
chmod +x /Users/zeh/Local_Projects/Strategy_agents/setup_github_remote.sh
chmod +x /Users/zeh/Local_Projects/Strategy_agents/push_to_github.sh
chmod +x /Users/zeh/Local_Projects/Strategy_agents/complete_github_setup.sh
chmod +x /Users/zeh/Local_Projects/Strategy_agents/test_export.sh
chmod +x /Users/zeh/Local_Projects/Strategy_agents/n8n/scripts/sync_workflows.sh
chmod +x /Users/zeh/Local_Projects/Strategy_agents/n8n/scripts/quick_export.sh

echo "✅ All scripts are now executable!"
echo ""
echo "🎯 Quick Start Commands:"
echo "  ./complete_github_setup.sh    # Complete setup guide"
echo "  ./test_export.sh              # Test n8n connection"
echo "  ./n8n/scripts/sync_workflows.sh status  # Check workflow status"
echo ""
