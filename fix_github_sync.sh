#!/bin/bash

# Fix GitHub sync conflict - merge remote README with local changes

echo "🔧 Fixing GitHub sync conflict..."
cd /Users/zeh/Local_Projects/Strategy_agents

echo "📥 Fetching remote changes..."
git fetch origin

echo "🔀 Merging remote README with local changes..."
git merge origin/main --allow-unrelated-histories -m "Merge remote README with local n8n workflow sync"

if [ $? -eq 0 ]; then
    echo "✅ Merge successful!"
    
    echo "🚀 Pushing all changes to GitHub..."
    git push origin main
    
    if [ $? -eq 0 ]; then
        echo "🎉 SUCCESS! Everything is now synced to GitHub!"
        echo ""
        echo "📊 Final status:"
        git log --oneline -5
        echo ""
        echo "🔗 View your workflows at:"
        echo "https://github.com/peguesi/Strategy_agents/tree/main/n8n/workflows"
        echo ""
        echo "🎯 Test the complete sync system:"
        echo "./n8n/scripts/sync_workflows.sh status"
    else
        echo "❌ Push failed"
    fi
else
    echo "❌ Merge failed - manual intervention needed"
    echo "Try: git status"
fi
