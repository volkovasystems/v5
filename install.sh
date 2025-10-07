#!/bin/bash
# V5 - 5 Strategies Productive Development Tool - Unified Installation Script
# Global installation by default, with local-only option available

set -euo pipefail

# Read version from VERSION file
VERSION="$(cat "$(dirname "${BASH_SOURCE[0]}")/VERSION" 2>/dev/null || echo "unknown")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default to global installation
INSTALL_MODE="global"
DRY_RUN=false
CHECK_DEPS_ONLY=false

# Handle command line flags
for arg in "$@"; do
    case "$arg" in
        "--help"|"help"|"usage")
            echo "V5 - 5 Strategies Productive Development Tool - Installation Script v$VERSION"
            echo "========================================================================"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Installation Modes:"
            echo "  --global        Install globally (default) - creates 'v5' command system-wide"
            echo "  --local         Local installation only - no global command"
            echo ""
            echo "Options:"
            echo "  --help          Show this help message"
            echo "  --version       Show version information"
            echo "  --check-deps    Check system dependencies without installing"
            echo "  --dry-run       Show what would be installed without doing it"
            echo ""
            echo "Examples:"
            echo "  $0                    # Default global installation"
            echo "  $0 --global          # Explicit global installation"
            echo "  $0 --local           # Local installation only"
            echo "  $0 --check-deps      # Check dependencies"
            echo ""
            echo "Global installation creates 'v5' command available from any git repository."
            echo "Local installation requires running './v5' from the V5 directory."
            exit 0
            ;;
        "--version"|"version")
            echo "Installing V5 - 5 Strategies Productive Development Tool v$VERSION"
            exit 0
            ;;
        "--check-deps"|"check-deps")
            CHECK_DEPS_ONLY=true
            ;;
        "--dry-run")
            DRY_RUN=true
            ;;
        "--global")
            INSTALL_MODE="global"
            ;;
        "--local")
            INSTALL_MODE="local"
            ;;
        --*)
            echo -e "${RED}❌ Unknown option: $arg${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Display installation header
if [[ "$CHECK_DEPS_ONLY" == "true" ]]; then
    echo "V5 Dependency Check v$VERSION"
    echo "============================="
elif [[ "$DRY_RUN" == "true" ]]; then
    echo "V5 Dry Run Installation v$VERSION (no actual installation)"
    echo "=========================================================="
else
    echo "🚀 Installing V5 - 5 Strategies Productive Development Tool v$VERSION"
    echo "================================================================="
    if [[ "$INSTALL_MODE" == "global" ]]; then
        echo -e "${GREEN}📦 Installation Mode: Global (creates system-wide 'v5' command)${NC}"
    else
        echo -e "${BLUE}📦 Installation Mode: Local (run as './v5' from V5 directory)${NC}"
    fi
fi

echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
V5_TOOL_PATH="$SCRIPT_DIR/src/core/v5_tool.py"

# Check if we're in the v5 directory (skip for dependency check)
if [[ "$CHECK_DEPS_ONLY" != "true" ]] && { [[ ! -f "$V5_TOOL_PATH" ]] || [[ ! -d "src" ]]; }; then
    echo -e "${RED}❌ Error: Please run this script from the v5 directory${NC}"
    echo "   Current directory: $(pwd)"
    echo "   Expected files: src/core/v5_tool.py and src/ directory"
    exit 1
fi

# Detect operating system
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

# Check for WSL (Windows Subsystem for Linux)
if grep -qi microsoft /proc/version 2>/dev/null || grep -qi wsl /proc/version 2>/dev/null; then
    OS="${OS}_wsl"
    echo -e "${BLUE}📍 Detected OS: $OS (Windows Subsystem for Linux)${NC}"
else
    echo -e "${BLUE}📍 Detected OS: $OS${NC}"
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install with sudo prompt
install_with_sudo() {
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${BLUE}🔧 [DRY RUN] Would run: sudo $*${NC}"
    else
        echo -e "${YELLOW}This step requires sudo privileges for package installation.${NC}"
        echo "You may be prompted for your password."
        sudo "$@"
    fi
}

# Check Python installation
echo -e "${BLUE}🐍 Checking Python dependencies...${NC}"

if ! command_exists python3; then
    if [[ "$CHECK_DEPS_ONLY" == "true" ]]; then
        echo -e "${YELLOW}   ⚠️  Python3: Not found${NC}"
    else
        echo -e "${RED}❌ Python3 not found. Installing Python3...${NC}"
        case "$OS" in
            "linux"|"linux_wsl")
                if command_exists apt-get; then
                    install_with_sudo apt-get update
                    install_with_sudo apt-get install -y python3 python3-pip python3-venv
                elif command_exists yum; then
                    install_with_sudo yum install -y python3 python3-pip
                elif command_exists dnf; then
                    install_with_sudo dnf install -y python3 python3-pip
                fi
                ;;
            "darwin")
                if command_exists brew; then
                    brew install python3
                else
                    echo -e "${RED}❌ Please install Python3 manually from python.org${NC}"
                    exit 1
                fi
                ;;
        esac
    fi
else
    echo -e "${GREEN}   ✅ Python3: Available${NC}"
fi

# Install pip if not available
if ! command_exists pip3; then
    if [[ "$CHECK_DEPS_ONLY" == "true" ]]; then
        echo -e "${YELLOW}   ⚠️  pip3: Not found${NC}"
    else
        echo -e "${BLUE}Installing pip3...${NC}"
        case "$OS" in
            "linux"|"linux_wsl")
                if command_exists apt-get; then
                    install_with_sudo apt-get install -y python3-pip
                fi
                ;;
        esac
    fi
else
    echo -e "${GREEN}   ✅ pip3: Available${NC}"
fi

# If only checking dependencies, exit here
if [[ "$CHECK_DEPS_ONLY" == "true" ]]; then
    echo ""
    echo "Dependency Check Complete"
    echo "========================"
    exit 0
fi

# Create virtual environment for cleaner installation
echo -e "${BLUE}📦 Setting up Python environment...${NC}"
if [[ "$DRY_RUN" != "true" ]]; then
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    
    # Activate virtual environment and install packages
    echo -e "${BLUE}Installing Python packages in virtual environment...${NC}"
    # shellcheck source=/dev/null
    source venv/bin/activate
    
    if pip install -r requirements.txt; then
        echo -e "${GREEN}   ✅ Python packages installed successfully${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Trying alternative installation methods...${NC}"
        # Try user installation as fallback
        if pip3 install -r requirements.txt --user; then
            echo -e "${GREEN}   ✅ Python packages installed in user directory${NC}"
            deactivate
            rm -rf venv
            echo -e "${YELLOW}   Note: Using user installation instead of virtual environment${NC}"
        else
            echo -e "${RED}   ❌ Failed to install Python packages${NC}"
            deactivate
            rm -rf venv
            exit 1
        fi
    fi
else
    echo -e "${BLUE}[DRY RUN] Would create virtual environment and install packages${NC}"
fi

# Install RabbitMQ based on OS
echo -e "${BLUE}🐰 Installing RabbitMQ...${NC}"

rabbitmq_installed=false

if [[ "$DRY_RUN" != "true" ]]; then
    case "$OS" in
        "linux"|"linux_wsl")
            if command_exists apt-get; then
                echo -e "${BLUE}   Installing RabbitMQ via apt...${NC}"
                if install_with_sudo apt-get update && install_with_sudo apt-get install -y rabbitmq-server; then
                    echo -e "${GREEN}   ✅ RabbitMQ installed successfully${NC}"
                    # Enable and start RabbitMQ
                    if command_exists systemctl; then
                        install_with_sudo systemctl enable rabbitmq-server 2>/dev/null || true
                        install_with_sudo systemctl start rabbitmq-server 2>/dev/null || true
                    fi
                    rabbitmq_installed=true
                else
                    echo -e "${YELLOW}   ⚠️  RabbitMQ installation failed${NC}"
                fi
            elif command_exists yum || command_exists dnf; then
                PKG_MGR=$(command_exists dnf && echo "dnf" || echo "yum")
                echo -e "${BLUE}   Installing RabbitMQ via $PKG_MGR...${NC}"
                if install_with_sudo $PKG_MGR install -y rabbitmq-server; then
                    echo -e "${GREEN}   ✅ RabbitMQ installed successfully${NC}"
                    install_with_sudo systemctl enable rabbitmq-server
                    install_with_sudo systemctl start rabbitmq-server
                    rabbitmq_installed=true
                else
                    echo -e "${YELLOW}   ⚠️  RabbitMQ installation failed${NC}"
                fi
            fi
            ;;
        "darwin")
            if command_exists brew; then
                echo -e "${BLUE}   Installing RabbitMQ via Homebrew...${NC}"
                if brew install rabbitmq; then
                    echo -e "${GREEN}   ✅ RabbitMQ installed successfully${NC}"
                    brew services start rabbitmq
                    rabbitmq_installed=true
                else
                    echo -e "${YELLOW}   ⚠️  RabbitMQ installation failed${NC}"
                fi
            else
                echo -e "${YELLOW}   Homebrew not found - please install manually${NC}"
            fi
            ;;
        *)
            echo -e "${YELLOW}   RabbitMQ requires manual installation for this OS${NC}"
            ;;
    esac
else
    echo -e "${BLUE}[DRY RUN] Would install RabbitMQ${NC}"
    rabbitmq_installed=true
fi

# Global installation setup
if [[ "$INSTALL_MODE" == "global" ]] && [[ "$DRY_RUN" != "true" ]]; then
    echo -e "${BLUE}🌐 Setting up global v5 command...${NC}"
    
    # Check if running as root or with sudo
    if [[ $EUID -eq 0 ]]; then
        SUDO=""
    else
        SUDO="sudo"
        echo -e "${YELLOW}⚠️  This step requires sudo privileges to install to /usr/local/bin${NC}"
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
        echo -e "${GREEN}   ✅ Global v5 command installed successfully${NC}"
        global_installed=true
    else
        echo -e "${RED}   ❌ Global installation failed${NC}"
        global_installed=false
    fi
elif [[ "$INSTALL_MODE" == "global" ]] && [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${BLUE}[DRY RUN] Would install global v5 command to /usr/local/bin${NC}"
    global_installed=true
else
    echo -e "${BLUE}📋 Skipping global installation (local mode)${NC}"
    global_installed=false
fi

# Make local v5 script executable (if it exists)
if [[ -f "v5" ]] && [[ "$DRY_RUN" != "true" ]]; then
    echo -e "${BLUE}🔧 Making local v5 script executable...${NC}"
    chmod +x v5
fi

# Final validation and summary
echo ""
echo -e "${BLUE}🔍 Final validation...${NC}"

# Check if v5 works (global or local)
v5_working=false
if [[ "$global_installed" == "true" ]] && command -v v5 > /dev/null 2>&1; then
    if v5 --version 2>&1 | grep -q "V5"; then
        echo -e "${GREEN}   ✅ Global v5 command is working${NC}"
        v5_working=true
    fi
elif [[ -f "v5" ]] && ./v5 --version 2>&1 | grep -q "V5"; then
    echo -e "${GREEN}   ✅ Local v5 script is working${NC}"
    v5_working=true
else
    echo -e "${RED}   ❌ V5 command has issues${NC}"
fi

# Check Python dependencies
python_deps_ok=true
if [[ "$DRY_RUN" != "true" ]]; then
    if [ -d "venv" ]; then
        # shellcheck source=/dev/null
        source venv/bin/activate
        for package in pika psutil watchdog PyYAML; do
            if ! pip show $package >/dev/null 2>&1; then
                python_deps_ok=false
                break
            fi
        done
        deactivate
    else
        # Check user installation
        for package in pika psutil watchdog PyYAML; do
            if ! pip3 show $package >/dev/null 2>&1; then
                python_deps_ok=false
                break
            fi
        done
    fi
fi

if [[ "$python_deps_ok" == "true" ]]; then
    echo -e "${GREEN}   ✅ Python dependencies are available${NC}"
else
    echo -e "${YELLOW}   ⚠️  Some Python dependencies may be missing${NC}"
fi

# Installation Summary
echo ""
echo -e "${GREEN}✨ INSTALLATION COMPLETE ✨${NC}"
echo "============================="

if [[ "$v5_working" == "true" ]] && [[ "$python_deps_ok" == "true" ]]; then
    echo -e "${GREEN}🎉 V5 is ready to use!${NC}"
else
    echo -e "${YELLOW}⚠️  V5 installed with some issues${NC}"
fi

echo ""
echo "Installation Status:"
if [[ "$v5_working" == "true" ]]; then
    echo -e "${GREEN}✅ V5 script: Working${NC}"
else
    echo -e "${RED}❌ V5 script: Issues detected${NC}"
fi

if [[ "$python_deps_ok" == "true" ]]; then
    echo -e "${GREEN}✅ Python deps: Installed${NC}"
else
    echo -e "${YELLOW}⚠️  Python deps: May need manual installation${NC}"
fi

if [[ "$rabbitmq_installed" == "true" ]]; then
    echo -e "${GREEN}✅ RabbitMQ: Installed and running${NC}"
else
    echo -e "${YELLOW}⚠️  RabbitMQ: Will run in offline mode${NC}"
fi

if [[ "$global_installed" == "true" ]]; then
    echo -e "${GREEN}✅ Global command: Available system-wide${NC}"
else
    echo -e "${BLUE}ℹ️  Global command: Local installation only${NC}"
fi

echo ""
echo -e "${BLUE}🚀 Quick Start:${NC}"
if [[ "$global_installed" == "true" ]]; then
    echo "1. Navigate to any git repository: cd /path/to/your/project"
    echo "2. Initialize V5:                  v5 init"
    echo "3. Start V5 tool:                  v5 start"
    echo "4. Check status anytime:           v5 status"
    echo "5. Get help:                       v5 help"
else
    echo "1. Initialize a project:  ./v5 /path/to/your/project init"
    echo "2. Start V5 tool:         ./v5 /path/to/your/project start"
    echo "3. Check status:          ./v5 /path/to/your/project status"
fi
echo ""
echo -e "${BLUE}📌 Documentation: README.md${NC}"
echo -e "${GREEN}🎯 Ready to transform your development workflow!${NC}"