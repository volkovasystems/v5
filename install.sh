#!/bin/bash
set -e

# Read version from VERSION file
VERSION="$(cat "$(dirname "${BASH_SOURCE[0]}")/VERSION" 2>/dev/null || echo "unknown")"

# V5 - 5 Strategies Productive Development Tool - Installation Script
echo "🚀 Installing V5 - 5 Strategies Productive Development Tool v$VERSION"
echo "================================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the v5 directory
if [[ ! -f "v5" ]] || [[ ! -d "src" ]]; then
    echo -e "${RED}❌ Error: Please run this script from the v5 directory${NC}"
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
    echo -e "${YELLOW}This step requires sudo privileges for package installation.${NC}"
    echo "You may be prompted for your password."
    "$@"
}

# Make v5 executable
echo -e "${BLUE}🔧 Making v5 executable...${NC}"
chmod +x v5

# Install Python dependencies
echo -e "${BLUE}🐍 Installing Python dependencies...${NC}"

# Check Python installation
if ! command_exists python3; then
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

# Install pip if not available
if ! command_exists pip3; then
    echo -e "${BLUE}Installing pip3...${NC}"
    case "$OS" in
        "linux"|"linux_wsl")
            if command_exists apt-get; then
                install_with_sudo apt-get install -y python3-pip
            fi
            ;;
    esac
fi

# Create virtual environment for cleaner installation
echo -e "${BLUE}Creating virtual environment...${NC}"
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

# Install RabbitMQ based on OS
echo -e "${BLUE}🐰 Installing RabbitMQ...${NC}"

rabbitmq_installed=false

case "$OS" in
    "linux")
        if command_exists apt-get; then
            echo -e "${BLUE}   Installing RabbitMQ via apt...${NC}"
            if install_with_sudo apt-get update && install_with_sudo apt-get install -y rabbitmq-server; then
                echo -e "${GREEN}   ✅ RabbitMQ installed successfully${NC}"
                # Enable and start RabbitMQ
                install_with_sudo systemctl enable rabbitmq-server
                install_with_sudo systemctl start rabbitmq-server
                rabbitmq_installed=true
            else
                echo -e "${YELLOW}   ⚠️  RabbitMQ installation via apt failed${NC}"
            fi
        elif command_exists yum; then
            echo -e "${BLUE}   Installing RabbitMQ via yum...${NC}"
            if install_with_sudo yum install -y rabbitmq-server; then
                echo -e "${GREEN}   ✅ RabbitMQ installed successfully${NC}"
                install_with_sudo systemctl enable rabbitmq-server
                install_with_sudo systemctl start rabbitmq-server
                rabbitmq_installed=true
            else
                echo -e "${YELLOW}   ⚠️  RabbitMQ installation via yum failed${NC}"
            fi
        elif command_exists dnf; then
            echo -e "${BLUE}   Installing RabbitMQ via dnf...${NC}"
            if install_with_sudo dnf install -y rabbitmq-server; then
                echo -e "${GREEN}   ✅ RabbitMQ installed successfully${NC}"
                install_with_sudo systemctl enable rabbitmq-server
                install_with_sudo systemctl start rabbitmq-server
                rabbitmq_installed=true
            else
                echo -e "${YELLOW}   ⚠️  RabbitMQ installation via dnf failed${NC}"
            fi
        else
            echo -e "${YELLOW}   No supported package manager found for automatic installation${NC}"
        fi
        ;;
    "darwin")
        if command_exists brew; then
            echo -e "${BLUE}   Installing RabbitMQ via Homebrew...${NC}"
            if brew install rabbitmq; then
                echo -e "${GREEN}   ✅ RabbitMQ installed successfully${NC}"
                # Start RabbitMQ service
                brew services start rabbitmq
                rabbitmq_installed=true
            else
                echo -e "${YELLOW}   ⚠️  RabbitMQ installation via Homebrew failed${NC}"
            fi
        else
            echo -e "${YELLOW}   Homebrew not found. Installing Homebrew first...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            if command_exists brew; then
                brew install rabbitmq
                brew services start rabbitmq
                rabbitmq_installed=true
            fi
        fi
        ;;
    "msys"*|"cygwin"*|"mingw"*)
        echo -e "${YELLOW}   Windows detected. RabbitMQ requires manual installation.${NC}"
        echo -e "${BLUE}   Please download and install from: https://www.rabbitmq.com/download.html${NC}"
        echo -e "${BLUE}   Or use Windows Subsystem for Linux (WSL) for automatic installation${NC}"
        ;;
    "linux_wsl")
        # WSL detected - treat as Linux with WSL-specific handling
        echo -e "${GREEN}   WSL detected - proceeding with Linux installation...${NC}"
        if command_exists apt-get; then
            echo -e "${BLUE}   Installing RabbitMQ via apt in WSL...${NC}"
            if install_with_sudo apt-get update && install_with_sudo apt-get install -y rabbitmq-server; then
                echo -e "${GREEN}   ✅ RabbitMQ installed successfully${NC}"
                # Note: systemctl might not work in some WSL versions, so we'll be more cautious
                if command_exists systemctl; then
                    install_with_sudo systemctl enable rabbitmq-server 2>/dev/null || echo "   Note: systemctl not fully supported in this WSL version"
                    install_with_sudo systemctl start rabbitmq-server 2>/dev/null || echo "   You may need to start RabbitMQ manually"
                fi
                rabbitmq_installed=true
            else
                echo -e "${YELLOW}   ⚠️  RabbitMQ installation via apt failed${NC}"
            fi
        fi
        ;;
    *)
        echo -e "${YELLOW}   Unsupported OS for automatic installation${NC}"
        echo -e "${BLUE}   Please install RabbitMQ manually from: https://www.rabbitmq.com/download.html${NC}"
        ;;
esac

# Verify RabbitMQ installation
if $rabbitmq_installed; then
    echo -e "${BLUE}   Verifying RabbitMQ installation...${NC}"
    sleep 2
    if command_exists rabbitmq-server; then
        echo -e "${GREEN}   ✅ RabbitMQ is ready${NC}"
    else
        echo -e "${YELLOW}   ⚠️  RabbitMQ installed but may need PATH update${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️  RabbitMQ not automatically installed - V5 will work in offline mode${NC}"
fi

# Final validation and summary
echo ""
echo -e "${BLUE}🔍 Final validation...${NC}"

# Check if v5 script works
if ./v5 2>&1 | grep -q "Usage:"; then
    echo -e "${GREEN}   ✅ V5 script is working${NC}"
    v5_working=true
else
    echo -e "${RED}   ❌ V5 script has issues${NC}"
    v5_working=false
fi

# Check Python dependencies
if [ -d "venv" ]; then
    # shellcheck source=/dev/null
    source venv/bin/activate
    python_deps_ok=true
    for package in pika psutil watchdog PyYAML; do
        if ! pip show $package >/dev/null 2>&1; then
            python_deps_ok=false
            break
        fi
    done
    deactivate
else
    # Check user installation
    python_deps_ok=true
    for package in pika psutil watchdog PyYAML; do
        if ! pip3 show $package >/dev/null 2>&1; then
            python_deps_ok=false
            break
        fi
    done
fi

if $python_deps_ok; then
    echo -e "${GREEN}   ✅ Python dependencies are available${NC}"
else
    echo -e "${YELLOW}   ⚠️  Some Python dependencies may be missing${NC}"
fi

# Installation Summary
echo ""
echo -e "${GREEN}✨ INSTALLATION COMPLETE ✨${NC}"
echo "============================="

if $v5_working && $python_deps_ok; then
    echo -e "${GREEN}🎉 V5 is ready to use!${NC}"
else
    echo -e "${YELLOW}⚠️  V5 installed with some issues${NC}"
fi

echo ""
echo "Installation Status:"
if $v5_working; then
    echo -e "${GREEN}✅ V5 script: Working${NC}"
else
    echo -e "${RED}❌ V5 script: Issues detected${NC}"
fi

if $python_deps_ok; then
    echo -e "${GREEN}✅ Python deps: Installed${NC}"
else
    echo -e "${YELLOW}⚠️  Python deps: May need manual installation${NC}"
fi

if $rabbitmq_installed; then
    echo -e "${GREEN}✅ RabbitMQ: Installed and running${NC}"
else
    echo -e "${YELLOW}⚠️  RabbitMQ: Will run in offline mode${NC}"
fi

echo ""
echo -e "${BLUE}🚀 Quick Start:${NC}"
echo "1. Initialize a project:  ./v5 /path/to/your/project init"
echo "2. Start V5 tool:        ./v5 /path/to/your/project start"
echo "3. Work in Window A and let the other 4 windows assist you!"
echo ""
echo -e "${BLUE}📌 Documentation: README.md${NC}"
echo -e "${GREEN}🎯 Ready to transform your development workflow!${NC}"
