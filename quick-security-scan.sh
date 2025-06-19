#!/bin/bash
cd /Users/zeh/Local_Projects/Strategy_agents

echo "=== Security Scan Results ===" > security-scan-output.txt
echo "Scan started: $(date)" >> security-scan-output.txt
echo "" >> security-scan-output.txt

echo "1. Searching for API keys and secrets..." >> security-scan-output.txt
find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.json" -o -name "*.md" -o -name "*.sh" \) -exec grep -l -i "api.*key\|secret\|token\|password" {} \; >> security-scan-output.txt 2>&1

echo "" >> security-scan-output.txt
echo "2. Detailed matches:" >> security-scan-output.txt
find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.json" -o -name "*.md" -o -name "*.sh" \) -exec grep -n -i "api.*key\|secret\|token\|password" {} /dev/null \; >> security-scan-output.txt 2>&1

echo "" >> security-scan-output.txt
echo "Scan completed: $(date)" >> security-scan-output.txt
