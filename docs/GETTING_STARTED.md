# Getting Started - Strategy Agents System

> **Goal**: Create an intelligent system that captures your work patterns, automates strategic decisions, and amplifies your productivity through AI agents.

## 🎯 What This System Does

This system transforms your digital behavior into strategic intelligence by:
- **Capturing Everything**: Your screen activity, app usage, and work patterns via Screenpipe
- **Understanding Context**: AI analyzes what you're working on and how you work best
- **Automating Decisions**: Creates tasks, manages projects, and optimizes workflows automatically
- **Strategic Intelligence**: Turns daily activities into long-term strategic insights

## 📋 Prerequisites

- **macOS or Linux** (Windows support limited for Screenpipe)
- **Claude Pro subscription** (for desktop app and API access)
- **Linear workspace** (project management)
- **GitHub account** (code repositories)
- **Terminal comfort** (basic command line usage)

---

## 🚀 Setup Order (Critical - Follow This Sequence)

### Phase 1: Foundation Setup

#### Step 1: Get Claude Desktop + MCP
```bash
# 1. Download Claude Desktop from anthropic.com
# 2. Install and sign in with your Claude Pro account

# 3. Verify MCP support is enabled in Claude Desktop settings
# Settings > Features > Model Context Protocol should be ON
```

#### Step 2: Enable Terminal & File Access
```bash
# Create MCP configuration file
mkdir -p ~/.config/claude-desktop
cat > ~/.config/claude-desktop/claude_desktop_config.json << 'EOF'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/YOUR_USERNAME"],
      "env": {}
    },
    "screenpipe-terminal": {
      "command": "npx",
      "args": ["-y", "screenpipe-mcp"],
      "env": {}
    }
  }
}
EOF

# Replace YOUR_USERNAME with your actual username
# Restart Claude Desktop
```

> **Why This Order**: Claude needs terminal and file access BEFORE we install other components. This lets Claude help you with the rest of the setup.

### Phase 2: Screenpipe Installation (Major Component)

#### Step 3: Install Screenpipe
```bash
# Option A: Using Homebrew (Recommended)
brew install screenpipe

# Option B: Download from screenpipe.ai
# Download the .dmg file and install manually

# Option C: Build from source (if you want latest features)
git clone https://github.com/mediar-ai/screenpipe
cd screenpipe
cargo install --path .
```

#### Step 4: Configure Screenpipe
```bash
# Start screenpipe for first time
screenpipe

# This will:
# 1. Ask for screen recording permissions
# 2. Ask for microphone permissions (optional but recommended)
# 3. Create ~/.screenpipe/ directory
# 4. Start capturing your activity

# Keep this running in the background
```

#### Step 5: Test Screenpipe Integration
```bash
# In Claude Desktop, test the connection:
# "Can you search my recent screenpipe activity?"
# Claude should now be able to see your screen activity
```

### Phase 3: Project Management Setup

#### Step 6: Linear Configuration
```bash
# 1. Create Linear workspace at linear.app
# 2. Get your API key: Linear Settings > API > Personal API Keys
# 3. Note your workspace URL and team IDs

# Add Linear to Claude Desktop config
cat > ~/.config/claude-desktop/claude_desktop_config.json << 'EOF'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/YOUR_USERNAME"],
      "env": {}
    },
    "screenpipe-terminal": {
      "command": "npx",
      "args": ["-y", "screenpipe-mcp"],
      "env": {}
    },
    "linear": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-linear"],
      "env": {
        "LINEAR_API_KEY": "YOUR_LINEAR_API_KEY"
      }
    }
  }
}
EOF
```

#### Step 7: n8n Workflow Engine
```bash
# Install n8n globally
npm install -g n8n

# Start n8n
n8n start

# Access at http://localhost:5678
# Set up your first workflow connecting Linear + Claude API
```

### Phase 4: Strategy Agents Activation

#### Step 8: Clone Strategy Agents Repository
```bash
# Create your projects directory
mkdir -p ~/Local_Projects
cd ~/Local_Projects

# Clone the strategy agents system
git clone https://github.com/your-username/strategy-agents.git
cd strategy-agents

# Install dependencies
npm install
```

#### Step 9: Configure Agent System
```bash
# Copy environment template
cp .env.example .env

# Edit with your credentials
nano .env

# Required variables:
# CLAUDE_API_KEY=your_claude_api_key
# LINEAR_API_KEY=your_linear_api_key  
# SCREENPIPE_URL=http://localhost:3030
# N8N_WEBHOOK_URL=your_n8n_webhook_url
```

#### Step 10: Start the Agent System
```bash
# Start all agents
npm run start:agents

# This launches:
# - Research Inspiration Agent (monitors Instagram/social)
# - Strategic PM Agent (manages Linear tasks)
# - Productivity Pattern Agent (analyzes screenpipe data)
# - Revenue Optimization Agent (tracks business metrics)
```

---

## 🧠 Understanding the System Architecture

### Data Flow
```
Your Activity (Screenpipe) → AI Analysis (Claude) → Strategic Actions (Linear/n8n)
```

### Core Agents

#### 1. **Research Inspiration Agent**
- **Purpose**: Captures inspiring content from social media
- **Triggers**: Instagram activity >30s, screenshots, saves
- **Actions**: Creates Linear research tasks with business analysis
- **Data Source**: Screenpipe OCR + screen capture

#### 2. **Strategic PM Agent**  
- **Purpose**: Intelligent project management automation
- **Triggers**: New Linear issues, project updates, deadlines
- **Actions**: Auto-assigns labels, creates dependencies, sends updates
- **Integration**: Linear GraphQL API + Claude reasoning

#### 3. **Productivity Pattern Agent**
- **Purpose**: Analyzes work patterns for optimization
- **Triggers**: Daily/weekly screenpipe analysis
- **Actions**: Suggests focus times, identifies distractions
- **Output**: Productivity reports in Linear

#### 4. **Revenue Optimization Agent**
- **Purpose**: Tracks progress toward €50k revenue goal
- **Triggers**: Client work completion, revenue milestones
- **Actions**: Updates revenue tracking, suggests high-value tasks
- **Integration**: Linear + custom revenue tracking

### Key Directories
```
strategy-agents/
├── agents/           # Individual agent code
├── config/           # Configuration files
├── workflows/        # n8n workflow exports
├── scripts/          # Utility scripts
├── docs/            # Documentation
└── data/            # Agent memory and logs
```

---

## 🔧 Daily Usage Patterns

### Morning Routine
1. **Check Overnight Captures**: "Claude, what did screenpipe capture overnight?"
2. **Review Agent Actions**: "Show me what the agents did yesterday"
3. **Plan Today**: "Based on my patterns, what should I focus on today?"

### During Work
- Agents automatically capture inspiration content
- Strategic PM agent manages Linear tasks in background
- Productivity patterns analyzed in real-time

### Evening Review
1. **Productivity Analysis**: "Analyze today's productivity patterns"
2. **Revenue Progress**: "Update revenue tracking based on today's work"
3. **Tomorrow Planning**: "Based on today's patterns, plan tomorrow's priorities"

---

## 🛠 Customization Guide

### Adding New Agents
```javascript
// Create new agent file: agents/my-custom-agent.js
const agent = {
  name: 'MyCustomAgent',
  triggers: ['specific_events'],
  actions: async (data) => {
    // Your agent logic
  }
};

export default agent;
```

### Modifying Screenpipe Filters
```javascript
// Edit config/screenpipe-filters.json
{
  "apps_to_monitor": ["Instagram", "LinkedIn", "Claude"],
  "keywords_to_track": ["AI", "automation", "strategy"],
  "minimum_session_length": 30
}
```

### Custom Linear Labels
The system uses intelligent labeling:
- **Size**: XS, S, M, L, XL (effort estimation)
- **Revenue**: High/Medium/Low Revenue (business impact)
- **Type**: Client Work, Research, Implementation, Strategy
- **Focus**: Deep-Work, Quick-Win, Related Automation

---

## 🚨 Troubleshooting

### Screenpipe Issues
```bash
# Check if screenpipe is running
ps aux | grep screenpipe

# Restart screenpipe
killall screenpipe
screenpipe

# Check permissions
# System Preferences > Security & Privacy > Screen Recording
```

### Claude MCP Connection Issues
```bash
# Verify MCP config
cat ~/.config/claude-desktop/claude_desktop_config.json

# Check Claude Desktop logs
tail -f ~/Library/Logs/Claude/claude-desktop.log
```

### Linear API Issues
```bash
# Test Linear API key
curl -H "Authorization: YOUR_LINEAR_API_KEY" \
     -H "Content-Type: application/json" \
     https://api.linear.app/graphql \
     -d '{"query": "{ viewer { id name } }"}'
```

### n8n Workflow Issues
```bash
# Check n8n logs
n8n start --log-level debug

# Restart n8n service
pkill n8n
n8n start
```

---

## 📈 Success Metrics

### Week 1 Goals
- [ ] Screenpipe capturing 8+ hours daily
- [ ] Claude can search and analyze your activity
- [ ] Linear tasks being created automatically
- [ ] First inspiration content captured and analyzed

### Month 1 Goals  
- [ ] 50+ automated task creations
- [ ] Productivity patterns identified
- [ ] Revenue tracking system operational
- [ ] Custom agents responding to your work style

### Month 3 Goals
- [ ] €10k+ revenue tracked through system
- [ ] 3+ custom agents built for your workflow
- [ ] Client delivery templates automated
- [ ] Strategic insights driving major decisions

---

## 🎁 Pro Tips

1. **Start Small**: Begin with just Screenpipe + Claude, add agents gradually
2. **Privacy First**: All data stays local, no cloud processing required
3. **Iterate Fast**: The system learns your patterns - give it 2 weeks minimum
4. **Document Everything**: Use Linear to track what works and what doesn't
5. **Share Patterns**: Export successful workflows to help others

---

## 🆘 Getting Help

### Community
- **Discord**: Join the Screenpipe community
- **GitHub**: Issues and feature requests
- **Claude Forums**: MCP integration help

### Direct Support
- **Linear**: Contact for project management questions
- **Screenpipe**: GitHub issues for technical problems
- **n8n**: Community forum for workflow automation

### Emergency Stops
```bash
# Stop all agents
pkill -f "strategy-agents"

# Stop screenpipe
killall screenpipe

# Reset Claude MCP config
mv ~/.config/claude-desktop/claude_desktop_config.json ~/.config/claude-desktop/claude_desktop_config.json.backup
```

---

## 🎯 Next Level (Advanced Features)

Once you're comfortable with the basics:

- **Multi-Agent Orchestration**: Complex workflows between agents
- **Predictive Analytics**: Forecast productivity and revenue trends  
- **Client Automation**: Automated proposal generation and delivery
- **Cross-Platform Sync**: Mobile app integration and cloud sync
- **Team Collaboration**: Multi-user agent coordination

---

## 🔗 Related Documentation

- **[BUSINESS_QUALIFICATION.md](BUSINESS_QUALIFICATION.md)** - Complete qualification survey for business customization
- **[README.md](README.md)** - Technical platform overview and architecture
- **[docs/SETUP.md](docs/SETUP.md)** - Detailed technical installation guide
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System design and component relationships

---

*This system is designed to grow with you. Start with the foundation, let it learn your patterns, and gradually add more sophisticated automation as you see what works best for your unique workflow.*
