#!/bin/bash

# ✅ COMPLETE SYSTEM VERIFICATION
# Validates entire Phase 2 setup and readiness for Phase 3

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_status() {
    local status=$1
    local message=$2
    case $status in
        "PASS") echo -e "${GREEN}✅ PASS: $message${NC}" ;;
        "FAIL") echo -e "${RED}❌ FAIL: $message${NC}" ;;
        "WARN") echo -e "${YELLOW}⚠️  WARN: $message${NC}" ;;
        "INFO") echo -e "${BLUE}ℹ️  INFO: $message${NC}" ;;
        "TEST") echo -e "${CYAN}🧪 TEST: $message${NC}" ;;
        "HEADER") echo -e "${PURPLE}═══ $message ═══${NC}" ;;
    esac
}

# Paths
STRATEGY_DIR="/Users/zeh/Local_Projects/Strategy_agents"
SCREENPIPE_DIR="$STRATEGY_DIR/screenpipe"
BIN_DIR="$SCREENPIPE_DIR/bin"

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNED=0

# Function to run test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    print_status "TEST" "$test_name"
    
    if eval "$test_command"; then
        if [ "$expected_result" = "pass" ]; then
            print_status "PASS" "$test_name"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        else
            print_status "FAIL" "$test_name (unexpected pass)"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi
    else
        if [ "$expected_result" = "fail" ]; then
            print_status "PASS" "$test_name (expected fail)"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        else
            print_status "FAIL" "$test_name"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi
    fi
}

# Function to run warning test (non-critical)
run_warning_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    print_status "TEST" "$test_name"
    
    if eval "$test_command"; then
        print_status "PASS" "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        print_status "WARN" "$test_name (not critical)"
        TESTS_WARNED=$((TESTS_WARNED + 1))
        return 1
    fi
}

echo "🔍 STRATEGY AGENTS - COMPLETE SYSTEM VERIFICATION"
echo "================================================="
echo ""

# TEST CATEGORY 1: DIRECTORY STRUCTURE
print_status "HEADER" "DIRECTORY STRUCTURE TESTS"
echo ""

run_test "Strategy Agents directory exists" "[ -d '$STRATEGY_DIR' ]" "pass"
run_test "Screenpipe directory exists" "[ -d '$SCREENPIPE_DIR' ]" "pass"
run_test "Binary directory exists" "[ -d '$BIN_DIR' ]" "pass"
run_test "MCP directory exists" "[ -d '$SCREENPIPE_DIR/mcp' ]" "pass"
run_test "Data directory exists" "[ -d '$SCREENPIPE_DIR/data' ]" "pass"
run_test "Logs directory exists" "[ -d '$SCREENPIPE_DIR/logs' ]" "pass"
run_test "Config directory exists" "[ -d '$SCREENPIPE_DIR/config' ]" "pass"

echo ""

# TEST CATEGORY 2: SCRIPT FILES
print_status "HEADER" "SCRIPT FILES TESTS"
echo ""

run_test "Start script exists" "[ -f '$BIN_DIR/start_screenpipe.sh' ]" "pass"
run_test "Health check script exists" "[ -f '$BIN_DIR/health_check.sh' ]" "pass"
run_test "Menu bar script exists" "[ -f '$BIN_DIR/screenpipe_menubar.py' ]" "pass"
run_test "MCP server script exists" "[ -f '$SCREENPIPE_DIR/mcp/screenpipe_server.py' ]" "pass"
run_test "Start script is executable" "[ -x '$BIN_DIR/start_screenpipe.sh' ]" "pass"
run_test "Health check script is executable" "[ -x '$BIN_DIR/health_check.sh' ]" "pass"
run_test "Menu bar script is executable" "[ -x '$BIN_DIR/screenpipe_menubar.py' ]" "pass"

echo ""

# TEST CATEGORY 3: DEPENDENCIES
print_status "HEADER" "DEPENDENCIES TESTS"
echo ""

run_test "Screenpipe binary installed" "command -v screenpipe >/dev/null 2>&1" "pass"
run_test "Python3 available" "command -v python3 >/dev/null 2>&1" "pass"
run_test "Curl available" "command -v curl >/dev/null 2>&1" "pass"
run_warning_test "jq available" "command -v jq >/dev/null 2>&1"
run_test "Menu bar dependencies" "python3 -c 'import rumps, requests' 2>/dev/null" "pass"
run_test "MCP dependencies" "python3 -c 'import mcp, httpx, nest_asyncio' 2>/dev/null" "pass"

echo ""

# TEST CATEGORY 4: SERVICE OPERATION
print_status "HEADER" "SERVICE OPERATION TESTS"
echo ""

# Start service if not running
if ! pgrep -f "screenpipe" > /dev/null; then
    print_status "INFO" "Starting Screenpipe service for testing..."
    cd "$BIN_DIR"
    ./start_screenpipe.sh start true >/dev/null 2>&1
    sleep 10
fi

run_test "Screenpipe process running" "pgrep -f 'screenpipe' >/dev/null" "pass"
run_test "API port accessible" "curl -s http://localhost:3030/health >/dev/null 2>&1" "pass"
run_test "Health endpoint responds" "curl -s http://localhost:3030/health | grep -q 'status'" "pass"
run_test "Search endpoint responds" "curl -s 'http://localhost:3030/search?limit=1' >/dev/null 2>&1" "pass"

echo ""

# TEST CATEGORY 5: DATA CAPTURE
print_status "HEADER" "DATA CAPTURE TESTS"
echo ""

# Wait a moment for data capture
sleep 5

run_test "Data directory has files" "[ \$(find '$SCREENPIPE_DIR/data' -type f | wc -l) -gt 0 ]" "pass"
run_warning_test "Recent data files exist" "[ \$(find '$SCREENPIPE_DIR/data' -type f -mmin -60 | wc -l) -gt 0 ]"
run_test "API returns search results" "curl -s 'http://localhost:3030/search?limit=1' | grep -q 'data'" "pass"

echo ""

# TEST CATEGORY 6: CLAUDE INTEGRATION
print_status "HEADER" "CLAUDE INTEGRATION TESTS"
echo ""

CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
run_test "Claude config directory exists" "[ -d '$HOME/Library/Application Support/Claude' ]" "pass"
run_test "Claude Desktop config exists" "[ -f '$CLAUDE_CONFIG' ]" "pass"
run_test "Claude config contains MCP server" "grep -q 'screenpipe' '$CLAUDE_CONFIG' 2>/dev/null" "pass"
run_test "MCP server script works" "cd '$SCREENPIPE_DIR/mcp' && python3 -c 'import screenpipe_server' 2>/dev/null" "pass"

echo ""

# TEST CATEGORY 7: SERVICE MANAGEMENT
print_status "HEADER" "SERVICE MANAGEMENT TESTS"
echo ""

cd "$BIN_DIR"
run_test "Start script works" "./start_screenpipe.sh status >/dev/null 2>&1" "pass"
run_test "Health check script works" "./health_check.sh summary >/dev/null 2>&1" "pass"
run_test "Service can be controlled" "./start_screenpipe.sh restart >/dev/null 2>&1 && sleep 5" "pass"

echo ""

# TEST CATEGORY 8: AUTO-START (if configured)
print_status "HEADER" "AUTO-START TESTS (OPTIONAL)"
echo ""

LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
run_warning_test "Service launch agent exists" "[ -f '$LAUNCH_AGENTS_DIR/com.strategy.screenpipe.service.plist' ]"
run_warning_test "Menu bar launch agent exists" "[ -f '$LAUNCH_AGENTS_DIR/com.strategy.screenpipe.menubar.plist' ]"
run_warning_test "Service agent loaded" "launchctl list | grep -q 'com.strategy.screenpipe.service'"
run_warning_test "Menu bar agent loaded" "launchctl list | grep -q 'com.strategy.screenpipe.menubar'"

echo ""

# TEST CATEGORY 9: RESOURCE USAGE
print_status "HEADER" "RESOURCE USAGE TESTS"
echo ""

if pgrep -f "screenpipe" > /dev/null; then
    SCREENPIPE_PID=$(pgrep -f "screenpipe")
    MEMORY_MB=$(ps -o rss= -p $SCREENPIPE_PID 2>/dev/null | awk '{print int($1/1024)}')
    
    if [ ! -z "$MEMORY_MB" ]; then
        if [ "$MEMORY_MB" -lt 1000 ]; then
            print_status "PASS" "Memory usage acceptable: ${MEMORY_MB}MB"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            print_status "WARN" "Memory usage high: ${MEMORY_MB}MB"
            TESTS_WARNED=$((TESTS_WARNED + 1))
        fi
        TESTS_TOTAL=$((TESTS_TOTAL + 1))
    fi
fi

# Check disk usage
DATA_SIZE=$(du -sm "$SCREENPIPE_DIR/data" 2>/dev/null | cut -f1)
if [ ! -z "$DATA_SIZE" ]; then
    print_status "INFO" "Data directory size: ${DATA_SIZE}MB"
fi

echo ""

# FINAL RESULTS
print_status "HEADER" "VERIFICATION RESULTS"
echo ""

echo -e "${BLUE}📊 TEST SUMMARY:${NC}"
echo "  Total Tests: $TESTS_TOTAL"
echo "  Passed: $TESTS_PASSED"
echo "  Failed: $TESTS_FAILED"  
echo "  Warnings: $TESTS_WARNED"
echo ""

# Calculate success rate
if [ $TESTS_TOTAL -gt 0 ]; then
    SUCCESS_RATE=$(( (TESTS_PASSED * 100) / TESTS_TOTAL ))
    echo -e "${BLUE}📈 SUCCESS RATE: ${SUCCESS_RATE}%${NC}"
    echo ""
fi

# Determine overall status
if [ $TESTS_FAILED -eq 0 ]; then
    if [ $TESTS_WARNED -eq 0 ]; then
        print_status "PASS" "ALL SYSTEMS OPERATIONAL"
        echo ""
        echo -e "${GREEN}🎉 PHASE 2 COMPLETE! READY FOR PHASE 3!${NC}"
        echo ""
        echo -e "${CYAN}✅ Core Functionality Working${NC}"
        echo -e "${CYAN}✅ Service Management Operational${NC}"  
        echo -e "${CYAN}✅ Claude Integration Ready${NC}"
        echo -e "${CYAN}✅ Background Operation Enabled${NC}"
        echo ""
        echo -e "${PURPLE}🚀 NEXT STEPS - PHASE 3:${NC}"
        echo "  • Advanced automation development"
        echo "  • Linear integration workflows"
        echo "  • Productivity analytics"
        echo "  • Custom pipes development"
        echo "  • N8N workflow integration"
        
    else
        print_status "PASS" "SYSTEMS OPERATIONAL (minor warnings)"
        echo ""
        echo -e "${YELLOW}⚠️  PHASE 2 MOSTLY COMPLETE${NC}"
        echo -e "${CYAN}• Core functionality works${NC}"
        echo -e "${YELLOW}• Some optional features need attention${NC}"
        echo -e "${CYAN}• Ready to proceed with Phase 3${NC}"
    fi
else
    print_status "FAIL" "CRITICAL ISSUES DETECTED"
    echo ""
    echo -e "${RED}❌ PHASE 2 INCOMPLETE${NC}"
    echo -e "${RED}• Fix critical failures before proceeding${NC}"
    echo -e "${YELLOW}• Review failed tests above${NC}"
    echo -e "${BLUE}• Run individual tests for debugging${NC}"
    echo ""
    echo -e "${PURPLE}🔧 DEBUGGING COMMANDS:${NC}"
    echo "  ./health_check.sh full"
    echo "  ./start_screenpipe.sh status"
    echo "  curl http://localhost:3030/health"
    echo "  python3 -c 'import rumps, requests, mcp, httpx'"
fi

echo ""
print_status "INFO" "Verification complete!"
print_status "INFO" "Logs available in: $SCREENPIPE_DIR/logs/"
print_status "INFO" "Run specific tests: ./health_check.sh [category]"

# Exit with appropriate code
if [ $TESTS_FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi
