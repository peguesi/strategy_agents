// Enhanced Memory Retrieval Function for Strategic PM Agent
// This function adds similarity search and context enhancement to the existing memory system

async function enhanceMemoryWithSimilarity() {
  const { Pool } = require('pg');
  
  // Database connection configuration
  const pool = new Pool({
    host: 'agent-memory-postgres.postgres.database.azure.com',
    database: 'postgres', 
    user: 'isaiah',
    password: 'fgh6ckf-nyp3afg!VEQ',
    port: 5432,
    ssl: { rejectUnauthorized: false }
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
