#!/bin/bash

# Strategy Agents Repository Setup Script
# Initializes Git repository and GitHub integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Main setup function
main() {
    log_info "🚀 Setting up Strategy Agents repository..."
    
    # Change to project directory
    cd /Users/zeh/Local_Projects/Strategy_agents
    
    # Initialize Git repository
    log_step "1. Initializing Git repository..."
    if [ ! -d ".git" ]; then
        git init
        log_info "Git repository initialized ✓"
    else
        log_info "Git repository already exists ✓"
    fi
    
    # Create initial commit
    log_step "2. Creating initial commit..."
    git add .
    if git diff --staged --quiet; then
        log_warn "No changes to commit"
    else
        git commit -m "Initial commit: Strategy Agents ecosystem

- Complete project structure
- PostgreSQL + pgvector integration  
- n8n workflow automation setup
- MCP server configurations
- Screenpipe behavioral monitoring
- Linear integration framework
- Azure infrastructure templates"
        log_info "Initial commit created ✓"
    fi
    
    # Make scripts executable
    log_step "3. Setting script permissions..."
    chmod +x n8n/scripts/sync_workflows.sh
    log_info "Scripts made executable ✓"
    
    # Test n8n sync script if n8n is running
    log_step "4. Testing n8n workflow sync..."
    if curl -s http://localhost:5678/healthz > /dev/null 2>&1; then
        log_info "n8n is running, testing workflow sync..."
        ./n8n/scripts/sync_workflows.sh
        log_info "Workflow sync test completed ✓"
    else
        log_warn "n8n is not running, skipping workflow sync test"
        log_info "To test later, run: ./n8n/scripts/sync_workflows.sh"
    fi
    
    # Setup instructions
    log_step "5. Next steps..."
    echo ""
    echo "🎯 Repository setup complete! Next steps:"
    echo ""
    echo "1. Create GitHub repository:"
    echo "   gh repo create strategy-agents --public --description 'AI agent ecosystem for strategic operations'"
    echo ""
    echo "2. Add remote and push:"
    echo "   git remote add origin https://github.com/YOUR_USERNAME/strategy-agents.git"
    echo "   git branch -M main"
    echo "   git push -u origin main"
    echo ""
    echo "3. Set up environment variables:"
    echo "   cp .env.example .env"
    echo "   # Edit .env with your actual credentials"
    echo ""
    echo "4. Test n8n workflow sync:"
    echo "   ./n8n/scripts/sync_workflows.sh"
    echo ""
    echo "🚀 Your Strategy Agents ecosystem is ready!"
}

# Run main function
main "$@"
