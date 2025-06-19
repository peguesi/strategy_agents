# Strategy Agents Complete Setup Guide 🚀

> **Professional deployment guide for the Strategy Agents automation platform**

## 📋 Prerequisites

### System Requirements
- **Python 3.10+** with pip and venv
- **Git** for version control
- **Claude Desktop** for MCP integration
- **Terminal access** (macOS/Linux)

### Required Accounts & Services
- **n8n Instance** (cloud or self-hosted)
- **Linear Workspace** with API access
- **Azure OpenAI** subscription
- **Slack Workspace** (for notifications)
- **GitHub Account** (for version control)

## 🎯 Installation Process

### Step 1: Repository Setup
```bash
# Clone the repository
git clone <your-repository-url>
cd Strategy_agents

# Run automated setup
./scripts/setup.sh
```

### Step 2: Environment Configuration
```bash
# Copy environment template
cp .env.example .env

# Edit configuration file
nano .env
```

### Step 3: Environment Variables
Add these to your `.env` file:

```bash
# === n8n Configuration ===
N8N_API_KEY=your-n8n-api-key-here
N8N_URL=https://your-n8n-instance.com
N8N_USER=your-email@domain.com

# === Linear Integration ===
LINEAR_API_KEY=lin_api_your-linear-api-key
LINEAR_API_URL=https://api.linear.app/graphql

# === Azure OpenAI ===
AZURE_OPENAI_KEY=your-azure-openai-key
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4

# === PostgreSQL Database ===
DATABASE_URL=postgresql://user:password@host:port/database

# === Slack Integration ===
SLACK_BOT_TOKEN=xoxb-your-slack-bot-token
SLACK_CHANNEL_ID=your-notification-channel-id
```

## 🔧 Claude Desktop Integration

### Step 1: Locate Configuration File
```bash
# macOS location
~/.config/claude-desktop/config.json

# Create if doesn't exist
mkdir -p ~/.config/claude-desktop
touch ~/.config/claude-desktop/config.json
```

### Step 2: Add MCP Server Configuration
```json
{
  "mcpServers": {
    "screenpipe-terminal": {
      "command": "/usr/bin/python3",
      "args": [
        "/path/to/Strategy_agents/screenpipe/mcp/screenpipe_server_with_terminal.py"
      ],
      "env": {
        "SCREENPIPE_API_URL": "http://localhost:3030"
      }
    },
    "n8n-complete": {
      "command": "/usr/bin/python3",
      "args": [
        "/path/to/Strategy_agents/mcp/n8n/n8n_complete_mcp_server.py"
      ]
    },
    "azure-postgresql": {
      "command": "/usr/bin/python3",
      "args": [
        "/path/to/Strategy_agents/mcp/azure-postgresql/src/azure_postgresql_mcp/server.py"
      ],
      "env": {
        "DATABASE_URL": "postgresql://localhost/strategy_db"
      }
    }
  }
}
```

### Step 3: Restart Claude Desktop
```bash
# Quit Claude Desktop completely
# Restart Claude Desktop application
```

## 🤖 n8n Workflow Setup

### Step 1: Import Workflows
```bash
# Navigate to n8n directory
cd n8n/workflows

# Import existing workflows to your n8n instance
# (Manual import through n8n UI using provided JSON files)
```

### Step 2: Configure Credentials
In your n8n instance, create these credentials:

#### Azure OpenAI Credential
- **Type**: HTTP Request Auth
- **Auth Type**: Generic Credential Type
- **Credential Type**: Custom
- **Headers**: 
  - `api-key`: Your Azure OpenAI key
  - `Content-Type`: application/json

#### Linear API Credential
- **Type**: HTTP Request Auth  
- **Auth Type**: Generic Credential Type
- **Authorization**: Bearer your-linear-api-key

#### Slack Credential
- **Type**: Slack
- **Access Token**: Your Slack bot token

### Step 3: Test Workflow Connections
```bash
# Test n8n MCP connection
./scripts/test.sh
```

## 👁️ Screenpipe Setup

### Step 1: Install Screenpipe
```bash
# Install Screenpipe (if not already installed)
# Follow screenpipe installation guide for your system
```

### Step 2: Configure Screenpipe
```bash
# Start Screenpipe service
cd screenpipe/bin
./start_screenpipe.sh

# Verify API is running
curl http://localhost:3030/health
```

### Step 3: Menu Bar Integration
```bash
# Start enhanced menu bar controller
cd screenpipe/bin
python3 screenpipe_menubar.py
```

## 📋 Linear Integration Setup

### Step 1: Obtain API Key
1. Go to Linear Settings → API
2. Create new Personal API Key
3. Copy key to `.env` file

### Step 2: Configure Workspace
```bash
# Test Linear connection
cd linear/scripts
python3 test_linear_connection.py
```

### Step 3: Import Strategic Framework
1. Import label system (High/Medium/Low Revenue)
2. Set up project templates
3. Configure workflow automations

## 🔄 GitHub Integration

### Step 1: Repository Configuration
```bash
# Add remote repository
git remote add origin <your-github-repo-url>

# Push initial version
git add .
git commit -m "feat: Strategy Agents v2.0 - Production Setup"
git push -u origin main
```

### Step 2: GitHub Secrets
Add these secrets in GitHub Settings → Secrets:

- `N8N_API_KEY`: Your n8n API key
- `N8N_API_URL`: Your n8n instance URL
- `LINEAR_API_KEY`: Your Linear API key

### Step 3: Enable GitHub Actions
The repository includes automated workflows for:
- Daily n8n workflow backups
- System health monitoring
- Automated testing

## ✅ Verification & Testing

### Step 1: System Health Check
```bash
# Run comprehensive test suite
./scripts/test.sh
```

### Step 2: Claude Desktop Verification
Open Claude Desktop and test commands:
```
n8n-complete:health-monitor
n8n-complete:list-workflows
screenpipe-terminal:search-content --q="test"
```

### Step 3: Workflow Testing
```bash
# Test n8n workflow execution
n8n-complete:execute-workflow --workflow_id="PvXBGYpFiuuGkPk6"

# Monitor execution logs
n8n-complete:list-executions --limit=5
```

## 🎯 Strategic Configuration

### Revenue Impact Labels
Set up these labels in Linear:
- 🔴 **High Revenue**: Direct client work, immediately billable
- 🟡 **Medium Revenue**: Framework development, reusable solutions  
- 🟢 **Low Revenue**: Research, maintenance, documentation

### Project Templates
Create these project templates in Linear:
- **Client Automation Project**
- **Strategic Framework Development**
- **System Optimization Initiative**

### Workflow Triggers
Configure these automation triggers:
- **Daily Revenue Review**: Morning strategic planning
- **Weekly Performance Analysis**: Goal progress assessment
- **Monthly Strategic Planning**: Objective realignment

## 🚨 Troubleshooting

### Common Issues

#### MCP Server Not Loading
```bash
# Check Python path
which python3

# Verify MCP server syntax
python3 mcp/n8n/n8n_complete_mcp_server.py --help

# Check Claude Desktop logs
tail -f ~/.claude-desktop/logs/mcp.log
```

#### n8n Connection Failed
```bash
# Test API connection directly
curl -H "X-N8N-API-KEY: your-key" https://your-n8n-instance.com/api/v1/workflows

# Verify credentials
echo $N8N_API_KEY

# Check network connectivity
ping your-n8n-instance.com
```

#### Screenpipe Not Starting
```bash
# Check port availability
lsof -i :3030

# Restart Screenpipe service
killall screenpipe
./screenpipe/bin/start_screenpipe.sh

# Check logs
tail -f screenpipe/logs/screenpipe.log
```

### Performance Optimization
```bash
# Optimize Python dependencies
pip install --upgrade pip
pip install -r requirements.txt --force-reinstall

# Clear cache files
find . -name "__pycache__" -type d -exec rm -rf {} +
find . -name "*.pyc" -delete

# Update system components
./scripts/update.sh
```

## 📊 Monitoring & Maintenance

### Daily Checks
- System health via `n8n-complete:health-monitor`
- Workflow execution status
- Error log review

### Weekly Maintenance
- Performance analysis
- Credential rotation (if needed)
- Documentation updates

### Monthly Reviews
- Strategic goal alignment
- System optimization opportunities
- New feature integration

## 🎯 Next Steps

After successful setup:

1. **Activate PM_Agent**: Enable strategic project management automation
2. **Customize Workflows**: Adapt workflows to your specific needs
3. **Expand Integration**: Add additional tools and services
4. **Monitor Performance**: Track progress toward €50k revenue goal

## 📞 Support

For technical support:
1. Check [Troubleshooting Guide](TROUBLESHOOTING.md)
2. Review system logs in `/logs` directory
3. Test components individually using `scripts/test.sh`
4. Consult [API Reference](API_REFERENCE.md) for integration details

---

**Strategy Agents Setup Complete!** 🎉

Your strategic automation platform is now ready to drive toward the €50k annual revenue goal through intelligent workflow management and behavioral optimization.
