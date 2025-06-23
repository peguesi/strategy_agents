# Obsidian Setup Instructions

## Step 1: Open Obsidian with Your Vault

1. Open Obsidian desktop app
2. Select "Open folder as vault"
3. Navigate to: `/Users/zeh/Local_Projects/Strategy_agents/obsidian/vault`
4. Click "Open"

## Step 2: Install Local REST API Plugin

1. In Obsidian, go to Settings (⚙️ icon)
2. Click "Community plugins" in the left sidebar
3. If not enabled, click "Turn on community plugins"
4. Click "Browse" to open the community plugins browser
5. Search for "Local REST API"
6. Find "Local REST API" by coddingtonbear
7. Click "Install"
8. After installation, click "Enable"

## Step 3: Configure the Plugin

1. In Settings, go to "Local REST API" (under Plugin Options)
2. **Enable the Non-encrypted (HTTP) Server** (recommended for simplicity)
3. Set port to: `27123` (default)
4. Generate or set an API key (copy this - you'll need it)
5. Click "Start Server"

## Step 4: Test the API

The plugin should show:
- Server running on: `http://127.0.0.1:27123`
- API Key: `[your-generated-key]`

## Step 5: Update Claude MCP Configuration

After completing the above, you'll need to add the Obsidian MCP server to your Claude Desktop configuration.

---

**Next**: Once you complete these steps, I'll help you configure the MCP integration with Claude.