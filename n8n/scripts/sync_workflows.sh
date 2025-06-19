#!/bin/bash

# n8n Workflow Sync Script
# Syncs workflows between n8n instance and GitHub repository

set -e

# Configuration
N8N_API_URL="https://n8n-agent-gdctd7f5e6e0a5br.eastus2-01.azurewebsites.net:443/api/v1"
# N8N_API_KEY now comes from environment variable
WORKFLOWS_DIR="/Users/zeh/Local_Projects/Strategy_agents/n8n/workflows"
REPO_DIR="/Users/zeh/Local_Projects/Strategy_agents"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get API key from environment variable
if [ -z "$N8N_API_KEY" ]; then
    log_error "N8N_API_KEY environment variable is required"
    log_info "Please set it in your .env file or export it:"
    log_info "export N8N_API_KEY='your_api_key_here'"
    exit 1
fi

# Create workflows directory if it doesn't exist
mkdir -p "$WORKFLOWS_DIR"

# Function to fetch workflows from n8n
fetch_workflows() {
    log_info "Fetching workflows from n8n instance..."
    
    response=$(curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" \
        -H "Content-Type: application/json" \
        "$N8N_API_URL/workflows")
    
    if [ $? -ne 0 ]; then
        log_error "Failed to fetch workflows from n8n"
        return 1
    fi
    
    echo "$response" | jq -r '.data[] | @json' | while read -r workflow; do
        workflow_id=$(echo "$workflow" | jq -r '.id')
        workflow_name=$(echo "$workflow" | jq -r '.name')
        workflow_active=$(echo "$workflow" | jq -r '.active')
        
        # Sanitize filename
        safe_name=$(echo "$workflow_name" | sed 's/[^a-zA-Z0-9._-]/_/g')
        filename="${safe_name}_${workflow_id}.json"
        
        log_info "Saving workflow: $workflow_name -> $filename"
        echo "$workflow" | jq '.' > "$WORKFLOWS_DIR/$filename"
        
        # Create metadata file
        cat > "$WORKFLOWS_DIR/${safe_name}_${workflow_id}.meta" << EOF
{
  "id": "$workflow_id",
  "name": "$workflow_name",
  "active": $workflow_active,
  "lastSync": "$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")",
  "filename": "$filename"
}
EOF
    done
    
    log_success "Workflows fetched successfully"
}

# Function to push specific workflow to n8n
push_workflow() {
    local workflow_file="$1"
    
    if [ ! -f "$workflow_file" ]; then
        log_error "Workflow file not found: $workflow_file"
        return 1
    fi
    
    log_info "Pushing workflow from: $workflow_file"
    
    # Extract workflow ID from file
    workflow_id=$(jq -r '.id' "$workflow_file")
    workflow_name=$(jq -r '.name' "$workflow_file")
    
    # Remove id from payload for creation/update
    payload=$(jq 'del(.id)' "$workflow_file")
    
    # Check if workflow exists
    existing=$(curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" \
        "$N8N_API_URL/workflows/$workflow_id" 2>/dev/null)
    
    if echo "$existing" | jq -e '.id' >/dev/null 2>&1; then
        # Update existing workflow
        log_info "Updating existing workflow: $workflow_name"
        response=$(curl -s -X PUT \
            -H "X-N8N-API-KEY: $N8N_API_KEY" \
            -H "Content-Type: application/json" \
            -d "$payload" \
            "$N8N_API_URL/workflows/$workflow_id")
    else
        # Create new workflow
        log_info "Creating new workflow: $workflow_name"
        response=$(curl -s -X POST \
            -H "X-N8N-API-KEY: $N8N_API_KEY" \
            -H "Content-Type: application/json" \
            -d "$payload" \
            "$N8N_API_URL/workflows")
    fi
    
    if echo "$response" | jq -e '.id' >/dev/null 2>&1; then
        log_success "Workflow pushed successfully: $workflow_name"
    else
        log_error "Failed to push workflow: $workflow_name"
        echo "$response" | jq '.'
        return 1
    fi
}

# Function to commit and push to GitHub
git_sync() {
    local commit_message="$1"
    
    cd "$REPO_DIR"
    
    log_info "Staging workflow changes..."
    git add n8n/workflows/
    
    # Check if there are changes to commit
    if git diff --staged --quiet; then
        log_info "No changes to commit"
        return 0
    fi
    
    log_info "Committing changes..."
    git commit -m "${commit_message:-"Update n8n workflows $(date +%Y-%m-%d_%H:%M:%S)"}"
    
    log_info "Pushing to GitHub..."
    git push origin main
    
    log_success "Changes pushed to GitHub"
}

# Function to create workflow summary
create_summary() {
    local summary_file="$WORKFLOWS_DIR/workflows_summary.md"
    
    log_info "Creating workflow summary..."
    
    cat > "$summary_file" << 'EOF'
# n8n Workflows Summary

This directory contains exported n8n workflows for the Strategy Agents project.

## Active Workflows

EOF
    
    find "$WORKFLOWS_DIR" -name "*.json" | while read -r workflow_file; do
        workflow_name=$(jq -r '.name' "$workflow_file")
        workflow_active=$(jq -r '.active' "$workflow_file")
        workflow_id=$(jq -r '.id' "$workflow_file")
        workflow_updated=$(jq -r '.updatedAt' "$workflow_file")
        
        if [ "$workflow_active" = "true" ]; then
            status="🟢 Active"
        else
            status="🔴 Inactive"
        fi
        
        cat >> "$summary_file" << EOF
### $workflow_name
- **Status**: $status
- **ID**: \`$workflow_id\`
- **Last Updated**: $workflow_updated
- **File**: \`$(basename "$workflow_file")\`

EOF
    done
    
    cat >> "$summary_file" << 'EOF'

## Sync Information

- **Last Sync**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
- **n8n Instance**: https://n8n-agent-gdctd7f5e6e0a5br.eastus2-01.azurewebsites.net
- **Total Workflows**: $(find . -name "*.json" | wc -l)

## Usage

To sync workflows:
```bash
# Pull latest from n8n
./scripts/sync_workflows.sh pull

# Push specific workflow to n8n
./scripts/sync_workflows.sh push workflows/workflow_file.json

# Full sync (pull + git commit + push)
./scripts/sync_workflows.sh sync
```
EOF
    
    # Replace placeholders with actual values
    total_workflows=$(find "$WORKFLOWS_DIR" -name "*.json" | wc -l)
    sed -i '' "s/\$(date -u +\"%Y-%m-%d %H:%M:%S UTC\")/$(date -u +"%Y-%m-%d %H:%M:%S UTC")/g" "$summary_file"
    sed -i '' "s/\$(find . -name \"\*.json\" | wc -l)/$total_workflows/g" "$summary_file"
    
    log_success "Workflow summary created: $summary_file"
}

# Main command handling
case "${1:-help}" in
    "pull")
        log_info "=== Pulling workflows from n8n ==="
        fetch_workflows
        create_summary
        log_success "Pull completed"
        ;;
    
    "push")
        if [ -z "$2" ]; then
            log_error "Please specify a workflow file to push"
            echo "Usage: $0 push <workflow_file.json>"
            exit 1
        fi
        log_info "=== Pushing workflow to n8n ==="
        push_workflow "$2"
        ;;
    
    "sync")
        log_info "=== Full sync: Pull -> Commit -> Push ==="
        fetch_workflows
        create_summary
        git_sync "Auto-sync n8n workflows"
        log_success "Full sync completed"
        ;;
    
    "status")
        log_info "=== Workflow Status ==="
        if [ ! -d "$WORKFLOWS_DIR" ] || [ -z "$(ls -A "$WORKFLOWS_DIR" 2>/dev/null)" ]; then
            log_warning "No workflows found locally. Run 'sync_workflows.sh pull' first."
            exit 0
        fi
        
        echo
        printf "%-30s %-10s %-20s %s\n" "Workflow Name" "Status" "Last Updated" "ID"
        printf "%-30s %-10s %-20s %s\n" "-------------" "------" "------------" "--"
        
        find "$WORKFLOWS_DIR" -name "*.json" | while read -r workflow_file; do
            name=$(jq -r '.name' "$workflow_file")
            active=$(jq -r '.active' "$workflow_file")
            updated=$(jq -r '.updatedAt' "$workflow_file" | cut -d'T' -f1)
            id=$(jq -r '.id' "$workflow_file")
            
            if [ "$active" = "true" ]; then
                status="🟢 Active"
            else
                status="🔴 Inactive"
            fi
            
            printf "%-30s %-10s %-20s %s\n" "$name" "$status" "$updated" "$id"
        done
        ;;
    
    "backup")
        log_info "=== Creating backup ==="
        backup_dir="$WORKFLOWS_DIR/backups/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        cp "$WORKFLOWS_DIR"/*.json "$backup_dir/" 2>/dev/null || true
        cp "$WORKFLOWS_DIR"/*.meta "$backup_dir/" 2>/dev/null || true
        log_success "Backup created: $backup_dir"
        ;;
    
    "help"|*)
        cat << EOF
n8n Workflow Sync Script

Usage: $0 <command> [options]

Commands:
  pull                    Pull all workflows from n8n instance
  push <workflow.json>    Push specific workflow to n8n instance
  sync                    Full sync: pull + git commit + push
  status                  Show status of local workflows
  backup                  Create backup of current workflows
  help                    Show this help message

Examples:
  $0 pull                                    # Fetch latest workflows
  $0 push workflows/my_workflow.json         # Push specific workflow
  $0 sync                                    # Full sync with git
  $0 status                                  # Show workflow status

Environment Variables:
  N8N_API_KEY             API key for n8n instance (required)

Files:
  n8n/credentials/api_key.txt               API key storage
  n8n/workflows/                            Local workflow storage
  n8n/workflows/workflows_summary.md        Workflow summary

EOF
        ;;
esac
