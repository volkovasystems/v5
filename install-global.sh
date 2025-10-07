#!/bin/bash
# Global installation script for V5 productive development tool
# This creates a wrapper script in /usr/local/bin to make v5 available globally

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
V5_TOOL_PATH="$SCRIPT_DIR/src/core/v5_tool.py"

echo -e "${BLUE}🚀 Installing V5 productive development tool globally...${NC}"

# Check if v5_tool.py exists
if [[ ! -f "$V5_TOOL_PATH" ]]; then
    echo -e "${RED}❌ Error: v5_tool.py not found at $V5_TOOL_PATH${NC}"
    exit 1
fi

# Check if running as root or with sudo
if [[ $EUID -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
    echo -e "${YELLOW}⚠️  This script requires sudo privileges to install to /usr/local/bin${NC}"
fi

# Create the wrapper script content
WRAPPER_CONTENT="#!/bin/bash
# V5 Global Wrapper Script
# This script allows running v5 from any directory in any git repository

exec python3 \"$V5_TOOL_PATH\" \"\$@\"
"

# Install the wrapper script
echo -e "${BLUE}📦 Creating global v5 command...${NC}"
echo "$WRAPPER_CONTENT" | $SUDO tee /usr/local/bin/v5 > /dev/null

# Make it executable
$SUDO chmod +x /usr/local/bin/v5

# Verify installation
if command -v v5 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ V5 installed successfully!${NC}"
    echo -e "${BLUE}🎯 You can now run 'v5' from any git repository directory${NC}"
    echo ""
    echo -e "${YELLOW}Usage examples:${NC}"
    echo "  v5              # Initialize and start in current git repo"
    echo "  v5 init         # Initialize V5 environment"
    echo "  v5 start        # Start V5 services"
    echo "  v5 stop         # Stop V5 services"
    echo "  v5 status       # Check V5 status"
    echo "  v5 version      # Show version"
    echo "  v5 help         # Show help"
    echo ""
    echo -e "${BLUE}📋 To test: cd to any git repository and run 'v5 help'${NC}"
else
    echo -e "${RED}❌ Installation failed - v5 command not found in PATH${NC}"
    exit 1
fi