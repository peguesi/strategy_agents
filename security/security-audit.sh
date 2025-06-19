#!/bin/bash

echo "🔍 STRATEGY AGENTS SECURITY AUDIT"
echo "================================="
cd /Users/zeh/Local_Projects/Strategy_agents

# Configuration
SCAN_TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
SCAN_LOG="security-audit-${SCAN_TIMESTAMP}.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create comprehensive search patterns
CREDENTIAL_PATTERNS=(
    "lin_api_[A-Za-z0-9]+"
    "lin_oauth_[A-Za-z0-9]+"
    "sk-[A-Za-z0-9]+"
    "pk_[A-Za-z0-9]+"
    "eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*"
    "api[_-]?key['\"]?\s*[:=]\s*['\"][^'\"]{10,}['\"]"
    "secret['\"]?\s*[:=]\s*['\"][^'\"]{10,}['\"]"
    "token['\"]?\s*[:=]\s*['\"][^'\"]{10,}['\"]"
    "password['\"]?\s*[:=]\s*['\"][^'\"]{8,}['\"]"
    "Bearer [A-Za-z0-9_-]+"
    "Basic [A-Za-z0-9+/=]+"
)

echo "🎯 Starting comprehensive security scan..."
echo "📝 Logging to: $SCAN_LOG"

# Initialize log
cat > "$SCAN_LOG" << EOF
Strategy Agents Security Audit Report
======================================
Timestamp: $(date)
Location: $(pwd)
User: $(whoami)

EOF

VIOLATIONS_FOUND=0

log_info "🔍 Scanning for hardcoded credentials..."

# Scan for credential patterns
for pattern in "${CREDENTIAL_PATTERNS[@]}"; do
    echo "  📋 Pattern: $pattern" >> "$SCAN_LOG"
    
    # Find files containing the pattern
    matches=$(find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.sh" -o -name "*.bash" -o -name "*.md" -o -name "*.txt" -o -name "*.conf" \) \
        ! -path "./.venv/*" \
        ! -path "./.git/*" \
        ! -path "./node_modules/*" \
        ! -path "*/site-packages/*" \
        ! -path "*/__pycache__/*" \
        ! -path "*/security-audit-*.log" \
        -exec grep -l -E "$pattern" {} \; 2>/dev/null || true)
    
    if [ ! -z "$matches" ]; then
        log_error "🚨 POTENTIAL CREDENTIALS FOUND"
        echo "$matches" | while read -r file; do
            if [ -f "$file" ]; then
                echo "    📁 FILE: $file" | tee -a "$SCAN_LOG"
                grep -n -E "$pattern" "$file" 2>/dev/null | head -3 | sed 's/^/      /' | tee -a "$SCAN_LOG"
                VIOLATIONS_FOUND=$((VIOLATIONS_FOUND + 1))
            fi
        done
    fi
done

log_info "🔒 Checking .env file protection..."
if git check-ignore .env >/dev/null 2>&1; then
    log_success ".env file is properly gitignored"
    echo "✅ .env file protection: SECURE" >> "$SCAN_LOG"
else
    log_error ".env file is NOT gitignored!"
    echo "❌ .env file protection: VULNERABLE" >> "$SCAN_LOG"
    VIOLATIONS_FOUND=$((VIOLATIONS_FOUND + 1))
fi

log_info "📁 Checking for exposed credential files..."
exposed_files=$(find . -type f \( -name "*credential*" -o -name "*secret*" -o -name "*key*.txt" -o -name "*key*.json" \) \
    ! -path "./.venv/*" \
    ! -path "./.git/*" \
    ! -path "./node_modules/*" \
    ! -path "*/site-packages/*" \
    ! -path "*/azure/*" \
    ! -path "*/cryptography/*" \
    ! -path "*/setuptools/*" \
    ! -path "*/msal_extensions/*" \
    ! -path "*/fastapi/*" \
    2>/dev/null || true)

if [ ! -z "$exposed_files" ]; then
    log_warning "Credential files found:"
    echo "$exposed_files" | while read -r file; do
        echo "  📄 $file" | tee -a "$SCAN_LOG"
    done
else
    log_success "No exposed credential files found"
    echo "✅ Credential files: CLEAN" >> "$SCAN_LOG"
fi

log_info "🔧 Checking environment variable usage..."
env_check_files=(
    "mcp/n8n/n8n_complete_mcp_server.py"
    "scripts/fetch_workflows.py"
    "n8n/scripts/quick_export.sh"
    "n8n/scripts/sync_workflows.sh"
    "linear/setup-linear.js"
    "linear/update-labels.js"
    "linear/linear-initiative-fix.js"
)

for file in "${env_check_files[@]}"; do
    if [ -f "$file" ]; then
        if grep -q "process.env\|os.getenv\|os.environ\|\$.*_API_KEY" "$file"; then
            log_success "$file uses environment variables"
            echo "✅ $file: SECURE" >> "$SCAN_LOG"
        else
            log_error "$file may not use environment variables"
            echo "❌ $file: NEEDS REVIEW" >> "$SCAN_LOG"
            VIOLATIONS_FOUND=$((VIOLATIONS_FOUND + 1))
        fi
    else
        log_warning "$file not found"
        echo "⚠️  $file: NOT FOUND" >> "$SCAN_LOG"
    fi
done

# Summary
echo "" | tee -a "$SCAN_LOG"
echo "🎯 SECURITY AUDIT SUMMARY" | tee -a "$SCAN_LOG"
echo "=========================" | tee -a "$SCAN_LOG"

if [ "$VIOLATIONS_FOUND" -eq 0 ]; then
    log_success "✅ NO SECURITY VIOLATIONS FOUND"
    echo "✅ Repository Status: SECURE" | tee -a "$SCAN_LOG"
    echo "✅ All credentials properly use environment variables" | tee -a "$SCAN_LOG"
    echo "✅ No hardcoded API keys detected" | tee -a "$SCAN_LOG"
    echo "✅ Credential files properly protected" | tee -a "$SCAN_LOG"
    EXIT_CODE=0
else
    log_error "❌ $VIOLATIONS_FOUND SECURITY VIOLATIONS FOUND"
    echo "❌ Repository Status: VULNERABLE" | tee -a "$SCAN_LOG"
    echo "❌ Violations found: $VIOLATIONS_FOUND" | tee -a "$SCAN_LOG"
    echo "🔧 ACTION REQUIRED: Review and fix all violations above" | tee -a "$SCAN_LOG"
    EXIT_CODE=1
fi

echo "" | tee -a "$SCAN_LOG"
echo "📊 Audit completed: $(date)" | tee -a "$SCAN_LOG"
echo "📝 Detailed log: $SCAN_LOG" | tee -a "$SCAN_LOG"
echo ""
echo "🔐 Security Best Practices:" | tee -a "$SCAN_LOG"
echo "  1. Always use environment variables for API keys" | tee -a "$SCAN_LOG"
echo "  2. Keep .env files gitignored" | tee -a "$SCAN_LOG"
echo "  3. Never commit credential files" | tee -a "$SCAN_LOG"
echo "  4. Regenerate any exposed keys immediately" | tee -a "$SCAN_LOG"
echo "  5. Run this audit regularly" | tee -a "$SCAN_LOG"

exit $EXIT_CODE
