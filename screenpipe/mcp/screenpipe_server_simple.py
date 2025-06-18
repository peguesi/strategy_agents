#!/usr/bin/env python3
"""
Simplified Screenpipe MCP Server for Strategy Agents
Minimal version to resolve Claude Desktop integration issues
"""

import asyncio
import json
import sys
import os
from pathlib import Path

# Add error handling for imports
try:
    import mcp.server.stdio
    import mcp.types as types
    from mcp.server import Server
    from mcp.server.models import InitializationOptions
except ImportError as e:
    print(f"MCP import error: {e}", file=sys.stderr)
    print("Install with: pip3 install mcp", file=sys.stderr)
    sys.exit(1)

try:
    import httpx
except ImportError as e:
    print(f"httpx import error: {e}", file=sys.stderr)
    print("Install with: pip3 install httpx", file=sys.stderr)
    sys.exit(1)

# Initialize server
server = Server("screenpipe-strategy")

# Constants
SCREENPIPE_API = "http://localhost:3030"

@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    """List available tools."""
    return [
        types.Tool(
            name="search-content",
            description="Search through screenpipe recorded content",
            inputSchema={
                "type": "object",
                "properties": {
                    "q": {
                        "type": "string",
                        "description": "Search query",
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Maximum results",
                        "default": 10
                    }
                }
            },
        ),
        types.Tool(
            name="test-connection",
            description="Test the connection to Screenpipe",
            inputSchema={
                "type": "object",
                "properties": {}
            }
        )
    ]

@server.call_tool()
async def handle_call_tool(
    name: str, 
    arguments: dict | None
) -> list[types.TextContent]:
    """Handle tool calls."""
    if not arguments:
        arguments = {}

    if name == "test-connection":
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(f"{SCREENPIPE_API}/health", timeout=5.0)
                if response.status_code == 200:
                    return [types.TextContent(
                        type="text",
                        text="✅ Successfully connected to Screenpipe API"
                    )]
                else:
                    return [types.TextContent(
                        type="text",
                        text=f"❌ Screenpipe API returned status {response.status_code}"
                    )]
        except Exception as e:
            return [types.TextContent(
                type="text",
                text=f"❌ Failed to connect to Screenpipe: {str(e)}"
            )]

    elif name == "search-content":
        try:
            async with httpx.AsyncClient() as client:
                params = {
                    "q": arguments.get("q", ""),
                    "limit": arguments.get("limit", 10)
                }
                
                response = await client.get(
                    f"{SCREENPIPE_API}/search",
                    params=params,
                    timeout=10.0
                )
                
                if response.status_code == 200:
                    data = response.json()
                    results = data.get("data", [])
                    
                    if not results:
                        return [types.TextContent(
                            type="text",
                            text="No results found"
                        )]
                    
                    # Format results simply
                    formatted = f"Found {len(results)} results:\n\n"
                    for i, result in enumerate(results[:5], 1):
                        content = result.get("content", {})
                        text = content.get("text", "N/A")[:100]
                        app = content.get("app_name", "Unknown")
                        time = content.get("timestamp", "Unknown")
                        formatted += f"{i}. {app} - {time}\n   {text}...\n\n"
                    
                    return [types.TextContent(
                        type="text",
                        text=formatted
                    )]
                else:
                    return [types.TextContent(
                        type="text",
                        text=f"Search failed with status {response.status_code}"
                    )]
                    
        except Exception as e:
            return [types.TextContent(
                type="text",
                text=f"Search error: {str(e)}"
            )]
    
    else:
        return [types.TextContent(
            type="text",
            text=f"Unknown tool: {name}"
        )]

async def main():
    """Main entry point."""
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name="screenpipe-strategy",
                server_version="1.0.0",
                capabilities=server.get_capabilities(),
            ),
        )

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except Exception as e:
        print(f"Server error: {e}", file=sys.stderr)
        sys.exit(1)
