#!/bin/bash

# 📊 STRATEGY AGENTS SERVICE DASHBOARD
# Real-time monitoring and control interface

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Unicode symbols
CHECKMARK="✅"
WARNING="⚠️"
ERROR="❌"
INFO="ℹ️"
ROCKET="🚀"
GEAR="⚙️"
CHART="📊"
SEARCH="🔍"

# Function to clear screen
clear_screen() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    ${PURPLE}STRATEGY AGENTS${BLUE}                        ║${NC}"
    echo -e "${BLUE}║                ${CYAN}Service Status Dashboard${BLUE}                  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function to get service status
get_service_status() {
    if pgrep -f "screenpipe" > /dev/null; then
        echo -e "${GREEN}${CHECKMARK} RUNNING${NC}"
    else
        echo -e "${RED}${ERROR} STOPPED${NC}"
    fi
}

# Function to get API status
get_api_status() {
    if curl -s http://localhost:3030/health > /dev/null 2>&1; then
        echo -e "${GREEN}${CHECKMARK} RESPONDING${NC}"
    else
        echo -e "${RED}${ERROR} NOT RESPONDING${NC}"
    fi
}

# Function to get data info
get_data_info() {
    local data_dir="/Users/zeh/Local_Projects/Strategy_agents/screenpipe/data"
    if [ -d "$data_dir" ]; then
        local size=$(du -sh "$data_dir" 2>/dev/null | cut -f1)
        local files=$(find "$data_dir" -type f 2>/dev/null | wc -l)
        echo -e "${GREEN}${size} (${files} files)${NC}"
    else
        echo -e "${RED}No data directory${NC}"
    fi
}

# Function to get recent activity
get_recent_activity() {
    local response=$(curl -s "http://localhost:3030/search?limit=1" 2>/dev/null)
    if [ $? -eq 0 ] && [ ! -z "$response" ]; then
        if command -v jq >/dev/null 2>&1; then
            local total=$(echo "$response" | jq -r '.pagination.total // 0' 2>/dev/null)
            if [ "$total" -gt 0 ]; then
                echo -e "${GREEN}${total} entries captured${NC}"
            else
                echo -e "${YELLOW}No entries yet${NC}"
            fi
        else
            echo -e "${GREEN}Data available${NC}"
        fi
    else
        echo -e "${RED}No response${NC}"
    fi
}

# Function to get memory usage
get_memory_usage() {
    if [ "$(uname)" = "Darwin" ]; then
        local screenpipe_pid=$(pgrep -f "screenpipe")
        if [ ! -z "$screenpipe_pid" ]; then
            local mem=$(ps -o rss= -p $screenpipe_pid 2>/dev/null | awk '{print int($1/1024)"MB"}')
            echo -e "${GREEN}${mem}${NC}"
        else
            echo -e "${RED}Process not found${NC}"
        fi
    else
        echo -e "${YELLOW}N/A${NC}"
    fi
}

# Function to show main dashboard
show_dashboard() {
    clear_screen
    
    echo -e "${CHART} ${PURPLE}SYSTEM STATUS${NC}"
    echo "════════════════════════════════════════════════════════════"
    printf "%-20s %s\n" "Screenpipe Service:" "$(get_service_status)"
    printf "%-20s %s\n" "API Endpoint:" "$(get_api_status)"
    printf "%-20s %s\n" "Memory Usage:" "$(get_memory_usage)"
    echo ""
    
    echo -e "${SEARCH} ${PURPLE}DATA STATUS${NC}"
    echo "════════════════════════════════════════════════════════════"
    printf "%-20s %s\n" "Data Size:" "$(get_data_info)"
    printf "%-20s %s\n" "Recent Activity:" "$(get_recent_activity)"
    echo ""
    
    echo -e "${GEAR} ${PURPLE}QUICK ACTIONS${NC}"
    echo "════════════════════════════════════════════════════════════"
    echo "1) Start Service          6) View Logs"
    echo "2) Stop Service           7) Health Check"
    echo "3) Restart Service        8) Test Search"
    echo "4) Service Status         9) Open Web Interface"
    echo "5) Launch Menu Bar        0) Exit"
    echo ""
    
    echo -e "${INFO} ${PURPLE}USEFUL COMMANDS${NC}"
    echo "════════════════════════════════════════════════════════════"
    echo "• Web Interface: http://localhost:3030"
    echo "• Data Folder: /Users/zeh/Local_Projects/Strategy_agents/screenpipe/data"
    echo "• Logs Folder: /Users/zeh/Local_Projects/Strategy_agents/screenpipe/logs"
    echo ""
    
    read -p "Select action (1-9, 0 to exit): " choice
}

# Function to execute actions
execute_action() {
    local choice=$1
    local bin_dir="/Users/zeh/Local_Projects/Strategy_agents/screenpipe/bin"
    
    case $choice in
        1)
            echo -e "${ROCKET} Starting Screenpipe service..."
            cd "$bin_dir"
            ./start_screenpipe.sh start true
            read -p "Press Enter to continue..."
            ;;
        2)
            echo -e "${WARNING} Stopping Screenpipe service..."
            cd "$bin_dir"
            ./start_screenpipe.sh stop
            read -p "Press Enter to continue..."
            ;;
        3)
            echo -e "${GEAR} Restarting Screenpipe service..."
            cd "$bin_dir"
            ./start_screenpipe.sh restart
            read -p "Press Enter to continue..."
            ;;
        4)
            echo -e "${INFO} Service Status:"
            echo "══════════════"
            cd "$bin_dir"
            ./start_screenpipe.sh status
            echo ""
            ./health_check.sh summary
            read -p "Press Enter to continue..."
            ;;
        5)
            echo -e "${ROCKET} Launching Menu Bar App..."
            cd "$bin_dir"
            python3 screenpipe_menubar.py &
            echo "Menu bar app launched in background"
            read -p "Press Enter to continue..."
            ;;
        6)
            echo -e "${INFO} Recent Logs:"
            echo "════════════"
            local logs_dir="/Users/zeh/Local_Projects/Strategy_agents/screenpipe/logs"
            if [ -f "$logs_dir/service.log" ]; then
                echo "Service Log (last 20 lines):"
                tail -20 "$logs_dir/service.log"
            fi
            echo ""
            if [ -f "$logs_dir/screenpipe_stderr.log" ]; then
                echo "Error Log (last 10 lines):"
                tail -10 "$logs_dir/screenpipe_stderr.log"
            fi
            read -p "Press Enter to continue..."
            ;;
        7)
            echo -e "${CHECKMARK} Running Health Check..."
            echo "═════════════════════════"
            cd "$bin_dir"
            ./health_check.sh full
            read -p "Press Enter to continue..."
            ;;
        8)
            echo -e "${SEARCH} Testing Search Functionality..."
            echo "═══════════════════════════════"
            if curl -s "http://localhost:3030/search?limit=5" | jq . 2>/dev/null; then
                echo ""
                echo -e "${GREEN}Search test successful!${NC}"
            else
                echo "Testing without jq..."
                curl -s "http://localhost:3030/search?limit=5" || echo -e "${RED}Search test failed${NC}"
            fi
            read -p "Press Enter to continue..."
            ;;
        9)
            echo -e "${ROCKET} Opening Web Interface..."
            if command -v open >/dev/null 2>&1; then
                open http://localhost:3030
            else
                echo "Open http://localhost:3030 in your browser"
            fi
            read -p "Press Enter to continue..."
            ;;
        0)
            echo -e "${CHECKMARK} Goodbye!"
            exit 0
            ;;
        *)
            echo -e "${WARNING} Invalid choice. Please try again."
            read -p "Press Enter to continue..."
            ;;
    esac
}

# Main loop
while true; do
    show_dashboard
    execute_action "$choice"
done
