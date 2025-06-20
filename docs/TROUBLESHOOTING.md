# Troubleshooting Guide 🔧

> **Common issues and solutions for Strategy Agents platform**

## 🤖 n8n Workflow Issues

### "Cannot read properties of undefined (reading 'disabled')" Error

**Problem**: Workflow execution fails immediately with this error

**Root Cause**: Workflow nodes are missing the required `disabled` property

**Symptoms**:
- Execution starts and stops within 50ms
- Status shows "error" with "finished": false
- Appears in manual and scheduled executions

**Solution**:
1. **Quick Fix**: Open workflow in n8n interface, click each node and save (adds missing properties automatically)
2. **Programmatic Fix**: Add `"disabled": false` to all nodes in workflow JSON

**Example Fix**:
```json
{
  "parameters": { ... },
  "id": "node-id",
  "name": "Node Name", 
  "type": "node-type",
  "disabled": false,  // ← Add this property
  "position": [x, y]
}
```

**Prevention**: Always ensure imported workflows have all required node properties

---

## 🔌 MCP Server Issues

### MCP Server Connection Failures

**Problem**: MCP servers not responding or timing out

**Common Causes**:
- Environment variables not set
- Claude Desktop config issues
- Server not running

**Solution**:
```bash
# Check MCP server status
curl -X POST http://localhost:3001/mcp/list-tools

# Restart Claude Desktop
# Quit Claude (Cmd+Q) and reopen

# Check environment variables
echo $N8N_API_KEY
```

### n8n MCP Server Authentication

**Problem**: n8n MCP commands return authentication errors

**Solution**: Ensure N8N_API_KEY is properly set in Claude Desktop config:
```json
{
  "mcpServers": {
    "n8n-complete": {
      "command": "node",
      "args": ["path/to/server.js"],
      "env": {
        "N8N_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

---

## 📊 Database Issues

### PostgreSQL Connection Errors

**Problem**: Cannot connect to Azure PostgreSQL instance

**Symptoms**:
- "Connection refused" errors
- "Authentication failed" messages

**Solutions**:
1. **Check connection string**: Verify host, port, database name
2. **Firewall rules**: Ensure your IP is whitelisted in Azure
3. **SSL requirements**: Use `sslmode=require` for Azure PostgreSQL
4. **Credentials**: Verify username/password are correct

**Test Connection**:
```bash
psql "host=your-host.postgres.database.azure.com port=5432 dbname=your-db user=your-user sslmode=require"
```

---

## 🎯 Linear Integration Issues

### GraphQL Authentication Errors

**Problem**: Linear API returns 401 unauthorized

**Solution**:
1. **Check API key**: Verify `lin_api_` key is valid and active
2. **Permissions**: Ensure API key has required scopes
3. **Header format**: Use `Authorization: Bearer lin_api_your_key`

**Test Linear API**:
```bash
curl -H "Authorization: Bearer lin_api_your_key" \
     -H "Content-Type: application/json" \
     -d '{"query": "query { viewer { id name } }"}' \
     https://api.linear.app/graphql
```

### Missing Team or Project IDs

**Problem**: Queries return empty results

**Solution**: Verify team/project IDs are correct:
```graphql
query {
  teams {
    nodes {
      id
      name
    }
  }
}
```

---

## 📱 Screenpipe Issues

### Search API Not Responding

**Problem**: Screenpipe search returns no results or errors

**Symptoms**:
- `Connection refused` on localhost:3030
- `404 Not Found` errors

**Solutions**:
1. **Start Screenpipe**: Ensure screenpipe is running
2. **Check port**: Verify it's running on port 3030
3. **Update ngrok URL**: If using ngrok, update URLs in workflows

**Test Screenpipe**:
```bash
# Local test
curl "http://localhost:3030/search?q=test&limit=1"

# Check if screenpipe is running
ps aux | grep screenpipe
```

---

## ⚡ Performance Issues

### Slow Workflow Execution

**Problem**: Workflows take too long to complete

**Common Causes**:
- Large data processing
- External API rate limits
- Memory constraints

**Solutions**:
1. **Optimize queries**: Limit data retrieval
2. **Add pagination**: Process data in chunks
3. **Cache results**: Store frequently accessed data
4. **Parallel processing**: Use parallel execution where possible

### Memory Issues

**Problem**: "Out of memory" errors during execution

**Solutions**:
1. **Reduce batch size**: Process smaller chunks
2. **Clear variables**: Remove unnecessary data from memory
3. **Optimize node logic**: Use efficient algorithms
4. **Restart n8n**: Clear accumulated memory

---

## 🔒 Security Issues

### Exposed Credentials in Logs

**Problem**: Sensitive data appearing in execution logs

**Solution**:
1. **Use credential IDs**: Reference credentials by ID, not value
2. **Sanitize logs**: Remove sensitive data from error messages
3. **Environment variables**: Store secrets in environment, not workflows

### SSL Certificate Errors

**Problem**: "Certificate verification failed" errors

**Solution**:
1. **Update certificates**: Ensure SSL certs are current
2. **Allow self-signed**: Only for development environments
3. **Check certificate chain**: Verify complete certificate path

---

## 🔄 Workflow Development Issues

### Node Configuration Errors

**Problem**: Nodes not saving configuration properly

**Common Issues**:
- Missing required fields
- Invalid parameter formats
- Credential configuration errors

**Debug Steps**:
1. **Check required fields**: Ensure all mandatory parameters are set
2. **Validate JSON**: Check parameter format is correct
3. **Test credentials**: Verify external service connections
4. **Console logs**: Check browser console for JavaScript errors

### Workflow Import/Export Issues

**Problem**: Workflows fail to import correctly

**Symptoms**:
- Missing nodes after import
- Broken connections
- Configuration lost

**Solutions**:
1. **Check JSON format**: Validate workflow JSON structure
2. **Match n8n version**: Ensure compatibility with target n8n version
3. **Update node versions**: Check if newer node versions are available
4. **Manual reconstruction**: Rebuild workflow manually if corruption is severe

---

## 📞 Getting Help

### Diagnostic Information to Collect

When reporting issues, include:

1. **Error messages**: Complete error text and stack traces
2. **System info**: Operating system, n8n version, Node.js version  
3. **Workflow details**: Workflow JSON (with credentials removed)
4. **Execution logs**: Recent execution IDs and timestamps
5. **Configuration**: Relevant environment variables and settings

### Log Collection Commands

```bash
# n8n execution logs
curl -H "X-N8N-API-KEY: $N8N_API_KEY" \
     "https://your-n8n-instance/api/v1/executions?limit=5"

# System information
node --version
npm --version
ps aux | grep n8n

# Configuration check
echo "N8N_URL: $N8N_URL"
echo "Database connection: [REDACTED]"
```

### Emergency Recovery

**If workflows are completely broken**:

1. **Stop all executions**: Deactivate all workflows
2. **Backup current state**: Export all workflows
3. **Restore from backup**: Import last known good workflows
4. **Test individually**: Activate and test one workflow at a time
5. **Check dependencies**: Verify all external services are accessible

---

**Remember**: Always test changes in development before applying to production workflows.

---

Part of the Strategy Agents platform - [Main Documentation](../README.md)
