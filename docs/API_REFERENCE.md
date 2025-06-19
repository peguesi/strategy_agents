# Strategy Agents API Reference 📖

> **Complete API documentation for the Strategy Agents automation platform**

## 🎯 Overview

Strategy Agents exposes APIs through **Model Context Protocol (MCP) servers** that provide unified access to all system components. This reference covers all available endpoints, parameters, and usage patterns.

## 🔌 MCP Server Endpoints

### n8n-complete Server
**Purpose**: Complete n8n workflow lifecycle management  
**Server ID**: `n8n-complete`  
**Base URL**: Direct MCP communication (no HTTP endpoint)

---

## 🔄 Workflow Management

### list-workflows
**Purpose**: List all workflows with status and metadata

#### Parameters
```json
{
  "active": boolean,     // Filter by active status (optional)
  "limit": integer       // Maximum results (default: 20)
}
```

#### Example Usage
```javascript
// List all workflows
n8n-complete:list-workflows

// List only active workflows
n8n-complete:list-workflows --active=true --limit=10
```

#### Response Format
```
🔄 **Active Workflows:**

**v1** (PvXBGYpFiuuGkPk6)
Status: 🟢 ACTIVE
Nodes: 8
Updated: 2025-06-18

**PM_Agent** (qYHxZmr3VbZLcDS0)
Status: 🔴 INACTIVE
Nodes: 7
Updated: 2025-06-18
```

### get-workflow
**Purpose**: Get detailed workflow information including nodes and connections

#### Parameters
```json
{
  "workflow_id": string  // Workflow ID or name (required)
}
```

#### Example Usage
```javascript
// Get workflow by ID
n8n-complete:get-workflow --workflow_id="PvXBGYpFiuuGkPk6"

// Get workflow by name
n8n-complete:get-workflow --workflow_id="v1"
```

#### Response Format
```
📋 **Workflow: v1**

**ID:** PvXBGYpFiuuGkPk6
**Status:** 🟢 Active
**Nodes:** 8

**Nodes:**
• Sticky Note (n8n-nodes-base.stickyNote)
• Trigger (n8n-nodes-base.cron)
• Fetch News (n8n-nodes-base.httpRequest)
• AI Agent (@n8n/n8n-nodes-langchain.agent)
• Azure OpenAI Chat Model (@n8n/n8n-nodes-langchain.lmChatAzureOpenAi)
```

### create-workflow
**Purpose**: Create new workflow from JSON configuration

#### Parameters
```json
{
  "name": string,           // Workflow name (required)
  "nodes": array,           // Node configuration array (required)
  "connections": object,    // Node connections (optional)
  "active": boolean,        // Activate immediately (default: false)
  "settings": object        // Workflow settings (optional)
}
```

#### Example Usage
```javascript
n8n-complete:create-workflow --name="Revenue Tracker" --nodes=[...] --active=false
```

### update-workflow
**Purpose**: Update existing workflow configuration

#### Parameters
```json
{
  "workflow_id": string,    // Target workflow (required)
  "name": string,           // New name (optional)
  "nodes": array,           // Updated nodes (optional)
  "connections": object,    // Updated connections (optional)
  "settings": object        // Updated settings (optional)
}
```

### delete-workflow
**Purpose**: Permanently delete a workflow

#### Parameters
```json
{
  "workflow_id": string     // Workflow to delete (required)
}
```

---

## ⚡ Execution Management

### execute-workflow
**Purpose**: Execute workflow manually with optional input data

#### Parameters
```json
{
  "workflow_id": string,        // Target workflow (required)
  "input_data": object,         // Input data (optional)
  "wait_for_completion": boolean // Wait for result (default: true)
}
```

#### Example Usage
```javascript
// Execute Calamity Profiteer Agent
n8n-complete:execute-workflow --workflow_id="PvXBGYpFiuuGkPk6"

// Execute with custom input
n8n-complete:execute-workflow --workflow_id="PvXBGYpFiuuGkPk6" --input_data={"keywords": ["AI", "automation"]}
```

#### Response Format
```
🚀 **Workflow Execution Started**
**Execution ID:** exec-abc123
**Status:** Running
**Final Status:** ✅ Success
```

### get-execution-logs
**Purpose**: Get detailed execution logs with error analysis

#### Parameters
```json
{
  "execution_id": string,    // Execution ID (required)
  "include_data": boolean    // Include node data (default: false)
}
```

#### Example Usage
```javascript
n8n-complete:get-execution-logs --execution_id="exec-abc123" --include_data=true
```

### list-executions
**Purpose**: List recent executions with filtering and metrics

#### Parameters
```json
{
  "workflow_id": string,        // Filter by workflow (optional)
  "status": string,             // Filter by status: success|error|running|waiting
  "limit": integer,             // Max results (default: 10)
  "include_metrics": boolean    // Include performance data (default: true)
}
```

---

## 🔧 Node Management

### add-node
**Purpose**: Add new node to existing workflow

#### Parameters
```json
{
  "workflow_id": string,    // Target workflow (required)
  "node_type": string,      // Node type (required)
  "name": string,           // Node name (required)
  "parameters": object,     // Node configuration (optional)
  "position": array         // Position [x, y] (optional)
}
```

#### Example Usage
```javascript
n8n-complete:add-node --workflow_id="PvXBGYpFiuuGkPk6" --node_type="n8n-nodes-base.httpRequest" --name="API Call"
```

#### Common Node Types
```javascript
// HTTP Request
"n8n-nodes-base.httpRequest"

// Webhook
"n8n-nodes-base.webhook"

// Schedule Trigger
"n8n-nodes-base.cron"

// AI Agent
"@n8n/n8n-nodes-langchain.agent"

// Azure OpenAI
"@n8n/n8n-nodes-langchain.lmChatAzureOpenAi"

// PostgreSQL
"n8n-nodes-base.postgres"

// Slack
"n8n-nodes-base.slack"
```

### update-node
**Purpose**: Update node configuration and parameters

#### Parameters
```json
{
  "workflow_id": string,    // Target workflow (required)
  "node_name": string,      // Node to update (required)
  "parameters": object,     // New parameters (optional)
  "position": array         // New position [x, y] (optional)
}
```

### remove-node
**Purpose**: Remove node from workflow

#### Parameters
```json
{
  "workflow_id": string,    // Target workflow (required)
  "node_name": string       // Node to remove (required)
}
```

### connect-nodes
**Purpose**: Create connection between two nodes

#### Parameters
```json
{
  "workflow_id": string,    // Target workflow (required)
  "source_node": string,    // Source node name (required)
  "target_node": string,    // Target node name (required)
  "source_output": integer, // Output index (default: 0)
  "target_input": string    // Input name (default: "main")
}
```

---

## 🔐 Credentials Management

### list-credentials
**Purpose**: List all available credentials

#### Parameters
```json
{}  // No parameters required
```

### create-credential
**Purpose**: Create new credential for API access

#### Parameters
```json
{
  "name": string,      // Credential name (required)
  "type": string,      // Credential type (required)
  "data": object       // Credential data (required)
}
```

#### Example Usage
```javascript
// Azure OpenAI Credential
n8n-complete:create-credential --name="Azure-OpenAI" --type="httpAuth" --data={"api-key": "your-key"}

// Slack Credential
n8n-complete:create-credential --name="Slack-Bot" --type="slackApi" --data={"accessToken": "xoxb-token"}
```

### update-credential
**Purpose**: Update existing credential

#### Parameters
```json
{
  "credential_id": string,  // Credential ID (required)
  "name": string,           // New name (optional)
  "data": object            // Updated data (optional)
}
```

---

## 📊 Performance & Analytics

### analyze-performance
**Purpose**: Analyze workflow performance and identify bottlenecks

#### Parameters
```json
{
  "workflow_id": string,    // Target workflow (required)
  "days_back": integer      // Analysis period (default: 7)
}
```

### optimize-workflow
**Purpose**: Get optimization suggestions for workflow efficiency

#### Parameters
```json
{
  "workflow_id": string     // Target workflow (required)
}
```

### health-monitor
**Purpose**: Comprehensive system health monitoring

#### Parameters
```json
{}  // No parameters required
```

#### Response Format
```
🏥 **n8n System Health Report**

**Health Score:** 100/100
**Status:** 🟢 Healthy

**Workflows:**
• Total: 2
• Active: 1
• Inactive: 1

**Recent Activity:**
• Executions (last 10): 10
• Recent Errors: 0
```

---

## 🏗️ Template System

### create-from-template
**Purpose**: Create workflow from predefined template

#### Parameters
```json
{
  "template_type": string,  // Template type (required)
  "name": string,           // Workflow name (required)
  "parameters": object      // Template-specific config (optional)
}
```

#### Available Templates
```javascript
// Data synchronization workflow
"data-sync"

// System monitoring workflow
"monitoring"

// Notification workflow
"notification"

// API integration workflow
"api-integration"
```

---

## 👁️ Screenpipe Terminal Server

### search-content
**Purpose**: Search through recorded screen and audio content

#### Parameters
```json
{
  "q": string,              // Search query (optional)
  "content_type": string,   // Filter: all|ocr|audio|ui (default: all)
  "app_name": string,       // Filter by application (optional)
  "window_name": string,    // Filter by window (optional)
  "start_time": string,     // ISO datetime start (optional)
  "end_time": string,       // ISO datetime end (optional)
  "limit": integer,         // Max results (default: 10)
  "offset": integer         // Result offset (default: 0)
}
```

#### Example Usage
```javascript
// Search for recent work on n8n
screenpipe-terminal:search-content --q="n8n workflow" --limit=5

// Search for coding sessions today
screenpipe-terminal:search-content --q="python" --app_name="Code" --start_time="2025-06-19T00:00:00Z"
```

### execute-terminal-command
**Purpose**: Execute command in active terminal

#### Parameters
```json
{
  "command": string,    // Command to execute (required)
  "timeout": integer    // Timeout seconds (default: 30)
}
```

#### Example Usage
```javascript
screenpipe-terminal:execute-terminal-command --command="cd Strategy_agents && git status"
```

### analyze-productivity
**Purpose**: Analyze productivity patterns from behavioral data

#### Parameters
```json
{
  "hours_back": integer,        // Analysis period (default: 8)
  "focus_apps": array          // Apps to analyze (optional)
}
```

---

## 📋 Azure PostgreSQL Server

### get_databases
**Purpose**: List all databases in PostgreSQL server

### query_data
**Purpose**: Execute read queries on database

#### Parameters
```json
{
  "dbname": string,     // Database name (required)
  "s": string           // SQL query (required)
}
```

### update_values
**Purpose**: Execute write queries (INSERT/UPDATE/DELETE)

#### Parameters
```json
{
  "dbname": string,     // Database name (required)
  "s": string           // SQL statement (required)
}
```

---

## 🔄 Error Handling

### Common Error Responses

#### Connection Errors
```
❌ Error executing list-workflows: Failed to connect to n8n: 
```
**Solution**: Check n8n instance status and API credentials

#### Authentication Errors
```
❌ Error executing list-workflows: n8n API error 401: Unauthorized
```
**Solution**: Verify API key configuration

#### Not Found Errors
```
❌ Workflow not found: invalid-workflow-id
```
**Solution**: Use valid workflow ID from list-workflows

#### Timeout Errors
```
❌ Error executing list-workflows: Request timeout
```
**Solution**: Check network connectivity and server responsiveness

---

## 📚 Usage Patterns

### Strategic Workflow Management
```javascript
// 1. Check system health
n8n-complete:health-monitor

// 2. List workflows to see current state
n8n-complete:list-workflows

// 3. Get detailed workflow information
n8n-complete:get-workflow --workflow_id="PvXBGYpFiuuGkPk6"

// 4. Execute workflow manually
n8n-complete:execute-workflow --workflow_id="PvXBGYpFiuuGkPk6"

// 5. Monitor execution results
n8n-complete:list-executions --workflow_id="PvXBGYpFiuuGkPk6" --limit=5
```

### Performance Optimization
```javascript
// 1. Analyze workflow performance
n8n-complete:analyze-performance --workflow_id="PvXBGYpFiuuGkPk6" --days_back=30

// 2. Get optimization suggestions
n8n-complete:optimize-workflow --workflow_id="PvXBGYpFiuuGkPk6"

// 3. Monitor productivity patterns
screenpipe-terminal:analyze-productivity --hours_back=24
```

### Development Workflow
```javascript
// 1. Create new workflow from template
n8n-complete:create-from-template --template_type="monitoring" --name="Revenue Tracker"

// 2. Add nodes to workflow
n8n-complete:add-node --workflow_id="new-id" --node_type="n8n-nodes-base.httpRequest" --name="API Call"

// 3. Connect nodes
n8n-complete:connect-nodes --workflow_id="new-id" --source_node="Trigger" --target_node="API Call"

// 4. Test execution
n8n-complete:execute-workflow --workflow_id="new-id" --wait_for_completion=true
```

---

**Strategy Agents API Reference** - *Complete programmatic control over strategic automation*

This API enables full lifecycle management of strategic workflows, behavioral analysis, and revenue-focused automation through unified MCP interfaces.
