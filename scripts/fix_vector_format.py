#!/usr/bin/env python3
"""
PEG-50 Vector Format Fix
Test and demonstrate the correct format for PostgreSQL vector insertion
"""

def generate_corrected_n8n_code():
    """Generate the corrected n8n Code node JavaScript"""
    
    code = '''// CORRECTED CODE FOR N8N "Process Embeddings" NODE
// Fixes the PostgreSQL vector format issue for PEG-50

const items = $input.all();
const results = [];

// Simple UUID v4 generator for n8n Code node
function generateUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

for (let i = 0; i < items.length; i++) {
  const embeddingResponse = items[i].json;
  
  // Validate embedding response
  if (!embeddingResponse.data || !embeddingResponse.data[0] || !embeddingResponse.data[0].embedding) {
    throw new Error('Invalid embedding response from Azure OpenAI at index ' + i);
  }
  
  // Extract embedding and usage data
  const embedding = embeddingResponse.data[0].embedding;
  const usage = embeddingResponse.usage || {};
  
  // Validate embedding dimensions (text-embedding-3-small should be 1536)
  if (!Array.isArray(embedding) || embedding.length !== 1536) {
    throw new Error(`Invalid embedding dimensions: expected 1536, got ${embedding.length} at index ${i}`);
  }
  
  // Get the input text that was sent to Azure OpenAI
  const inputText = embeddingResponse.input || 'Unknown content';
  
  // Generate conversation ID if not provided
  const conversationId = items[i].json.conversation_id || generateUUID();
  
  // ✅ CRITICAL FIX: Format embedding as PostgreSQL vector string
  // PostgreSQL pgvector expects format: '[1.0,2.0,3.0]' as a string
  const embeddingVector = '[' + embedding.join(',') + ']';
  
  // Prepare data for agent_conversations table
  results.push({
    json: {
      conversation_id: conversationId,
      content: inputText,
      embedding: embeddingVector, // ✅ FIXED: Formatted as PostgreSQL vector string
      metadata: {
        // Embedding info
        token_count: usage.total_tokens || 0,
        prompt_tokens: usage.prompt_tokens || 0,
        model: embeddingResponse.model || 'text-embedding-3-small',
        
        // Vector validation
        dimensions: embedding.length,
        vector_format: 'pgvector_string',
        first_values: embedding.slice(0, 3), // For debugging
        
        // Processing info
        item_index: i,
        total_items: items.length,
        source: 'n8n_embeddings_pipeline',
        processing_date: new Date().toISOString(),
        pipeline_version: '1.1' // Updated with vector fix
      }
    }
  });
}

return results;'''
    
    return code

def create_test_vector():
    """Create a test vector in the correct format"""
    # Create a 1536-dimensional test vector
    dimensions = 1536
    test_values = [0.1] * dimensions
    vector_string = '[' + ','.join(map(str, test_values)) + ']'
    
    return {
        'vector_string': vector_string,
        'dimensions': dimensions,
        'string_length': len(vector_string),
        'sample_start': vector_string[:50],
        'sample_end': vector_string[-50:]
    }

def main():
    print("🔧 PEG-50 EMBEDDING VECTOR FORMAT FIX")
    print("=" * 60)
    
    # Show the problem
    print("\n❌ PROBLEM IDENTIFIED:")
    print("- Error: 'embedding' expects [] but got array")
    print("- Root cause: n8n PostgreSQL node not handling pgvector format")
    print("- Column type: vector(1536) in PostgreSQL")
    print("- Required format: '[value1,value2,...]' as string")
    
    # Show the solution
    print("\n✅ SOLUTION:")
    print("1. Convert JavaScript array to PostgreSQL vector string format")
    print("2. Use embeddingVector = '[' + embedding.join(',') + ']'")
    print("3. Pass this string to PostgreSQL node")
    
    # Generate test vector
    test_vector = create_test_vector()
    print(f"\n🧪 TEST VECTOR GENERATED:")
    print(f"- Dimensions: {test_vector['dimensions']}")
    print(f"- String length: {test_vector['string_length']} chars")
    print(f"- Start: {test_vector['sample_start']}...")
    print(f"- End: ...{test_vector['sample_end']}")
    
    # Show the corrected code
    print("\n📝 CORRECTED N8N CODE:")
    print("-" * 40)
    corrected_code = generate_corrected_n8n_code()
    print(corrected_code)
    
    print("\n🎯 IMPLEMENTATION STEPS:")
    print("1. Open n8n workflow 'Embeddings Pipeline Test'")
    print("2. Edit 'Process Embeddings' Code node")
    print("3. Replace existing code with corrected version above")
    print("4. Save and test with manual trigger")
    print("5. Verify vectors are stored in agent_conversations table")
    
    print("\n🔍 VERIFICATION QUERY:")
    print("SELECT id, content, array_length(embedding::float[], 1) as dims")
    print("FROM agent_conversations ORDER BY created_at DESC LIMIT 3;")

if __name__ == "__main__":
    main()
