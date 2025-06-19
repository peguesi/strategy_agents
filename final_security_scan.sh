#!/bin/bash

echo "🔍 Running Final Security Scan..."
cd /Users/zeh/Local_Projects/Strategy_agents

echo "📋 Scanning for sensitive patterns..."

# Create temporary scan results
SCAN_FILE=$(mktemp)

# Comprehensive search for sensitive data
echo "Checking for API keys, tokens, passwords..."
grep -r -n -i --include="*.py" --include="*.js" --include="*.json" --include="*.sh" --include="*.md" --include="*.yml" --include="*.yaml" \
  -E "(api[_-]?key|secret|token|password|credential).*[=:]\s*['\"][^'\"]+['\"]" . \
  | grep -v ".venv" \
  | grep -v "node_modules" \
  | grep -v ".git/" \
  > "$SCAN_FILE"

# Check for hardcoded JWT tokens
echo "Checking for JWT tokens..."
grep -r -n --include="*.py" --include="*.js" --include="*.json" --include="*.sh" --include="*.md" --include="*.yml" --include="*.yaml" \
  "eyJ[A-Za-z0-9_-]*\." . \
  | grep -v ".venv" \
  | grep -v "node_modules" \
  | grep -v ".git/" \
  >> "$SCAN_FILE"

# Check for common credential patterns
echo "Checking for common credential patterns..."
grep -r -n -i --include="*.py" --include="*.js" --include="*.json" --include="*.sh" --include="*.md" --include="*.yml" --include="*.yaml" \
  -E "(lin_api_|lin_oauth_|sk-|pk_)" . \
  | grep -v ".venv" \
  | grep -v "node_modules" \
  | grep -v ".git/" \
  >> "$SCAN_FILE"

# Display results
if [ -s "$SCAN_FILE" ]; then
    echo "⚠️  POTENTIAL SECURITY ISSUES FOUND:"
    echo "================================================"
    cat "$SCAN_FILE"
    echo "================================================"
    echo ""
    echo "🔧 ACTION REQUIRED: Review the above findings"
else
    echo "✅ No obvious security issues found in code files"
fi

# Check .env file protection
echo ""
echo "🔒 Checking .env file protection..."
if git check-ignore .env >/dev/null 2>&1; then
    echo "✅ .env file is properly gitignored"
else
    echo "⚠️  .env file is NOT gitignored!"
fi

# Check for any credential files
echo ""
echo "📁 Checking for credential files..."
find . -type f \( -name "*credential*" -o -name "*secret*" -o -name "*key*" \) \
  | grep -v ".venv" \
  | grep -v "node_modules" \
  | grep -v ".git/" \
  | grep -v "/azure/" \
  | grep -v "/cryptography/" \
  | grep -v "/setuptools/" \
  | grep -v "/msal_extensions/" \
  | grep -v "/fastapi/"

echo ""
echo "🎯 Security Scan Complete"

# Cleanup
rm -f "$SCAN_FILE"
