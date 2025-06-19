#!/bin/bash
# Strategy Agents Project Cleanup Script
# Transforms development repository into production-ready structure

echo "🧹 Starting Strategy Agents Project Cleanup..."

# Create new directory structure
echo "📁 Creating organized directory structure..."
mkdir -p docs
mkdir -p scripts

# Move root scripts to scripts directory
echo "🔄 Moving scripts to organized locations..."
[ -f "setup.sh" ] && mv setup.sh scripts/
[ -f "cleanup_project.sh" ] && mv cleanup_project.sh scripts/cleanup_legacy.sh
[ -f "make_executable.sh" ] && mv make_executable.sh scripts/
[ -f "diagnose_mcp.sh" ] && mv diagnose_mcp.sh scripts/diagnose_legacy.sh
[ -f "fix_enhanced_mcp.sh" ] && mv fix_enhanced_mcp.sh scripts/fix_legacy.sh
[ -f "install_iterm2_mcp.sh" ] && mv install_iterm2_mcp.sh scripts/
[ -f "run_iterm2_setup.sh" ] && mv run_iterm2_setup.sh scripts/
[ -f "setup_iterm2_mcp.sh" ] && mv setup_iterm2_mcp.sh scripts/
[ -f "setup_n8n_mcp.sh" ] && mv setup_n8n_mcp.sh scripts/
[ -f "test_terminal_mcp.sh" ] && mv test_terminal_mcp.sh scripts/

# Remove temporary test files
echo "🗑️  Removing temporary test files..."
[ -f "test_n8n_api.py" ] && rm test_n8n_api.py
[ -f "fetch_workflows.py" ] && rm fetch_workflows.py

# Clean up empty or legacy files
echo "🧽 Cleaning up legacy files..."
[ -f ".DS_Store" ] && rm .DS_Store

# Create main project scripts
echo "⚙️  Creating main project management scripts..."

# Create setup script
cat > scripts/setup.sh << 'EOF'
#!/bin/bash
# Strategy Agents Setup Script
echo "🚀 Setting up Strategy Agents..."

# Check dependencies
echo "📦 Checking dependencies..."
command -v python3 >/dev/null 2>&1 || { echo "❌ Python 3 required"; exit 1; }

# Setup virtual environment
echo "🐍 Setting up Python environment..."
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x scripts/*.sh
chmod +x n8n/scripts/*.sh
chmod +x screenpipe/bin/*.sh

echo "✅ Strategy Agents setup complete!"
echo "📚 See docs/SETUP.md for detailed configuration"
EOF

# Create test script
cat > scripts/test.sh << 'EOF'
#!/bin/bash
# Strategy Agents Test Script
echo "🧪 Running Strategy Agents tests..."

# Test n8n MCP connection
echo "🔄 Testing n8n MCP connection..."
python3 -c "
import asyncio
import sys
sys.path.append('mcp/n8n')

async def test_connection():
    try:
        from n8n_complete_mcp_server import n8n_request
        result = await n8n_request('GET', 'workflows')
        print('✅ n8n MCP connection successful')
        return True
    except Exception as e:
        print(f'❌ n8n MCP connection failed: {e}')
        return False

if asyncio.run(test_connection()):
    print('🎉 All tests passed!')
else:
    print('⚠️  Some tests failed - check configuration')
"
EOF

# Make scripts executable
chmod +x scripts/*.sh

# Update .gitignore for new structure
echo "📝 Updating .gitignore..."
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
.venv/
env/
venv/

# Environment variables
.env
!.env.example

# Logs
logs/
*.log

# Data directories
data/
screenpipe/data/
!screenpipe/data/README.md

# Credentials
credentials/
n8n/credentials/
!n8n/credentials/README.md

# macOS
.DS_Store

# IDE
.vscode/
.idea/

# Node modules (for pipes)
node_modules/

# Temporary files
tmp/
*.tmp
test_*.py
temp_*

# Virtual environments in subdirectories
**/venv/
**/.venv/
EOF

echo "✅ Strategy Agents cleanup complete!"
echo "📁 Project structure organized"
echo "🧹 Temporary files removed"
echo "📚 Ready for documentation phase"
