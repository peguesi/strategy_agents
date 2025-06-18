#!/bin/bash
set -e

# Alternative Installation Methods for Screenpipe GUI

echo "=== Screenpipe GUI Installation Script ==="
echo

# Method 1: Direct download from website
echo "Method 1: Opening official download page..."
open "https://screenpi.pe"
echo "✓ Please download the desktop app from the opened webpage"
echo

# Method 2: Install via CLI (which includes GUI)
echo "Method 2: Installing via official CLI installer..."
echo "This will install both CLI and GUI components"
echo

read -p "Do you want to install via CLI method? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Installing Screenpipe..."
    curl -fsSL https://get.screenpi.pe/cli | sh
    echo "✓ Installation complete"
    echo
    echo "The CLI installation includes the desktop app functionality."
    echo "You can now run 'screenpipe' from terminal"
fi

# Method 3: Build from source
echo
echo "Method 3: Build from source (Advanced)"
echo "Would you like instructions to build from source? (y/n): "
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    cat << 'EOF'

Building from Source:
====================

# Prerequisites
brew install rust node

# Clone and build
git clone https://github.com/mediar-ai/screenpipe.git
cd screenpipe
cargo build --release --features metal

# For the Tauri GUI app specifically:
git clone https://github.com/mediar-ai/screenpipe-app-tauri.git
cd screenpipe-app-tauri
npm install
npm run tauri build

The built app will be in: src-tauri/target/release/bundle/

EOF
fi

echo
echo "=== Next Steps ==="
echo "1. If you downloaded from the website, drag the app to /Applications"
echo "2. Grant necessary permissions (Screen Recording, Accessibility)"
echo "3. Configure data directory to use your existing data"
echo
echo "Your existing data location: /Users/zeh/Local_Projects/Strategy_agents/screenpipe/data"
