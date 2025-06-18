#!/bin/bash
# Screenpipe Health Check for Strategy Agents
# Monitors Screenpipe health and provides detailed diagnostics

# Set up paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$BASE_DIR/data"
LOGS_DIR="$BASE_DIR/logs"
CONFIG_DIR="$BASE_DIR/config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "INFO") echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

# Function to check if screenpipe process is running
check_process() {
    if pgrep -f "screenpipe" > /dev/null; then
        local pid=$(pgrep -f "screenpipe")
        print_status "OK" "Screenpipe process running (PID: $pid)"
        return 0
    else
        print_status "ERROR" "Screenpipe process not running"
        return 1
    fi
}

# Function to check API health
check_api() {
    local response=$(curl -s -w "%{http_code}" http://localhost:3030/health)
    local http_code="${response: -3}"
    local body="${response%???}"
    
    if [ "$http_code" = "200" ]; then
        print_status "OK" "API responding on port 3030"
        
        # Parse health data if JSON
        if command -v jq >/dev/null 2>&1; then
            local status=$(echo "$body" | jq -r '.status // "unknown"')
            local frame_status=$(echo "$body" | jq -r '.frame_status // "unknown"')
            local audio_status=$(echo "$body" | jq -r '.audio_status // "unknown"')
            
            print_status "INFO" "Health Status: $status"
            print_status "INFO" "Frame Status: $frame_status"
            print_status "INFO" "Audio Status: $audio_status"
        else
            print_status "INFO" "Health Response: $body"
        fi
        return 0
    else
        print_status "ERROR" "API not responding (HTTP: $http_code)"
        return 1
    fi
}

# Function to check data directory
check_data_dir() {
    if [ -d "$DATA_DIR" ]; then
        local size=$(du -sh "$DATA_DIR" 2>/dev/null | cut -f1)
        local file_count=$(find "$DATA_DIR" -type f 2>/dev/null | wc -l)
        print_status "OK" "Data directory exists: $DATA_DIR"
        print_status "INFO" "Data size: $size ($file_count files)"
        
        # Check for recent activity (files modified in last hour)
        local recent_files=$(find "$DATA_DIR" -type f -mmin -60 2>/dev/null | wc -l)
        if [ "$recent_files" -gt 0 ]; then
            print_status "OK" "Recent activity detected ($recent_files files in last hour)"
        else
            print_status "WARNING" "No recent activity detected"
        fi
    else
        print_status "ERROR" "Data directory does not exist: $DATA_DIR"
        return 1
    fi
}

# Function to check logs
check_logs() {
    local service_log="$LOGS_DIR/service.log"
    local screenpipe_stderr="$LOGS_DIR/screenpipe_stderr.log"
    
    if [ -f "$service_log" ]; then
        local last_entry=$(tail -n 1 "$service_log" 2>/dev/null)
        print_status "OK" "Service logs available"
        print_status "INFO" "Last entry: $last_entry"
    else
        print_status "WARNING" "No service logs found"
    fi
    
    if [ -f "$screenpipe_stderr" ]; then
        local error_count=$(wc -l < "$screenpipe_stderr" 2>/dev/null || echo "0")
        if [ "$error_count" -gt 0 ]; then
            print_status "WARNING" "Screenpipe errors detected ($error_count lines)"
            print_status "INFO" "Recent errors:"
            tail -n 3 "$screenpipe_stderr" 2>/dev/null | sed 's/^/    /'
        else
            print_status "OK" "No errors in Screenpipe logs"
        fi
    fi
}

# Function to check system resources
check_resources() {
    # Check disk space
    local disk_usage=$(df "$DATA_DIR" | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$disk_usage" -lt 80 ]; then
        print_status "OK" "Disk usage: ${disk_usage}%"
    elif [ "$disk_usage" -lt 90 ]; then
        print_status "WARNING" "Disk usage: ${disk_usage}% (getting high)"
    else
        print_status "ERROR" "Disk usage: ${disk_usage}% (critically high)"
    fi
    
    # Check memory usage (if available)
    if command -v free >/dev/null 2>&1; then
        local mem_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
        print_status "INFO" "Memory usage: ${mem_usage}%"
    elif [ "$(uname)" = "Darwin" ]; then
        # macOS memory check
        local mem_pressure=$(memory_pressure | grep "System-wide memory free percentage" | awk '{print $5}' | sed 's/%//')
        if [ ! -z "$mem_pressure" ]; then
            print_status "INFO" "Memory free: ${mem_pressure}%"
        fi
    fi
}

# Function to test search functionality
test_search() {
    print_status "INFO" "Testing search functionality..."
    
    local search_response=$(curl -s "http://localhost:3030/search?limit=1")
    if [ $? -eq 0 ]; then
        if command -v jq >/dev/null 2>&1; then
            local total=$(echo "$search_response" | jq -r '.pagination.total // 0')
            print_status "OK" "Search working (total entries: $total)"
        else
            print_status "OK" "Search endpoint responding"
        fi
    else
        print_status "ERROR" "Search functionality failed"
        return 1
    fi
}

# Function to check MCP server
check_mcp() {
    local mcp_script="$BASE_DIR/mcp/screenpipe_server.py"
    if [ -f "$mcp_script" ]; then
        print_status "OK" "MCP server script found"
        
        # Check if Python dependencies are available
        if python3 -c "import mcp, httpx, nest_asyncio" 2>/dev/null; then
            print_status "OK" "MCP dependencies available"
        else
            print_status "WARNING" "MCP dependencies missing"
        fi
    else
        print_status "ERROR" "MCP server script not found"
    fi
}

# Function to show quick summary
show_summary() {
    echo ""
    echo "=================="
    echo "HEALTH CHECK SUMMARY"
    echo "=================="
    
    local process_ok=0
    local api_ok=0
    
    # Quick checks for summary
    if pgrep -f "screenpipe" > /dev/null; then
        process_ok=1
    fi
    
    if curl -s http://localhost:3030/health > /dev/null 2>&1; then
        api_ok=1
    fi
    
    if [ $process_ok -eq 1 ] && [ $api_ok -eq 1 ]; then
        print_status "OK" "Screenpipe is healthy and operational"
    elif [ $process_ok -eq 1 ]; then
        print_status "WARNING" "Screenpipe process running but API issues detected"
    else
        print_status "ERROR" "Screenpipe is not running"
    fi
    
    echo ""
    print_status "INFO" "Data: $DATA_DIR"
    print_status "INFO" "Logs: $LOGS_DIR"
    print_status "INFO" "Run '$0 full' for detailed diagnostics"
}

# Main execution
case "${1:-summary}" in
    "full"|"detailed")
        echo "🔍 SCREENPIPE HEALTH CHECK - DETAILED"
        echo "===================================="
        echo ""
        
        echo "📊 Process Status"
        echo "----------------"
        check_process
        echo ""
        
        echo "🌐 API Health"
        echo "-------------"
        check_api
        echo ""
        
        echo "💾 Data Directory"
        echo "----------------"
        check_data_dir
        echo ""
        
        echo "📄 Logs"
        echo "-------"
        check_logs
        echo ""
        
        echo "⚡ System Resources"
        echo "------------------"
        check_resources
        echo ""
        
        echo "🔍 Search Test"
        echo "-------------"
        test_search
        echo ""
        
        echo "🔌 MCP Integration"
        echo "-----------------"
        check_mcp
        echo ""
        
        show_summary
        ;;
    "quick"|"summary")
        show_summary
        ;;
    "api")
        check_api
        ;;
    "process")
        check_process
        ;;
    "data")
        check_data_dir
        ;;
    "logs")
        check_logs
        ;;
    "resources")
        check_resources
        ;;
    "search")
        test_search
        ;;
    "mcp")
        check_mcp
        ;;
    *)
        echo "Usage: $0 {summary|full|api|process|data|logs|resources|search|mcp}"
        echo ""
        echo "Commands:"
        echo "  summary    - Quick health summary (default)"
        echo "  full       - Detailed health check"
        echo "  api        - Check API health only"
        echo "  process    - Check process status only"
        echo "  data       - Check data directory only"
        echo "  logs       - Check logs only"
        echo "  resources  - Check system resources only"
        echo "  search     - Test search functionality only"
        echo "  mcp        - Check MCP integration only"
        exit 1
        ;;
esac
