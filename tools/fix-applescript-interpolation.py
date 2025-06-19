#!/usr/bin/env python3
"""
Fix the AppleScript interpolation issue in the MCP server
"""

from pathlib import Path

def fix_applescript_interpolation():
    """Fix the AppleScript string interpolation"""
    
    server_path = Path("/Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp/screenpipe_server_with_terminal.py")
    
    with open(server_path, 'r') as f:
        content = f.read()
    
    # Fix the broken string interpolation
    old_broken = 'write text "{escape_applescript_string(command)}"'
    
    # Replace with proper variable escaping approach
    fixed_content = content.replace(
        'script = f\'\'\'',
        'escaped_command = escape_applescript_string(command)\n            script = f\'\'\''
    ).replace(
        old_broken,
        'write text "{escaped_command}"'
    )
    
    # Also fix the Terminal fallback script
    fixed_content = fixed_content.replace(
        'do script "{command}"',
        'do script "{escaped_command}"'
    )
    
    with open(server_path, 'w') as f:
        f.write(fixed_content)
    
    print("✅ Fixed AppleScript string interpolation")

if __name__ == "__main__":
    fix_applescript_interpolation()
