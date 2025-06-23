# 🛠️ Manual n8n Workflow Setup - Screenpipe to Memory Pipeline

## 🎯 **Fixed Configuration with Proper Field Values**

### **Step 1: PostgreSQL Insert Node Configuration**

When configuring the "Insert New Conversations" PostgreSQL node:

**Operation**: Insert  
**Schema**: public  
**Table**: agent_conversations  

**Column Mappings** (this is the critical part):
```
conversation_id = {{ $json.conversation_id }}
content = {{ $json.content }}
metadata = {{ JSON.stringify($json.metadata) }}
created_at = {{ $json.created_at }}
```

**Alternative Configuration**:
- **Operation**: Execute Query
- **Query**: 
```sql
INSERT INTO agent_conversations (conversation_id, content, metadata, created_at) 
VALUES ($1, $2, $3, $4) 
ON CONFLICT (conversation_id) DO NOTHING
```
- **Parameters**:
  - `$1` = `{{ $json.conversation_id }}`
  - `$2` = `{{ $json.content }}`
  - `$3` = `{{ JSON.stringify($json.metadata) }}`
  - `$4` = `{{ $json.created_at }}`

### **Step 2: Process Conversations Node (Fixed)**

**Key Fix**: Updated to handle Screenpipe's actual data structure:

```javascript
// Process Screenpipe data into conversation format
const items = $input.all();
const processedConversations = [];

for (const item of items) {
  const data = item.json.data || [];
  
  for (const entry of data) {
    // Only process substantial content (OCR text or audio transcripts)
    if (entry.content && entry.content.text && entry.content.text.length > 100) {
      // Create unique conversation ID based on content hash
      const contentText = entry.content.text.trim();
      const contentHash = require('crypto').createHash('md5').update(contentText).digest('hex');
      
      processedConversations.push({
        conversation_id: contentHash,
        content: contentText,
        metadata: {
          timestamp: entry.timestamp,
          app_name: entry.app_name || 'unknown',
          window_name: entry.window_name || 'unknown',
          content_type: entry.type || 'text',
          file_path: entry.file_path || null,
          source: 'screenpipe',
          processed_at: new Date().toISOString()
        },
        created_at: entry.timestamp ? new Date(entry.timestamp).toISOString() : new Date().toISOString()
      });
    }
  }
}

console.log(`Processed ${processedConversations.length} conversations from Screenpipe`);
return processedConversations.map(conv => ({ json: conv }));
```

### **Step 3: Store Embedding Node (Fixed)**

**Operation**: Execute Query  
**Query**:
```sql
UPDATE agent_conversations 
SET embedding = $1::vector 
WHERE conversation_id = $2
```

**Parameters**:
- `$1` = `{{ $json.embedding }}`
- `$2` = `{{ $json.conversation_id }}`

### **Step 4: Process Embedding Response Node (New)**

Add this node between "Generate Embedding" and "Store Embedding":

```javascript
// Extract embedding vector from Azure OpenAI response
const items = $input.all();
const results = [];

for (const item of items) {
  const response = item.json;
  const conversationId = $input.first().json.conversation_id;
  
  if (response.data && response.data.length > 0) {
    const embedding = response.data[0].embedding;
    
    results.push({
      conversation_id: conversationId,
      embedding: JSON.stringify(embedding), // Convert array to JSON string
      embedding_length: embedding.length,
      success: true
    });
  } else {
    results.push({
      conversation_id: conversationId,
      embedding: null,
      error: 'No embedding returned',
      success: false
    });
  }
}

return results.map(result => ({ json: result }));
```

## 🔄 **Complete Workflow Flow**

```
Cron (Every 10 min) 
    ↓
Screenpipe Search 
    ↓
Process Conversations (with fixed data structure)
    ↓
Insert New Conversations (with proper field mapping)
    ↓
Find Missing Embeddings
    ↓
Chunk Text
    ↓
Generate Embedding
    ↓
Process Embedding Response (NEW - formats embedding data)
    ↓
Store Embedding (with proper UPDATE query)
    ↓
Success Notification
```

## 🎯 **Key Fixes Applied**

1. **✅ Fixed Screenpipe Data Structure**: Now correctly accesses `entry.content.text`
2. **✅ Fixed PostgreSQL Insert**: Proper field mapping with explicit values
3. **✅ Fixed Embedding Storage**: Converts embedding array to proper format
4. **✅ Added Processing Node**: Handles Azure OpenAI response format
5. **✅ Removed Deduplication Logic**: Simplified for initial implementation

## 📋 **Import Instructions**

1. **Copy the JSON** from `screenpipe_to_memory_pipeline_fixed.json`
2. **Open n8n UI**
3. **Import Workflow** (or create manually with above configs)
4. **Set PostgreSQL Credentials** in all database nodes
5. **Set Azure OpenAI API Key** in the Generate Embedding node
6. **Test Each Node** individually before activating
7. **Activate Workflow** once all tests pass

## ✅ **Testing Checklist**

- [ ] Screenpipe Search returns data
- [ ] Process Conversations creates proper objects
- [ ] Insert New Conversations adds to database
- [ ] Find Missing Embeddings finds records
- [ ] Generate Embedding gets Azure OpenAI response
- [ ] Process Embedding Response formats correctly
- [ ] Store Embedding updates database
- [ ] Success Notification shows completion

This should resolve the field mapping issues and create a working pipeline!
