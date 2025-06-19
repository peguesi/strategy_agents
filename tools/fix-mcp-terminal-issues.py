#!/usr/bin/env python3
"""
Fix Strategy Agents MCP Terminal Issues
Addresses timeout and AppleScript parsing problems
"""

import shutil
from pathlib import Path

def fix_mcp_server():
    """Apply fixes to the MCP server"""
    
    server_path = Path("/Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp/screenpipe_server_with_terminal.py")
    backup_path = Path("/Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp/screenpipe_server_with_terminal.py.backup")
    
    # Create backup
    shutil.copy2(server_path, backup_path)
    print(f"✅ Created backup: {backup_path}")
    
    # Read current file
    with open(server_path, 'r') as f:
        content = f.read()
    
    # Fix 1: Increase timeout from 30 to 120 seconds
    content = content.replace(
        'def execute_terminal_command(command, timeout=30):',
        'def execute_terminal_command(command, timeout=120):'
    )
    
    # Fix 2: Add escaping function
    escape_function = '''def escape_applescript_string(text):
    """Properly escape strings for AppleScript"""
    text = text.replace('\\\\', '\\\\\\\\')
    text = text.replace('"', '\\\\"')
    text = text.replace("'", "\\\\'")
    return text

'''
    
    # Insert before execute_terminal_command function
    content = content.replace(
        'def execute_terminal_command(command, timeout=120):',
        escape_function + 'def execute_terminal_command(command, timeout=120):'
    )
    
    # Fix 3: Update AppleScript command injection
    old_pattern = r'write text "{command}"'
    new_pattern = 'write text "' + '{escape_applescript_string(command)}' + '"'
    content = content.replace(old_pattern, new_pattern)
    
    # Fix 4: Improve timeout error message
    old_timeout_msg = 'return {"success": False, "error": f"Command timed out after {timeout} seconds"}'
    new_timeout_msg = '''return {
        "success": False, 
        "error": f"Command timed out after {timeout} seconds. Try: 1) Breaking into smaller steps, 2) Using '&' for background processes, 3) Writing output to file",
        "suggestion": "For long commands, consider: command > output.txt 2>&1 &"
    }'''
    content = content.replace(old_timeout_msg, new_timeout_msg)
    
    # Write fixed file
    with open(server_path, 'w') as f:
        f.write(content)
    
    print("✅ Applied timeout fix (30s → 120s)")
    print("✅ Added AppleScript string escaping")
    print("✅ Improved error messages")
    print("✅ MCP server fixes complete")
    
    return True

def test_fixes():
    """Test that the fixes work"""
    print("\n🧪 Testing fixes...")
    
    # Test 1: Check if file was modified correctly
    server_path = Path("/Users/zeh/Local_Projects/Strategy_agents/screenpipe/mcp/screenpipe_server_with_terminal.py")
    with open(server_path, 'r') as f:
        content = f.read()
    
    if 'timeout=120' in content:
        print("✅ Timeout increased to 120 seconds")
    else:
        print("❌ Timeout fix not applied")
        
    if 'escape_applescript_string' in content:
        print("✅ AppleScript escaping function added")
    else:
        print("❌ AppleScript escaping not added")
        
    if 'suggestion' in content:
        print("✅ Improved error messages added")
    else:
        print("❌ Error message improvements not applied")

def create_test_script():
    """Create a test script to verify the fixes work"""
    
    test_script = '''#!/bin/bash
# Test script for Strategy Agents MCP fixes
echo "Testing MCP terminal fixes..."

# Test 1: Simple command that should work quickly
echo "Test 1: Simple command"
echo "ls -la" > /tmp/mcp_test_simple.sh

# Test 2: Command with quotes (was breaking AppleScript)
echo "Test 2: Command with quotes"
echo 'find . -name "*.py" -type f | head -5' > /tmp/mcp_test_quotes.sh

# Test 3: Command that outputs to file (for longer operations)
echo "Test 3: Output to file"
echo 'gitleaks detect --no-banner --exit-code=0 > /tmp/gitleaks-test-output.txt 2>&1 && echo "Gitleaks scan complete"' > /tmp/mcp_test_output.sh

chmod +x /tmp/mcp_test_*.sh

echo "✅ Test scripts created in /tmp/"
echo "Use these commands to test the MCP server:"
echo "1. bash /tmp/mcp_test_simple.sh"
echo "2. bash /tmp/mcp_test_quotes.sh" 
echo "3. bash /tmp/mcp_test_output.sh"
'''
    
    with open("/tmp/test_mcp_fixes.sh", "w") as f:
        f.write(test_script)
    
    print("✅ Created test script: /tmp/test_mcp_fixes.sh")

if __name__ == "__main__":
    print("🔧 Fixing Strategy Agents MCP Terminal Issues")
    print("=" * 50)
    
    try:
        fix_mcp_server()
        test_fixes()
        create_test_script()
        
        print("\n🎯 Next Steps:")
        print("1. Restart Claude Desktop to reload MCP server")
        print("2. Test with: screenpipe-terminal:execute-terminal-command")
        print("3. Try the security scan again")
        print("4. Run test script: bash /tmp/test_mcp_fixes.sh")
        
    except Exception as e:
        print(f"❌ Error applying fixes: {e}")
        print("Check that the file exists and you have write permissions")
