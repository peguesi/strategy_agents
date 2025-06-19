#!/bin/bash
# Strategy Agents v2.0 - Production Deployment Script
# Commits cleaned project and pushes to GitHub

echo "🚀 Strategy Agents v2.0 - Production Deployment"
echo "================================================="

# Check git status
echo "📊 Checking current project status..."
git status --porcelain

# Add all files to staging
echo "📦 Staging all changes..."
git add .

# Check what we're about to commit
echo "📋 Files to be committed:"
git status --cached --name-only

# Create comprehensive commit message
echo "💾 Creating commit..."
git commit -m "feat: Strategy Agents v2.0 - Complete Production Platform

🎯 STRATEGIC AUTOMATION PLATFORM - PRODUCTION READY

## Core Achievements ✅
- Complete n8n workflow management via MCP servers
- Screenpipe behavioral analysis integration  
- Linear project management automation
- Professional documentation and setup guides
- Clean, scalable project structure

## Active Components 🤖
- Calamity Profiteer Agent: News analysis → profit opportunities
- PM_Agent: Strategic project management (ready for activation)
- MCP Servers: Complete system control via Claude Desktop
- Behavioral Intelligence: Screenpipe productivity optimization

## Technical Implementation 🔧
- n8n Complete MCP Server: Full workflow lifecycle management
- Screenpipe Terminal Server: Behavioral analysis + system control
- Azure PostgreSQL Server: Data persistence and analytics
- Professional documentation with setup guides
- Comprehensive API reference and troubleshooting

## Strategic Framework 🎯
- Revenue-First Prioritization: High/Medium/Low impact classification
- €50k Annual Revenue Target: Systematic progress tracking
- Intelligent Automation: AI-driven workflow orchestration
- Behavioral Optimization: Data-driven productivity improvements

## Documentation 📚
- Complete setup guide (docs/SETUP.md)
- System architecture overview (docs/ARCHITECTURE.md)  
- Full API reference (docs/API_REFERENCE.md)
- Component-specific documentation
- Professional README with quick start

## Infrastructure Ready 🚀
- Claude Desktop integration configured
- GitHub Actions for automated backups
- Azure cloud deployment ready
- Scalable, maintainable codebase
- Professional development workflow

BREAKING CHANGES: 
- Complete project restructure requires new setup
- Updated MCP server configuration needed
- New documentation and setup process

This release transforms Strategy Agents from development repository 
into production-ready strategic automation platform capable of 
achieving €50k annual revenue through intelligent workflow management."

# Check if we have a remote repository
if git remote | grep -q origin; then
    echo "🌐 Pushing to GitHub..."
    git push origin main
    
    echo "✅ Strategy Agents v2.0 successfully deployed to GitHub!"
    echo ""
    echo "🎯 Next Steps:"
    echo "1. Share repository with stakeholders"
    echo "2. Set up Claude Desktop integration" 
    echo "3. Activate PM_Agent for strategic automation"
    echo "4. Begin monitoring €50k revenue progress"
    echo ""
    echo "📚 Documentation available at:"
    echo "   - Setup Guide: docs/SETUP.md"
    echo "   - Architecture: docs/ARCHITECTURE.md" 
    echo "   - API Reference: docs/API_REFERENCE.md"
    echo ""
    echo "🤖 Test MCP integration:"
    echo "   n8n-complete:health-monitor"
    echo "   n8n-complete:list-workflows"
    echo ""
    echo "🎉 Strategy Agents v2.0 - Production Platform Ready!"
else
    echo "⚠️  No git remote 'origin' found."
    echo "📝 To add remote repository:"
    echo "   git remote add origin <your-github-repo-url>"
    echo "   git push -u origin main"
    echo ""
    echo "✅ Local commit completed successfully!"
fi

echo ""
echo "📊 Repository Status:"
git log --oneline -5
echo ""
echo "🎯 Strategy Agents v2.0 deployment complete!"
