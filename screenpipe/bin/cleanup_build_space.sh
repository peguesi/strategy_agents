#!/bin/bash
set -e

echo "=== Disk Space Cleanup for Screenpipe Build ==="
echo

# Check current disk space
echo "Current disk usage:"
df -h / | grep -v Filesystem
echo

# Show target directory size
echo "Build directory size:"
du -sh /Users/zeh/Local_Projects/screenpipe/target 2>/dev/null || echo "0"
echo

# Clean options
echo "Cleanup options:"
echo "1) Clean build artifacts (recommended - frees most space)"
echo "2) Clean only release build"
echo "3) Clean everything and restart build"
echo "4) Check what's using disk space"
echo "5) Exit"
echo

read -p "Choose option (1-5): " choice

case $choice in
    1)
        echo "Cleaning build artifacts..."
        cd /Users/zeh/Local_Projects/screenpipe
        cargo clean
        echo "✅ Build artifacts cleaned"
        echo
        echo "Space freed. Now run:"
        echo "cd /Users/zeh/Local_Projects/screenpipe"
        echo "./build_macos_gui.sh"
        ;;
    2)
        echo "Cleaning release build only..."
        cd /Users/zeh/Local_Projects/screenpipe
        rm -rf target/release
        echo "✅ Release build cleaned"
        ;;
    3)
        echo "Full clean and restart..."
        cd /Users/zeh/Local_Projects/screenpipe
        cargo clean
        rm -rf screenpipe-app-tauri/node_modules
        rm -rf screenpipe-app-tauri/.next
        rm -rf ~/.cargo/registry/cache
        echo "✅ Everything cleaned"
        echo
        echo "This will require a full rebuild from scratch"
        ;;
    4)
        echo "Checking disk usage..."
        echo
        echo "=== Largest directories in home ==="
        du -sh ~/* 2>/dev/null | sort -hr | head -10
        echo
        echo "=== Screenpipe project size ==="
        du -sh /Users/zeh/Local_Projects/screenpipe/* 2>/dev/null | sort -hr | head -10
        echo
        echo "=== Cargo cache size ==="
        du -sh ~/.cargo 2>/dev/null || echo "Not found"
        echo
        echo "=== Other suggestions ==="
        echo "- Empty Trash: rm -rf ~/.Trash/*"
        echo "- Clear Downloads: check ~/Downloads"
        echo "- Clear Caches: ~/Library/Caches"
        ;;
    5)
        echo "Exiting..."
        exit 0
        ;;
esac

echo
echo "Current free space:"
df -h / | grep -v Filesystem
