#!/bin/bash
# V5 - 5 Strategies Productive Development Tool - Unified Uninstall Script
# Provides options for repository-only or machine-wide uninstallation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default uninstall mode
UNINSTALL_MODE=""
DRY_RUN=false

# Handle command line flags
for arg in "$@"; do
    case "$arg" in
        "--help"|"help"|"usage")
            echo "V5 - 5 Strategies Productive Development Tool - Uninstall Script"
            echo "================================================================"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Uninstall Modes:"
            echo "  --repo          Remove V5 from current repository only (removes .warp, features)"
            echo "  --machine       Remove V5 from machine (removes global command, keeps repos)"
            echo "  --complete      Complete removal (both repository and machine)"
            echo ""
            echo "Options:"
            echo "  --help          Show this help message"
            echo "  --dry-run       Show what would be removed without doing it"
            echo ""
            echo "Examples:"
            echo "  $0 --repo           # Remove V5 from current repository"
            echo "  $0 --machine        # Remove global V5 command only"
            echo "  $0 --complete       # Complete removal"
            echo "  $0 --dry-run --repo # Show what would be removed from repository"
            echo ""
            echo "Repository uninstall removes .warp/ and features/ directories."
            echo "Machine uninstall removes global 'v5' command and dependencies."
            echo "Complete uninstall does both."
            exit 0
            ;;
        "--repo")
            if [[ -n "$UNINSTALL_MODE" ]]; then
                echo -e "${RED}❌ Cannot specify multiple uninstall modes${NC}"
                exit 1
            fi
            UNINSTALL_MODE="repo"
            ;;
        "--machine")
            if [[ -n "$UNINSTALL_MODE" ]]; then
                echo -e "${RED}❌ Cannot specify multiple uninstall modes${NC}"
                exit 1
            fi
            UNINSTALL_MODE="machine"
            ;;
        "--complete")
            if [[ -n "$UNINSTALL_MODE" ]]; then
                echo -e "${RED}❌ Cannot specify multiple uninstall modes${NC}"
                exit 1
            fi
            UNINSTALL_MODE="complete"
            ;;
        "--dry-run")
            DRY_RUN=true
            ;;
        --*)
            echo -e "${RED}❌ Unknown option: $arg${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# If no mode specified, ask user
if [[ -z "$UNINSTALL_MODE" ]]; then
    # Check if we're in a non-interactive environment (no TTY for both input and output)
    if [[ ! -t 0 ]] && [[ ! -t 1 ]]; then
        echo -e "${RED}❌ Error: No uninstall mode specified and running in non-interactive environment${NC}"
        echo ""
        echo "Please specify an uninstall mode:"
        echo "  --repo          Remove V5 from current repository only"
        echo "  --machine       Remove V5 from machine only"
        echo "  --complete      Complete removal (both repository and machine)"
        echo ""
        echo "Example: $0 --repo"
        exit 1
    fi
    
    echo "V5 - 5 Strategies Productive Development Tool - Uninstall Script"
    echo "==============================================================="
    echo ""
    echo "What would you like to uninstall?"
    echo ""
    echo "1) Repository only  - Remove V5 from current repository (.warp, features)"
    echo "2) Machine only     - Remove global V5 command (keeps repository data)"
    echo "3) Complete removal - Remove both repository and machine installation"
    echo "4) Cancel           - Exit without removing anything"
    echo ""
    while true; do
        read -p "Enter your choice (1-4): " choice || {
            echo -e "\n${RED}❌ Error: Could not read input (non-interactive environment?)${NC}"
            echo -e "${BLUE}ℹ️  Use command line flags: --repo, --machine, or --complete${NC}"
            exit 1
        }
        case $choice in
            1)
                UNINSTALL_MODE="repo"
                break
                ;;
            2)
                UNINSTALL_MODE="machine"
                break
                ;;
            3)
                UNINSTALL_MODE="complete"
                break
                ;;
            4)
                echo -e "${BLUE}ℹ️  Cancelled by user${NC}"
                exit 0
                ;;
            *)
                echo "Please enter a valid choice (1-4)"
                ;;
        esac
    done
fi

# Display uninstall header
if [[ "$DRY_RUN" == "true" ]]; then
    echo ""
    echo -e "${YELLOW}🧹 V5 Dry Run Uninstallation (no actual removal)${NC}"
    echo "================================================="
else
    echo ""
    echo -e "${YELLOW}🗑️  V5 Uninstallation${NC}"
    echo "==================="
fi

case "$UNINSTALL_MODE" in
    "repo")
        echo -e "${BLUE}📋 Mode: Repository only (removes .warp and features from current directory)${NC}"
        ;;
    "machine")
        echo -e "${BLUE}🌐 Mode: Machine only (removes global command and dependencies)${NC}"
        ;;
    "complete")
        echo -e "${RED}💥 Mode: Complete removal (repository + machine)${NC}"
        ;;
esac

echo ""

# Function to remove directory with confirmation
remove_directory() {
    local dir_path="$1"
    local description="$2"
    
    if [[ -d "$dir_path" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "${YELLOW}   [DRY RUN] Would remove: $dir_path ($description)${NC}"
        else
            echo -e "${BLUE}🗂️  Removing $description: $dir_path${NC}"
            rm -rf "$dir_path"
            echo -e "${GREEN}   ✅ Removed successfully${NC}"
        fi
    else
        echo -e "${YELLOW}   ⚠️  $description not found: $dir_path${NC}"
    fi
}

# Function to remove file with confirmation
remove_file() {
    local file_path="$1"
    local description="$2"
    
    if [[ -f "$file_path" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "${YELLOW}   [DRY RUN] Would remove: $file_path ($description)${NC}"
        else
            echo -e "${BLUE}🗃️  Removing $description: $file_path${NC}"
            rm -f "$file_path"
            echo -e "${GREEN}   ✅ Removed successfully${NC}"
        fi
    else
        echo -e "${YELLOW}   ⚠️  $description not found: $file_path${NC}"
    fi
}

# Repository uninstallation
uninstall_repository() {
    echo -e "${BLUE}🏠 Removing V5 from current repository...${NC}"
    
    # Get current directory
    CURRENT_DIR="$(pwd)"
    echo "   Working directory: $CURRENT_DIR"
    
    # Remove .warp directory
    remove_directory "$CURRENT_DIR/.warp" "V5 configuration directory (.warp)"
    
    # Remove features directory
    remove_directory "$CURRENT_DIR/features" "V5 features directory"
    
    # Remove any V5-specific files in the repository
    remove_file "$CURRENT_DIR/.v5_config" "V5 local config file"
    remove_file "$CURRENT_DIR/v5.log" "V5 log file"
    
    echo ""
    echo -e "${GREEN}✅ Repository cleanup complete${NC}"
    echo -e "${BLUE}ℹ️  Repository is now free of V5 files${NC}"
}

# Machine uninstallation
uninstall_machine() {
    echo -e "${BLUE}🌐 Removing V5 from machine...${NC}"
    
    # Check if running as root or with sudo for global command removal
    if [[ -f "/usr/local/bin/v5" ]]; then
        if [[ $EUID -eq 0 ]]; then
            SUDO=""
        else
            SUDO="sudo"
            if [[ "$DRY_RUN" != "true" ]]; then
                echo -e "${YELLOW}⚠️  This step requires sudo privileges to remove from /usr/local/bin${NC}"
            fi
        fi
        
        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "${YELLOW}   [DRY RUN] Would remove: /usr/local/bin/v5 (global command)${NC}"
        else
            echo -e "${BLUE}🗑️  Removing global v5 command...${NC}"
            $SUDO rm -f /usr/local/bin/v5
            echo -e "${GREEN}   ✅ Global command removed${NC}"
        fi
    else
        echo -e "${YELLOW}   ⚠️  Global v5 command not found at /usr/local/bin/v5${NC}"
    fi
    
    # Check if V5 installation directory exists
    V5_INSTALL_DIRS=(
        "$HOME/.local/share/v5"
        "$HOME/v5-tool"
        "/opt/v5"
        "/usr/local/v5"
    )
    
    for install_dir in "${V5_INSTALL_DIRS[@]}"; do
        if [[ -d "$install_dir" ]]; then
            echo -e "${BLUE}📁 Found V5 installation directory: $install_dir${NC}"
            if [[ "$DRY_RUN" == "true" ]]; then
                echo -e "${YELLOW}   [DRY RUN] Would ask to remove installation directory${NC}"
            else
                echo ""
                read -p "Remove V5 installation directory $install_dir? (y/N): " confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    remove_directory "$install_dir" "V5 installation directory"
                else
                    echo -e "${BLUE}   ℹ️  Keeping installation directory: $install_dir${NC}"
                fi
            fi
        fi
    done
    
    # Verify global command removal
    if command -v v5 > /dev/null 2>&1; then
        echo -e "${YELLOW}   ⚠️  v5 command still found in PATH${NC}"
        echo -e "${BLUE}   📍 Current v5 location: $(which v5)${NC}"
        echo -e "${YELLOW}   💡 You may need to manually remove it or restart your shell${NC}"
    else
        echo -e "${GREEN}   ✅ Global v5 command successfully removed from PATH${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}✅ Machine cleanup complete${NC}"
    echo -e "${BLUE}ℹ️  Global V5 command removed from system${NC}"
}

# Execute uninstallation based on mode
case "$UNINSTALL_MODE" in
    "repo")
        uninstall_repository
        ;;
    "machine")
        uninstall_machine
        ;;
    "complete")
        echo -e "${RED}🔥 Performing complete V5 removal...${NC}"
        echo ""
        uninstall_repository
        echo ""
        uninstall_machine
        ;;
esac

echo ""

# Final summary
if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}📋 DRY RUN COMPLETE${NC}"
    echo "=================="
    echo -e "${BLUE}ℹ️  This was a dry run - no files were actually removed${NC}"
    echo -e "${BLUE}ℹ️  Run without --dry-run to perform actual removal${NC}"
else
    echo -e "${GREEN}✨ UNINSTALLATION COMPLETE ✨${NC}"
    echo "=============================="
    
    case "$UNINSTALL_MODE" in
        "repo")
            echo -e "${GREEN}✅ V5 removed from current repository${NC}"
            echo -e "${BLUE}ℹ️  Global V5 command (if installed) is still available${NC}"
            echo -e "${BLUE}ℹ️  You can still use V5 in other repositories${NC}"
            ;;
        "machine")
            echo -e "${GREEN}✅ V5 removed from machine${NC}"
            echo -e "${BLUE}ℹ️  Existing repository V5 data (.warp, features) preserved${NC}"
            echo -e "${BLUE}ℹ️  You can still run V5 locally if installation files remain${NC}"
            ;;
        "complete")
            echo -e "${GREEN}✅ V5 completely removed${NC}"
            echo -e "${BLUE}ℹ️  All V5 files removed from repository and machine${NC}"
            echo -e "${BLUE}ℹ️  To use V5 again, you'll need to reinstall it${NC}"
            ;;
    esac
fi

echo ""
echo -e "${BLUE}💡 Need V5 again? Download from: https://github.com/volkovasystems/v5${NC}"