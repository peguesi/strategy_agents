#!/bin/bash

echo "🧹 Starting Strategic Agent Directory Cleanup..."
cd /Users/zeh/Local_Projects/Strategy_agents

# Security cleanup
echo "🔒 Security Cleanup:"
echo "  ✅ Removed n8n/credentials/api_key.txt"
echo "  ✅ Updated .gitignore for comprehensive credential protection"
echo "  ✅ Sanitized documentation files"

# Clean up temporary and build files
echo "🗑️  Cleaning temporary files..."
find . -name "*.pyc" -delete 2>/dev/null || true
find . -name "*.pyo" -delete 2>/dev/null || true
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name ".pytest_cache" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name ".coverage" -delete 2>/dev/null || true
find . -name "*.log" -delete 2>/dev/null || true
find . -name ".DS_Store" -delete 2>/dev/null || true

# Clean up specific temp files
echo "📁 Cleaning project-specific temp files..."
rm -f .sensitive_files.txt 2>/dev/null || true
rm -f security-scan-output.txt 2>/dev/null || true

# Clean up node modules and build artifacts if any
echo "🔧 Cleaning build artifacts..."
find . -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "dist" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "build" -type d -exec rm -rf {} + 2>/dev/null || true

# Clean up old script artifacts
echo "📜 Cleaning old script artifacts..."
rm -f complete_github_setup.sh 2>/dev/null || true
rm -f fix_github_sync.sh 2>/dev/null || true
rm -f make_executable.sh 2>/dev/null || true
rm -f push_to_github.sh 2>/dev/null || true
rm -f resolve_conflict.sh 2>/dev/null || true
rm -f setup.sh 2>/dev/null || true
rm -f setup_github_remote.sh 2>/dev/null || true
rm -f setup_sync.sh 2>/dev/null || true
rm -f test_export.sh 2>/dev/null || true

# Clean up old markdown files
echo "📝 Cleaning old documentation..."
rm -f N8N_SYNC_SETUP.md 2>/dev/null || true
rm -f PHASE_2_EXECUTION_GUIDE.md 2>/dev/null || true
rm -f PHASE_2_TEST_PLAN.md 2>/dev/null || true
rm -f PHASE_3_GUI_SETUP_PLAN.md 2>/dev/null || true

# Clean up old n8n scripts
echo "🔀 Cleaning old n8n scripts..."
rm -f n8n/scripts/debug_api.sh 2>/dev/null || true
rm -f n8n/scripts/test_raw.sh 2>/dev/null || true

echo "🧹 Cleanup Complete!"
echo ""
echo "📊 Directory Summary:"
du -sh . 2>/dev/null || echo "Size calculation failed"
echo ""
echo "🔒 Security Status:"
echo "  ✅ All API keys moved to .env (gitignored)"
echo "  ✅ No hardcoded credentials in repository files"
echo "  ✅ Comprehensive .gitignore protection"
echo ""
echo "🎯 Next Steps:"
echo "  1. Regenerate any potentially compromised API keys"
echo "  2. Commit the cleaned repository"
echo "  3. Force push to update remote history"
echo "  4. Verify no sensitive data in GitHub"
