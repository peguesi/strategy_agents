#!/bin/bash

# Make scripts executable
chmod +x /Users/zeh/Local_Projects/Strategy_agents/n8n/scripts/sync_workflows.sh
chmod +x /Users/zeh/Local_Projects/Strategy_agents/n8n/scripts/quick_export.sh

echo "✅ Scripts made executable"

# Run quick export to test the API connection
echo "🔄 Testing API connection and exporting workflows..."
/Users/zeh/Local_Projects/Strategy_agents/n8n/scripts/quick_export.sh

echo "📁 Workflow directory contents:"
ls -la /Users/zeh/Local_Projects/Strategy_agents/n8n/workflows/

echo "🎯 Ready to sync! Next steps:"
echo "1. Run: ./n8n/scripts/sync_workflows.sh status    # Check current status"
echo "2. Run: ./n8n/scripts/sync_workflows.sh sync     # Full sync with GitHub"
echo "3. Run: ./n8n/scripts/sync_workflows.sh pull     # Just pull workflows"
