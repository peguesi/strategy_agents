#!/usr/bin/env python3
"""
Enhanced Screenpipe MCP Server for Strategy Agents
Comprehensive MCP server with Screenpipe integration, cross-platform support, and Strategy Agents features
"""

import asyncio
import httpx
import nest_asyncio
from mcp.server import NotificationOptions, Server
from mcp.server.models import InitializationOptions
import mcp.types as types
import mcp.server.stdio
import argparse
import json
import platform
import sys
import os
from pathlib import Path
from datetime import datetime, timedelta
import logging

# Enable nested event loops (needed for some environments)
nest_asyncio.apply()

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Detect OS
CURRENT_OS = platform.system()
IS_MACOS = CURRENT_OS == "Darwin"
IS_WINDOWS = CURRENT_OS == "Windows"
IS_LINUX = CURRENT_OS == "Linux"

# Parse command line arguments
parser = argparse.ArgumentParser(description='Screenpipe MCP Server for Strategy Agents')
parser.add_argument('--port', type=int, default=3030, help='Port number for the screenpipe API (default: 3030)')
parser.add_argument('--data-dir', type=str, help='Directory for screenpipe data storage')
args = parser.parse_args()

# Initialize server
server = Server("screenpipe-strategy")

# Constants
SCREENPIPE_API = f"http://localhost:{args.port}"

# Set up paths
base_path = Path(__file__).parent.parent
data_path = Path(args.data_dir) if args.data_dir else base_path / "data"
logs_path = base_path / "logs"

# Ensure directories exist
data_path.mkdir(exist_ok=True)
logs_path.mkdir(exist_ok=True)

def log_to_file(message):
    """Log messages to our MCP log file"""
    log_file = logs_path / "mcp_server.log"
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_file, "a") as f:
        f.write(f"[{timestamp}] {message}\n")

@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    """List available search tools for screenpipe with Strategy Agents enhancements."""
    
    # Core screenpipe tools
    tools = [
        types.Tool(
            name="search-content",
            description=(
                "Search through screenpipe recorded content (OCR text, audio transcriptions, UI elements). "
                "Use this to find specific content that has appeared on your screen or been spoken. "
                "Results include timestamps, app context, and the content itself."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "q": {
                        "type": "string",
                        "description": "Search query to find in recorded content",
                    },
                    "content_type": {
                        "type": "string",
                        "enum": ["all","ocr", "audio","ui"],
                        "description": "Type of content to search: 'ocr' for screen text, 'audio' for spoken words, 'ui' for UI elements, or 'all' for everything",
                        "default": "all"
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Maximum number of results to return",
                        "default": 10
                    },
                    "offset": {
                        "type": "integer",
                        "description": "Number of results to skip (for pagination)",
                        "default": 0
                    },
                    "start_time": {
                        "type": "string",
                        "format": "date-time",
                        "description": "Start time in ISO format UTC (e.g. 2024-01-01T00:00:00Z). Filter results from this time onward."
                    },
                    "end_time": {
                        "type": "string",
                        "format": "date-time",
                        "description": "End time in ISO format UTC (e.g. 2024-01-01T00:00:00Z). Filter results up to this time."
                    },
                    "app_name": {
                        "type": "string",
                        "description": "Filter by application name (e.g. 'Chrome', 'Safari', 'Terminal')"
                    },
                    "window_name": {
                        "type": "string",
                        "description": "Filter by window name or title"
                    },
                    "min_length": {
                        "type": "integer",
                        "description": "Minimum content length in characters"
                    },
                    "max_length": {
                        "type": "integer",
                        "description": "Maximum content length in characters"
                    }
                }
            },
        ),
        
        # Strategy Agents specific tools
        types.Tool(
            name="analyze-productivity",
            description=(
                "Analyze productivity patterns from screenpipe data. "
                "Returns insights about app usage, focus time, interruptions, and work patterns."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "hours_back": {
                        "type": "integer",
                        "description": "Number of hours to analyze (default: 8)",
                        "default": 8
                    },
                    "focus_apps": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "List of apps considered as 'focus work' (e.g. ['VSCode', 'Terminal', 'Linear'])",
                        "default": ["VSCode", "Code", "Terminal", "Linear", "Notion"]
                    }
                }
            }
        ),
        
        types.Tool(
            name="find-coding-sessions",
            description=(
                "Find recent coding or development work sessions based on screen activity. "
                "Identifies VS Code usage, terminal commands, Git activity, etc."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "hours_back": {
                        "type": "integer",
                        "description": "Number of hours to look back (default: 24)",
                        "default": 24
                    },
                    "language": {
                        "type": "string",
                        "description": "Programming language to focus on (optional)"
                    },
                    "project": {
                        "type": "string", 
                        "description": "Project name or path to focus on (optional)"
                    }
                }
            }
        ),
        
        types.Tool(
            name="export-daily-summary",
            description=(
                "Export a comprehensive daily summary of activities to data directory. "
                "Includes productivity metrics, app usage, and key activities."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "date": {
                        "type": "string",
                        "description": "Date to export (YYYY-MM-DD format, default: today)"
                    },
                    "format": {
                        "type": "string",
                        "enum": ["json", "markdown", "csv"],
                        "description": "Export format",
                        "default": "json"
                    }
                }
            }
        ),
        
        # Cross-platform control tools
        types.Tool(
            name="pixel-control",
            description=(
                "Control mouse and keyboard at the pixel level. This is a cross-platform tool that works on all operating systems. "
                "Use this to type text, press keys, move the mouse, and click buttons."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "action_type": {
                        "type": "string",
                        "enum": ["WriteText", "KeyPress", "MouseMove", "MouseClick"],
                        "description": "Type of input action to perform",
                    },
                    "data": {
                        "oneOf": [
                            {
                                "type": "string",
                                "description": "Text to type or key to press (for WriteText and KeyPress)",
                            },
                            {
                                "type": "object",
                                "properties": {
                                    "x": {"type": "integer", "description": "X coordinate for mouse movement"},
                                    "y": {"type": "integer", "description": "Y coordinate for mouse movement"},
                                },
                                "description": "Coordinates for MouseMove",
                            },
                            {
                                "type": "string",
                                "enum": ["left", "right", "middle"],
                                "description": "Button to click for MouseClick",
                            },
                        ],
                        "description": "Action-specific data",
                    },
                },
                "required": ["action_type", "data"]
            },
        ),
    ]
    
    # Add MacOS-specific tools only if running on MacOS
    if IS_MACOS:
        macos_tools = [
            types.Tool(
                name="find-elements",
                description=(
                    "Find UI elements with a specific role in an application. "
                    "This tool is especially useful for identifying interactive elements."
                ),
                inputSchema={
                    "type": "object",
                    "properties": {
                        "app": {
                            "type": "string",
                            "description": "The name of the application (e.g., 'Chrome', 'Finder', 'Terminal')"
                        },
                        "role": {
                            "type": "string",
                            "description": "The role to search for (e.g., 'button', 'textfield', 'AXButton', 'AXTextField')"
                        },
                        "max_results": {
                            "type": "integer",
                            "description": "Maximum number of elements to return",
                            "default": 10
                        }
                    },
                    "required": ["app", "role"]
                }
            ),
            types.Tool(
                name="open-application",
                description="Open an application by name",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "app_name": {
                            "type": "string",
                            "description": "The name of the application to open"
                        }
                    },
                    "required": ["app_name"]
                }
            ),
            types.Tool(
                name="open-url",
                description="Open a URL in a browser",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "url": {
                            "type": "string",
                            "description": "The URL to open"
                        },
                        "browser": {
                            "type": "string",
                            "description": "The browser to use (optional)"
                        }
                    },
                    "required": ["url"]
                }
            ),
        ]
        tools.extend(macos_tools)
    
    return tools

@server.call_tool()
async def handle_call_tool(
    name: str, 
    arguments: dict | None
) -> list[types.TextContent | types.ImageContent | types.EmbeddedResource]:
    """Handle tool execution requests."""
    if not arguments:
        arguments = {}

    log_to_file(f"Tool called: {name} with args: {arguments}")

    # Check if the tool is MacOS-only and we're not on MacOS
    macos_only_tools = ["find-elements", "open-application", "open-url"]
    
    if name in macos_only_tools and not IS_MACOS:
        return [types.TextContent(
            type="text",
            text=f"the '{name}' tool is only available on MacOS. current platform: {CURRENT_OS}"
        )]

    if name == "search-content":
        async with httpx.AsyncClient() as client:
            try:
                # Build query parameters
                params = {k: v for k, v in arguments.items() if v is not None}        
                
                response = await client.get(
                    f"{SCREENPIPE_API}/search",
                    params=params,
                    timeout=30.0
                )
                response.raise_for_status()
                
                try:
                    data = json.loads(response.text)
                except json.JSONDecodeError as json_error:
                    return [types.TextContent(
                        type="text",
                        text=f"failed to parse JSON response: {json_error}"
                    )]
                
                results = data.get("data", [])
                    
            except Exception as e:
                log_to_file(f"Search error: {str(e)}")
                return [types.TextContent(
                    type="text",
                    text=f"failed to search screenpipe: {str(e)}"
                )]
                    
            # Format results
            if not results:
                return [types.TextContent(
                    type="text", 
                    text="no results found"
                )]

            # Format each result based on content type
            formatted_results = []
            for result in results:
                if "content" not in result:
                    continue
                
                content = result["content"]
                if result.get("type") == "OCR":
                    text = (
                        f"OCR Text: {content.get('text', 'N/A')}\n"
                        f"App: {content.get('app_name', 'N/A')}\n"
                        f"Window: {content.get('window_name', 'N/A')}\n"
                        f"Time: {content.get('timestamp', 'N/A')}\n"
                        "---\n"
                    )
                elif result.get("type") == "Audio":
                    text = (
                        f"Audio Transcription: {content.get('transcription', 'N/A')}\n"
                        f"Device: {content.get('device_name', 'N/A')}\n"
                        f"Time: {content.get('timestamp', 'N/A')}\n"
                        "---\n"
                    )
                elif result.get("type") == "UI":
                    text = (
                        f"UI Text: {content.get('text', 'N/A')}\n"
                        f"App: {content.get('app_name', 'N/A')}\n"
                        f"Window: {content.get('window_name', 'N/A')}\n"
                        f"Time: {content.get('timestamp', 'N/A')}\n"
                        "---\n"
                    )
                else:
                    continue
                
                formatted_results.append(text)
                
            return [types.TextContent(
                type="text",
                text="Search Results:\n\n" + "\n".join(formatted_results)
            )]
    
    elif name == "analyze-productivity":
        try:
            hours_back = arguments.get("hours_back", 8)
            focus_apps = arguments.get("focus_apps", ["VSCode", "Code", "Terminal", "Linear", "Notion"])
            
            # Calculate time range
            end_time = datetime.now()
            start_time = end_time - timedelta(hours=hours_back)
            
            async with httpx.AsyncClient() as client:
                # Get all OCR data for the time period
                response = await client.get(
                    f"{SCREENPIPE_API}/search",
                    params={
                        "content_type": "ocr",
                        "start_time": start_time.isoformat() + "Z",
                        "end_time": end_time.isoformat() + "Z",
                        "limit": 1000
                    },
                    timeout=30.0
                )
                response.raise_for_status()
                data = response.json()
                results = data.get("data", [])
                
                # Analyze productivity patterns
                app_usage = {}
                focus_time = 0
                total_time = 0
                
                for result in results:
                    content = result.get("content", {})
                    app_name = content.get("app_name", "Unknown")
                    
                    if app_name not in app_usage:
                        app_usage[app_name] = 0
                    app_usage[app_name] += 1
                    
                    if app_name in focus_apps:
                        focus_time += 1
                    total_time += 1
                
                # Calculate focus percentage
                focus_percentage = (focus_time / total_time * 100) if total_time > 0 else 0
                
                # Sort apps by usage
                sorted_apps = sorted(app_usage.items(), key=lambda x: x[1], reverse=True)
                
                # Generate insights
                insights = f"""Productivity Analysis ({hours_back} hours):

Focus Time: {focus_percentage:.1f}% ({focus_time}/{total_time} activities)

Top Applications:
"""
                for app, count in sorted_apps[:10]:
                    percentage = (count / total_time * 100) if total_time > 0 else 0
                    focus_indicator = "🎯" if app in focus_apps else "📱"
                    insights += f"{focus_indicator} {app}: {count} activities ({percentage:.1f}%)\n"
                
                insights += f"\nData points analyzed: {total_time}"
                
                return [types.TextContent(
                    type="text",
                    text=insights
                )]
                
        except Exception as e:
            log_to_file(f"Productivity analysis error: {str(e)}")
            return [types.TextContent(
                type="text",
                text=f"failed to analyze productivity: {str(e)}"
            )]
    
    elif name == "find-coding-sessions":
        try:
            hours_back = arguments.get("hours_back", 24)
            language = arguments.get("language")
            project = arguments.get("project")
            
            # Calculate time range
            end_time = datetime.now()
            start_time = end_time - timedelta(hours=hours_back)
            
            async with httpx.AsyncClient() as client:
                # Search for coding-related content
                search_params = {
                    "start_time": start_time.isoformat() + "Z",
                    "end_time": end_time.isoformat() + "Z",
                    "limit": 500
                }
                
                # Add app filter for coding apps
                coding_apps = ["VSCode", "Code", "Terminal", "iTerm", "Xcode", "IntelliJ", "PyCharm"]
                
                coding_sessions = []
                
                for app in coding_apps:
                    search_params["app_name"] = app
                    response = await client.get(
                        f"{SCREENPIPE_API}/search",
                        params=search_params,
                        timeout=30.0
                    )
                    if response.status_code == 200:
                        data = response.json()
                        results = data.get("data", [])
                        
                        for result in results:
                            content = result.get("content", {})
                            text = content.get("text", "")
                            
                            # Filter by language if specified
                            if language and language.lower() not in text.lower():
                                continue
                            
                            # Filter by project if specified  
                            if project and project.lower() not in text.lower():
                                continue
                            
                            coding_sessions.append({
                                "app": app,
                                "time": content.get("timestamp", ""),
                                "text": text[:100] + "..." if len(text) > 100 else text,
                                "window": content.get("window_name", "")
                            })
                
                # Sort by time
                coding_sessions.sort(key=lambda x: x["time"], reverse=True)
                
                if not coding_sessions:
                    return [types.TextContent(
                        type="text",
                        text=f"No coding sessions found in the last {hours_back} hours"
                    )]
                
                # Generate summary
                summary = f"Found {len(coding_sessions)} coding activities in the last {hours_back} hours:\n\n"
                
                for i, session in enumerate(coding_sessions[:20], 1):
                    try:
                        dt = datetime.fromisoformat(session["time"].replace("Z", "+00:00"))
                        time_str = dt.strftime("%m/%d %H:%M")
                    except:
                        time_str = session["time"][:16]
                    
                    summary += f"{i}. {session['app']} - {time_str}\n"
                    summary += f"   Window: {session['window']}\n"
                    summary += f"   Content: {session['text']}\n\n"
                
                if len(coding_sessions) > 20:
                    summary += f"... and {len(coding_sessions) - 20} more sessions"
                
                return [types.TextContent(
                    type="text",
                    text=summary
                )]
                
        except Exception as e:
            log_to_file(f"Coding sessions error: {str(e)}")
            return [types.TextContent(
                type="text",
                text=f"failed to find coding sessions: {str(e)}"
            )]
    
    elif name == "export-daily-summary":
        try:
            date_str = arguments.get("date", datetime.now().strftime("%Y-%m-%d"))
            format_type = arguments.get("format", "json")
            
            # Parse date
            target_date = datetime.strptime(date_str, "%Y-%m-%d")
            start_time = target_date.replace(hour=0, minute=0, second=0)
            end_time = target_date.replace(hour=23, minute=59, second=59)
            
            async with httpx.AsyncClient() as client:
                # Get all data for the day
                response = await client.get(
                    f"{SCREENPIPE_API}/search",
                    params={
                        "start_time": start_time.isoformat() + "Z",
                        "end_time": end_time.isoformat() + "Z",
                        "limit": 2000
                    },
                    timeout=30.0
                )
                response.raise_for_status()
                data = response.json()
                results = data.get("data", [])
                
                # Process data
                summary_data = {
                    "date": date_str,
                    "total_activities": len(results),
                    "apps": {},
                    "hourly_activity": {},
                    "content_types": {"ocr": 0, "audio": 0, "ui": 0}
                }
                
                for result in results:
                    content = result.get("content", {})
                    app_name = content.get("app_name", "Unknown")
                    timestamp = content.get("timestamp", "")
                    content_type = result.get("type", "").lower()
                    
                    # Count apps
                    if app_name not in summary_data["apps"]:
                        summary_data["apps"][app_name] = 0
                    summary_data["apps"][app_name] += 1
                    
                    # Count content types
                    if content_type in summary_data["content_types"]:
                        summary_data["content_types"][content_type] += 1
                    
                    # Count hourly activity
                    try:
                        dt = datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
                        hour = dt.hour
                        if hour not in summary_data["hourly_activity"]:
                            summary_data["hourly_activity"][hour] = 0
                        summary_data["hourly_activity"][hour] += 1
                    except:
                        pass
                
                # Save to file
                filename = f"daily_summary_{date_str}.{format_type}"
                filepath = data_path / filename
                
                if format_type == "json":
                    with open(filepath, "w") as f:
                        json.dump(summary_data, f, indent=2)
                elif format_type == "markdown":
                    with open(filepath, "w") as f:
                        f.write(f"# Daily Summary - {date_str}\n\n")
                        f.write(f"**Total Activities:** {summary_data['total_activities']}\n\n")
                        f.write("## Top Applications\n")
                        for app, count in sorted(summary_data['apps'].items(), key=lambda x: x[1], reverse=True)[:10]:
                            f.write(f"- {app}: {count}\n")
                        f.write("\n## Hourly Activity\n")
                        for hour in sorted(summary_data['hourly_activity'].keys()):
                            f.write(f"- {hour:02d}:00: {summary_data['hourly_activity'][hour]}\n")
                
                log_to_file(f"Exported daily summary to {filepath}")
                
                return [types.TextContent(
                    type="text",
                    text=f"Daily summary exported to {filepath}\n\nSummary:\n- Total activities: {summary_data['total_activities']}\n- Apps used: {len(summary_data['apps'])}\n- Most active hour: {max(summary_data['hourly_activity'], key=summary_data['hourly_activity'].get) if summary_data['hourly_activity'] else 'N/A'}"
                )]
                
        except Exception as e:
            log_to_file(f"Export error: {str(e)}")
            return [types.TextContent(
                type="text",
                text=f"failed to export daily summary: {str(e)}"
            )]
    
    elif name == "pixel-control":
        async with httpx.AsyncClient() as client:
            try:
                action = {
                    "type": arguments.get("action_type"),
                    "data": arguments.get("data")
                }
                
                response = await client.post(
                    f"{SCREENPIPE_API}/experimental/operator/pixel",
                    json={"action": action},
                    timeout=10.0
                )
                response.raise_for_status()
                data = response.json()
                
                if not data.get("success", False):
                    return [types.TextContent(
                        type="text",
                        text=f"failed to perform input control: {data.get('error', 'unknown error')}"
                    )]
                
                action_type = arguments.get("action_type")
                action_data = arguments.get("data")
                
                if action_type == "WriteText":
                    result_text = f"successfully typed text: '{action_data}'"
                elif action_type == "KeyPress":
                    result_text = f"successfully pressed key: '{action_data}'"
                elif action_type == "MouseMove":
                    result_text = f"successfully moved mouse to coordinates: x={action_data.get('x')}, y={action_data.get('y')}"
                elif action_type == "MouseClick":
                    result_text = f"successfully clicked {action_data} mouse button"
                else:
                    result_text = "successfully performed input control action"
                
                return [types.TextContent(
                    type="text",
                    text=result_text
                )]
                
            except Exception as e:
                return [types.TextContent(
                    type="text",
                    text=f"failed to perform input control: {str(e)}"
                )]
    
    else:
        raise ValueError(f"unknown tool: {name}")

async def run():
    """Run the MCP server."""
    log_to_file("Starting Screenpipe MCP Server for Strategy Agents")
    
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name="screenpipe-strategy",
                server_version="1.0.0",
                capabilities=server.get_capabilities(
                    notification_options=NotificationOptions(),
                    experimental_capabilities={},
                ),
            ),
        )

if __name__ == "__main__":
    asyncio.run(run())
