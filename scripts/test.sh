#!/bin/bash

# Strategy Agents Platform Test Script
# Comprehensive testing to verify platform functionality

set -e  # Exit on any error

# Colors for output
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
BLUE='\\033[0;34m'
NC='\\033[0m' # No Color

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

# Print colored output
print_status() {
    echo -e \"${BLUE}[TEST]${NC} $1\"
}

print_success() {
    echo -e \"${GREEN}[PASS]${NC} $1\"
    ((TESTS_PASSED++))
}

print_failure() {
    echo -e \"${RED}[FAIL]${NC} $1\"
    ((TESTS_FAILED++))
    FAILED_TESTS+=(\"$1\")
}

print_warning() {
    echo -e \"${YELLOW}[WARN]${NC} $1\"
}

# Test environment setup
test_environment() {
    print_status \"Testing environment configuration...\"
    
    # Check if .env file exists
    if [ -f \".env\" ]; then
        print_success \"Environment file (.env) exists\"
    else
        print_failure \"Environment file (.env) missing\"
        return
    fi
    
    # Load environment variables
    export $(cat .env | grep -v '^#' | xargs) 2>/dev/null || true
    
    # Check for essential environment variables
    local required_vars=(\"LINEAR_API_KEY\" \"N8N_API_KEY\" \"N8N_URL\")
    
    for var in \"${required_vars[@]}\"; do
        if [ -n \"${!var}\" ] && [ \"${!var}\" != \"your_${var,,}\" ]; then
            print_success \"$var is configured\"
        else
            print_failure \"$var is not properly configured\"
        fi
    done
}

# Test Python environment
test_python_environment() {
    print_status \"Testing Python environment...\"
    
    # Check if virtual environment exists
    if [ -d \".venv\" ]; then
        print_success \"Python virtual environment exists\"
    else
        print_failure \"Python virtual environment missing\"
        return
    fi
    
    # Activate virtual environment
    source .venv/bin/activate
    
    # Test Python imports
    python3 -c \"
import sys
import asyncio
import httpx
import json
import os
print('Python environment OK')
\" && print_success \"Python dependencies available\" || print_failure \"Python dependencies missing\"
}

# Test Linear API connection
test_linear_api() {
    print_status \"Testing Linear API connection...\"
    
    if [ -z \"$LINEAR_API_KEY\" ] || [ \"$LINEAR_API_KEY\" = \"your_linear_api_key\" ]; then
        print_failure \"Linear API key not configured\"
        return
    fi
    
    source .venv/bin/activate
    python3 -c \"
import asyncio
import httpx
import os
import sys

async def test_linear():
    headers = {'Authorization': f'Bearer {os.getenv('LINEAR_API_KEY')}'}
    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(
                'https://api.linear.app/graphql',
                headers=headers,
                json={'query': 'query { viewer { id name email } }'},
                timeout=10.0
            )
            if response.status_code == 200:
                data = response.json()
                if 'data' in data and 'viewer' in data['data']:
                    print(f'Linear API: Connected as {data[\\\"data\\\"][\\\"viewer\\\"][\\\"name\\\"]}')
                    sys.exit(0)
                else:
                    print('Linear API: Invalid response format')
                    sys.exit(1)
            else:
                print(f'Linear API: HTTP {response.status_code}')
                sys.exit(1)
        except Exception as e:
            print(f'Linear API: Connection failed - {e}')
            sys.exit(1)

asyncio.run(test_linear())
\" && print_success \"Linear API connection successful\" || print_failure \"Linear API connection failed\"
}

# Test n8n API connection
test_n8n_api() {
    print_status \"Testing n8n API connection...\"
    
    if [ -z \"$N8N_API_KEY\" ] || [ \"$N8N_API_KEY\" = \"your_n8n_api_key\" ]; then
        print_failure \"n8n API key not configured\"
        return
    fi
    
    if [ -z \"$N8N_URL\" ] || [ \"$N8N_URL\" = \"your_n8n_url\" ]; then
        print_failure \"n8n URL not configured\"
        return
    fi
    
    source .venv/bin/activate
    python3 -c \"
import asyncio
import httpx
import os
import sys

async def test_n8n():
    headers = {'X-N8N-API-KEY': os.getenv('N8N_API_KEY')}
    base_url = os.getenv('N8N_URL').rstrip('/')
    
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(
                f'{base_url}/api/v1/workflows',
                headers=headers,
                timeout=10.0
            )
            if response.status_code == 200:
                workflows = response.json()
                print(f'n8n API: Found {len(workflows)} workflows')
                sys.exit(0)
            else:
                print(f'n8n API: HTTP {response.status_code}')
                sys.exit(1)
        except Exception as e:
            print(f'n8n API: Connection failed - {e}')
            sys.exit(1)

asyncio.run(test_n8n())
\" && print_success \"n8n API connection successful\" || print_failure \"n8n API connection failed\"
}

# Test MCP servers
test_mcp_servers() {
    print_status \"Testing MCP server files...\"
    
    local mcp_servers=(
        \"mcp/n8n/n8n_complete_mcp_server.py\"
        \"mcp/screenpipe/screenpipe_mcp_server.py\"
        \"mcp/linear/linear_mcp_server.py\"
    )
    
    for server in \"${mcp_servers[@]}\"; do
        if [ -f \"$server\" ]; then
            # Test if the Python file is valid
            source .venv/bin/activate
            python3 -m py_compile \"$server\" && print_success \"$server syntax OK\" || print_failure \"$server syntax error\"
        else
            print_failure \"$server not found\"
        fi
    done
}

# Test Claude Desktop configuration
test_claude_config() {
    print_status \"Testing Claude Desktop configuration...\"
    
    local config_file
    if [[ \"$OSTYPE\" == \"darwin\"* ]]; then
        config_file=\"$HOME/Library/Application Support/Claude/claude_desktop_config.json\"
    else
        config_file=\"$HOME/.config/claude/claude_desktop_config.json\"
    fi
    
    if [ -f \"$config_file\" ]; then
        # Validate JSON syntax
        python3 -c \"
import json
import sys

try:
    with open('$config_file', 'r') as f:
        config = json.load(f)
    
    if 'mcpServers' in config:
        servers = config['mcpServers']
        print(f'Claude config: {len(servers)} MCP servers configured')
        
        required_servers = ['n8n-complete', 'linear', 'screenpipe-terminal']
        for server in required_servers:
            if server in servers:
                print(f'  ✓ {server}')
            else:
                print(f'  ✗ {server} missing')
        sys.exit(0)
    else:
        print('Claude config: No mcpServers section found')
        sys.exit(1)
        
except json.JSONDecodeError as e:
    print(f'Claude config: Invalid JSON - {e}')
    sys.exit(1)
except Exception as e:
    print(f'Claude config: Error - {e}')
    sys.exit(1)
\" && print_success \"Claude Desktop configuration valid\" || print_failure \"Claude Desktop configuration invalid\"
    else
        print_failure \"Claude Desktop configuration file not found\"
    fi
}

# Test project structure
test_project_structure() {
    print_status \"Testing project structure...\"
    
    local required_dirs=(
        \"mcp\"
        \"n8n\"
        \"screenpipe\"
        \"linear\"
        \"docs\"
        \"examples\"
        \"scripts\"
        \"config\"
        \"security\"
    )
    
    for dir in \"${required_dirs[@]}\"; do
        if [ -d \"$dir\" ]; then
            print_success \"Directory $dir exists\"
        else
            print_failure \"Directory $dir missing\"
        fi
    done
    
    # Test required files
    local required_files=(
        \"README.md\"
        \"GETTING_STARTED.md\"
        \"scripts/setup.sh\"
        \"config/.env.example\"
    )
    
    for file in \"${required_files[@]}\"; do
        if [ -f \"$file\" ]; then
            print_success \"File $file exists\"
        else
            print_failure \"File $file missing\"
        fi
    done
}

# Test security configuration
test_security() {
    print_status \"Testing security configuration...\"
    
    # Check if .env is in .gitignore
    if grep -q \".env\" .gitignore 2>/dev/null; then
        print_success \".env file is in .gitignore\"
    else
        print_failure \".env file not in .gitignore (security risk!)\"
    fi
    
    # Check for hardcoded secrets in Python files
    if grep -r \"api.*key\\|secret\\|token\" --include=\"*.py\" . | grep -v \"os.getenv\\|os.environ\" | grep -v \"your_\" | grep -v \"test.sh\" >/dev/null 2>&1; then
        print_failure \"Potential hardcoded secrets found in Python files\"
    else
        print_success \"No hardcoded secrets found in Python files\"
    fi
    
    # Run security audit if available
    if [ -f \"security/security-audit.sh\" ]; then
        chmod +x security/security-audit.sh
        if ./security/security-audit.sh >/dev/null 2>&1; then
            print_success \"Security audit passed\"
        else
            print_failure \"Security audit failed\"
        fi
    else
        print_warning \"Security audit script not found\"
    fi
}

# Test Screenpipe integration
test_screenpipe() {
    print_status \"Testing Screenpipe integration...\"
    
    if command -v screenpipe &> /dev/null; then
        print_success \"Screenpipe CLI available\"
        
        # Test if Screenpipe is running
        if curl -s \"http://localhost:3030/health\" >/dev/null 2>&1; then
            print_success \"Screenpipe API is running\"
        else
            print_warning \"Screenpipe API not running (start with 'screenpipe')\"
        fi
    else
        print_warning \"Screenpipe not installed (optional for behavioral analysis)\"
    fi
}

# Test GitHub integration
test_github() {
    print_status \"Testing GitHub integration...\"
    
    if [ -d \".git\" ]; then
        print_success \"Git repository initialized\"
        
        # Check if GitHub workflows exist
        if [ -d \".github/workflows\" ]; then
            local workflow_count=$(ls -1 .github/workflows/*.yml 2>/dev/null | wc -l)
            if [ \"$workflow_count\" -gt 0 ]; then
                print_success \"GitHub Actions workflows found ($workflow_count)\"
            else
                print_warning \"No GitHub Actions workflows found\"
            fi
        else
            print_warning \"GitHub workflows directory not found\"
        fi
    else
        print_warning \"Not a Git repository\"
    fi
}

# Performance test
test_performance() {
    print_status \"Running performance tests...\"
    
    source .venv/bin/activate
    
    # Test import speed
    start_time=$(date +%s%N)
    python3 -c \"import asyncio, httpx, json, os\" 2>/dev/null
    end_time=$(date +%s%N)
    import_time=$(((end_time - start_time) / 1000000))
    
    if [ \"$import_time\" -lt 1000 ]; then
        print_success \"Python import performance: ${import_time}ms\"
    else
        print_warning \"Python import performance slow: ${import_time}ms\"
    fi
}

# Generate test report
generate_report() {
    echo
    echo \"========================================\"
    echo \"           Test Results Summary\"
    echo \"========================================\"
    echo
    echo \"Tests Passed: $TESTS_PASSED\"
    echo \"Tests Failed: $TESTS_FAILED\"
    echo \"Total Tests: $((TESTS_PASSED + TESTS_FAILED))\"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e \"${GREEN}\\n🎉 All tests passed! Your Strategy Agents platform is ready to use.${NC}\"
        echo
        echo \"Next steps:\"
        echo \"1. Complete your .env configuration with real API keys\"
        echo \"2. Restart Claude Desktop to load MCP servers\"
        echo \"3. Test by asking Claude: 'List my Linear workflows'\"
        echo \"4. Review the getting started guide: GETTING_STARTED.md\"
    else
        echo -e \"${RED}\\n❌ Some tests failed. Please address the following issues:${NC}\"
        for failed_test in \"${FAILED_TESTS[@]}\"; do
            echo \"  - $failed_test\"
        done
        echo
        echo \"Refer to the documentation for troubleshooting guidance.\"
        exit 1
    fi
}

# Main test function
main() {
    echo \"========================================\"
    echo \"     Strategy Agents Platform Tests\"
    echo \"========================================\"
    echo
    
    print_status \"Starting comprehensive platform tests...\"
    echo
    
    # Load environment variables if available
    if [ -f \".env\" ]; then
        export $(cat .env | grep -v '^#' | xargs) 2>/dev/null || true
    fi
    
    # Run all tests
    test_project_structure
    test_environment
    test_python_environment
    test_mcp_servers
    test_claude_config
    test_linear_api
    test_n8n_api
    test_screenpipe
    test_github
    test_security
    test_performance
    
    # Generate final report
    generate_report
}

# Run main function
main \"$@\"
