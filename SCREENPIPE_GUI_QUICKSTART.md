# 🎉 Screenpipe GUI App - Post-Build Quick Start

## **Once Build Completes**

### **1. Immediate Actions**
```bash
# The app will be at:
# ./src-tauri/target/release/bundle/macos/Screenpipe.app

# Option 1: Install to Applications (Recommended)
cp -R ./src-tauri/target/release/bundle/macos/Screenpipe.app /Applications/

# Option 2: Run from build directory
open ./src-tauri/target/release/bundle/macos/Screenpipe.app
```

### **2. First Launch Configuration**

1. **Grant Permissions**
   - Screen Recording: System Preferences → Security & Privacy → Screen Recording
   - Accessibility: For keyboard shortcuts and UI automation

2. **Configure Data Directory**
   - Settings → Advanced → Data Directory
   - Set to: `/Users/zeh/Local_Projects/Strategy_agents/screenpipe/data`
   - This preserves all your existing recordings!

3. **Stop Old Services**
   ```bash
   # Stop CLI service to avoid conflicts
   cd /Users/zeh/Local_Projects/Strategy_agents/screenpipe/bin
   ./start_screenpipe.sh stop
   
   # Kill menu bar app
   pkill -f screenpipe_menubar.py
   ```

### **3. Essential First Steps**

1. **AI Provider Setup**
   - Settings → AI → Provider: Ollama
   - Model: phi4:14b-q4_K_M (or your preferred model)

2. **Install Core Pipes**
   - Open Pipe Store tab
   - Recommended first installs:
     - **Timeline View** - Visual activity timeline
     - **Search Enhanced** - Better search UI
     - **Productivity Analytics** - Work patterns
     - **Meeting Assistant** - Auto-detect meetings

3. **Test Core Features**
   - Search for recent activity
   - Check timeline view
   - Verify recording status
   - Test export function

### **4. Update MCP Integration**

```bash
# Update Claude config for GUI app
cat > ~/Library/Application\ Support/Claude/claude_desktop_config.json << 'EOF'
{
  "mcpServers": {
    "screenpipe": {
      "command": "/Applications/Screenpipe.app/Contents/MacOS/screenpipe",
      "args": ["--mcp-server"],
      "env": {
        "SCREENPIPE_DATA_DIR": "/Users/zeh/Local_Projects/Strategy_agents/screenpipe/data"
      }
    }
  }
}
EOF

# Restart Claude
osascript -e 'quit app "Claude"'
sleep 2
open -a "Claude"
```

### **5. Quick Feature Tour**

**Dashboard Tab**
- Real-time activity cards
- Quick stats (apps used, productivity score)
- Recent meetings/focused work

**Search Tab**
- Natural language search
- Time filters
- App filters
- Visual previews

**Timeline Tab**
- Chronological view
- Zoom in/out
- Click to see details

**Pipe Store Tab**
- Browse available pipes
- One-click install
- Check for updates

**Settings Tab**
- Recording preferences
- Privacy zones
- Export options
- Keyboard shortcuts

### **6. Next Development Steps**

Once running, consider:
1. Creating a custom pipe for Linear integration
2. Setting up productivity rules
3. Configuring export automation
4. Building Strategy Agent pipe

### **Troubleshooting**

**App won't start?**
```bash
# Check logs
tail -f ~/Library/Logs/Screenpipe/screenpipe.log

# Reset preferences
rm ~/Library/Preferences/com.screenpipe.app.plist
```

**Performance issues?**
- Settings → Performance → Lower quality settings
- Disable unnecessary pipes
- Check Activity Monitor

**Can't see old data?**
- Verify data directory path in settings
- Check permissions on data folder

---

## **Enjoy your new Screenpipe GUI! 🚀**

The visual interface will transform how you interact with your screen data.
