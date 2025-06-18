#!/bin/bash
# Debug Screenpipe status

echo "🔍 Checking Screenpipe Process..."
echo ""

# Check if PID from file is running
PID_FILE="/Users/zeh/Local_Projects/Strategy_agents/screenpipe/config/screenpipe.pid"
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    echo "PID from file: $PID"
    
    if ps -p $PID > /dev/null; then
        echo "✅ Process $PID is running"
        echo ""
        echo "Process details:"
        ps aux | grep -E "^[^ ]+[ ]+$PID" | grep -v grep
    else
        echo "❌ Process $PID is NOT running"
    fi
else
    echo "❌ No PID file found"
fi

echo ""
echo "All Screenpipe processes:"
ps aux | grep screenpipe | grep -v grep

echo ""
echo "Checking port 3030:"
lsof -i :3030

echo ""
echo "Checking other common ports (3031-3035):"
for port in 3031 3032 3033 3034 3035; do
    if lsof -i :$port 2>/dev/null | grep LISTEN; then
        echo "Found service on port $port"
    fi
done

echo ""
echo "Recent Screenpipe logs:"
tail -n 20 /Users/zeh/Local_Projects/Strategy_agents/screenpipe/logs/screenpipe_stdout.log 2>/dev/null | grep -E "(port|listening|started|error)" || echo "No recent port info in logs"
