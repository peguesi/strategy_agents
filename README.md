# Strategy Agents

A comprehensive automation and intelligence platform combining n8n workflows, MCP servers, and AI agents.

## 🏗️ Project Structure

```
strategy_agents/
├── config/           # Configuration files and schemas
├── docs/             # Documentation and guides
├── n8n/             # n8n automation workflows
│   ├── workflows/
│   │   ├── active/   # Production-ready workflows
│   │   ├── testing/  # Workflows under development
│   │   ├── archive/  # Historical/backup workflows
│   │   └── docs/     # Workflow documentation
├── scripts/         # Utility scripts and tools
│   └── tests/       # Test scripts
├── mcp/             # Model Context Protocol servers
├── obsidian/        # Obsidian integration
├── screenpipe/      # Screenpipe automation
└── tools/           # Development tools
```

## 🚀 Quick Start

1. **Setup Environment**
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # or .venv\Scripts\activate on Windows
   pip install -r requirements.txt
   ```

2. **Configure Credentials**
   - Copy `.env.example` to `.env`
   - Add your API keys and configuration

3. **Start n8n Workflows**
   - Import workflows from `n8n/workflows/active/`
   - Configure credentials in n8n interface

## 📚 Documentation

- [Getting Started](docs/GETTING_STARTED.md)
- [Business Qualification](docs/BUSINESS_QUALIFICATION.md)
- [PEG102 Implementation](docs/PEG102_Implementation_Guide.md)
- [Navigation Guide](docs/NAVIGATION.md)

## 🔧 Active Workflows

- **Universal Auto Embeddings**: Automated content embedding pipeline
- **Screenpipe to Memory**: Screen activity processing and storage
- **PM Agent**: Project management automation
- **Daily Morning Brief**: Automated daily summaries

## 🧪 Development

See `scripts/tests/` for testing utilities and examples.

---

## 📊 Recent Updates

- Enhanced workflow organization and documentation structure
- Improved MCP server integration capabilities
- Updated screenpipe automation features

---

*Last updated: 2025-10-23*
