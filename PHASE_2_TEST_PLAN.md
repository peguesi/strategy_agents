# 🚀 PHASE 2: SERVICE MANAGEMENT & TESTING

## **SYSTEMATIC TEST PLAN**

Execute these tests in order to verify your complete Screenpipe setup and enable background operation.

---

## **TEST 1: BASIC SETUP VERIFICATION** ✅

### **1.1 Make Scripts Executable**
```bash
cd /Users/zeh/Local_Projects/Strategy_agents/screenpipe/bin
chmod +x *.sh *.py
chmod +x ../mcp/screenpipe_server.py
echo "✅ Scripts made executable"
```

### **1.2 Check Current Screenpipe Status**
```bash
# Check if screenpipe is running
ps aux | grep screenpipe

# Check port usage
lsof -i :3030

# Test API (if running)
curl http://localhost:3030/health
```

### **1.3 Directory Structure Verification**
```bash
# Verify all directories exist
ls -la /Users/zeh/Local_Projects/Strategy_agents/screenpipe/
```

**Expected Result:** ✅ All directories present (bin, mcp, data, logs, config)

---

## **TEST 2: SCREENPIPE SERVICE TESTING** 🔧

### **2.1 Start Screenpipe Service**
```bash
cd /Users/zeh/Local_Projects/Strategy_agents/screenpipe/bin
./start_screenpipe.sh start true
```

### **2.2 Verify Service Started**
```bash
# Wait 10 seconds, then check
sleep 10
./health_check.sh summary
```

### **2.3 Test API Endpoints**
```bash
# Health check
curl http://localhost:3030/health | jq

# Search test (should return empty or existing data)
curl 'http://localhost:3030/search?limit=5' | jq

# Check if recording is active
./health_check.sh full
```

**Expected Results:**
- ✅ Process running with PID
- ✅ API responding on port 3030
- ✅ Health status shows recording active
- ✅ Data directory being populated

---

## **TEST 3: MENU BAR APP TESTING** 📱

### **3.1 Install Python Dependencies**
```bash
# Install required packages
pip3 install rumps requests

# Verify installation
python3 -c "import rumps, requests; print('✅ Dependencies OK')"
```

### **3.2 Launch Menu Bar App**
```bash
cd /Users/zeh/Local_Projects/Strategy_agents/screenpipe/bin
python3 screenpipe_menubar.py
```

### **3.3 Test Menu Bar Functions**
1. **Check Menu Bar Icon** - Should appear in macOS menu bar
2. **Test Recording Controls:**
   - Click "🎤 Full Recording" 
   - Click "📹 Video Only"
   - Click "⏸️ Pause Recording"
3. **Test Quick Functions:**
   - Click "🔍 Quick Search"
   - Click "📱 Web Interface"
   - Click "📤 Export Daily Data"
   - Click "🛠️ Data Folder"
   - Click "📋 View Logs"

**Expected Results:**
- ✅ Menu bar icon visible
- ✅ All buttons respond
- ✅ Recording mode changes work
- ✅ Web interface opens (localhost:3030)

---

## **TEST 4: MCP INTEGRATION TESTING** 🔌

### **4.1 Test MCP Server Directly**
```bash
cd /Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp
python3 screenpipe_server.py
```

### **4.2 Install MCP Dependencies**
```bash
# Install MCP packages
pip3 install mcp httpx nest-asyncio

# Verify installation
python3 -c "import mcp, httpx, nest_asyncio; print('✅ MCP Dependencies OK')"
```

### **4.3 Configure Claude Desktop**
```bash
# Backup existing config
cp ~/Library/Application\ Support/Claude/claude_desktop_config.json ~/claude_desktop_config_backup.json

# Install new config
cp /Users/zeh/Local_Projects/Strategy_agents/screenpipe/config/claude_desktop_config.json ~/Library/Application\ Support/Claude/claude_desktop_config.json

echo "✅ Claude Desktop configured"
```

### **4.4 Restart Claude Desktop**
1. **Quit Claude Desktop** completely
2. **Relaunch Claude Desktop**
3. **Wait for startup** (MCP server will start automatically)

### **4.5 Test MCP Tools in Claude**
In Claude Desktop, try these commands:
```
"Search my recent screenpipe activity"
"Find coding sessions from today"
"Analyze my productivity patterns"
"Export a daily summary"
```

**Expected Results:**
- ✅ MCP server starts automatically with Claude
- ✅ Search tools work in Claude
- ✅ Productivity analysis available
- ✅ No connection errors

---

## **TEST 5: DATA PERSISTENCE & LOGGING** 📊

### **5.1 Generate Test Data**
1. **Record Some Activity:**
   - Open VS Code for 2 minutes
   - Open Chrome and browse websites
   - Type some text in any application
   
2. **Wait 3-5 minutes** for processing

### **5.2 Verify Data Capture**
```bash
# Check data directory
ls -la /Users/zeh/Local_Projects/Strategy_agents/screenpipe/data/

# Check database exists
ls -la /Users/zeh/Local_Projects/Strategy_agents/screenpipe/data/*.db

# Test search for recent activity
curl 'http://localhost:3030/search?q=Code&limit=10' | jq
```

### **5.3 Check Logs**
```bash
# View all logs
ls -la /Users/zeh/Local_Projects/Strategy_agents/screenpipe/logs/

# Check for errors
./health_check.sh logs

# Monitor real-time (optional)
tail -f /Users/zeh/Local_Projects/Strategy_agents/screenpipe/logs/service.log
```

**Expected Results:**
- ✅ Video files being created in data/
- ✅ Database file exists and grows
- ✅ Search returns your recent activity
- ✅ Logs show normal operation

---

## **TEST 6: SERVICE MANAGEMENT** ⚙️

### **6.1 Test Service Controls**
```bash
cd /Users/zeh/Local_Projects/Strategy_agents/screenpipe/bin

# Test stop
./start_screenpipe.sh stop
sleep 5
./health_check.sh summary

# Test start
./start_screenpipe.sh start true
sleep 10
./health_check.sh summary

# Test restart
./start_screenpipe.sh restart
sleep 10
./health_check.sh summary

# Test status
./start_screenpipe.sh status
```

### **6.2 Test Health Monitoring**
```bash
# Quick health
./health_check.sh

# Full diagnostics
./health_check.sh full

# Specific checks
./health_check.sh api
./health_check.sh process
./health_check.sh data
./health_check.sh mcp
```

**Expected Results:**
- ✅ Stop/start/restart all work
- ✅ Status reports correctly
- ✅ Health checks provide useful info
- ✅ No critical errors

---

## **TEST 7: AUTO-START CONFIGURATION** 🚀

### **7.1 Create Launch Agent (Optional)**
```bash
# Create launch agent for auto-start
mkdir -p ~/Library/LaunchAgents

cat > ~/Library/LaunchAgents/com.strategy.screenpipe.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.strategy.screenpipe</string>
    <key>Program</key>
    <string>/Users/zeh/Local_Projects/Strategy_agents/screenpipe/bin/start_screenpipe.sh</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/zeh/Local_Projects/Strategy_agents/screenpipe/bin/start_screenpipe.sh</string>
        <string>start</string>
        <string>true</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/zeh/Local_Projects/Strategy_agents/screenpipe/logs/launch_agent.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/zeh/Local_Projects/Strategy_agents/screenpipe/logs/launch_agent_error.log</string>
</dict>
</plist>
EOF

# Load launch agent
launchctl load ~/Library/LaunchAgents/com.strategy.screenpipe.plist

echo "✅ Auto-start configured"
```

### **7.2 Test Auto-Start**
```bash
# Stop current service
./start_screenpipe.sh stop

# Wait and check if launch agent restarts it
sleep 30
./health_check.sh summary
```

**Expected Results:**
- ✅ Service automatically restarts
- ✅ Runs without terminal session
- ✅ Survives system restart (test optional)

---

## **VALIDATION CHECKLIST** ✅

After completing all tests, verify:

### **Core Functionality**
- [ ] Screenpipe records screen activity
- [ ] Audio recording works (if enabled)
- [ ] Search returns relevant results
- [ ] Web interface accessible at localhost:3030

### **Integration**
- [ ] Menu bar app controls recording
- [ ] Claude Desktop MCP tools work
- [ ] Service management scripts function
- [ ] Health monitoring provides insights

### **Reliability**
- [ ] Service survives stop/start cycles
- [ ] Logs capture useful information
- [ ] Data persists between sessions
- [ ] No critical errors in health checks

### **Automation**
- [ ] Can run without VS Code/terminal
- [ ] Auto-start works (if configured)
- [ ] Background operation confirmed
- [ ] Resource usage acceptable

---

## **TROUBLESHOOTING** 🔧

### **Common Issues & Solutions**

**Issue: Screenpipe won't start**
```bash
# Check logs
./health_check.sh logs

# Try manual start
screenpipe --port 3030 --data-dir /Users/zeh/Local_Projects/Strategy_agents/screenpipe/data

# Check permissions
chmod +x /usr/local/bin/screenpipe
```

**Issue: API not responding**
```bash
# Check port conflicts
lsof -i :3030

# Try different port
screenpipe --port 3031

# Check firewall settings
```

**Issue: Menu bar app won't start**
```bash
# Install dependencies
pip3 install rumps requests

# Check Python path
which python3

# Run with debug
python3 -v screenpipe_menubar.py
```

**Issue: MCP integration fails**
```bash
# Install MCP packages
pip3 install mcp httpx nest-asyncio

# Check Claude config
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Restart Claude Desktop completely
```

**Issue: No data being captured**
```bash
# Check permissions
./start_screenpipe.sh logs

# Verify recording mode
curl http://localhost:3030/health

# Check disk space
df -h /Users/zeh/Local_Projects/Strategy_agents/screenpipe/data
```

---

## **SUCCESS CRITERIA** 🎯

**Phase 2 is COMPLETE when:**

1. ✅ **Screenpipe runs reliably** - Starts, stops, restarts without issues
2. ✅ **Menu bar control works** - All buttons function correctly
3. ✅ **Claude Desktop integration** - MCP tools respond in Claude
4. ✅ **Data capture verified** - Search returns your actual activity
5. ✅ **Background operation** - Runs without VS Code dependency
6. ✅ **Health monitoring** - Scripts provide useful diagnostics
7. ✅ **Service management** - Start/stop scripts work properly
8. ✅ **Auto-start configured** - Optional but recommended

---

## **NEXT: PHASE 3 PREPARATION** 🚀

Once Phase 2 tests pass, we'll move to:
- **Advanced automation** - Custom pipes development
- **Linear integration** - Task creation from activity
- **Productivity analytics** - Detailed pattern analysis
- **N8N workflows** - Real-time monitoring integration

**Ready to begin testing?** Start with **TEST 1** and work through systematically!
