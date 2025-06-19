# Strategy Agents v2.0 🎯

> **Complete strategic automation platform achieving €50k annual revenue through intelligent workflow management, behavioral analysis, and project optimization.**

[![n8n](https://img.shields.io/badge/n8n-Workflow%20Automation-orange)](https://n8n.io)
[![Linear](https://img.shields.io/badge/Linear-Project%20Management-blue)](https://linear.app)
[![Screenpipe](https://img.shields.io/badge/Screenpipe-Behavioral%20Analysis-green)](https://screenpipe.ai)
[![Claude](https://img.shields.io/badge/Claude-AI%20Integration-purple)](https://claude.ai)

## 🚀 What This Does

Strategy Agents is a **production-ready automation platform** that transforms how you achieve strategic business goals through:

- **🤖 Automated Intelligence**: AI agents that analyze news for profit opportunities and manage strategic projects
- **📊 Behavioral Optimization**: Real-time analysis of work patterns to maximize productivity
- **🎯 Revenue Focus**: Every workflow and task prioritized by revenue impact potential
- **⚡ End-to-End Control**: Complete system management through Claude Desktop integration

## ⭐ Key Achievements

✅ **€50k Revenue Target Framework** - Strategic prioritization system  
✅ **Complete n8n Workflow Management** - Create, edit, execute, monitor via Claude  
✅ **Behavioral Intelligence** - Screenpipe integration for productivity optimization  
✅ **Linear Project Automation** - Strategic task management and tracking  
✅ **Production-Ready Architecture** - Professional documentation and deployment

## 🎯 Active Strategic Workflows

### 1. Calamity Profiteer Agent 🟢 ACTIVE
**Real-time news analysis and profit opportunity detection**
- **Trigger**: Automated every 30 minutes
- **Intelligence**: Azure OpenAI analysis of breaking news
- **Action**: Slack alerts for immediate profit opportunities
- **Memory**: Context retention for pattern recognition

### 2. PM_Agent (Strategic Project Manager) 🔴 READY
**Linear/Screenpipe integration for strategic management**
- **Monitoring**: 30-minute behavioral analysis cycles
- **Integration**: Screenpipe → Linear → Slack workflow
- **Intelligence**: AI-driven project prioritization
- **Focus**: €50k revenue goal tracking and optimization

## 🛠️ Technology Stack

### Core Infrastructure
- **n8n**: Workflow automation and AI agent orchestration
- **Azure OpenAI**: Strategic intelligence and analysis
- **PostgreSQL**: Data persistence and analytics
- **Linear**: Strategic project management
- **Screenpipe**: Behavioral analysis and optimization

### Integration Layer
- **Model Context Protocol (MCP)**: Complete system control via Claude
- **GitHub Actions**: Automated workflows and backups
- **Azure Cloud**: Scalable hosting and AI services
- **Slack**: Real-time notifications and alerts

## 🚀 Quick Start

### 1. Initial Setup
```bash
# Clone and setup
git clone <repository-url>
cd Strategy_agents
./scripts/setup.sh
```

### 2. Configure Claude Desktop
```json
{
  "mcpServers": {
    "n8n-complete": {
      "command": "/path/to/python3",
      "args": ["/path/to/Strategy_agents/mcp/n8n/n8n_complete_mcp_server.py"]
    }
  }
}
```

### 3. Test System
```bash
./scripts/test.sh
```

### 4. Activate Workflows
Use Claude Desktop to manage workflows:
- `n8n-complete:list-workflows` - View all workflows
- `n8n-complete:health-monitor` - System health check
- `n8n-complete:execute-workflow` - Run workflows manually

## 📁 Project Structure

```
Strategy_agents/
├── 🤖 mcp/                     # Model Context Protocol Servers
│   ├── n8n/                    # Complete n8n workflow management
│   ├── screenpipe/             # Behavioral analysis integration
│   └── azure-postgresql/       # Database integration
├── ⚡ n8n/                     # n8n Workflow Automation
│   ├── workflows/              # Production workflow definitions
│   └── scripts/                # Workflow management tools
├── 👁️ screenpipe/              # Behavioral Analysis System
│   ├── bin/                    # Control scripts and utilities
│   ├── mcp/                    # Screenpipe MCP server
│   └── data/                   # Behavioral data storage
├── 📋 linear/                  # Project Management Integration
│   └── scripts/                # Linear automation tools
├── 📚 docs/                    # Comprehensive Documentation
│   ├── SETUP.md               # Detailed setup instructions
│   ├── ARCHITECTURE.md        # System design overview
│   └── API_REFERENCE.md       # Complete API documentation
├── 🔧 scripts/                # Project Management Tools
│   ├── setup.sh               # Initial environment setup
│   ├── test.sh                # System testing suite
│   └── cleanup.sh             # Project maintenance
└── 🚀 .github/                # CI/CD and GitHub Integration
    └── workflows/              # Automated testing and deployment
```

## 🎯 Strategic Revenue Framework

### High Revenue Priority 💰
- **Direct Client Work**: Immediately billable hours
- **Client Automation**: Revenue-generating workflow creation
- **Strategic Consulting**: High-value advisory services

### Medium Revenue Priority 💼
- **Framework Development**: Reusable client solutions
- **Tool Integration**: Efficiency-multiplying automation
- **Process Optimization**: Scalable workflow improvements

### Low Revenue Priority 🔧
- **Research Tasks**: Knowledge building activities
- **System Maintenance**: Infrastructure upkeep
- **Documentation**: Process recording and sharing

## 🔧 Available Commands

### Workflow Management
```bash
# List all workflows with status
n8n-complete:list-workflows

# Execute workflow manually
n8n-complete:execute-workflow --workflow_id="PvXBGYpFiuuGkPk6"

# Monitor system health
n8n-complete:health-monitor

# Get execution logs
n8n-complete:get-execution-logs --execution_id="<id>"
```

### System Administration
```bash
# Add new workflow node
n8n-complete:add-node --workflow_id="<id>" --node_type="n8n-nodes-base.httpRequest"

# Update workflow configuration
n8n-complete:update-workflow --workflow_id="<id>" --nodes="<config>"

# Manage credentials
n8n-complete:create-credential --name="api-key" --type="httpAuth"
```

## 📊 System Monitoring

### Health Dashboard
- **Workflow Status**: Active/inactive workflow tracking
- **Execution Monitoring**: Success/failure rate analysis
- **Performance Metrics**: Execution time and efficiency
- **Error Tracking**: Real-time issue detection and resolution

### Key Performance Indicators
- **Revenue Impact**: Workflow contribution to €50k goal
- **Automation Efficiency**: Manual work reduction percentage
- **System Reliability**: Uptime and error rate metrics
- **Strategic Alignment**: Goal-focused task completion rate

## 🔒 Security & Configuration

### Environment Variables Setup
Create a `.env` file in the project root:
```bash
# n8n Configuration
N8N_API_KEY=your-n8n-api-key
N8N_URL=https://your-n8n-instance.com
N8N_USER=your-n8n-username
N8N_PASS=your-n8n-password

# Linear Integration
LINEAR_API_KEY=your-linear-api-key
LINEAR_API_URL=https://api.linear.app/graphql

# Azure Services
AZURE_OPENAI_KEY=your-azure-openai-key
AZURE_OPENAI_ENDPOINT=your-azure-endpoint
```

### Security Features
- ✅ **Environment Variables Only**: No hardcoded credentials
- ✅ **Gitignore Protection**: `.env` files never committed
- ✅ **Security Audit Script**: Regular credential scanning
- ✅ **GitHub Secrets**: Encrypted CI/CD configuration
- ✅ **Clean Repository**: Zero exposed API keys or tokens

### Security Audit
Run regular security checks:
```bash
# Comprehensive security scan
./security-audit.sh

# Check for exposed credentials
grep -r "api.*key\|secret\|token" . --exclude-dir=.venv --exclude-dir=.git
```

**⚠️ IMPORTANT**: 
- Never commit API keys or credentials to git
- Always use environment variables for sensitive data
- Run `./security-audit.sh` before pushing changes
- Regenerate any accidentally exposed keys immediately

## 📚 Documentation

- **[Complete Setup Guide](docs/SETUP.md)** - Detailed installation and configuration
- **[System Architecture](docs/ARCHITECTURE.md)** - Component relationships and design
- **[API Reference](docs/API_REFERENCE.md)** - Complete endpoint documentation
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions

## 🎯 Strategic Objectives

### Primary Goals
1. **€50k Annual Revenue**: Through strategic automation and optimization
2. **Workflow Efficiency**: 80% reduction in manual strategic tasks
3. **Intelligence Integration**: AI-driven decision making across all processes
4. **Behavioral Optimization**: Data-driven productivity improvements

### Success Metrics
- **Revenue Growth**: Monthly progress toward €50k target
- **Time Savings**: Hours saved through automation
- **Decision Quality**: AI-enhanced strategic choices
- **System Reliability**: 99%+ uptime for critical workflows

## 🤝 Contributing

This is a strategic business automation platform. For collaboration:

1. **Review Architecture**: Understand system design in `docs/ARCHITECTURE.md`
2. **Follow Standards**: Use established patterns for new components
3. **Security First**: Run `./security-audit.sh` before committing
4. **Environment Variables**: Never hardcode credentials
5. **Test Thoroughly**: Ensure reliability with `scripts/test.sh`
6. **Document Changes**: Update relevant documentation

## 📄 License

Strategic business automation platform - All rights reserved.

---

**Strategy Agents v2.0** - *Transforming strategic goals into automated reality.*

🎯 **Goal**: €50k annual revenue through intelligent automation  
⚡ **Method**: AI-driven workflows + behavioral optimization  
🚀 **Result**: Professional-grade strategic business automation
