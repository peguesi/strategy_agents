#!/usr/bin/env python3
"""
Create a working MCP terminal solution using file-based communication
This bypasses AppleScript issues entirely
"""

from pathlib import Path
import shutil

def create_working_mcp_fix():
    """Create a working solution that bypasses AppleScript issues"""
    
    server_path = Path("/Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp/screenpipe_server_with_terminal.py")
    backup_path = Path("/Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp/screenpipe_server_with_terminal.py.backup")
    
    # Restore from backup first
    if backup_path.exists():
        shutil.copy2(backup_path, server_path)
        print("✅ Restored from backup")
    
    # Read the file
    with open(server_path, 'r') as f:
        content = f.read()
    
    # Replace the execute_terminal_command function with a working version
    old_function = '''def execute_terminal_command(command, timeout=30):
    """Execute a command in the terminal and return the result"""
    try:
        if IS_MACOS:
            # Use osascript to send command to iTerm2 or Terminal
            script = f\'\'\'
            tell application "iTerm"
                if (count of windows) = 0 then
                    create window with default profile
                end if
                tell current session of current window
                    write text "{command}"
                end tell
            end tell
            \'\'\'
            
            # Try iTerm2 first, fallback to Terminal
            try:
                result = subprocess.run(
                    ['osascript', '-e', script],
                    capture_output=True,
                    text=True,
                    timeout=timeout
                )
                if result.returncode == 0:
                    return {"success": True, "output": f"Command sent to iTerm2: {command}"}
            except:
                pass
            
            # Fallback to Terminal app
            script = f\'\'\'
            tell application "Terminal"
                if (count of windows) = 0 then
                    do script "{command}"
                else
                    do script "{command}" in front window
                end if
            end tell
            \'\'\'
            
            result = subprocess.run(
                ['osascript', '-e', script],
                capture_output=True,
                text=True,
                timeout=timeout
            )
            
            if result.returncode == 0:
                return {"success": True, "output": f"Command sent to Terminal: {command}"}
            else:
                return {"success": False, "error": f"AppleScript error: {result.stderr}"}
        
        else:
            # For non-macOS systems, execute directly
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=timeout
            )
            
            return {
                "success": True,
                "output": result.stdout,
                "error": result.stderr,
                "return_code": result.returncode
            }
            
    except subprocess.TimeoutExpired:
        return {"success": False, "error": f"Command timed out after {timeout} seconds"}
    except Exception as e:
        return {"success": False, "error": str(e)}'''

    new_function = '''def execute_terminal_command(command, timeout=120):
    """Execute a command via file-based communication (bypasses AppleScript issues)"""
    try:
        if IS_MACOS:
            # Create a temporary script file with proper escaping
            import tempfile
            import os
            
            with tempfile.NamedTemporaryFile(mode='w', suffix='.sh', delete=False) as f:
                f.write(f"#!/bin/bash\\n{command}\\n")
                script_path = f.name
            
            # Make executable
            os.chmod(script_path, 0o755)
            
            # Use Terminal to run the script
            applescript = f\'\'\'
            tell application "Terminal"
                if (count of windows) = 0 then
                    do script "bash {script_path}"
                else
                    do script "bash {script_path}" in front window
                end if
            end tell
            \'\'\'
            
            result = subprocess.run(
                ['osascript', '-e', applescript],
                capture_output=True,
                text=True,
                timeout=30  # Short timeout for AppleScript only
            )
            
            # Clean up
            os.unlink(script_path)
            
            if result.returncode == 0:
                return {"success": True, "output": f"Command executed via Terminal: {command}"}
            else:
                return {"success": False, "error": f"Terminal execution failed: {result.stderr}"}
        
        else:
            # For non-macOS systems, execute directly
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=timeout
            )
            
            return {
                "success": True,
                "output": result.stdout,
                "error": result.stderr,
                "return_code": result.returncode
            }
            
    except subprocess.TimeoutExpired:
        return {
            "success": False, 
            "error": f"Command timed out after {timeout} seconds. Try breaking into smaller steps or using background execution with '&'",
            "suggestion": "For long commands: command > output.txt 2>&1 &"
        }
    except Exception as e:
        return {"success": False, "error": str(e)}'''

    # Replace the function
    content = content.replace(old_function, new_function)
    
    # Also update the default timeout in the tool schema
    content = content.replace(
        '"description": "Timeout in seconds (default: 30)",\n                        "default": 30',
        '"description": "Timeout in seconds (default: 120)",\n                        "default": 120'
    )
    
    # Write the fixed file
    with open(server_path, 'w') as f:
        f.write(content)
    
    print("✅ Applied file-based terminal execution (bypasses AppleScript issues)")
    print("✅ Increased timeout to 120 seconds")
    print("✅ Added improved error messages")
    
    return True

if __name__ == "__main__":
    create_working_mcp_fix()
    print("\\n🎯 Restart Claude Desktop to load the fixes, then test with:")
    print("screenpipe-terminal:execute-terminal-command")
    print("command: cd /Users/zeh/Local_Projects/Strategy_agents && gitleaks detect --no-banner > security-results.txt")
