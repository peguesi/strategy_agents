#!/bin/bash

# Setup GitHub remote for Strategy_agents project

echo "🔧 Setting up GitHub remote..."

# Navigate to project directory
cd /Users/zeh/Local_Projects/Strategy_agents

# Check current git status
echo "📊 Current git status:"
git status
echo ""

# Check current remotes
echo "🌐 Current remotes:"
git remote -v
echo ""

# Check if we need to add origin
if ! git remote | grep -q "origin"; then
    echo "➕ Adding GitHub origin remote..."
    
    # You'll need to replace this with your actual GitHub repository URL
    # Common formats:
    # HTTPS: https://github.com/username/Strategy_agents.git
    # SSH: git@github.com:username/Strategy_agents.git
    
    echo "❓ Please provide your GitHub repository URL:"
    echo "Format: https://github.com/yourusername/Strategy_agents.git"
    echo "Or: git@github.com:yourusername/Strategy_agents.git"
    echo ""
    echo "Run this command manually:"
    echo "git remote add origin YOUR_GITHUB_URL"
    echo ""
else
    echo "✅ Origin remote already exists"
    git remote -v
fi

echo "🔍 Checking if we can push..."
if git push --dry-run origin main 2>/dev/null; then
    echo "✅ Ready to push to GitHub!"
    echo ""
    echo "🚀 To complete the sync, run:"
    echo "git push origin main"
    echo ""
    echo "🔄 Then re-run the workflow sync:"
    echo "./n8n/scripts/sync_workflows.sh sync"
else
    echo "⚠️ Cannot push to GitHub yet."
    echo "Please set up the remote repository first:"
    echo ""
    echo "1. Create a GitHub repository named 'Strategy_agents'"
    echo "2. Add the remote: git remote add origin YOUR_GITHUB_URL"
    echo "3. Push: git push -u origin main"
fi

echo ""
echo "📁 Current workflow files:"
ls -la n8n/workflows/*.json 2>/dev/null || echo "No workflow JSON files found"
