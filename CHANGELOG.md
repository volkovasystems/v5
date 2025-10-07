# Changelog

All notable changes to the V5 - 5 Strategies Productive Development Tool will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-10-08

**Major Enhancement**: Consolidated Installation & Uninstall Scripts

### Added
- **Unified Installation Script**: Single `install.sh` with global installation as default
- **Comprehensive Uninstall Script**: `uninstall.sh` with repository, machine, and complete removal options
- **Interactive Uninstall Menu**: User-friendly selection when no flags provided
- **Dry Run Support**: Preview changes with `--dry-run` flag for both install and uninstall
- **Flexible Installation Modes**: `--global` (default) and `--local` options

### Enhanced
- **Concise Script Management**: Reduced from 3 separate scripts to 2 unified scripts
- **Better User Experience**: Clear distinction between repository and machine-level operations
- **Improved Documentation**: Comprehensive uninstallation section in README
- **Smart Dependency Detection**: Enhanced Python and system package checking

### Installation Changes

**New unified install.sh:**
```bash
# Global installation (default)
./install.sh

# Local installation only
./install.sh --local

# Check dependencies
./install.sh --check-deps

# Preview installation
./install.sh --dry-run
```

**New unified uninstall.sh:**
```bash
# Interactive menu
./uninstall.sh

# Specific uninstall modes
./uninstall.sh --repo      # Repository only
./uninstall.sh --machine   # Machine only
./uninstall.sh --complete  # Both
```

### Removed
- **install-global.sh**: Functionality merged into main install.sh
- **uninstall-global.sh**: Replaced with comprehensive uninstall.sh

### Technical Improvements
- Enhanced error handling and user feedback
- Consistent color coding and output formatting
- Better cross-platform compatibility
- Improved sudo privilege management

---

## [1.1.0] - 2025-10-08

**Major Enhancement**: Global Installation and Enhanced Repository Detection

### Added
- **Global Installation Support**: New `install-global.sh` script creates system-wide `v5` command
- **Auto Git Repository Detection**: Automatically finds git repository root from current directory
- **Enhanced CLI Interface**: Improved argument parsing with better help system
- **Repository Path Arguments**: Optional repository path argument, defaults to current git repo
- **Smart Directory Navigation**: Works from any directory within a git repository
- **Global Uninstall Script**: `uninstall-global.sh` for clean removal of global installation

### Enhanced
- **Improved User Experience**: Run `v5` from anywhere within any git repository
- **Better Error Messages**: Clear feedback when not in a git repository
- **Command Examples**: Enhanced help with practical usage examples
- **Installation Documentation**: Updated README with global installation instructions

### Usage Improvements

After global installation:
```bash
# Navigate to any git repository
cd /path/to/your/project

# Run V5 commands directly
v5              # Initialize and start
v5 init         # Initialize only
v5 status       # Check status
v5 help         # Show help
```

### Technical Changes
- Enhanced `v5_tool.py` with automatic git root detection
- Improved CLI argument parsing and validation
- Added repository path resolution logic
- Better error handling for non-git directories

---

## [1.0.0] - 2025-10-07

**Initial Release**: V5 - 5 Strategies Productive Development Tool

*A lean, concise, performant productive development tool that transforms how you code using five specialized window strategies.*

### Core Features

**5-Window Architecture**
- **Window A**: Interactive Development Hub (Human + AI)
- **Window B**: Silent Code Quality Enhancer (Productive QA)
- **Window C**: Pattern Learning Governor (Protocol Creator)
- **Window D**: Standards Guardian (Quality Assurance)
- **Window E**: Feature Insight Documentarian (Strategic Intelligence)

**Installation & Deployment**
- One-line remote installation via curl
- Cross-platform support (Linux, macOS, Windows WSL, Windows Native)
- Automatic dependency management (Python3, pip, RabbitMQ)
- Virtual environment setup with isolated dependencies

**Core Implementation**
- `src/core/v5_tool.py`: Main tool controller
- `src/utils/messaging.py`: RabbitMQ message bus
- `src/utils/goal_parser.py`: Repository goal parsing
- `src/windows/window_*.py`: Individual window implementations
- Professional version management system

**Testing Infrastructure**
- BATS test suite with TAP-compliant output
- Docker-based isolated testing environment
- Automatic timestamp preservation for clean repositories
- Comprehensive test runner with CI/CD integration

### Installation

```bash
# Remote one-liner install
curl -fsSL https://raw.githubusercontent.com/volkovasystems/v5/main/get-v5.sh | bash

# Local install
git clone https://github.com/volkovasystems/v5
cd v5 && ./install.sh
```

### Usage

```bash
# Initialize repository
./v5 /path/to/project init

# Start V5 tool
./v5 /path/to/project start

# Check version
./v5 --version
```

---

*V5: Where productive development meets human creativity* 🚀
