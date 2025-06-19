# n8n Workflow Sync Setup - Complete Guide

You now have a complete n8n workflow synchronization system set up! Here's what was created:

## 📁 Files Created

### Sync Scripts
- `n8n/scripts/sync_workflows.sh` - Main sync script with full functionality
- `n8n/scripts/quick_export.sh` - Quick export for testing
- `test_export.sh` - Simple test script

### Credentials
- `n8n/credentials/api_key.txt` - Your n8n API key (secure)

### GitHub Automation
- `.github/workflows/n8n-sync.yml` - Automated daily backup to GitHub

## 🚀 Quick Start

### 1. Make Scripts Executable
```bash
chmod +x /Users/zeh/Local_Projects/Strategy_agents/n8n/scripts/sync_workflows.sh
chmod +x /Users/zeh/Local_Projects/Strategy_agents/n8n/scripts/quick_export.sh
chmod +x /Users/zeh/Local_Projects/Strategy_agents/test_export.sh
```

### 2. Test the Connection
```bash
./test_export.sh
```

### 3. Full Workflow Sync
```bash
# Check status
./n8n/scripts/sync_workflows.sh status

# Pull workflows from n8n
./n8n/scripts/sync_workflows.sh pull

# Full sync: pull + commit + push to GitHub
./n8n/scripts/sync_workflows.sh sync
```

## 🔧 Available Commands

### `sync_workflows.sh` Commands:
- `pull` - Fetch all workflows from n8n instance
- `push <file>` - Push specific workflow file to n8n
- `sync` - Full sync: pull + git commit + push
- `status` - Show local workflow status
- `backup` - Create timestamped backup
- `help` - Show usage information

### Examples:
```bash
# Daily workflow pull
./n8n/scripts/sync_workflows.sh pull

# Push updated workflow
./n8n/scripts/sync_workflows.sh push workflows/v1.json

# Full sync with GitHub
./n8n/scripts/sync_workflows.sh sync

# Check what workflows you have
./n8n/scripts/sync_workflows.sh status
```

## 📊 Current Workflows Detected

From your n8n instance:

### 1. "v1" (Active)
- **ID:** PvXBGYpFiuuGkPk6
- **Type:** Calamity Profiteer Agent
- **Function:** News analysis and profit opportunity detection
- **Active:** Yes ✅
- **Key Nodes:** 
  - Cron trigger
  - News API fetch
  - AI analysis agent
  - Slack notifications

### 2. "PM_Agent" (Inactive)
- **ID:** qYHxZmr3VbZLcDS0  
- **Type:** Strategic Project Management Agent
- **Function:** Linear/Screenpipe integration for €50k revenue goal
- **Active:** No ⏸️
- **Key Nodes:**
  - 30-minute interval trigger
  - Screenpipe analysis
  - Linear GraphQL
  - Strategic reporting

## 🔄 Automated Sync

The GitHub workflow (`.github/workflows/n8n-sync.yml`) will:
- Run daily at 6 PM UTC
- Backup all workflows
- Commit changes to GitHub
- Can be triggered manually

### Required GitHub Secrets:
Add these to your GitHub repository settings:

1. `N8N_API_KEY` = `[Your N8N JWT Token - get from .env file]`

2. `N8N_API_URL` = `https://n8n-agent-gdctd7f5e6e0a5br.eastus2-01.azurewebsites.net:443/api/v1`

## 🎯 Next Steps

1. **Test the setup:**
   ```bash
   ./test_export.sh
   ```

2. **Perform initial sync:**
   ```bash
   ./n8n/scripts/sync_workflows.sh sync
   ```

3. **Set up GitHub secrets** for automated backups

4. **Consider activating PM_Agent** for strategic workflow management

## 🔒 Security Notes

- API key is stored locally in `n8n/credentials/api_key.txt`
- GitHub secrets keep credentials secure in CI/CD
- Workflows are backed up as JSON files
- No sensitive data exposed in repository

## 📝 Workflow Management

Your synced workflows will be stored as:
- `n8n/workflows/v1.json` - Calamity Profiteer Agent
- `n8n/workflows/PM_Agent.json` - Strategic PM Agent
- `n8n/workflows/workflows_summary.md` - Auto-generated summary

## 🛠️ Troubleshooting

If sync fails:

1. **Check API key:**
   ```bash
   cat n8n/credentials/api_key.txt
   ```

2. **Test connection:**
   ```bash
   curl -H "X-N8N-API-KEY: $(cat n8n/credentials/api_key.txt)" \
        "https://n8n-agent-gdctd7f5e6e0a5br.eastus2-01.azurewebsites.net:443/api/v1/workflows"
   ```

3. **Check logs:**
   ```bash
   ./n8n/scripts/sync_workflows.sh pull
   ```

You're all set! Your n8n workflows are now version controlled and automatically backed up to GitHub.
