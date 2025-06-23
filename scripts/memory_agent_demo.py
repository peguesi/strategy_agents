#!/usr/bin/env python3
"""
Memory-Enhanced Strategic Agent Demo
Demonstrates context-aware responses using conversation memory
"""

import psycopg2
import json
from datetime import datetime

# Database connection (use environment variables in production)
DB_CONFIG = {
    'host': 'agent-memory-postgres.postgres.database.azure.com',
    'database': 'postgres',
    'user': 'myadmin',
    'port': 5432
}

def retrieve_relevant_memory(query_context, limit=3):
    """
    Retrieve relevant conversations based on context keywords
    """
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        # Simple keyword-based search (in production, use vector similarity)
        search_query = """
        SELECT content, metadata, created_at 
        FROM agent_conversations 
        WHERE content ILIKE %s 
           OR metadata::text ILIKE %s
        ORDER BY created_at DESC 
        LIMIT %s
        """
        
        search_pattern = f"%{query_context}%"
        cursor.execute(search_query, (search_pattern, search_pattern, limit))
        
        results = cursor.fetchall()
        cursor.close()
        conn.close()
        
        return [
            {
                'content': row[0],
                'metadata': row[1],
                'created_at': row[2].isoformat()
            }
            for row in results
        ]
        
    except Exception as e:
        print(f"Memory retrieval error: {e}")
        return []

def generate_context_aware_response(user_query, relevant_memory):
    """
    Generate response enhanced with relevant memory context
    """
    memory_context = ""
    if relevant_memory:
        memory_context = "\n\nRelevant Past Context:\n"
        for memory in relevant_memory:
            memory_context += f"- {memory['content'][:100]}...\n"
    
    response = f"""
Strategic Analysis for: {user_query}

{memory_context}

Based on previous strategic discussions and current context, here's my analysis:
[This would be enhanced by the AI agent with memory-informed insights]

Memory-Enhanced Insights:
- References {len(relevant_memory)} relevant past conversations
- Maintains strategic context across sessions
- Builds on previous decisions and outcomes
"""
    return response

def demo_memory_enhanced_agent():
    """
    Demonstrate memory-enhanced strategic responses
    """
    print("=== Memory-Enhanced Strategic Agent Demo ===\n")
    
    # Test queries
    test_queries = [
        "high revenue work",
        "automation infrastructure", 
        "VibeCoding platform",
        "crisis profit signals"
    ]
    
    for query in test_queries:
        print(f"Query: {query}")
        memory = retrieve_relevant_memory(query)
        response = generate_context_aware_response(query, memory)
        print(response)
        print("-" * 50)

if __name__ == "__main__":
    demo_memory_enhanced_agent()
