#!/bin/bash

# Strategy Agents Platform Setup Script
# Automated installation and configuration for the Strategy Agents platform

set -e  # Exit on any error

# Colors for output
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
BLUE='\\033[0;34m'
NC='\\033[0m' # No Color

# Print colored output
print_status() {
    echo -e \"${BLUE}[INFO]${NC} $1\"
}

print_success() {
    echo -e \"${GREEN}[SUCCESS]${NC} $1\"
}

print_warning() {
    echo -e \"${YELLOW}[WARNING]${NC} $1\"
}

print_error() {
    echo -e \"${RED}[ERROR]${NC} $1\"
}

# Check if running on macOS
check_macos() {
    if [[ \"$OSTYPE\" != \"darwin\"* ]]; then
        print_warning \"This script is optimized for macOS. Some features may not work on other systems.\"
        read -p \"Continue anyway? (y/N): \" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Check for required tools
check_dependencies() {
    print_status \"Checking dependencies...\"
    
    local missing_tools=()
    
    # Check for Python 3
    if ! command -v python3 &> /dev/null; then
        missing_tools+=(\"python3\")
    fi
    
    # Check for pip
    if ! command -v pip3 &> /dev/null; then
        missing_tools+=(\"pip3\")
    fi
    
    # Check for git
    if ! command -v git &> /dev/null; then
        missing_tools+=(\"git\")
    fi
    
    # Check for node (optional but recommended)
    if ! command -v node &> /dev/null; then
        print_warning \"Node.js not found. Some integrations may require it.\"
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error \"Missing required tools: ${missing_tools[*]}\"
        print_status \"Please install missing tools and run this script again.\"
        exit 1
    fi
    
    print_success \"All required dependencies found\"
}

# Create Python virtual environment
setup_python_env() {
    print_status \"Setting up Python virtual environment...\"
    
    if [ ! -d \".venv\" ]; then
        python3 -m venv .venv
        print_success \"Created Python virtual environment\"
    else
        print_status \"Virtual environment already exists\"
    fi
    
    # Activate virtual environment
    source .venv/bin/activate
    
    # Upgrade pip
    pip install --upgrade pip
    
    # Install requirements
    if [ -f \"config/requirements.txt\" ]; then
        pip install -r config/requirements.txt
        print_success \"Installed Python dependencies\"
    else
        print_warning \"requirements.txt not found, installing minimal dependencies\"
        pip install httpx asyncio python-dotenv
    fi
}

# Setup environment configuration
setup_environment() {
    print_status \"Setting up environment configuration...\"
    
    if [ ! -f \".env\" ]; then
        if [ -f \"config/.env.example\" ]; then
            cp config/.env.example .env
            print_success \"Created .env file from template\"
            print_warning \"Please edit .env file with your actual API keys and configuration\"
        else
            print_error \"No .env.example template found\"
            exit 1
        fi
    else
        print_status \".env file already exists\"
    fi
}

# Setup Linear workspace
setup_linear() {
    print_status \"Setting up Linear workspace...\"
    
    if [ -z \"$LINEAR_API_KEY\" ]; then
        print_warning \"LINEAR_API_KEY not set in environment\"
        print_status \"Please set your Linear API key in the .env file\"
        return
    fi
    
    # Test Linear API connection
    python3 -c \"
import os
import asyncio
import httpx

async def test_linear():
    headers = {'Authorization': f'Bearer {os.getenv(\\\"LINEAR_API_KEY\\\")}'}
    async with httpx.AsyncClient() as client:
        response = await client.post(
            'https://api.linear.app/graphql',
            headers=headers,
            json={'query': 'query { viewer { id name email } }'}
        )
        if response.status_code == 200:
            print('Linear API connection successful')
        else:
            print(f'Linear API connection failed: {response.status_code}')

asyncio.run(test_linear())
\" 2>/dev/null && print_success \"Linear API connection verified\" || print_warning \"Linear API connection could not be verified\"
}

# Setup n8n configuration
setup_n8n() {
    print_status \"Setting up n8n configuration...\"
    
    # Create n8n workflows directory if it doesn't exist
    mkdir -p n8n/workflows
    mkdir -p n8n/exports
    
    if [ -z \"$N8N_API_KEY\" ]; then
        print_warning \"N8N_API_KEY not set in environment\"
        print_status \"Please configure n8n integration in the .env file\"
        return
    fi
    
    print_success \"n8n configuration directory created\"
}

# Setup Screenpipe integration
setup_screenpipe() {
    print_status \"Setting up Screenpipe integration...\"
    
    # Check if Screenpipe is installed
    if command -v screenpipe &> /dev/null; then
        print_success \"Screenpipe found in PATH\"
    else
        print_warning \"Screenpipe not found. Please install Screenpipe for behavioral analysis features.\"
        print_status \"Visit: https://github.com/mediar-ai/screenpipe for installation instructions\"
    fi
    
    # Create screenpipe data directory
    mkdir -p screenpipe/data
    mkdir -p screenpipe/bin
    
    print_success \"Screenpipe directories created\"
}

# Setup MCP servers
setup_mcp_servers() {
    print_status \"Setting up MCP servers...\"
    
    # Make MCP server scripts executable
    find mcp -name \"*.py\" -exec chmod +x {} \\;
    
    # Create Claude Desktop MCP configuration
    create_claude_config
    
    print_success \"MCP servers configured\"
}

# Create Claude Desktop configuration
create_claude_config() {
    print_status \"Creating Claude Desktop MCP configuration...\"
    
    local config_dir
    if [[ \"$OSTYPE\" == \"darwin\"* ]]; then
        config_dir=\"$HOME/Library/Application Support/Claude\"
    else
        config_dir=\"$HOME/.config/claude\"
    fi
    
    mkdir -p \"$config_dir\"
    
    local claude_config=\"$config_dir/claude_desktop_config.json\"
    local project_path=\"$(pwd)\"
    
    cat > \"$claude_config\" << EOF
{
  \"mcpServers\": {
    \"n8n-complete\": {
      \"command\": \"$project_path/.venv/bin/python\",
      \"args\": [\"$project_path/mcp/n8n/n8n_complete_mcp_server.py\"],
      \"env\": {
        \"N8N_API_KEY\": \"${N8N_API_KEY:-your_n8n_api_key}\",
        \"N8N_URL\": \"${N8N_URL:-your_n8n_url}\"
      }
    },
    \"screenpipe-terminal\": {
      \"command\": \"$project_path/.venv/bin/python\",
      \"args\": [\"$project_path/mcp/screenpipe/screenpipe_mcp_server.py\"],
      \"env\": {
        \"SCREENPIPE_API_URL\": \"${SCREENPIPE_API_URL:-http://localhost:3030}\"
      }
    },
    \"linear\": {
      \"command\": \"$project_path/.venv/bin/python\",
      \"args\": [\"$project_path/mcp/linear/linear_mcp_server.py\"],
      \"env\": {
        \"LINEAR_API_KEY\": \"${LINEAR_API_KEY:-your_linear_api_key}\"
      }
    },
    \"azure-postgresql-mcp\": {
      \"command\": \"$project_path/.venv/bin/python\",
      \"args\": [\"$project_path/mcp/azure-postgresql/azure_postgresql_mcp_server.py\"],
      \"env\": {
        \"POSTGRESQL_HOST\": \"${POSTGRESQL_HOST:-your_postgres_host}\",
        \"POSTGRESQL_USER\": \"${POSTGRESQL_USER:-your_postgres_user}\",
        \"POSTGRESQL_PASSWORD\": \"${POSTGRESQL_PASSWORD:-your_postgres_password}\"
      }
    },
    \"filesystem\": {
      \"command\": \"npx\",
      \"args\": [\"-y\", \"@modelcontextprotocol/server-filesystem\", \"$project_path\"]
    }
  }
}
EOF
    
    print_success \"Claude Desktop configuration created: $claude_config\"
    print_warning \"Please restart Claude Desktop to load the new configuration\"
}

# Setup GitHub integration
setup_github() {
    print_status \"Setting up GitHub integration...\"
    
    # Check if this is a git repository
    if [ ! -d \".git\" ]; then
        print_warning \"Not a git repository. Initializing...\"
        git init
        git add .
        git commit -m \"Initial commit - Strategy Agents Platform setup\"
    fi
    
    # Setup GitHub Actions if not exists
    mkdir -p .github/workflows
    
    print_success \"GitHub integration ready\"
}

# Run security audit
run_security_audit() {
    print_status \"Running security audit...\"
    
    if [ -f \"security/security-audit.sh\" ]; then
        chmod +x security/security-audit.sh
        ./security/security-audit.sh
    else
        print_warning \"Security audit script not found\"
    fi
}

# Setup project structure
setup_project_structure() {
    print_status \"Ensuring project structure...\"
    
    # Create essential directories
    mkdir -p logs
    mkdir -p data
    mkdir -p shared
    mkdir -p docs
    mkdir -p examples
    mkdir -p tools
    mkdir -p config
    mkdir -p security
    
    print_success \"Project structure verified\"
}

# Install Claude Desktop (macOS only)
install_claude_desktop() {
    if [[ \"$OSTYPE\" == \"darwin\"* ]]; then
        print_status \"Checking for Claude Desktop...\"
        
        if [ ! -d \"/Applications/Claude.app\" ]; then
            print_status \"Claude Desktop not found. Would you like to download it?\"
            read -p \"Download Claude Desktop? (y/N): \" -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_status \"Opening Claude Desktop download page...\"
                open \"https://claude.ai/download\"
            fi
        else
            print_success \"Claude Desktop found\"
        fi
    fi
}

# Main setup function
main() {
    echo \"========================================\"
    echo \"   Strategy Agents Platform Setup\"
    echo \"========================================\"
    echo
    
    print_status \"Starting Strategy Agents Platform setup...\"
    
    # Load environment variables if .env exists
    if [ -f \".env\" ]; then
        export $(cat .env | grep -v '^#' | xargs)
    fi
    
    check_macos
    check_dependencies
    setup_project_structure
    setup_python_env
    setup_environment
    setup_linear
    setup_n8n
    setup_screenpipe
    setup_mcp_servers
    setup_github
    install_claude_desktop
    run_security_audit
    
    echo
    echo \"========================================\"
    print_success \"Setup completed successfully!\"
    echo \"========================================\"
    echo
    print_status \"Next steps:\"
    echo \"1. Edit .env file with your API keys and configuration\"
    echo \"2. Restart Claude Desktop to load MCP servers\"
    echo \"3. Test the integration by asking Claude to list workflows\"
    echo \"4. Review the documentation in docs/ directory\"
    echo \"5. Run ./scripts/test.sh to verify everything is working\"
    echo
    print_warning \"Important: Never commit your .env file with real API keys!\"
    echo
}

# Run main function
main \"$@\"
