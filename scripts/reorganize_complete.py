#!/usr/bin/env python3
"""
Complete Strategy Agents Reorganization
=======================================

Master script that executes the complete reorganization of the strategy_agents directory.
Run this script to perform the full cleanup and organization process.
"""

import sys
import subprocess
from pathlib import Path

def run_script(script_path):
    """Run a Python script and handle errors"""
    try:
        print(f"\n🚀 Executing {script_path.name}...")
        result = subprocess.run([sys.executable, str(script_path)], 
                              capture_output=True, text=True, check=True)
        print(result.stdout)
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error executing {script_path.name}:")
        print(e.stderr)
        return False

def main():
    """Execute complete reorganization"""
    base_dir = Path(__file__).parent
    
    print("🏗️ Starting Complete Strategy Agents Reorganization")
    print("=" * 55)
    
    # Scripts to run in order
    scripts = [
        base_dir / 'cleanup_and_organize.py',
        base_dir / 'create_n8n_docs.py'
    ]
    
    # Verify all scripts exist
    missing_scripts = [script for script in scripts if not script.exists()]
    if missing_scripts:
        print("❌ Missing required scripts:")
        for script in missing_scripts:
            print(f"   - {script}")
        return False
    
    # Execute scripts in sequence
    success_count = 0
    for script in scripts:
        if run_script(script):
            success_count += 1
        else:
            print(f"❌ Failed to execute {script.name}, stopping...")
            break
    
    # Summary
    print("\n" + "=" * 55)
    if success_count == len(scripts):
        print("✅ Complete reorganization successful!")
        print("\n📁 New directory structure:")
        print("   - Root files organized into docs/, scripts/, config/")
        print("   - N8N workflows organized by status (active/testing/archive)")
        print("   - Updated documentation and READMEs")
        print("\n🚀 Next steps:")
        print("   1. Review the new organization")
        print("   2. Update any hardcoded paths in your workflows")
        print("   3. Re-import active workflows into n8n if needed")
        print("   4. Test critical workflows to ensure they still function")
    else:
        print(f"⚠️ Partial success: {success_count}/{len(scripts)} scripts completed")
        print("Please review errors above and run individual scripts as needed")
    
    return success_count == len(scripts)

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
