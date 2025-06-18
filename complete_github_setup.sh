#!/bin/bash

# Complete GitHub setup and workflow sync for Strategy_agents

echo "🎯 Strategy Agents - GitHub Integration Setup"
echo "=============================================="
echo ""

cd /Users/zeh/Local_Projects/Strategy_agents

# Step 1: Check current git status
echo "📊 STEP 1: Current Git Status"
echo "Current directory: $(pwd)"
echo "Git status:"
git status --short
echo ""

# Step 2: Check for existing remotes
echo "🌐 STEP 2: Remote Repository Status"
if git remote | grep -q "origin"; then
    echo "✅ Origin remote exists:"
    git remote -v
else
    echo "❌ No origin remote found"
    echo ""
    echo "🔧 SETTING UP GITHUB REMOTE"
    echo "Choose your preferred method:"
    echo ""
    echo "Option A - HTTPS (recommended for most users):"
    echo "git remote add origin https://github.com/YOUR_USERNAME/Strategy_agents.git"
    echo ""
    echo "Option B - SSH (if you have SSH keys set up):"
    echo "git remote add origin git@github.com:YOUR_USERNAME/Strategy_agents.git"
    echo ""
    echo "⚠️ IMPORTANT: Replace YOUR_USERNAME with your actual GitHub username"
    echo ""
    echo "To find your GitHub username:"
    echo "1. Go to github.com"
    echo "2. Click your profile picture (top right)"
    echo "3. Your username is shown below your name"
    echo ""
fi

# Step 3: Show current workflows
echo "📁 STEP 3: Current n8n Workflows"
if [ -d "n8n/workflows" ]; then
    echo "Workflows ready to sync:"
    ls -la n8n/workflows/*.json 2>/dev/null | while read -r line; do
        filename=$(basename $(echo "$line" | awk '{print $NF}'))
        size=$(echo "$line" | awk '{print $5}')
        echo "  📄 $filename ($size bytes)"
    done
    echo ""
    
    echo "Workflow summary:"
    if [ -f "n8n/workflows/workflows_summary.md" ]; then
        grep -E "### |Status.*:" n8n/workflows/workflows_summary.md | head -10
    fi
else
    echo "❌ No workflows directory found"
fi

echo ""
echo "🚀 STEP 4: Next Actions Required"
echo "================================"
echo ""

if ! git remote | grep -q "origin"; then
    echo "1️⃣ CREATE GITHUB REPOSITORY:"
    echo "   • Go to https://github.com/new"
    echo "   • Repository name: Strategy_agents"
    echo "   • Make it Private (recommended for business)"
    echo "   • Don't initialize with README (you already have files)"
    echo ""
    
    echo "2️⃣ ADD REMOTE (run ONE of these commands):"
    echo "   HTTPS: git remote add origin https://github.com/YOUR_USERNAME/Strategy_agents.git"
    echo "   SSH:   git remote add origin git@github.com:YOUR_USERNAME/Strategy_agents.git"
    echo ""
    
    echo "3️⃣ PUSH TO GITHUB:"
    echo "   git push -u origin main"
    echo ""
    
    echo "4️⃣ RE-RUN WORKFLOW SYNC:"
    echo "   ./n8n/scripts/sync_workflows.sh sync"
    echo ""
    
else
    echo "1️⃣ PUSH CURRENT CHANGES:"
    if git log --oneline origin/main..HEAD 2>/dev/null | head -1; then
        echo "   Unpushed commits found:"
        git log --oneline origin/main..HEAD | head -5
        echo "   Run: git push origin main"
    else
        echo "   Run: git push -u origin main"
    fi
    echo ""
    
    echo "2️⃣ SETUP GITHUB SECRETS (for automated backup):"
    echo "   • Go to your GitHub repository"
    echo "   • Settings → Secrets and variables → Actions"
    echo "   • Add New repository secret:"
    echo "     Name: N8N_API_KEY"
    echo "     Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI3MWM2ZjRiNC00ZTIwLTQ4YjUtODkyMi02NzUxNjMxMzJkZmEiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzUwMDc5MjQwfQ.1Tf5YHdlDrMObOM8fOw1bE19ltNfgo3ZVMJCITJejVs"
    echo ""
    echo "   • Add another secret:"
    echo "     Name: N8N_API_URL"
    echo "     Value: https://n8n-agent-gdctd7f5e6e0a5br.eastus2-01.azurewebsites.net:443/api/v1"
    echo ""
fi

echo "💡 HELPFUL COMMANDS:"
echo "   Check git status:          git status"
echo "   View remotes:              git remote -v"
echo "   Test workflow sync:        ./n8n/scripts/sync_workflows.sh status"
echo "   Manual workflow export:    ./n8n/scripts/quick_export.sh"
echo ""

echo "📚 DOCUMENTATION:"
echo "   Complete guide: ./N8N_SYNC_SETUP.md"
echo "   Linear task: PEG-62 (n8n Workflow Sync Setup Complete)"
echo ""

echo "✅ Setup script complete!"
echo "Follow the numbered steps above to complete GitHub integration."
