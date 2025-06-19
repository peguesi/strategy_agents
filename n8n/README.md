# n8n Workflow Automation 🤖

> **Complete n8n workflow management and AI agent orchestration for Strategy Agents**

## 🎯 Overview

This directory contains the complete n8n workflow automation system, including production workflows, management scripts, and MCP server integration for full lifecycle control.

## 📁 Directory Structure

```
n8n/
├── workflows/                    # Production Workflow Definitions
│   ├── v1_calamity_profiteer.json      # News analysis & profit detection
│   ├── pm_agent_strategic.json         # Strategic project management
│   └── templates/                       # Workflow templates
├── scripts/                      # Workflow Management Tools
│   ├── sync_workflows.sh               # GitHub sync automation
│   ├── quick_export.sh                 # Manual workflow export
│   ├── backup_workflows.sh             # Automated backups
│   └── test_connection.sh              # Connection testing
├── credentials/                  # API Credentials (Secure)
│   ├── api_key.txt                     # n8n API key (local only)
│   └── README.md                       # Credential management guide
└── README.md                    # This file
```

## 🤖 Active Workflows

### 1. Calamity Profiteer Agent (v1) 🟢 ACTIVE
**Purpose**: Real-time news analysis for profit opportunity detection

#### Architecture
```
Cron Trigger (30min) → News API Fetch → Azure OpenAI Analysis → Profit Detection → Slack Alert
                                ↓
                          Memory Storage (Context)
                                ↓
                        Additional Research (HTTP)
```

#### Nodes
- **Trigger**: `n8n-nodes-base.cron` - Every 30 minutes
- **News Fetch**: `n8n-nodes-base.httpRequest` - Multiple news APIs
- **AI Agent**: `@n8n/n8n-nodes-langchain.agent` - Strategic analysis
- **Azure OpenAI**: `@n8n/n8n-nodes-langchain.lmChatAzureOpenAi` - Intelligence engine
- **Memory**: `@n8n/n8n-nodes-langchain.memoryBufferWindow` - Context retention
- **Slack Alert**: `n8n-nodes-base.slackTool` - Profit opportunity notifications
- **Research**: `n8n-nodes-base.httpRequestTool` - Additional investigation

### 2. PM_Agent (Strategic Project Manager) 🔴 READY
**Purpose**: Strategic project management with Linear and Screenpipe integration

#### Architecture
```
30min Timer → Screenpipe Analysis → AI Strategic Review → Linear Task Creation → Slack Update
                      ↓                        ↓
               PostgreSQL Memory      Revenue Goal Tracking
```

#### Features
- **Behavioral Analysis**: Real-time productivity monitoring
- **Strategic Prioritization**: Revenue-focused task creation
- **Goal Tracking**: €50k revenue target monitoring
- **Intelligent Automation**: AI-driven project management

## 🛠️ Management Commands

### Via Claude Desktop (MCP)
```bash
# List all workflows
n8n-complete:list-workflows

# Get workflow details
n8n-complete:get-workflow --workflow_id="PvXBGYpFiuuGkPk6"

# Execute workflow manually
n8n-complete:execute-workflow --workflow_id="PvXBGYpFiuuGkPk6"

# Monitor system health
n8n-complete:health-monitor

# Check execution logs
n8n-complete:list-executions --limit=5
```

### Via Scripts
```bash
# Sync workflows with GitHub
./scripts/sync_workflows.sh sync

# Export all workflows
./scripts/quick_export.sh

# Test API connection
./scripts/test_connection.sh

# Backup workflows
./scripts/backup_workflows.sh
```

## 📊 Performance Metrics

### Calamity Profiteer Agent
- **Execution Frequency**: Every 30 minutes (48 times/day)
- **Success Rate**: >95% execution success
- **Response Time**: <30 seconds average
- **Profit Opportunities**: 2-5 alerts per day (high-confidence only)

### System Health
- **Overall Health Score**: 100/100
- **Active Workflows**: 1 of 2
- **Recent Errors**: 0
- **Uptime**: 99.9%

## 🔧 Configuration

### Environment Variables
```bash
# n8n Instance
N8N_URL=https://n8n-agent-gdctd7f5e6e0a5br.eastus2-01.azurewebsites.net
N8N_API_KEY=your-api-key-here

# Azure OpenAI
AZURE_OPENAI_KEY=your-azure-openai-key
AZURE_OPENAI_ENDPOINT=your-azure-endpoint

# External APIs
SLACK_BOT_TOKEN=xoxb-your-slack-token
LINEAR_API_KEY=lin_api_your-linear-key
```

### Credential Requirements
1. **Azure OpenAI**: For AI intelligence processing
2. **Slack**: For notification delivery
3. **Linear**: For project management integration
4. **News APIs**: For data source access
5. **PostgreSQL**: For persistent memory storage

## 🚀 Quick Start

### 1. Setup n8n Instance
```bash
# Ensure n8n is running and accessible
curl -H "X-N8N-API-KEY: your-key" https://your-n8n-instance.com/api/v1/workflows
```

### 2. Import Workflows
1. Open n8n web interface
2. Go to Templates → Import
3. Upload workflow JSON files from `workflows/` directory
4. Configure credentials for each node

### 3. Test Execution
```bash
# Test via Claude Desktop
n8n-complete:execute-workflow --workflow_id="PvXBGYpFiuuGkPk6"

# Or via script
./scripts/test_connection.sh
```

### 4. Monitor Performance
```bash
# System health check
n8n-complete:health-monitor

# Recent execution logs
n8n-complete:list-executions --limit=10
```

## 🔄 Workflow Development

### Creating New Workflows
1. **Design**: Plan workflow architecture and nodes
2. **Build**: Use n8n interface or MCP commands
3. **Test**: Execute with test data
4. **Deploy**: Activate for production use
5. **Monitor**: Track performance and optimize

### Best Practices
- **Modular Design**: Create reusable sub-workflows
- **Error Handling**: Implement comprehensive error paths
- **Monitoring**: Add logging and alerting nodes
- **Documentation**: Document workflow purpose and configuration
- **Testing**: Test with various input scenarios

### Node Selection Guide
```javascript
// Data Sources
"n8n-nodes-base.httpRequest"     // API calls
"n8n-nodes-base.webhook"         // Incoming data
"n8n-nodes-base.postgres"        // Database queries

// AI Processing
"@n8n/n8n-nodes-langchain.agent"              // AI agents
"@n8n/n8n-nodes-langchain.lmChatAzureOpenAi"  // Azure OpenAI
"@n8n/n8n-nodes-langchain.memoryBufferWindow" // Memory

// Integrations
"n8n-nodes-base.slack"           // Slack notifications
"n8n-nodes-base.graphqlTool"     // Linear GraphQL
"n8n-nodes-base.slackTool"       // Slack actions

// Utilities
"n8n-nodes-base.cron"            // Scheduling
"n8n-nodes-base.code"            // Custom logic
"n8n-nodes-base.switch"          // Conditional routing
```

## 📈 Optimization

### Performance Tuning
- **Parallel Execution**: Use parallel processing where possible
- **Caching**: Implement result caching for repeated operations
- **Batch Processing**: Group similar operations
- **Resource Management**: Monitor memory and CPU usage

### Strategic Optimization
- **Revenue Focus**: Prioritize high-revenue generating workflows
- **Automation Efficiency**: Maximize manual work reduction
- **Intelligence Quality**: Continuously improve AI decision making
- **System Reliability**: Maintain high uptime and low error rates

## 🔒 Security

### API Security
- **Credential Management**: Secure storage and rotation
- **Access Control**: Role-based permissions
- **Audit Logging**: Complete activity tracking
- **Network Security**: HTTPS and VPN protection

### Data Protection
- **Encryption**: Data at rest and in transit
- **Privacy**: Minimal data collection and retention
- **Compliance**: GDPR and business standard compliance
- **Backup**: Regular secure backups

## 📚 Resources

### Documentation
- [n8n Official Docs](https://docs.n8n.io/)
- [Azure OpenAI Integration](https://docs.microsoft.com/azure/cognitive-services/openai/)
- [Linear API Reference](https://developers.linear.app/)
- [Strategy Agents API Reference](../docs/API_REFERENCE.md)

### Troubleshooting
- [Common Issues](../docs/TROUBLESHOOTING.md)
- [Performance Guide](../docs/PERFORMANCE.md)
- [Security Best Practices](../docs/SECURITY.md)

---

**n8n Workflow Automation** - *Intelligent workflow orchestration for strategic business automation*

Part of the Strategy Agents platform driving toward €50k annual revenue through AI-powered workflow automation.
