# N8N Workflows

Organized automation workflows for the Strategy Agents platform.

## 📁 Directory Structure

```
workflows/
├── active/    # Production-ready workflows
├── testing/   # Development and testing workflows  
├── archive/   # Historical and backup workflows
├── docs/      # Workflow documentation
└── scripts/   # Supporting JavaScript and utilities
```

## 🚀 Active Workflows

### Universal Auto Embeddings (Simple Working)
- **File**: `active/universal_auto_embeddings_SIMPLE_WORKING.json`
- **Purpose**: Automated content embedding pipeline
- **Status**: ✅ Production Ready
- **Dependencies**: OpenAI API, PostgreSQL

### Screenpipe to Memory Pipeline (Fixed)
- **File**: `active/screenpipe_to_memory_pipeline_fixed.json`
- **Purpose**: Process screenpipe data and store in memory system
- **Status**: ✅ Production Ready
- **Dependencies**: Screenpipe, PostgreSQL

### Update Embeddings (Routed Working)
- **File**: `active/update_embeddings_ROUTED_WORKING.json`
- **Purpose**: Smart routing for embedding updates
- **Status**: ✅ Production Ready
- **Dependencies**: OpenAI API, PostgreSQL

### PM Agent
- **File**: `active/PM_Agent.json`
- **Purpose**: Project management automation
- **Status**: ✅ Production Ready
- **Dependencies**: Linear API, Obsidian

### Daily Morning Brief
- **File**: `active/daily_morning_brief.json`
- **Purpose**: Automated daily summary generation
- **Status**: ✅ Production Ready
- **Dependencies**: Multiple APIs

## 🧪 Testing Workflows

### Screenpipe to Memory (Simplified)
- **File**: `testing/screenpipe_to_memory_pipeline_simplified.json`
- **Purpose**: Simplified version for testing
- **Status**: 🔧 Under Development

### Update Embeddings (Fixed Routing)
- **File**: `testing/update_embeddings_FIXED_ROUTING.json`
- **Purpose**: Testing routing improvements
- **Status**: 🔧 Under Development

## 📦 Archived Workflows

Contains historical versions and backups. See `archive/` directory for legacy workflows.

## 🛠️ Setup Instructions

1. **Import Workflows**
   ```bash
   # Import active workflows into n8n
   n8n import:workflow active/universal_auto_embeddings_SIMPLE_WORKING.json
   n8n import:workflow active/screenpipe_to_memory_pipeline_fixed.json
   # ... repeat for other active workflows
   ```

2. **Configure Credentials**
   - Set up credentials in n8n for each required service
   - See `../credentials/` for credential templates

3. **Activate Workflows**
   - Enable desired workflows in n8n interface
   - Configure webhook URLs if needed

## 🔧 Troubleshooting

Common issues and solutions:

### Workflow Import Fails
- Check n8n version compatibility
- Verify all required nodes are installed
- Review credential configuration

### Embedding Pipeline Issues
- Verify OpenAI API key is valid
- Check PostgreSQL connection
- Monitor rate limits

### Screenpipe Integration Problems
- Ensure screenpipe is running
- Check file permissions
- Verify webhook endpoints

## 📚 Additional Resources

- [N8N Documentation](https://docs.n8n.io/)
- [Workflow Design Patterns](docs/workflow_patterns.md)
- [API Integration Guide](docs/api_integration.md)

---

*Last updated: 2025-06-23*
