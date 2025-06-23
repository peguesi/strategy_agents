#!/usr/bin/env python3
"""
Generate embeddings for existing conversations using Azure OpenAI
"""

import openai
import json
import requests
import os
from typing import List, Dict

# Azure OpenAI Configuration
AZURE_OPENAI_ENDPOINT = "https://isaiah-agents.openai.azure.com/"
AZURE_OPENAI_API_KEY = "b1e30ef2b20e437ba95d22f4b5dd6d0e"
AZURE_OPENAI_API_VERSION = "2024-02-15-preview"
EMBEDDING_MODEL = "text-embedding-ada-002"

def get_embedding(text: str) -> List[float]:
    """Generate embedding for text using Azure OpenAI"""
    client = openai.AzureOpenAI(
        azure_endpoint=AZURE_OPENAI_ENDPOINT,
        api_key=AZURE_OPENAI_API_KEY,
        api_version=AZURE_OPENAI_API_VERSION
    )
    
    try:
        response = client.embeddings.create(
            input=text,
            model=EMBEDDING_MODEL
        )
        return response.data[0].embedding
    except Exception as e:
        print(f"Error generating embedding: {e}")
        return None

def main():
    """Generate embeddings for test conversation"""
    test_conversations = [
        {
            "id": 1,
            "content": "AutomateBau.de platform development unlocks VibeCoding through German construction market validation, Simply-bau process abstraction, and AI need discovery optimization for heizung and sanitar business verticals."
        },
        {
            "id": 2, 
            "content": "Crisis Profit Signals MVP development focuses on High Revenue impact through WhatsApp delivery system, user database management, and automated opportunity matching based on crisis detection rules and filtering systems."
        }
    ]
    
    print("🔄 Generating embeddings for conversations...")
    
    for conv in test_conversations:
        print(f"\nProcessing conversation {conv['id']}...")
        embedding = get_embedding(conv['content'])
        
        if embedding:
            print(f"✅ Generated embedding vector with {len(embedding)} dimensions")
            print(f"First 5 values: {embedding[:5]}")
            
            # Output SQL UPDATE statement
            embedding_str = json.dumps(embedding)
            print(f"\nSQL Update for conversation {conv['id']}:")
            print(f"UPDATE agent_conversations SET embedding = '{embedding_str}' WHERE id = {conv['id']};")
        else:
            print(f"❌ Failed to generate embedding for conversation {conv['id']}")

if __name__ == "__main__":
    main()
