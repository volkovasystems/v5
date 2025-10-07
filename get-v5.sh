#!/usr/bin/env bash
set -euo pipefail

# V5 Remote Installer - 5 Strategies Productive Development Tool
# Usage: curl -fsSL https://raw.githubusercontent.com/volkovasystems/v5/main/get-v5.sh | bash

# Fetch version dynamically
VERSION=$(curl -fsSL "https://raw.githubusercontent.com/volkovasystems/v5/main/VERSION" 2>/dev/null || echo "latest")

echo "🚀 V5 Remote Installer - 5 Strategies Productive Development Tool v$VERSION"
echo "============================================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/volkovasystems/v5"
INSTALL_DIR="$HOME/.local/share/v5"
BIN_DIR="$HOME/.local/bin"
DEFAULT_INSTALL_DIR="$HOME/v5-tool"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to create directories
create_directories() {
    mkdir -p "$1"
    mkdir -p "$BIN_DIR"
}

# Function to add to PATH if needed
add_to_path() {
    local shell_rc=""

    # Detect shell and appropriate RC file
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_rc="$HOME/.bashrc"
    elif [[ "$SHELL" == *"fish"* ]]; then
        shell_rc="$HOME/.config/fish/config.fish"
        echo -e "${YELLOW}Note: Fish shell detected. You may need to manually add $BIN_DIR to your PATH${NC}"
        return
    else
        shell_rc="$HOME/.profile"
    fi

    # Check if PATH already contains the bin directory
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        echo -e "${BLUE}Adding $BIN_DIR to PATH in $shell_rc${NC}"
        {
            echo ""
            echo "# V5 Tool Path"
            echo "export PATH=\"$BIN_DIR:\$PATH\""
        } >> "$shell_rc"
        echo -e "${GREEN}✅ Added to PATH. Restart your shell or run: source $shell_rc${NC}"
    else
        echo -e "${GREEN}✅ $BIN_DIR already in PATH${NC}"
    fi
}

# Function to download files with curl
download_files_with_curl() {
    # Download main files
    curl -fsSL "$REPO_URL/raw/main/VERSION" -o VERSION
    curl -fsSL "$REPO_URL/raw/main/install.sh" -o install.sh
    curl -fsSL "$REPO_URL/raw/main/v5" -o v5
    curl -fsSL "$REPO_URL/raw/main/requirements.txt" -o requirements.txt
    curl -fsSL "$REPO_URL/raw/main/README.md" -o README.md

    # Create directory structure
    mkdir -p src/core src/utils src/windows

    # Download Python files
    curl -fsSL "$REPO_URL/raw/main/src/core/v5_system.py" -o src/core/v5_system.py
    curl -fsSL "$REPO_URL/raw/main/src/utils/messaging.py" -o src/utils/messaging.py
    curl -fsSL "$REPO_URL/raw/main/src/utils/goal_parser.py" -o src/utils/goal_parser.py
    curl -fsSL "$REPO_URL/raw/main/src/windows/window_a.py" -o src/windows/window_a.py
    curl -fsSL "$REPO_URL/raw/main/src/windows/window_b.py" -o src/windows/window_b.py
    curl -fsSL "$REPO_URL/raw/main/src/windows/window_c.py" -o src/windows/window_c.py
    curl -fsSL "$REPO_URL/raw/main/src/windows/window_d.py" -o src/windows/window_d.py
    curl -fsSL "$REPO_URL/raw/main/src/windows/window_e.py" -o src/windows/window_e.py

    # Create Python module files
    touch src/__init__.py src/core/__init__.py src/utils/__init__.py src/windows/__init__.py

    # Make scripts executable
    chmod +x install.sh v5
}

# Function to download V5
download_v5() {
    local install_dir="$1"

    echo -e "${BLUE}📥 Downloading V5 to $install_dir...${NC}"

    if command_exists git; then
        # Use git clone (preferred method)
        if [[ -d "$install_dir" ]]; then
            echo -e "${YELLOW}Directory exists. Updating...${NC}"
            cd "$install_dir"
            git pull
        else
            git clone "$REPO_URL" "$install_dir"
        fi
    elif command_exists curl; then
        # Fallback to curl download
        echo -e "${BLUE}Git not found. Using curl to download...${NC}"
        create_directories "$install_dir"
        cd "$install_dir"

        # Download and extract files efficiently
        download_files_with_curl

    else
        echo -e "${RED}❌ Error: git or curl required. Please install one: sudo apt-get install git curl${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ V5 downloaded successfully${NC}"
}

# Function to create symlink
create_symlink() {
    local install_dir="$1"

    if [[ -L "$BIN_DIR/v5" ]]; then
        rm "$BIN_DIR/v5"
    fi

    ln -sf "$install_dir/v5" "$BIN_DIR/v5"
    echo -e "${GREEN}✅ Created symlink: $BIN_DIR/v5 -> $install_dir/v5${NC}"
}

# Main installation function
main() {
    echo -e "${BLUE}🔍 Checking system requirements...${NC}"

    # Parse command line arguments
    INSTALL_LOCATION="$DEFAULT_INSTALL_DIR"
    USE_SYSTEM_INSTALL=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --system)
                USE_SYSTEM_INSTALL=true
                INSTALL_LOCATION="$INSTALL_DIR"
                shift
                ;;
            --dir=*)
                INSTALL_LOCATION="${1#*=}"
                shift
                ;;
            --dir)
                INSTALL_LOCATION="$2"
                shift
                shift
                ;;
            -h|--help)
                echo "V5 Remote Installer"
                echo ""
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --system              Install to system location (~/.local/share/v5)"
                echo "  --dir=PATH           Install to specific directory"
                echo "  --dir PATH           Install to specific directory"
                echo "  -h, --help           Show this help message"
                echo ""
                echo "Default installation directory: $DEFAULT_INSTALL_DIR"
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                echo "Use -h or --help for usage information"
                exit 1
                ;;
        esac
    done

    echo -e "${BLUE}📍 Installation directory: $INSTALL_LOCATION${NC}"

    # Create directories
    create_directories "$INSTALL_LOCATION"

    # Download V5
    download_v5 "$INSTALL_LOCATION"

    # Run the local installer
    echo -e "${BLUE}🔧 Running V5 installer...${NC}"
    cd "$INSTALL_LOCATION"
    chmod +x install.sh
    ./install.sh

    # Create symlink for system-wide access
    if [[ "$USE_SYSTEM_INSTALL" == "true" ]] || [[ "$INSTALL_LOCATION" == "$INSTALL_DIR" ]]; then
        create_symlink "$INSTALL_LOCATION"
        add_to_path
    else
        # For custom directory installations, inform user about manual setup
        echo -e "${YELLOW}📌 V5 installed to: $INSTALL_LOCATION${NC}"
        echo -e "${BLUE}To use V5 from anywhere, you can:${NC}"
        echo -e "${BLUE}1. Add to your PATH: export PATH=\"$INSTALL_LOCATION:\$PATH\"${NC}"
        echo -e "${BLUE}2. Create an alias: alias v5='$INSTALL_LOCATION/v5'${NC}"
        echo -e "${BLUE}3. Create a symlink: ln -sf $INSTALL_LOCATION/v5 $BIN_DIR/v5${NC}"
    fi

    # Installation complete
    echo ""
    echo -e "${GREEN}✨ V5 INSTALLATION COMPLETE ✨${NC}"
    echo "================================="
    echo ""
    echo -e "${GREEN}🎉 V5 is ready to use!${NC}"
    echo ""
    echo -e "${BLUE}🚀 Quick Start:${NC}"

    if [[ "$USE_SYSTEM_INSTALL" == "true" ]] || [[ "$INSTALL_LOCATION" == "$INSTALL_DIR" ]]; then
        echo "1. Restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
        echo "2. Initialize a project:  v5 /path/to/your/project init"
        echo "3. Start V5 tool:        v5 /path/to/your/project start"
    else
        echo "1. Initialize a project:  $INSTALL_LOCATION/v5 /path/to/your/project init"
        echo "2. Start V5 tool:        $INSTALL_LOCATION/v5 /path/to/your/project start"
    fi

    echo "4. Work in Window A and let the other 4 windows assist you!"
    echo ""
    echo -e "${BLUE}📖 Documentation: $INSTALL_LOCATION/README.md${NC}"
    echo -e "${GREEN}🎯 Ready to transform your development workflow!${NC}"
}

# Run main function
main "$@"
