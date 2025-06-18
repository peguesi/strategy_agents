#!/bin/bash

# Quick resolution of GitHub merge conflict

echo "🔧 Resolving README merge conflict..."
cd /Users/zeh/Local_Projects/Strategy_agents

# Check what's in the conflicted README
echo "📄 Current README conflict:"
head -20 README.md

echo ""
echo "🛠️ Resolving conflict by keeping both versions..."

# Create a new README that combines both
cat > README.md << 'EOF'
# Strategy Agents

A comprehensive automation and strategic management system combining n8n workflows, Linear project management, and Screenpipe behavioral analysis to achieve €50k annual revenue targets.

## 🎯 Project Overview

This repository contains the complete Strategy Agents infrastructure designed to maximize revenue through intelligent workflow automation and strategic project management.

### Core Components

- **n8n Workflows**: Automated agents for news analysis and strategic project management
- **Linear Integration**: Strategic project tracking and revenue-focused task management  
- **Screenpipe Integration**: Behavioral analysis and productivity optimization
- **Azure Infrastructure**: Cloud-based deployment and scaling

## 🤖 n8n Workflows

### Active Workflows
- **v1 (Calamity Profiteer Agent)**: Real-time news analysis and profit opportunity detection
- **PM_Agent (Strategic PM Agent)**: Linear/Screenpipe integration for strategic management

### Workflow Management
```bash
# Sync workflows with GitHub
./n8n/scripts/sync_workflows.sh sync

# Check workflow status  
./n8n/scripts/sync_workflows.sh status

# Export workflows manually
./n8n/scripts/quick_export.sh
```

## 📊 Strategic Framework

**Goal**: €50k annual revenue through Simply BAU → AutomateBau → VibeCoding progression

### Revenue Impact Prioritization
1. **High Revenue**: Direct client work, immediately billable
2. **Medium Revenue**: Framework development enabling multiple clients  
3. **Low Revenue**: Research, operational tasks, system maintenance

## 🚀 Quick Start

1. **Setup n8n workflow sync**:
   ```bash
   ./complete_github_setup.sh
   ```

2. **Test connections**:
   ```bash
   ./test_export.sh
   ```

3. **Sync workflows**:
   ```bash
   ./n8n/scripts/sync_workflows.sh sync
   ```

## 📁 Directory Structure

```
Strategy_agents/
├── n8n/                          # n8n workflow automation
│   ├── workflows/                 # Exported workflow definitions
│   ├── scripts/                   # Sync and management scripts
│   └── credentials/               # API credentials (secure)
├── linear/                        # Linear project management integration
├── screenpipe/                    # Behavioral analysis integration
├── mcp/                          # Model Context Protocol implementations
└── .github/workflows/            # GitHub Actions for automation
```

## 🔧 Configuration

### Environment Variables
- `N8N_API_KEY`: n8n instance API key
- `N8N_URL`: n8n instance URL
- `LINEAR_API_KEY`: Linear workspace API key

### GitHub Secrets (for automated backups)
- `N8N_API_KEY`: For workflow sync
- `N8N_API_URL`: n8n API endpoint

## 📚 Documentation

- [n8n Sync Setup Guide](N8N_SYNC_SETUP.md)
- [Linear Task: PEG-62](https://linear.app/pegues-innovations/issue/PEG-62)

## 🎯 Strategic Objectives

- **Revenue Maximization**: Focus on high-revenue activities
- **Process Automation**: Reduce manual work through intelligent workflows
- **Behavioral Intelligence**: Optimize productivity through Screenpipe analysis
- **Strategic Alignment**: Ensure all work contributes to €50k revenue goal

## 🔒 Security

- Local credential storage with secure GitHub secrets
- No sensitive data in repository
- Automated daily backups
- Version controlled workflow definitions

---

*Part of the Pegues Innovations strategic automation initiative.*
EOF

echo "✅ README conflict resolved!"

# Add all files and commit
echo "📦 Adding all files..."
git add .

echo "💾 Committing resolved merge..."
git commit -m "Resolve README merge conflict and sync n8n workflows

- Merged remote README with local Strategy Agents infrastructure
- Added complete n8n workflow sync system
- Included both active workflows: v1 (Calamity Profiteer) and PM_Agent (Strategic PM)
- Added automated GitHub backup system
- Ready for strategic workflow management"

if [ $? -eq 0 ]; then
    echo "🚀 Pushing to GitHub..."
    git push origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 SUCCESS! Everything synced to GitHub!"
        echo ""
        echo "🔗 View your repository:"
        echo "https://github.com/peguesi/Strategy_agents"
        echo ""
        echo "📊 View your workflows:"
        echo "https://github.com/peguesi/Strategy_agents/tree/main/n8n/workflows"
        echo ""
        echo "🎯 Next: Set up GitHub secrets for automated backups"
        echo "Go to: https://github.com/peguesi/Strategy_agents/settings/secrets/actions"
    else
        echo "❌ Push failed"
    fi
else
    echo "❌ Commit failed"
fi
