# 🎨 PHASE 3: SCREENPIPE GUI DESKTOP APP SETUP

## **EXECUTIVE SUMMARY**

The Screenpipe GUI desktop app offers significant advantages over the CLI/menu bar approach you've been using:

### **Key Benefits of the GUI App:**

1. **🖥️ Full Visual Interface**
   - Rich dashboard with real-time activity visualization
   - Interactive timeline and productivity analytics
   - Visual search interface with filters and previews
   - Built-in data export and management tools

2. **🔌 Pipe Store Integration**
   - Direct access to community plugins ("pipes")
   - One-click installation of productivity tools
   - Revenue potential for custom pipe development
   - No manual configuration required

3. **🎯 Enhanced Features**
   - Advanced search with visual previews
   - Meeting transcription with speaker identification
   - Productivity analytics and insights
   - Cross-platform synchronization capabilities
   - Built-in AI integration (Ollama, OpenAI, etc.)

4. **⚡ Performance Benefits**
   - Native performance using Tauri framework
   - 90% less memory usage than Electron alternatives
   - Instant startup and responsive UI
   - Background optimization for recording

5. **🔧 Developer Benefits**
   - Plugin development framework
   - TypeScript/React extensibility
   - Direct API access for custom integrations
   - Built-in debugging tools

---

## **INSTALLATION OPTIONS**

### **Option 1: Official Desktop App (Recommended)**

The official Screenpipe desktop app is built with Tauri and provides the best user experience.

```bash
# Download from official site
open https://screenpi.pe

# Or direct download link
curl -L https://github.com/mediar-ai/screenpipe/releases/latest/download/screenpipe-macos-x86_64.dmg -o screenpipe.dmg

# Install
hdiutil attach screenpipe.dmg
cp -R /Volumes/Screenpipe/Screenpipe.app /Applications/
hdiutil detach /Volumes/Screenpipe

# First launch
open /Applications/Screenpipe.app
```

### **Option 2: Build from Source (Advanced)**

For customization and development purposes:

```bash
# Clone the repository
cd /Users/zeh/Local_Projects/Strategy_agents
git clone https://github.com/mediar-ai/screenpipe-app-tauri.git
cd screenpipe-app-tauri

# Install dependencies
brew install rust node
cargo install tauri-cli

# Install frontend dependencies
npm install

# Build the app
npm run tauri build

# The built app will be in src-tauri/target/release/bundle/
```

---

## **GUI APP ARCHITECTURE**

The Screenpipe GUI uses a modern architecture:

```
┌─────────────────────────────────────┐
│        Tauri Desktop App            │
├─────────────────────────────────────┤
│  Frontend (React + TypeScript)      │
│  - Dashboard Components             │
│  - Search Interface                 │
│  - Timeline Visualization          │
│  - Pipe Store                      │
├─────────────────────────────────────┤
│  Rust Backend (Tauri)              │
│  - System Integration              │
│  - Database Management             │
│  - Recording Engine                │
│  - API Layer                       │
├─────────────────────────────────────┤
│  Local Storage                     │
│  - SQLite Database                 │
│  - Video/Audio Files               │
│  - Configuration                   │
└─────────────────────────────────────┘
```

---

## **SETUP STEPS**

### **Step 1: Pre-Installation Cleanup**

```bash
# Stop existing services
cd /Users/zeh/Local_Projects/Strategy_agents/screenpipe/bin
./start_screenpipe.sh stop

# Kill menu bar app if running
pkill -f screenpipe_menubar.py

# Backup existing data
cp -R /Users/zeh/Local_Projects/Strategy_agents/screenpipe/data ~/screenpipe_backup_$(date +%Y%m%d)
```

### **Step 2: Install GUI App**

```bash
# Download and install
curl -L https://github.com/mediar-ai/screenpipe/releases/latest/download/screenpipe-macos-x86_64.dmg -o ~/Downloads/screenpipe.dmg
hdiutil attach ~/Downloads/screenpipe.dmg
cp -R /Volumes/Screenpipe/Screenpipe.app /Applications/
hdiutil detach /Volumes/Screenpipe
rm ~/Downloads/screenpipe.dmg

echo "✅ Screenpipe GUI installed"
```

### **Step 3: Initial Configuration**

1. **Launch the App**
   ```bash
   open /Applications/Screenpipe.app
   ```

2. **Configure Data Directory**
   - Settings → Advanced → Data Directory
   - Set to: `/Users/zeh/Local_Projects/Strategy_agents/screenpipe/data`

3. **Import Existing Configuration**
   - Settings → Import/Export → Import Config
   - Select: `/Users/zeh/Local_Projects/Strategy_agents/screenpipe/config/`

4. **Set Recording Preferences**
   - Enable screen recording
   - Configure audio input
   - Set quality preferences
   - Configure privacy zones

### **Step 4: AI Provider Setup**

```bash
# Install Ollama (if not already installed)
curl -fsSL https://ollama.com/install.sh | sh

# Pull recommended model
ollama pull phi4:14b-q4_K_M

# Configure in GUI
# Settings → AI → Provider: Ollama
# Model: phi4:14b-q4_K_M
```

### **Step 5: Pipe Store Configuration**

1. **Browse Available Pipes**
   - Open Pipe Store tab in GUI
   - Popular pipes to install:
     - Timeline View
     - Meeting Transcriber
     - Productivity Analytics
     - Linear Integration
     - Code Activity Tracker

2. **Install Essential Pipes**
   ```javascript
   // Example: Install via GUI or CLI
   screenpipe pipe install timeline-view
   screenpipe pipe install meeting-transcriber
   screenpipe pipe install linear-integration
   ```

### **Step 6: MCP Integration Update**

Update Claude Desktop config for GUI app:

```bash
# Create updated config
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

# Restart Claude Desktop
osascript -e 'quit app "Claude"'
sleep 2
open -a "Claude"
```

---

## **GUI FEATURES OVERVIEW**

### **1. Dashboard**
- Real-time activity monitoring
- Productivity metrics
- Application usage statistics
- Meeting summary cards

### **2. Search Interface**
- Natural language search
- Time-based filtering
- Application filtering
- Content type filtering
- Visual previews

### **3. Timeline View**
- Chronological activity display
- Zoom and pan controls
- Activity clustering
- Quick navigation

### **4. Pipe Store**
- Browse community pipes
- One-click installation
- Automatic updates
- Revenue sharing for developers

### **5. Settings Panel**
- Recording configuration
- Privacy settings
- AI provider setup
- Export preferences
- Keyboard shortcuts

---

## **MIGRATION CHECKLIST**

- [ ] Stop existing CLI/menubar services
- [ ] Backup current data
- [ ] Install GUI application
- [ ] Configure data directory
- [ ] Set up AI provider
- [ ] Install essential pipes
- [ ] Update MCP configuration
- [ ] Test search functionality
- [ ] Verify recording works
- [ ] Configure auto-start

---

## **DEVELOPMENT OPPORTUNITIES**

### **Custom Pipe Development**

Create custom pipes for your workflow:

```typescript
// Example: Strategy Agent Integration Pipe
export default {
  name: "strategy-agent-integration",
  version: "1.0.0",
  description: "Integrate Screenpipe with Strategy Agents",
  
  async onInstall() {
    // Setup code
  },
  
  async processActivity(activity) {
    // Custom processing logic
    if (activity.app === "Linear") {
      await this.createLinearContext(activity);
    }
  },
  
  ui: {
    settings: StrategyAgentSettings,
    dashboard: StrategyAgentDashboard
  }
}
```

### **Revenue Potential**

The Pipe Store allows monetization:
- Develop specialized productivity pipes
- Set subscription pricing ($5-50/month)
- Screenpipe handles payments via Stripe
- 70/30 revenue split

---

## **TROUBLESHOOTING**

### **Common Issues**

**GUI Won't Start**
```bash
# Check logs
tail -f ~/Library/Logs/Screenpipe/screenpipe.log

# Reset preferences
rm -rf ~/Library/Preferences/com.screenpipe.app.plist

# Reinstall
rm -rf /Applications/Screenpipe.app
# Then reinstall
```

**Performance Issues**
```bash
# Clear cache
rm -rf ~/Library/Caches/com.screenpipe.app

# Optimize database
sqlite3 /Users/zeh/Local_Projects/Strategy_agents/screenpipe/data/screenpipe.db "VACUUM;"
```

**Recording Not Working**
1. System Preferences → Security & Privacy → Screen Recording
2. Ensure Screenpipe.app is checked
3. Restart the app

---

## **NEXT STEPS**

Once the GUI is set up:

1. **Explore Pipe Ecosystem**
   - Install productivity pipes
   - Test automation capabilities
   - Configure integrations

2. **Develop Custom Pipes**
   - Create Linear automation pipe
   - Build custom analytics
   - Integrate with Strategy Agents

3. **Advanced Configuration**
   - Set up cloud sync (optional)
   - Configure team sharing
   - Implement custom workflows

---

## **COMPARISON: CURRENT SETUP vs GUI**

| Feature | Current (CLI + Menu Bar) | GUI Desktop App |
|---------|-------------------------|-----------------|
| Interface | Basic menu bar | Full dashboard |
| Search | API calls only | Visual search UI |
| Pipes | Manual setup | One-click install |
| Analytics | Custom scripts | Built-in charts |
| Updates | Manual | Automatic |
| Memory | ~100MB | ~50MB |
| Features | Limited | Full ecosystem |

---

## **READY TO UPGRADE?**

The GUI app provides a significantly better experience while maintaining all the functionality of your current setup. It's the natural evolution for Phase 3 of your Strategy Agents project.

**Start with Step 1** and work through the setup process. The entire migration should take about 30 minutes.
