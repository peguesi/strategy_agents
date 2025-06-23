#!/usr/bin/env python3
"""
N8N Workflows Documentation Generator
====================================

Creates comprehensive documentation for the reorganized n8n workflows directory.
"""

import os
import json
from pathlib import Path
from datetime import datetime

def create_n8n_documentation(base_dir):
    """Create comprehensive n8n workflows documentation"""
    print("📚 Creating n8n workflows documentation...")
    
    n8n_dir = base_dir / 'n8n' / 'workflows'
    
    # Main workflows README
    workflows_readme = f"""# N8N Workflows

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

*Last updated: {datetime.now().strftime('%Y-%m-%d')}*
"""
    
    # Write main workflows README
    readme_path = n8n_dir / 'README.md'
    with open(readme_path, 'w') as f:
        f.write(workflows_readme)
    print(f"📝 Created {readme_path}")
    
    # Create active workflows documentation
    active_readme = f"""# Active Production Workflows

These workflows are production-ready and actively used in the Strategy Agents platform.

## Deployment Checklist

Before deploying any workflow:

- [ ] All credentials configured
- [ ] Dependencies verified
- [ ] Error handling tested
- [ ] Monitoring enabled
- [ ] Documentation updated

## Workflow Descriptions

### Universal Auto Embeddings (Simple Working)
**Purpose**: Processes content and generates embeddings automatically
**Trigger**: HTTP webhook or scheduled
**Key Features**:
- Content preprocessing
- OpenAI embedding generation
- PostgreSQL storage
- Error handling and retry logic

### Screenpipe to Memory Pipeline (Fixed)
**Purpose**: Captures and processes screen activity data
**Trigger**: File system events
**Key Features**:
- OCR text processing
- Audio transcription
- Memory system integration
- Duplicate detection

### Update Embeddings (Routed Working)
**Purpose**: Smart routing for embedding updates based on content type
**Trigger**: HTTP webhook
**Key Features**:
- Content type detection
- Dynamic routing
- Batch processing
- Performance optimization

### PM Agent
**Purpose**: Automates project management tasks
**Trigger**: Scheduled and webhook
**Key Features**:
- Linear integration
- Obsidian note creation
- Task tracking
- Progress reporting

### Daily Morning Brief
**Purpose**: Generates comprehensive daily summaries
**Trigger**: Scheduled (daily at 8 AM)
**Key Features**:
- Multi-source data aggregation
- AI-powered summarization
- Email/notification delivery
- Historical tracking

## Monitoring and Maintenance

- Monitor execution logs regularly
- Update API credentials before expiration
- Review performance metrics monthly
- Test backup and recovery procedures

---

*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*
"""
    
    # Write active workflows documentation
    active_dir = n8n_dir / 'active'
    active_readme_path = active_dir / 'README.md'
    with open(active_readme_path, 'w') as f:
        f.write(active_readme)
    print(f"📝 Created {active_readme_path}")

def main():
    """Main documentation generator"""
    base_dir = Path(__file__).parent
    create_n8n_documentation(base_dir)
    print("✅ N8N documentation created successfully!")

if __name__ == "__main__":
    main()
