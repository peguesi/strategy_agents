/**
 * Enhanced Memory Retrieval Function for Strategic PM Agent
 * 
 * This Node.js module provides advanced memory retrieval capabilities for the Strategic
 * Project Management Agent. It implements similarity search and context enhancement 
 * on top of the existing PostgreSQL-based memory system.
 * 
 * Features:
 * - Semantic similarity search using vector embeddings
 * - Context-aware memory retrieval
 * - PostgreSQL integration with Azure database
 * - Enhanced query processing and ranking
 * 
 * Dependencies:
 * - pg (PostgreSQL client)
 * - Azure PostgreSQL database connection
 * 
 * @author Strategy Agents Team
 * @version 1.3.0
 * @since 2025-10-23
 * @license MIT
 */

async function enhanceMemoryWithSimilarity() {
  const { Pool } = require('pg');
  
  // Database connection configuration - USE ENVIRONMENT VARIABLES
  const pool = new Pool({
    host: process.env.POSTGRES_HOST || 'localhost',
    database: process.env.POSTGRES_DB || 'postgres', 
    user: process.env.POSTGRES_USER,
    password: process.env.POSTGRES_PASSWORD,
    port: process.env.POSTGRES_PORT || 5432,
    ssl: process.env.POSTGRES_SSL === 'true' ? { rejectUnauthorized: false } : false
  });

  try {
    // Get current query/context from input
    const currentQuery = $input.all()[0]?.json?.query || $input.all()[0]?.json?.content || '';
    
    if (!currentQuery) {
      return $input.all();
    }

    // For now, implement keyword-based similarity (since embeddings are not ready)
    // Extract key terms from current query
    const keyTerms = currentQuery.toLowerCase()
      .split(/[^a-z0-9]+/)
      .filter(term => term.length > 3)
      .slice(0, 5); // Top 5 key terms

    console.log('🔍 Searching for similar conversations with terms:', keyTerms);

    // Query for similar conversations using keyword matching
    const searchQuery = `
      SELECT id, content, metadata, created_at
      FROM agent_conversations 
      WHERE LOWER(content) ~ ANY($1)
      ORDER BY created_at DESC 
      LIMIT 5
    `;
    
    const result = await pool.query(searchQuery, [keyTerms]);
    const similarConversations = result.rows;

    console.log(`📚 Found ${similarConversations.length} similar conversations`);

    // Build enhanced context
    let enhancedContext = '';
    if (similarConversations.length > 0) {
      enhancedContext = `
## 🧠 **RELEVANT MEMORY CONTEXT**

Based on previous conversations, here are relevant insights:

${similarConversations.map((conv, idx) => `
**Memory ${idx + 1}** (${new Date(conv.created_at).toLocaleDateString()}):
${conv.content}
${conv.metadata ? `Context: ${JSON.stringify(conv.metadata)}` : ''}
`).join('\n')}

---
**Current Query:** ${currentQuery}
`;
    }

    // Return enhanced input with memory context
    const enhancedInput = {
      ...($input.all()[0]?.json || {}),
      memoryContext: enhancedContext,
      similarConversationsCount: similarConversations.length,
      enhancedQuery: enhancedContext + '\n\n' + currentQuery
    };

    console.log('✅ Memory enhancement complete');
    return [enhancedInput];

  } catch (error) {
    console.error('❌ Memory enhancement error:', error.message);
    // Fallback to original input if memory enhancement fails
    return $input.all();
  } finally {
    await pool.end();
  }
}

// Execute the enhancement
return await enhanceMemoryWithSimilarity();
