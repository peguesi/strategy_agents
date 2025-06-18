#!/bin/bash
# Debug screenpipe status

echo "=== Current Screenpipe Processes ==="
ps aux | grep -i screenpipe | grep -v grep

echo -e "\n=== Port 3030 Status ==="
lsof -i :3030

echo -e "\n=== API Health Check ==="
curl -s http://localhost:3030/health | jq . || echo "API not responding"

echo -e "\n=== Recent Screenpipe Logs ==="
tail -n 20 /Users/zeh/Local_Projects/Strategy_agents/screenpipe/logs/screenpipe_stdout.log

echo -e "\n=== Recent Error Logs ==="
tail -n 10 /Users/zeh/Local_Projects/Strategy_agents/screenpipe/logs/screenpipe_stderr.log

echo -e "\n=== Menu Bar Log ==="
tail -n 10 /Users/zeh/Local_Projects/Strategy_agents/screenpipe/logs/menubar.log
