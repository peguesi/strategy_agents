#!/usr/bin/env python3
"""
Memory Enhancement Service for Strategic PM Agent
Provides similarity search and contextual memory retrieval
"""

from flask import Flask, request, jsonify
import psycopg2
import json
import re
from datetime import datetime
from typing import List, Dict, Optional

app = Flask(__name__)

# Database configuration
DB_CONFIG = {
    'host': 'agent-memory-postgres.postgres.database.azure.com',
    'database': 'postgres',
    'user': 'isaiah',
    'password': 'fgh6ckf-nyp3afg!VEQ',
    'port': 5432,
    'sslmode': 'require'
}

def get_db_connection():
    """Get database connection"""
    try:
        return psycopg2.connect(**DB_CONFIG)
    except Exception as e:
        print(f"Database connection error: {e}")
        return None

def extract_key_terms(text: str, max_terms: int = 5) -> List[str]:
    """Extract key terms from text for similarity matching"""
    # Clean and split text
    cleaned = re.sub(r'[^a-zA-Z0-9\s]', ' ', text.lower())
    words = [w for w in cleaned.split() if len(w) > 3]
    
    # Remove common stop words
    stop_words = {'this', 'that', 'with', 'have', 'will', 'from', 'they', 'been', 'said', 'each', 'which', 'their', 'what', 'were', 'them', 'would', 'there', 'could', 'other'}
    key_terms = [w for w in words if w not in stop_words]
    
    return key_terms[:max_terms]

def find_similar_conversations(query: str, limit: int = 5) -> List[Dict]:
    """Find similar conversations using keyword matching"""
    conn = get_db_connection()
    if not conn:
        return []
    
    try:
        cur = conn.cursor()
        
        # Extract key terms for similarity search
        key_terms = extract_key_terms(query)
        
        if not key_terms:
            return []
        
        # Create regex pattern for keyword matching
        pattern = '|'.join(key_terms)
        
        # Query for similar conversations
        search_query = """
        SELECT id, content, metadata, created_at
        FROM agent_conversations 
        WHERE LOWER(content) ~ %s
        ORDER BY created_at DESC 
        LIMIT %s
        """
        
        cur.execute(search_query, (pattern, limit))
        results = cur.fetchall()
        
        conversations = []
        for row in results:
            conversations.append({
                'id': row[0],
                'content': row[1],
                'metadata': row[2] if row[2] else {},
                'created_at': row[3].isoformat() if row[3] else None
            })
        
        cur.close()
        return conversations
        
    except Exception as e:
        print(f"Search error: {e}")
        return []
    finally:
        conn.close()

@app.route('/enhance_memory', methods=['POST'])
def enhance_memory():
    """Enhance query with memory context"""
    try:
        data = request.get_json()
        query = data.get('query', '')
        
        if not query:
            return jsonify({'error': 'No query provided'}), 400
        
        # Find similar conversations
        similar_conversations = find_similar_conversations(query)
        
        # Build enhanced context
        enhanced_context = ""
        if similar_conversations:
            enhanced_context = "## 🧠 **RELEVANT MEMORY CONTEXT**\n\n"
            enhanced_context += "Based on previous conversations, here are relevant insights:\n\n"
            
            for idx, conv in enumerate(similar_conversations, 1):
                date_str = datetime.fromisoformat(conv['created_at']).strftime('%Y-%m-%d') if conv['created_at'] else 'Unknown'
                enhanced_context += f"**Memory {idx}** ({date_str}):\n"
                enhanced_context += f"{conv['content']}\n"
                if conv['metadata']:
                    enhanced_context += f"Context: {json.dumps(conv['metadata'])}\n"
                enhanced_context += "\n"
            
            enhanced_context += f"---\n**Current Query:** {query}\n\n"
        
        # Return enhanced context
        response = {
            'original_query': query,
            'enhanced_context': enhanced_context,
            'similar_conversations_count': len(similar_conversations),
            'enhanced_query': enhanced_context + query if enhanced_context else query,
            'memory_available': len(similar_conversations) > 0
        }
        
        return jsonify(response)
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    conn = get_db_connection()
    if conn:
        conn.close()
        return jsonify({'status': 'healthy', 'database': 'connected'})
    else:
        return jsonify({'status': 'unhealthy', 'database': 'disconnected'}), 500

@app.route('/stats', methods=['GET'])
def stats():
    """Memory system statistics"""
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cur = conn.cursor()
        
        # Get conversation count
        cur.execute("SELECT COUNT(*) FROM agent_conversations")
        total_conversations = cur.fetchone()[0]
        
        # Get conversations with embeddings
        cur.execute("SELECT COUNT(*) FROM agent_conversations WHERE embedding IS NOT NULL")
        conversations_with_embeddings = cur.fetchone()[0]
        
        cur.close()
        
        return jsonify({
            'total_conversations': total_conversations,
            'conversations_with_embeddings': conversations_with_embeddings,
            'embedding_coverage': round(conversations_with_embeddings / total_conversations * 100, 1) if total_conversations > 0 else 0
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

if __name__ == '__main__':
    print("🚀 Starting Memory Enhancement Service...")
    print("🔗 Database connecting to: agent-memory-postgres.postgres.database.azure.com")
    print("🌐 Service will be available at: http://localhost:5001")
    app.run(host='0.0.0.0', port=5001, debug=True)
