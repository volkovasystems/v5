#!/bin/bash
# Global uninstall script for V5 productive development tool
# This removes the wrapper script from /usr/local/bin

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🗑️  Uninstalling V5 productive development tool globally...${NC}"

# Check if running as root or with sudo
if [[ $EUID -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
    echo -e "${YELLOW}⚠️  This script requires sudo privileges to remove from /usr/local/bin${NC}"
fi

# Check if the global v5 command exists
if [[ ! -f "/usr/local/bin/v5" ]]; then
    echo -e "${YELLOW}⚠️  Global v5 command not found at /usr/local/bin/v5${NC}"
    echo -e "${BLUE}ℹ️  V5 may not be installed globally or already uninstalled${NC}"
    exit 0
fi

# Remove the wrapper script
echo -e "${BLUE}🗑️  Removing global v5 command...${NC}"
$SUDO rm -f /usr/local/bin/v5

# Verify removal
if command -v v5 > /dev/null 2>&1; then
    echo -e "${RED}❌ Uninstall failed - v5 command still found in PATH${NC}"
    echo -e "${YELLOW}💡 The v5 command might be available from another location${NC}"
    echo -e "${BLUE}📍 Current v5 location: $(which v5)${NC}"
    exit 1
else
    echo -e "${GREEN}✅ V5 uninstalled successfully!${NC}"
    echo -e "${BLUE}ℹ️  The V5 tool files remain in the original installation directory${NC}"
    echo -e "${BLUE}ℹ️  You can still run V5 locally using ./v5_tool.py from the installation directory${NC}"
fi