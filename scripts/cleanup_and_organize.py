#!/usr/bin/env python3
"""
Strategy Agents Directory Cleanup and Organization Script
=========================================================

This script cleans up the strategy_agents directory by:
1. Identifying and organizing root directory files
2. Cleaning up the n8n workflows directory completely
3. Creating proper directory structure
4. Moving active workflows to organized locations
"""

import os
import shutil
import json
from pathlib import Path
from datetime import datetime

def main():
    """Main cleanup orchestrator"""
    base_dir = Path(__file__).parent
    print(f"🚀 Starting cleanup of {base_dir}")
    
    # Step 1: Clean root directory
    clean_root_directory(base_dir)
    
    # Step 2: Clean n8n workflows completely
    clean_n8n_workflows(base_dir)
    
    # Step 3: Update key READMEs
    update_main_readme(base_dir)
    
    print("✅ Cleanup completed successfully!")

def clean_root_directory(base_dir):
    """Clean up unnecessary files in root directory"""
    print("\n📁 Cleaning root directory...")
    
    # Files that should be moved or removed
    files_to_organize = {
        # Move to scripts/
        'check_creds.py': 'scripts/',
        'discover_n8n_endpoints.py': 'scripts/',
        'memory_agent_demo.py': 'scripts/',
        'test_alternative_execution.py': 'scripts/tests/',
        'test_fixed_mcp.py': 'scripts/tests/',
        'test_n8n_api.py': 'scripts/tests/',
        
        # Move to docs/
        'BUSINESS_QUALIFICATION.md': 'docs/',
        'CLAUDE_INSTRUCTIONS.md': 'docs/',
        'GETTING_STARTED.md': 'docs/',
        'LINEAR_GENERALIZED.md': 'docs/',
        'NAVIGATION.md': 'docs/',
        'ORGANIZATION_COMPLETE.md': 'docs/',
        'PEG102_Implementation_Guide.md': 'docs/',
        'memory_integration_plan.md': 'docs/',
        
        # Move to config/
        'schema_enhancements_peg102.sql': 'config/',
        'update_embeddings_enhanced.json': 'config/',
    }
    
    # Create necessary directories
    for target_dir in set(os.path.dirname(dest) for dest in files_to_organize.values() if dest):
        target_path = base_dir / target_dir
        target_path.mkdir(parents=True, exist_ok=True)
        print(f"📂 Created directory: {target_dir}")
    
    # Move files
    for file_name, target_dir in files_to_organize.items():
        source_path = base_dir / file_name
        if source_path.exists():
            target_path = base_dir / target_dir / file_name
            shutil.move(str(source_path), str(target_path))
            print(f"📦 Moved {file_name} → {target_dir}")

def clean_n8n_workflows(base_dir):
    """Completely clean and reorganize n8n workflows directory"""
    print("\n🔧 Cleaning n8n workflows directory...")
    
    n8n_dir = base_dir / 'n8n'
    workflows_dir = n8n_dir / 'workflows'
    
    # Active workflows to keep (based on naming and functionality)
    active_workflows = {
        'universal_auto_embeddings_SIMPLE_WORKING.json': 'active/',
        'screenpipe_to_memory_pipeline_fixed.json': 'active/',
        'update_embeddings_ROUTED_WORKING.json': 'active/',
        'PM_Agent.json': 'active/',
        'daily_morning_brief.json': 'active/',
    }
    
    # Test workflows
    test_workflows = {
        'screenpipe_to_memory_pipeline_simplified.json': 'testing/',
        'update_embeddings_FIXED_ROUTING.json': 'testing/',
        'update_embeddings_PROPERLY_FIXED.json': 'testing/',
    }
    
    # Archive old/backup workflows
    archive_workflows = {
        'embeddings_pipeline_original_backup.json': 'archive/',
        'agent_conversations_embeddings_FINAL.json': 'archive/',
        'Catastrophe_Fomo_v1.json': 'archive/',
        'v1.json': 'archive/',
        'universal_auto_embeddings.json': 'archive/',
        'PM_Agent_qYHxZmr3VbZLcDS0.json': 'archive/',
    }
    
    # Create new directory structure
    new_structure = ['active', 'testing', 'archive', 'docs']
    for dir_name in new_structure:
        target_dir = workflows_dir / dir_name
        target_dir.mkdir(parents=True, exist_ok=True)
        print(f"📂 Created workflows/{dir_name}/")
    
    # Move active workflows
    for workflow, target_dir in active_workflows.items():
        source_path = workflows_dir / workflow
        if source_path.exists():
            target_path = workflows_dir / target_dir / workflow
            shutil.move(str(source_path), str(target_path))
            print(f"✅ Moved {workflow} → {target_dir}")
    
    # Move test workflows
    for workflow, target_dir in test_workflows.items():
        source_path = workflows_dir / workflow
        if source_path.exists():
            target_path = workflows_dir / target_dir / workflow
            shutil.move(str(source_path), str(target_path))
            print(f"🧪 Moved {workflow} → {target_dir}")
    
    # Move archive workflows
    for workflow, target_dir in archive_workflows.items():
        source_path = workflows_dir / workflow
        if source_path.exists():
            target_path = workflows_dir / target_dir / workflow
            shutil.move(str(source_path), str(target_path))
            print(f"📦 Archived {workflow} → {target_dir}")
    
    # Move documentation files
    doc_files = [
        'IMPLEMENTATION_SUMMARY.md',
        'PEG102_IMPLEMENTATION_COMPLETE.md',
        'README_screenpipe_to_memory.md',
        'SETUP_GUIDE.md',
        'workflows_summary.md',
        'universal embedding discussion.txt'
    ]
    
    for doc_file in doc_files:
        source_path = workflows_dir / doc_file
        if source_path.exists():
            target_path = workflows_dir / 'docs' / doc_file
            shutil.move(str(source_path), str(target_path))
            print(f"📚 Moved {doc_file} → docs/")
    
    # Move JavaScript files
    js_files = ['fixed_trigger_detection.js']
    scripts_dir = workflows_dir / 'scripts'
    scripts_dir.mkdir(exist_ok=True)
    
    for js_file in js_files:
        source_path = workflows_dir / js_file
        if source_path.exists():
            target_path = scripts_dir / js_file
            shutil.move(str(source_path), str(target_path))
            print(f"📜 Moved {js_file} → scripts/")
    
    # Clean up meta files and other artifacts
    cleanup_files = ['.DS_Store', '*.meta']
    for pattern in cleanup_files:
        for file_path in workflows_dir.glob(pattern):
            if file_path.is_file():
                file_path.unlink()
                print(f"🗑️ Removed {file_path.name}")

def update_main_readme(base_dir):
    """Update the main README with current structure"""
    print("\n📝 Updating main README...")
    
    readme_content = f"""# Strategy Agents

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
   source .venv/bin/activate  # or .venv\\Scripts\\activate on Windows
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

*Last updated: {datetime.now().strftime('%Y-%m-%d')}*
"""
    
    readme_path = base_dir / 'README.md'
    with open(readme_path, 'w') as f:
        f.write(readme_content)
    
    print(f"📝 Updated {readme_path}")

if __name__ == "__main__":
    main()
