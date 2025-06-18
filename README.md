# Strategy Agents

A comprehensive AI agent ecosystem for strategic operations automation, productivity enhancement, and intelligent workflow management.

## 🎯 Project Overview

This repository contains the complete infrastructure for building, deploying, and managing AI agents that enhance strategic decision-making and operational efficiency.

### Core Components

- **🤖 Strategic PM Agent** - Intelligent project management and strategic analysis
- **📊 Agent Memory System** - PostgreSQL + pgvector for conversation embeddings and learning
- **🔧 n8n Workflows** - Automation pipelines and agent orchestration
- **📈 Screenpipe Integration** - Behavioral analysis and activity monitoring
- **⚡ Linear Integration** - Project management and task automation
- **☁️ Azure Infrastructure** - Cloud services and data storage

## 🏗️ Architecture

```
Strategy_agents/
├── agents/                     # Agent implementations
│   ├── strategic-pm/          # Strategic PM agent
│   ├── research/              # Research & inspiration agent
│   └── linear-automation/     # Linear task management
├── database/                  # PostgreSQL schema and migrations
│   ├── schema/               # Database schema definitions
│   ├── migrations/           # Database migration scripts
│   └── seeds/                # Sample data and testing
├── n8n/                      # n8n workflow automation
│   ├── workflows/            # Exported workflow JSON files
│   ├── credentials/          # Encrypted credential templates
│   └── scripts/              # Workflow management scripts
├── mcp/                      # Model Context Protocol servers
│   ├── postgresql/           # PostgreSQL MCP server
│   ├── screenpipe/           # Screenpipe MCP integration
│   └── linear/               # Linear MCP integration
├── screenpipe/               # Screen and audio monitoring
│   ├── bin/                  # Executables and scripts
│   ├── data/                 # Recorded data storage
│   └── config/               # Configuration files
├── linear/                   # Linear integration tools
│   ├── automations/          # Linear automation scripts
│   └── templates/            # Issue and project templates
└── shared/                   # Shared utilities and libraries
    ├── utils/                # Common utility functions
    ├── config/               # Shared configuration
    └── types/                # TypeScript/Python type definitions
```

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- Node.js 18+
- PostgreSQL 16
- Azure CLI
- n8n instance

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/strategy-agents.git
   cd strategy-agents
   ```

2. **Set up the environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your credentials
   ```

3. **Install dependencies:**
   ```bash
   # Python dependencies
   pip install -r requirements.txt
   
   # Node.js dependencies
   npm install
   ```

4. **Database setup:**
   ```bash
   # Run database migrations
   python database/migrations/run_migrations.py
   ```

5. **Configure MCP servers:**
   ```bash
   # Set up PostgreSQL MCP
   cd mcp/postgresql
   ./setup.sh
   ```

## 🤖 Agents

### Strategic PM Agent
Intelligent project management with real-time behavioral analysis and strategic recommendations.

**Features:**
- Real-time activity monitoring via Screenpipe
- Linear project analysis and optimization
- Memory-driven learning and pattern recognition
- Strategic decision support

**Status:** ✅ Operational with memory system integration

### Research & Inspiration Agent
Automated research and idea generation based on browsing patterns and strategic focus areas.

**Features:**
- Instagram/social media content analysis
- GitHub repository discovery and analysis
- Strategic relevance scoring
- Automated Linear issue creation

**Status:** 🚧 In Development (PEG-52)

### Linear Automation Agent
Natural language Linear management and project optimization.

**Features:**
- Voice/text command processing
- Intelligent issue matching and updates
- Project relationship mapping
- Automated workflow suggestions

**Status:** 📋 Planned (PEG-53)

## 💾 Database Architecture

### Agent Memory System
PostgreSQL with pgvector extensions for intelligent conversation storage and retrieval.

**Tables:**
- `agent_conversations` - Vector embeddings + conversation metadata
- `agent_patterns` - Detected behavior patterns
- `agent_outcomes` - Suggestion tracking + success rates
- `agent_preferences` - User settings + learning data

**Capabilities:**
- Semantic similarity search
- Cross-agent learning
- Performance analytics
- Pattern recognition

## 🔄 n8n Workflows

### Workflow Management
All n8n workflows are version-controlled and automatically synced with this repository.

**Key Workflows:**
- Strategic PM Agent (30-minute intervals)
- Embeddings Pipeline (conversation processing)
- PostgreSQL Integration (memory management)
- Screenpipe Analysis (behavioral monitoring)

**Sync Process:**
- Workflows exported automatically to `n8n/workflows/`
- Git integration maintains version history
- Rollback capabilities for workflow iterations

## 🛠️ Development

### Local Development Setup

1. **Start services:**
   ```bash
   # Start PostgreSQL
   brew services start postgresql
   
   # Start n8n
   n8n start
   
   # Start Screenpipe
   ./screenpipe/bin/start_screenpipe.sh
   ```

2. **Run tests:**
   ```bash
   # Python tests
   pytest
   
   # Node.js tests
   npm test
   ```

3. **Database operations:**
   ```bash
   # Create migration
   python database/migrations/create_migration.py --name "add_new_feature"
   
   # Run migrations
   python database/migrations/run_migrations.py
   ```

### Contributing

1. Create feature branch from `main`
2. Make changes and add tests
3. Update documentation
4. Submit pull request

## 📊 Monitoring & Analytics

### Agent Performance
- Conversation success rates
- Strategic recommendation accuracy
- User satisfaction tracking
- Cross-agent learning effectiveness

### Infrastructure Monitoring
- Database performance and query optimization
- n8n workflow execution metrics
- Screenpipe data capture rates
- Azure resource utilization

## 🔒 Security & Privacy

- Local-first approach with Screenpipe
- Encrypted credential storage
- Azure security best practices
- GDPR-compliant data handling

## 📋 Roadmap

### Phase 1: Foundation ✅
- [x] PostgreSQL + pgvector setup
- [x] Strategic PM Agent v1.0
- [x] Basic memory system
- [x] Screenpipe integration

### Phase 2: Intelligence 🚧
- [ ] Embeddings pipeline (PEG-50)
- [ ] Memory-enhanced agent (PEG-51)
- [ ] PostgreSQL MCP integration (PEG-61)
- [ ] Advanced analytics dashboard

### Phase 3: Ecosystem 📋
- [ ] Research & Inspiration Agent (PEG-52)
- [ ] Linear Automation Agent (PEG-53)
- [ ] Multi-agent coordination
- [ ] Enterprise deployment

## 🆘 Support

- **Issues:** Use GitHub Issues for bug reports and feature requests
- **Documentation:** See `/docs` for detailed guides
- **Community:** Join discussions in GitHub Discussions

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

**Built with ❤️ for strategic automation and intelligent productivity**
