# Screenpipe to Memory Pipeline - PEG-51 Implementation

## Overview
This workflow completes PEG-51 by implementing a complete pipeline that:
1. **Extracts conversations** from Screenpipe via API
2. **Stores new conversations** in PostgreSQL database
3. **Generates embeddings** for conversation search
4. **Enables memory-enhanced Strategic PM Agent**

## Workflow Architecture

### Phase 1: Conversation Extraction (Every 10 minutes)
```
Cron Trigger → Screenpipe API → Process Data → Check Existing → Insert New Conversations
```

### Phase 2: Embedding Generation
```
Find Missing Embeddings → Chunk Text → Generate Embedding → Store Embedding → Success Notification
```

## Screenpipe Integration
- **Endpoint**: https://28fc-2a0d-3344-1514-af10-35ec-bb77-7913-dcf.ngrok-free.app/search
- **Frequency**: Every 10 minutes
- **Content Filter**: Only text longer than 100 characters
- **Deduplication**: MD5 hash-based unique conversation IDs

## Database Schema
```sql
-- agent_conversations table
conversation_id UUID PRIMARY KEY     -- MD5 hash of content
content TEXT                        -- Actual conversation text
metadata JSONB                      -- App name, timestamp, source info  
embedding VECTOR(1536)              -- Azure OpenAI embedding
created_at TIMESTAMP                -- When conversation occurred
```

## Azure OpenAI Integration
- **Model**: text-embedding-3-small
- **Endpoint**: strategy-agents.openai.azure.com
- **Chunking**: 8000 character limit per embedding
- **Cost**: ~$0.00002 per 1K tokens

## Key Features

### Smart Content Processing
- Filters substantial content (>100 chars)
- Extracts metadata (app, window, timestamp)
- Creates unique IDs to prevent duplicates
- Handles OCR text and audio transcripts

### Robust Error Handling
- Database connection retries
- API timeout configuration (30s)
- Fallback processing for missing data
- Detailed logging and monitoring

### Memory Enhancement
- Vector similarity search ready
- Strategic PM Agent integration prepared
- Cross-conversation pattern recognition
- Real-time memory updates

## Installation Steps

### 1. Manual Workflow Creation (Required)
Since n8n API has limitations, create workflow manually:

1. **Access n8n UI**: Go to your n8n instance
2. **Import JSON**: Copy content from `screenpipe_to_memory_pipeline.json`
3. **Configure credentials**: Set up PostgreSQL and Azure OpenAI connections
4. **Test pipeline**: Run manually first to verify
5. **Activate**: Enable for automatic execution

### 2. Database Preparation
```sql
-- Ensure table exists with proper structure
CREATE TABLE IF NOT EXISTS agent_conversations (
    id SERIAL PRIMARY KEY,
    conversation_id UUID UNIQUE NOT NULL,
    content TEXT NOT NULL,
    embedding VECTOR(1536),
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for similarity search
CREATE INDEX IF NOT EXISTS idx_agent_conversations_embedding 
ON agent_conversations USING ivfflat (embedding vector_cosine_ops);
```

### 3. Credential Configuration
Set up in n8n:
- **PostgreSQL**: Connection to Azure PostgreSQL instance
- **Azure OpenAI**: API key and endpoint configuration

## Testing & Validation

### Manual Test Sequence
1. **Trigger workflow** manually in n8n
2. **Check Screenpipe data** extraction
3. **Verify database** inserts
4. **Confirm embeddings** generation
5. **Test similarity search**

### Expected Results
- New conversations appear in database
- Embeddings generated within 30 seconds
- No duplicate conversations
- Strategic PM Agent can access memory

## Success Metrics
- ✅ Conversations automatically captured from Screenpipe
- ✅ Embeddings generated for all content
- ✅ Database growing with real conversation data
- ✅ Strategic PM Agent has memory context
- ✅ No duplicate or missing conversations

## Troubleshooting

### Common Issues
1. **Screenpipe connection**: Check ngrok URL validity
2. **Database timeouts**: Verify PostgreSQL credentials
3. **Embedding failures**: Check Azure OpenAI API key
4. **Memory issues**: Monitor embedding generation costs

### Monitoring
- Check n8n execution logs
- Monitor database table growth
- Track embedding generation success rate
- Validate conversation deduplication

## Integration with Strategic PM Agent

Once operational, this pipeline enables:
- **Context-aware responses** based on conversation history
- **Pattern recognition** across strategic discussions
- **Automated insights** from previous decisions
- **Enhanced strategic recommendations**

## Next Steps (Post-PEG-51)
1. **Similarity search integration** with Strategic PM Agent
2. **Memory context enhancement** in agent responses  
3. **Pattern recognition algorithms** for strategic insights
4. **Cross-conversation intelligence** features

This completes the core memory infrastructure for Strategic PM Agent enhancement.
