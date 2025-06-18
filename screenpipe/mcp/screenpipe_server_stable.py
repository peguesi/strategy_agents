#!/usr/bin/env python3
"""
Ultra-Stable Screenpipe MCP Server for Strategy Agents
Robust version with proper error handling and asyncio management
"""

import asyncio
import json
import sys
import os
import logging
from pathlib import Path

# Set up proper logging to stderr so Claude can see it
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler(sys.stderr)]
)
logger = logging.getLogger(__name__)

# Add error handling for imports
try:
    import mcp.server.stdio
    import mcp.types as types
    from mcp.server import Server
    from mcp.server.models import InitializationOptions
    logger.info("MCP imports successful")
except ImportError as e:
    logger.error(f"MCP import error: {e}")
    print(f"MCP import error: {e}", file=sys.stderr)
    sys.exit(1)

try:
    import httpx
    logger.info("httpx import successful")
except ImportError as e:
    logger.error(f"httpx import error: {e}")
    print(f"httpx import error: {e}", file=sys.stderr)
    sys.exit(1)

# Initialize server
server = Server("screenpipe-strategy")
logger.info("Server initialized")

# Constants
SCREENPIPE_API = "http://localhost:3030"

@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    """List available tools."""
    logger.info("Listing tools")
    try:
        tools = [
            types.Tool(
                name="search-content",
                description="Search through screenpipe recorded content (OCR text, audio transcriptions, UI elements)",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "q": {
                            "type": "string",
                            "description": "Search query to find in recorded content",
                        },
                        "limit": {
                            "type": "integer",
                            "description": "Maximum number of results to return",
                            "default": 10
                        },
                        "content_type": {
                            "type": "string",
                            "enum": ["all", "ocr", "audio"],
                            "description": "Type of content to search",
                            "default": "all"
                        }
                    }
                },
            ),
            types.Tool(
                name="test-connection",
                description="Test the connection to Screenpipe API",
                inputSchema={
                    "type": "object",
                    "properties": {}
                }
            ),
            types.Tool(
                name="get-health",
                description="Get Screenpipe service health status",
                inputSchema={
                    "type": "object",
                    "properties": {}
                }
            )
        ]
        logger.info(f"Returning {len(tools)} tools")
        return tools
    except Exception as e:
        logger.error(f"Error listing tools: {e}")
        raise

@server.call_tool()
async def handle_call_tool(
    name: str, 
    arguments: dict | None
) -> list[types.TextContent]:
    """Handle tool calls with proper error handling."""
    logger.info(f"Tool called: {name} with args: {arguments}")
    
    if not arguments:
        arguments = {}

    try:
        if name == "test-connection":
            return await test_screenpipe_connection()
        elif name == "get-health":
            return await get_screenpipe_health()
        elif name == "search-content":
            return await search_screenpipe_content(arguments)
        else:
            logger.warning(f"Unknown tool: {name}")
            return [types.TextContent(
                type="text",
                text=f"Unknown tool: {name}"
            )]
    except Exception as e:
        logger.error(f"Error in tool {name}: {e}")
        return [types.TextContent(
            type="text",
            text=f"Error executing {name}: {str(e)}"
        )]

async def test_screenpipe_connection() -> list[types.TextContent]:
    """Test connection to Screenpipe."""
    try:
        timeout = httpx.Timeout(5.0)
        async with httpx.AsyncClient(timeout=timeout) as client:
            response = await client.get(f"{SCREENPIPE_API}/health")
            
            if response.status_code == 200:
                logger.info("Successfully connected to Screenpipe")
                return [types.TextContent(
                    type="text",
                    text="✅ Successfully connected to Screenpipe API"
                )]
            else:
                logger.warning(f"Screenpipe returned status {response.status_code}")
                return [types.TextContent(
                    type="text",
                    text=f"⚠️ Screenpipe API returned status {response.status_code}"
                )]
    except httpx.ConnectError:
        logger.error("Failed to connect to Screenpipe - connection refused")
        return [types.TextContent(
            type="text",
            text="❌ Cannot connect to Screenpipe - is it running on localhost:3030?"
        )]
    except httpx.TimeoutException:
        logger.error("Screenpipe connection timed out")
        return [types.TextContent(
            type="text",
            text="❌ Screenpipe connection timed out"
        )]
    except Exception as e:
        logger.error(f"Unexpected error connecting to Screenpipe: {e}")
        return [types.TextContent(
            type="text",
            text=f"❌ Failed to connect to Screenpipe: {str(e)}"
        )]

async def get_screenpipe_health() -> list[types.TextContent]:
    """Get Screenpipe health status."""
    try:
        timeout = httpx.Timeout(10.0)
        async with httpx.AsyncClient(timeout=timeout) as client:
            response = await client.get(f"{SCREENPIPE_API}/health")
            
            if response.status_code == 200:
                data = response.json()
                health_info = json.dumps(data, indent=2)
                logger.info("Retrieved Screenpipe health status")
                return [types.TextContent(
                    type="text",
                    text=f"📊 Screenpipe Health Status:\n\n```json\n{health_info}\n```"
                )]
            else:
                return [types.TextContent(
                    type="text",
                    text=f"❌ Health check failed with status {response.status_code}"
                )]
    except Exception as e:
        logger.error(f"Health check error: {e}")
        return [types.TextContent(
            type="text",
            text=f"❌ Health check error: {str(e)}"
        )]

async def search_screenpipe_content(arguments: dict) -> list[types.TextContent]:
    """Search Screenpipe content."""
    try:
        query = arguments.get("q", "")
        limit = arguments.get("limit", 10)
        content_type = arguments.get("content_type", "all")
        
        logger.info(f"Searching for: '{query}' (limit: {limit}, type: {content_type})")
        
        params = {
            "q": query,
            "limit": min(limit, 50)  # Cap at 50 for performance
        }
        
        if content_type != "all":
            params["content_type"] = content_type
        
        timeout = httpx.Timeout(15.0)
        async with httpx.AsyncClient(timeout=timeout) as client:
            response = await client.get(
                f"{SCREENPIPE_API}/search",
                params=params
            )
            
            if response.status_code == 200:
                data = response.json()
                results = data.get("data", [])
                total = data.get("pagination", {}).get("total", len(results))
                
                logger.info(f"Search returned {len(results)} results (total: {total})")
                
                if not results:
                    return [types.TextContent(
                        type="text",
                        text=f"No results found for query: '{query}'"
                    )]
                
                # Format results
                formatted = f"🔍 Found {len(results)} results (total: {total}) for '{query}':\n\n"
                
                for i, result in enumerate(results[:10], 1):  # Show max 10
                    try:
                        content = result.get("content", {})
                        text = content.get("text", "N/A")
                        app = content.get("app_name", "Unknown")
                        timestamp = content.get("timestamp", "Unknown")
                        
                        # Truncate long text
                        if len(text) > 150:
                            text = text[:150] + "..."
                        
                        formatted += f"{i}. **{app}** - {timestamp}\n"
                        formatted += f"   {text}\n\n"
                        
                    except Exception as e:
                        logger.warning(f"Error formatting result {i}: {e}")
                        continue
                
                if len(results) > 10:
                    formatted += f"... and {len(results) - 10} more results\n"
                
                return [types.TextContent(
                    type="text",
                    text=formatted
                )]
            else:
                logger.error(f"Search failed with status {response.status_code}")
                return [types.TextContent(
                    type="text",
                    text=f"❌ Search failed with status {response.status_code}"
                )]
                
    except Exception as e:
        logger.error(f"Search error: {e}")
        return [types.TextContent(
            type="text",
            text=f"❌ Search error: {str(e)}"
        )]

async def main():
    """Main entry point with proper error handling."""
    logger.info("Starting MCP server")
    
    try:
        async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
            logger.info("Server streams established")
            
            await server.run(
                read_stream,
                write_stream,
                InitializationOptions(
                    server_name="screenpipe-strategy",
                    server_version="1.0.0",
                    capabilities=server.get_capabilities(),
                ),
            )
    except Exception as e:
        logger.error(f"Server error: {e}")
        print(f"Server error: {e}", file=sys.stderr)
        raise

if __name__ == "__main__":
    try:
        # Set up asyncio with proper error handling
        if sys.platform == 'win32':
            asyncio.set_event_loop_policy(asyncio.WindowsProactorEventLoopPolicy())
        
        logger.info("Launching MCP server")
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Server stopped by user")
    except Exception as e:
        logger.error(f"Fatal error: {e}")
        print(f"Fatal error: {e}", file=sys.stderr)
        sys.exit(1)
