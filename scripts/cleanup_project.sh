#!/bin/bash

# Strategy Agents Project Cleanup Script
# Removes temp files, backups, and organizes the project structure
# Last updated: 2025-10-23

echo "🧹 Starting Strategy Agents Project Cleanup..."
echo "⏰ Started at: $(date)"

cd /Users/zeh/Local_Projects/Strategy_agents

# Phase 1: Remove backup directories
echo "📦 Removing backup directories..."
rm -rf azure-backup-20250708
rm -rf azure_backup_2025_07_08
echo "✅ Backup directories removed"

# Phase 2: Remove temp directory
echo "📂 Removing temp directory..."
rm -rf temp
echo "✅ Temp directory removed"

# Phase 3: Clean up n8n migration files (keep only the essential ones)
echo "🔧 Cleaning up n8n migration files..."

# Create scripts/n8n directory for organization
mkdir -p scripts/n8n

# Move the key migration files to organized location
mv n8n_complete_migration.sh scripts/n8n/
mv n8n_migration_guide.md scripts/n8n/

# Remove all the other scattered n8n files
rm -f n8n_analyze_credentials.sh
rm -f n8n_credential_export_attempt.sh
rm -f n8n_credential_export_final_analysis.md
rm -f n8n_direct_import.sh
rm -f n8n_email_fix.sh
rm -f n8n_import_ready.sh
rm -f n8n_import_to_new.sh
rm -f n8n_login_fixed.md
rm -f n8n_migration.sh
rm -f n8n_rapid_import.sh
rm -f n8n_simple_import.sh

echo "✅ n8n migration files cleaned up"

# Phase 4: Check for any other temp files
echo "🔍 Scanning for other temp files..."
find . -name "*temp*" -type f -not -path "./.git/*" -not -path "./mcp/*/venv/*" -not -path "./.venv/*"
find . -name "*tmp*" -type f -not -path "./.git/*" -not -path "./mcp/*/venv/*" -not -path "./.venv/*"

# Phase 5: Clean up any __pycache__ directories
echo "🐍 Removing Python cache files..."
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -type f -delete 2>/dev/null || true

echo "🎉 Project cleanup completed!"
echo "⏰ Finished at: $(date)"
echo ""
echo "📋 Cleanup Summary:"
echo "   ✅ Removed 2 backup directories"
echo "   ✅ Removed temp directory"
echo "   ✅ Organized n8n migration files"
echo "   ✅ Removed Python cache files"
echo "   ✅ Project structure cleaned"
echo ""
echo "📁 Organized files moved to:"
echo "   📂 scripts/n8n/ - Key migration files"
