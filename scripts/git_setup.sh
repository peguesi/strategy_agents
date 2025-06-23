#!/bin/bash

# Git setup for reorganization scripts
echo "🔧 Setting up git branch for reorganization scripts..."

# Create and switch to new branch
git checkout -b reorganization-scripts

# Add the reorganization scripts
git add cleanup_and_organize.py
git add create_n8n_docs.py  
git add reorganize_complete.py
git add git_and_reorganize.py
git add git_setup.sh

# Commit the scripts
git commit -m "Add comprehensive directory reorganization scripts

- cleanup_and_organize.py: Root directory cleanup and n8n workflow organization
- create_n8n_docs.py: Generate comprehensive n8n documentation  
- reorganize_complete.py: Master script for complete reorganization
- git_and_reorganize.py: Git integration wrapper
- git_setup.sh: Git branch setup script"

# Push to remote
git push origin reorganization-scripts

echo "✅ Scripts committed and pushed to reorganization-scripts branch"
echo "🚀 Now running the complete reorganization..."

# Run the reorganization
python reorganize_complete.py
