#!/bin/bash
# Wrapper script for menu bar app - ensures screenpipe is in PATH

# Change to the script directory first
cd "$(dirname "$0")"

# Add screenpipe to PATH
export PATH="/usr/local/bin:$PATH"

# Check if screenpipe is available
if ! command -v screenpipe &> /dev/null; then
    echo "Error: screenpipe not found in PATH"
    echo "Please ensure screenpipe is installed in /usr/local/bin"
    exit 1
fi

# Use system Python
PYTHON_CMD="/usr/bin/python3"

# Run the menu bar app with system Python
echo "Starting menu bar app..."
exec $PYTHON_CMD screenpipe_menubar.py
