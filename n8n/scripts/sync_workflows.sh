#!/bin/bash

# n8n Workflow Sync Script
# Exports n8n workflows to the repository for version control

set -e

# Configuration
N8N_HOST="${N8N_HOST:-localhost}"
N8N_PORT="${N8N_PORT:-5678}"
N8N_PROTOCOL="${N8N_PROTOCOL:-http}"
WORKFLOWS_DIR="$(dirname "$0")/../workflows"
BACKUP_DIR="$(dirname "$0")/../backups/$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if n8n is running
check_n8n() {
    log_info "Checking n8n connection..."
    if ! curl -s "${N8N_PROTOCOL}://${N8N_HOST}:${N8N_PORT}/healthz" > /dev/null 2>&1; then
        log_error "n8n is not running or not accessible at ${N8N_PROTOCOL}://${N8N_HOST}:${N8N_PORT}"
        log_info "Please start n8n with: n8n start"
        exit 1
    fi
    log_info "n8n is running ✓"
}

# Create backup of existing workflows
backup_workflows() {
    if [ -d "$WORKFLOWS_DIR" ] && [ "$(ls -A $WORKFLOWS_DIR)" ]; then
        log_info "Creating backup of existing workflows..."
        mkdir -p "$BACKUP_DIR"
        cp -r "$WORKFLOWS_DIR"/* "$BACKUP_DIR/"
        log_info "Backup created at: $BACKUP_DIR"
    fi
}

# Export workflows from n8n
export_workflows() {
    log_info "Exporting workflows from n8n..."
    
    # Create workflows directory if it doesn't exist
    mkdir -p "$WORKFLOWS_DIR"
    
    # Get list of workflows
    WORKFLOWS=$(curl -s "${N8N_PROTOCOL}://${N8N_HOST}:${N8N_PORT}/rest/workflows" | jq -r '.[].id')
    
    if [ -z "$WORKFLOWS" ]; then
        log_warn "No workflows found in n8n"
        return
    fi
    
    # Export each workflow
    for workflow_id in $WORKFLOWS; do
        log_info "Exporting workflow: $workflow_id"
        
        # Get workflow details
        WORKFLOW_DATA=$(curl -s "${N8N_PROTOCOL}://${N8N_HOST}:${N8N_PORT}/rest/workflows/$workflow_id")
        WORKFLOW_NAME=$(echo "$WORKFLOW_DATA" | jq -r '.name')
        
        # Sanitize filename
        SAFE_NAME=$(echo "$WORKFLOW_NAME" | sed 's/[^a-zA-Z0-9_-]/_/g' | tr '[:upper:]' '[:lower:]')
        
        # Save workflow to file
        echo "$WORKFLOW_DATA" | jq '.' > "$WORKFLOWS_DIR/${SAFE_NAME}.json"
        log_info "Saved: ${SAFE_NAME}.json"
    done
}

# Generate workflow index
generate_index() {
    log_info "Generating workflow index..."
    
    cat > "$WORKFLOWS_DIR/README.md" << EOF
# n8n Workflows

This directory contains exported n8n workflows for the Strategy Agents project.

## Workflows

EOF
    
    # List all workflow files
    for file in "$WORKFLOWS_DIR"/*.json; do
        if [ -f "$file" ]; then
            filename=$(basename "$file" .json)
            workflow_name=$(jq -r '.name' "$file" 2>/dev/null || echo "$filename")
            echo "- **$workflow_name** (\`$filename.json\`)" >> "$WORKFLOWS_DIR/README.md"
        fi
    done
    
    cat >> "$WORKFLOWS_DIR/README.md" << EOF

## Usage

To import a workflow:
1. Copy the JSON content
2. Go to n8n → Workflows → Import from URL/File
3. Paste the JSON content

## Sync

This directory is automatically synced with n8n using the sync script:
\`\`\`bash
./scripts/sync_workflows.sh
\`\`\`

Last updated: $(date)
EOF
}

# Main execution
main() {
    log_info "Starting n8n workflow sync..."
    
    # Check dependencies
    if ! command -v curl &> /dev/null; then
        log_error "curl is required but not installed"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log_error "jq is required but not installed. Install with: brew install jq"
        exit 1
    fi
    
    # Execute sync steps
    check_n8n
    backup_workflows
    export_workflows
    generate_index
    
    log_info "Workflow sync completed successfully! ✓"
    log_info "Workflows exported to: $WORKFLOWS_DIR"
}

# Run main function
main "$@"
