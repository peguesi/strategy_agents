#!/bin/bash

# Manual push to GitHub after setting up remote

cd /Users/zeh/Local_Projects/Strategy_agents

echo "🚀 Pushing n8n workflows to GitHub..."

# Check if origin remote exists
if ! git remote | grep -q "origin"; then
    echo "❌ No GitHub origin remote found!"
    echo "Please run: ./setup_github_remote.sh first"
    exit 1
fi

# Check git status
echo "📊 Git status:"
git status --short

# Show what will be pushed
echo ""
echo "📦 Files to be pushed:"
git log --oneline origin/main..HEAD 2>/dev/null || git log --oneline -5

# Push to GitHub
echo ""
echo "🔄 Pushing to GitHub..."
if git push origin main; then
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "🎯 Your n8n workflows are now synced:"
    echo "• v1 (Calamity Profiteer Agent) - Active"
    echo "• PM_Agent (Strategic PM Agent) - Inactive" 
    echo ""
    echo "🔗 View your workflows:"
    echo "https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]//' | sed 's/.git$//')/tree/main/n8n/workflows"
else
    echo "❌ Failed to push to GitHub"
    echo "Common issues:"
    echo "1. Repository doesn't exist on GitHub"
    echo "2. No permission to push"
    echo "3. Branch mismatch (try: git push -u origin main)"
fi
