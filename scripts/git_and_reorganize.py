#!/usr/bin/env python3
"""
Git Operations and Complete Reorganization
==========================================

This script handles git operations and then runs the complete reorganization.
"""

import subprocess
import sys
from pathlib import Path
from datetime import datetime

def run_command(cmd, cwd=None):
    """Run a shell command and return result"""
    try:
        result = subprocess.run(cmd, shell=True, cwd=cwd, 
                              capture_output=True, text=True, check=True)
        return True, result.stdout.strip()
    except subprocess.CalledProcessError as e:
        return False, e.stderr.strip()

def main():
    """Main execution function"""
    base_dir = Path(__file__).parent
    
    print("🔧 Strategy Agents Reorganization with Git Integration")
    print("=" * 60)
    
    # Step 1: Check git status
    print("\n📋 Checking git status...")
    success, output = run_command("git status --porcelain", cwd=base_dir)
    if not success:
        print(f"❌ Git status check failed: {output}")
        return False
    
    if output:
        print("📝 Uncommitted changes detected:")
        print(output)
        response = input("Continue with uncommitted changes? (y/N): ")
        if response.lower() != 'y':
            print("⏹️ Aborted by user")
            return False
    
    # Step 2: Create new branch
    branch_name = f"reorganization-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
    print(f"\n🌿 Creating branch: {branch_name}")
    
    success, output = run_command(f"git checkout -b {branch_name}", cwd=base_dir)
    if not success:
        print(f"❌ Failed to create branch: {output}")
        return False
    print(f"✅ Created and switched to branch: {branch_name}")
    
    # Step 3: Add reorganization scripts
    print("\n📦 Adding reorganization scripts...")
    scripts_to_add = [
        "cleanup_and_organize.py",
        "create_n8n_docs.py", 
        "reorganize_complete.py",
        "git_and_reorganize.py"  # This file
    ]
    
    for script in scripts_to_add:
        success, output = run_command(f"git add {script}", cwd=base_dir)
        if not success:
            print(f"❌ Failed to add {script}: {output}")
            return False
        print(f"✅ Added {script}")
    
    # Step 4: Commit scripts
    commit_message = "Add comprehensive directory reorganization scripts\n\n- cleanup_and_organize.py: Root directory cleanup and n8n workflow organization\n- create_n8n_docs.py: Generate comprehensive n8n documentation\n- reorganize_complete.py: Master script for complete reorganization\n- git_and_reorganize.py: Git integration and execution wrapper"
    
    print("\n💾 Committing reorganization scripts...")
    success, output = run_command(f'git commit -m "{commit_message}"', cwd=base_dir)
    if not success:
        print(f"❌ Failed to commit: {output}")
        return False
    print("✅ Committed reorganization scripts")
    
    # Step 5: Run the reorganization
    print("\n🚀 Running complete reorganization...")
    success, output = run_command(f"{sys.executable} reorganize_complete.py", cwd=base_dir)
    if not success:
        print(f"❌ Reorganization failed: {output}")
        return False
    print("✅ Reorganization completed successfully!")
    
    # Step 6: Add reorganized files
    print("\n📦 Adding reorganized files...")
    success, output = run_command("git add .", cwd=base_dir)
    if not success:
        print(f"❌ Failed to add reorganized files: {output}")
        return False
    
    # Step 7: Commit reorganized structure
    reorganization_commit = "Complete directory reorganization\n\n- Organized root files into docs/, scripts/, config/ directories\n- Restructured n8n/workflows/ with active/testing/archive organization\n- Updated main README with new structure\n- Created comprehensive n8n workflows documentation\n- Cleaned up legacy files and improved organization"
    
    print("\n💾 Committing reorganized structure...")
    success, output = run_command(f'git commit -m "{reorganization_commit}"', cwd=base_dir)
    if not success:
        print(f"❌ Failed to commit reorganization: {output}")
        return False
    print("✅ Committed reorganized structure")
    
    # Step 8: Summary
    print("\n" + "=" * 60)
    print("🎉 Complete reorganization with git integration successful!")
    print(f"\n📋 Summary:")
    print(f"   - Created branch: {branch_name}")
    print(f"   - Committed reorganization scripts")
    print(f"   - Executed complete reorganization")
    print(f"   - Committed new directory structure")
    
    print(f"\n🚀 Next steps:")
    print(f"   1. Review the reorganized structure")
    print(f"   2. Test critical workflows")
    print(f"   3. Merge branch to main when satisfied:")
    print(f"      git checkout main")
    print(f"      git merge {branch_name}")
    print(f"   4. Or push branch to remote:")
    print(f"      git push origin {branch_name}")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
