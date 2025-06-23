# Active Production Workflows

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

*Generated: 2025-06-23 14:37:00*
