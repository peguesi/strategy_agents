#!/bin/bash
# Screenpipe Service Starter for Strategy Agents
# Starts Screenpipe with proper configuration and logging

# Set up paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$BASE_DIR/data"
LOGS_DIR="$BASE_DIR/logs"
CONFIG_DIR="$BASE_DIR/config"

# Ensure directories exist
mkdir -p "$DATA_DIR" "$LOGS_DIR" "$CONFIG_DIR"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOGS_DIR/service.log"
}

# Find screenpipe executable
find_screenpipe() {
    # Check multiple possible locations
    local possible_paths=(
        "/usr/local/bin/screenpipe"
        "$HOME/.cargo/bin/screenpipe"
        "/opt/homebrew/bin/screenpipe"
        "/Users/zeh/Local_Projects/screenpipe/target/release/screenpipe"
        "$(which screenpipe 2>/dev/null)"
    )
    
    for path in "${possible_paths[@]}"; do
        if [ -x "$path" ] && [ -f "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    
    log_message "ERROR: Could not find screenpipe executable"
    return 1
}

# Set screenpipe path
SCREENPIPE_BIN=$(find_screenpipe)
if [ -z "$SCREENPIPE_BIN" ]; then
    echo "ERROR: screenpipe not found. Please install screenpipe first."
    exit 1
fi

log_message "Using screenpipe at: $SCREENPIPE_BIN"

# Function to check if screenpipe is running
is_screenpipe_running() {
    pgrep -f "$SCREENPIPE_BIN" > /dev/null
}

# Function to stop screenpipe
stop_screenpipe() {
    log_message "Stopping existing Screenpipe processes..."
    pkill -f "$SCREENPIPE_BIN"
    sleep 2
    
    # Force kill if still running
    if is_screenpipe_running; then
        log_message "Force killing stubborn processes..."
        pkill -9 -f "$SCREENPIPE_BIN"
        sleep 1
    fi
}

# Function to start screenpipe
start_screenpipe() {
    local audio_enabled=${1:-true}
    
    log_message "Starting Screenpipe..."
    log_message "Audio enabled: $audio_enabled"
    log_message "Data directory: $DATA_DIR"
    log_message "Port: 3030"
    
    # Build command
    cmd="$SCREENPIPE_BIN --port 3030 --data-dir \"$DATA_DIR\""
    
    if [ "$audio_enabled" = "false" ]; then
        cmd="$cmd --disable-audio"
    fi
    
    # Start screenpipe in background with logging
    log_message "Command: $cmd"
    
    # Start and capture PID
    eval "$cmd" > "$LOGS_DIR/screenpipe_stdout.log" 2> "$LOGS_DIR/screenpipe_stderr.log" &
    screenpipe_pid=$!
    
    # Save PID for management
    echo $screenpipe_pid > "$CONFIG_DIR/screenpipe.pid"
    
    log_message "Screenpipe started with PID: $screenpipe_pid"
    
    # Wait a moment and verify it started
    sleep 3
    if is_screenpipe_running; then
        # Test API
        if curl -s http://localhost:3030/health > /dev/null 2>&1; then
            log_message "✅ Screenpipe started successfully and API is responding"
            return 0
        else
            log_message "⚠️ Screenpipe started but API not responding yet (may need more time)"
            return 0
        fi
    else
        log_message "❌ Failed to start Screenpipe"
        return 1
    fi
}

# Function to get status
get_status() {
    if is_screenpipe_running; then
        if curl -s http://localhost:3030/health > /dev/null 2>&1; then
            echo "✅ Running (API responding)"
        else
            echo "⚠️ Running (API not responding)"
        fi
    else
        echo "❌ Not running"
    fi
}

# Function to restart screenpipe
restart_screenpipe() {
    local audio_enabled=${1:-true}
    log_message "Restarting Screenpipe..."
    stop_screenpipe
    sleep 2
    start_screenpipe "$audio_enabled"
}

# Main command handling
case "${1:-start}" in
    "start")
        if is_screenpipe_running; then
            log_message "Screenpipe is already running"
            get_status
        else
            start_screenpipe "${2:-true}"
        fi
        ;;
    "stop")
        stop_screenpipe
        log_message "Screenpipe stopped"
        ;;
    "restart")
        restart_screenpipe "${2:-true}"
        ;;
    "status")
        echo "Status: $(get_status)"
        if [ -f "$CONFIG_DIR/screenpipe.pid" ]; then
            pid=$(cat "$CONFIG_DIR/screenpipe.pid")
            echo "PID: $pid"
        fi
        echo "Data directory: $DATA_DIR"
        echo "Logs directory: $LOGS_DIR"
        echo "Screenpipe binary: $SCREENPIPE_BIN"
        ;;
    "logs")
        echo "=== Service Logs ==="
        tail -n 20 "$LOGS_DIR/service.log" 2>/dev/null || echo "No service logs found"
        echo ""
        echo "=== Screenpipe Stdout ==="
        tail -n 20 "$LOGS_DIR/screenpipe_stdout.log" 2>/dev/null || echo "No stdout logs found"
        echo ""
        echo "=== Screenpipe Stderr ==="
        tail -n 20 "$LOGS_DIR/screenpipe_stderr.log" 2>/dev/null || echo "No stderr logs found"
        ;;
    "test")
        log_message "Testing Screenpipe API..."
        if curl -s http://localhost:3030/health; then
            echo ""
            log_message "✅ API test successful"
        else
            log_message "❌ API test failed"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|test} [audio_enabled]"
        echo ""
        echo "Commands:"
        echo "  start [true|false]  - Start Screenpipe (audio enabled by default)"
        echo "  stop                - Stop Screenpipe"
        echo "  restart [true|false]- Restart Screenpipe"
        echo "  status              - Show current status"
        echo "  logs                - Show recent logs"
        echo "  test                - Test API connection"
        echo ""
        echo "Examples:"
        echo "  $0 start true       - Start with audio"
        echo "  $0 start false      - Start without audio"
        echo "  $0 restart false    - Restart without audio"
        exit 1
        ;;
esac
