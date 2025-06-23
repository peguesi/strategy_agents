-- Universal Auto-Embedding System - Database Schema Enhancement
-- PEG-102: Complete Hybrid Memory Architecture Implementation

-- Enable pgvector extension if not already enabled
CREATE EXTENSION IF NOT EXISTS vector;

-- ===========================================
-- PHASE 1: Add embedding columns to all tables
-- ===========================================

-- Agent outcomes embeddings (suggestion_text and outcome_description)
ALTER TABLE agent_outcomes 
ADD COLUMN IF NOT EXISTS suggestion_embedding VECTOR(1536),
ADD COLUMN IF NOT EXISTS outcome_embedding VECTOR(1536);

-- Agent patterns embeddings (pattern_description)
ALTER TABLE agent_patterns
ADD COLUMN IF NOT EXISTS pattern_embedding VECTOR(1536);

-- Agent preferences embeddings (preference_value)
ALTER TABLE agent_preferences 
ADD COLUMN IF NOT EXISTS preference_embedding VECTOR(1536);

-- Chat histories embeddings (message content)
ALTER TABLE n8n_chat_histories
ADD COLUMN IF NOT EXISTS message_embedding VECTOR(1536);

-- ===========================================
-- PHASE 2: Create indexes for vector similarity search
-- ===========================================

-- Indexes for efficient similarity search
CREATE INDEX IF NOT EXISTS idx_agent_outcomes_suggestion_embedding 
ON agent_outcomes USING ivfflat (suggestion_embedding vector_cosine_ops);

CREATE INDEX IF NOT EXISTS idx_agent_outcomes_outcome_embedding 
ON agent_outcomes USING ivfflat (outcome_embedding vector_cosine_ops);

CREATE INDEX IF NOT EXISTS idx_agent_patterns_pattern_embedding 
ON agent_patterns USING ivfflat (pattern_embedding vector_cosine_ops);

CREATE INDEX IF NOT EXISTS idx_agent_preferences_preference_embedding 
ON agent_preferences USING ivfflat (preference_embedding vector_cosine_ops);

CREATE INDEX IF NOT EXISTS idx_n8n_chat_histories_message_embedding 
ON n8n_chat_histories USING ivfflat (message_embedding vector_cosine_ops);

-- ===========================================
-- PHASE 3: Utility functions for hybrid search
-- ===========================================

-- Function to find similar outcomes by suggestion text
CREATE OR REPLACE FUNCTION find_similar_outcomes(
    query_embedding VECTOR(1536),
    similarity_threshold FLOAT DEFAULT 0.8,
    max_results INT DEFAULT 10
)
RETURNS TABLE (
    id UUID,
    suggestion_text TEXT,
    outcome_description TEXT,
    similarity_score FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ao.id,
        ao.suggestion_text,
        ao.outcome_description,
        1 - (ao.suggestion_embedding <=> query_embedding) as similarity_score
    FROM agent_outcomes ao
    WHERE ao.suggestion_embedding IS NOT NULL
        AND 1 - (ao.suggestion_embedding <=> query_embedding) > similarity_threshold
    ORDER BY ao.suggestion_embedding <=> query_embedding
    LIMIT max_results;
END;
$$ LANGUAGE plpgsql;

-- Function to find similar behavioral patterns
CREATE OR REPLACE FUNCTION find_similar_patterns(
    query_embedding VECTOR(1536),
    similarity_threshold FLOAT DEFAULT 0.8,
    max_results INT DEFAULT 10
)
RETURNS TABLE (
    id UUID,
    pattern_name TEXT,
    pattern_description TEXT,
    behavior_pattern JSONB,
    similarity_score FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ap.id,
        ap.pattern_name,
        ap.pattern_description,
        ap.behavior_pattern,
        1 - (ap.pattern_embedding <=> query_embedding) as similarity_score
    FROM agent_patterns ap
    WHERE ap.pattern_embedding IS NOT NULL
        AND 1 - (ap.pattern_embedding <=> query_embedding) > similarity_threshold
    ORDER BY ap.pattern_embedding <=> query_embedding
    LIMIT max_results;
END;
$$ LANGUAGE plpgsql;

-- Function to find similar user preferences
CREATE OR REPLACE FUNCTION find_similar_preferences(
    query_embedding VECTOR(1536),
    similarity_threshold FLOAT DEFAULT 0.8,
    max_results INT DEFAULT 10
)
RETURNS TABLE (
    id UUID,
    preference_key TEXT,
    preference_value TEXT,
    user_id TEXT,
    similarity_score FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ap.id,
        ap.preference_key,
        ap.preference_value,
        ap.user_id,
        1 - (ap.preference_embedding <=> query_embedding) as similarity_score
    FROM agent_preferences ap
    WHERE ap.preference_embedding IS NOT NULL
        AND 1 - (ap.preference_embedding <=> query_embedding) > similarity_threshold
    ORDER BY ap.preference_embedding <=> query_embedding
    LIMIT max_results;
END;
$$ LANGUAGE plpgsql;

-- Function for semantic chat history search
CREATE OR REPLACE FUNCTION search_chat_history(
    query_embedding VECTOR(1536),
    similarity_threshold FLOAT DEFAULT 0.7,
    max_results INT DEFAULT 20
)
RETURNS TABLE (
    id UUID,
    conversation_id TEXT,
    message TEXT,
    message_role TEXT,
    created_at TIMESTAMP,
    similarity_score FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        nch.id,
        nch.conversation_id,
        nch.message,
        nch.message_role,
        nch.created_at,
        1 - (nch.message_embedding <=> query_embedding) as similarity_score
    FROM n8n_chat_histories nch
    WHERE nch.message_embedding IS NOT NULL
        AND 1 - (nch.message_embedding <=> query_embedding) > similarity_threshold
    ORDER BY nch.message_embedding <=> query_embedding
    LIMIT max_results;
END;
$$ LANGUAGE plpgsql;

-- ===========================================
-- PHASE 4: Hybrid search combining multiple tables
-- ===========================================

-- Universal semantic search across all agent memory
CREATE OR REPLACE FUNCTION universal_agent_search(
    query_embedding VECTOR(1536),
    similarity_threshold FLOAT DEFAULT 0.7,
    max_results_per_table INT DEFAULT 5
)
RETURNS TABLE (
    source_table TEXT,
    record_id UUID,
    content_preview TEXT,
    metadata JSONB,
    similarity_score FLOAT,
    created_at TIMESTAMP
) AS $$
BEGIN
    -- Search conversations
    RETURN QUERY
    SELECT 
        'agent_conversations'::TEXT as source_table,
        ac.conversation_id::UUID as record_id,
        LEFT(ac.content, 200) as content_preview,
        jsonb_build_object(
            'type', 'conversation',
            'title', ac.title,
            'strategic', ac.is_strategic
        ) as metadata,
        1 - (ac.embedding <=> query_embedding) as similarity_score,
        ac.created_at
    FROM agent_conversations ac
    WHERE ac.embedding IS NOT NULL
        AND 1 - (ac.embedding <=> query_embedding) > similarity_threshold
    ORDER BY ac.embedding <=> query_embedding
    LIMIT max_results_per_table;

    -- Search outcomes
    RETURN QUERY
    SELECT 
        'agent_outcomes'::TEXT as source_table,
        ao.id as record_id,
        LEFT(ao.suggestion_text, 200) as content_preview,
        jsonb_build_object(
            'type', 'outcome',
            'outcome_description', ao.outcome_description
        ) as metadata,
        1 - (ao.suggestion_embedding <=> query_embedding) as similarity_score,
        ao.created_at
    FROM agent_outcomes ao
    WHERE ao.suggestion_embedding IS NOT NULL
        AND 1 - (ao.suggestion_embedding <=> query_embedding) > similarity_threshold
    ORDER BY ao.suggestion_embedding <=> query_embedding
    LIMIT max_results_per_table;

    -- Search patterns
    RETURN QUERY
    SELECT 
        'agent_patterns'::TEXT as source_table,
        ap.id as record_id,
        LEFT(ap.pattern_description, 200) as content_preview,
        jsonb_build_object(
            'type', 'pattern',
            'pattern_name', ap.pattern_name,
            'behavior_pattern', ap.behavior_pattern
        ) as metadata,
        1 - (ap.pattern_embedding <=> query_embedding) as similarity_score,
        ap.created_at
    FROM agent_patterns ap
    WHERE ap.pattern_embedding IS NOT NULL
        AND 1 - (ap.pattern_embedding <=> query_embedding) > similarity_threshold
    ORDER BY ap.pattern_embedding <=> query_embedding
    LIMIT max_results_per_table;

    -- Search preferences
    RETURN QUERY
    SELECT 
        'agent_preferences'::TEXT as source_table,
        ap.id as record_id,
        LEFT(ap.preference_value, 200) as content_preview,
        jsonb_build_object(
            'type', 'preference',
            'preference_key', ap.preference_key,
            'user_id', ap.user_id
        ) as metadata,
        1 - (ap.preference_embedding <=> query_embedding) as similarity_score,
        ap.created_at
    FROM agent_preferences ap
    WHERE ap.preference_embedding IS NOT NULL
        AND 1 - (ap.preference_embedding <=> query_embedding) > similarity_threshold
    ORDER BY ap.preference_embedding <=> query_embedding
    LIMIT max_results_per_table;

    -- Search chat histories
    RETURN QUERY
    SELECT 
        'n8n_chat_histories'::TEXT as source_table,
        nch.id as record_id,
        LEFT(nch.message, 200) as content_preview,
        jsonb_build_object(
            'type', 'chat',
            'conversation_id', nch.conversation_id,
            'message_role', nch.message_role
        ) as metadata,
        1 - (nch.message_embedding <=> query_embedding) as similarity_score,
        nch.created_at
    FROM n8n_chat_histories nch
    WHERE nch.message_embedding IS NOT NULL
        AND 1 - (nch.message_embedding <=> query_embedding) > similarity_threshold
    ORDER BY nch.message_embedding <=> query_embedding
    LIMIT max_results_per_table;
END;
$$ LANGUAGE plpgsql;

-- ===========================================
-- PHASE 5: Statistics and monitoring
-- ===========================================

-- View for embedding coverage statistics
CREATE OR REPLACE VIEW embedding_coverage_stats AS
SELECT 
    'agent_conversations' as table_name,
    COUNT(*) as total_records,
    COUNT(embedding) as records_with_embeddings,
    ROUND(100.0 * COUNT(embedding) / COUNT(*), 2) as coverage_percentage
FROM agent_conversations
UNION ALL
SELECT 
    'agent_outcomes' as table_name,
    COUNT(*) as total_records,
    COUNT(suggestion_embedding) as records_with_embeddings,
    ROUND(100.0 * COUNT(suggestion_embedding) / COUNT(*), 2) as coverage_percentage
FROM agent_outcomes
UNION ALL
SELECT 
    'agent_patterns' as table_name,
    COUNT(*) as total_records,
    COUNT(pattern_embedding) as records_with_embeddings,
    ROUND(100.0 * COUNT(pattern_embedding) / COUNT(*), 2) as coverage_percentage
FROM agent_patterns
UNION ALL
SELECT 
    'agent_preferences' as table_name,
    COUNT(*) as total_records,
    COUNT(preference_embedding) as records_with_embeddings,
    ROUND(100.0 * COUNT(preference_embedding) / COUNT(*), 2) as coverage_percentage
FROM agent_preferences
UNION ALL
SELECT 
    'n8n_chat_histories' as table_name,
    COUNT(*) as total_records,
    COUNT(message_embedding) as records_with_embeddings,
    ROUND(100.0 * COUNT(message_embedding) / COUNT(*), 2) as coverage_percentage
FROM n8n_chat_histories;

-- ===========================================
-- VERIFICATION QUERIES
-- ===========================================

-- Test the coverage view
-- SELECT * FROM embedding_coverage_stats ORDER BY coverage_percentage DESC;

-- Test similarity search (once embeddings are populated)
-- SELECT * FROM universal_agent_search('[0.1,0.2,...]'::vector(1536), 0.5, 3);

COMMENT ON SCHEMA public IS 'Enhanced with Universal Auto-Embedding System for PEG-102 - Complete Hybrid Memory Architecture';
