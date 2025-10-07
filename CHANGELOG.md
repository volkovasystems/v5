# Changelog

All notable changes to the V5 - 5 Strategies Productive Development Tool will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-07

**Initial Release**: Complete V5 - 5 Strategies Productive Development Tool implementation.

*This release represents the full implementation of V5 from conception to production-ready state, including all core features, installation systems, documentation, and version management.*

### Features Overview

V5 is a complete development productivity tool featuring:
- **5-Window Architecture**: Specialized autonomous agents working in parallel
- **Cross-Platform Support**: Linux, macOS, Windows WSL, Windows Native
- **One-Line Installation**: Remote deployment via curl command
- **Professional Version Management**: Single source of truth VERSION file system
- **Goal-Driven Development**: Repository objective-focused automation
- **Enterprise-Ready**: RabbitMQ messaging, virtual environments, robust error handling

### Added
- **Core V5 System Implementation**
  - Complete 5-window architecture with specialized autonomous agents
  - Window A: Interactive Development Hub (Human + AI)
  - Window B: Silent Code Fixer (Autonomous QA)
  - Window C: Pattern Learning Governor (Protocol Creator)
  - Window D: Governance QA Auditor (Standards Guardian)
  - Window E: Feature Insight Documentarian (Strategic Intelligence)

- **Installation System**
  - Remote installation script (`get-v5.sh`) with one-liner install capability
  - Local installation script (`install.sh`) with cross-platform support
  - Support for Linux, macOS, Windows WSL, and Windows Native
  - Automatic dependency management (Python3, pip, RabbitMQ)
  - Virtual environment setup with isolated dependencies
  - System-wide and custom directory installation options

- **Core Python Modules**
  - `src/core/v5_system.py`: Main system orchestrator
  - `src/utils/messaging.py`: RabbitMQ message bus with retry logic
  - `src/utils/goal_parser.py`: Repository goal parsing and validation
  - `src/windows/window_*.py`: Individual window implementations
  - Proper Python package structure with `__init__.py` files

- **Configuration & Documentation**
  - Comprehensive README with installation and usage instructions
  - Repository structure initialization with `.warp/` directory
  - Goal-driven development with `goal.yaml` configuration
  - Cross-platform compatibility documentation
  - Troubleshooting guides and manual installation fallbacks

- **Build & Distribution**
  - Git ignore configuration for clean repository
  - Requirements specification with exact dependencies
  - Executable permissions for all scripts
  - Production-ready repository URLs (volkovasystems/v5)

- **Version Management System**
  - Single source of truth `VERSION` file containing semantic version
  - Version display support across all components:
    - `./v5 --version` and `./v5 -v` flags in main executable
    - Version logging in Python V5System core on startup
    - Dynamic version fetching in remote installer (`get-v5.sh`)
    - Version display during local installation (`install.sh`)
    - Version command support in Python CLI (`python3 v5_system.py version`)
  - Consistent version propagation from single file to all tools
  - Professional version management following semantic versioning

### Technical Details
- **Dependencies**: `pika`, `psutil`, `watchdog`, `PyYAML`
- **Message Bus**: RabbitMQ for inter-window communication
- **File Watching**: Real-time repository monitoring
- **Process Management**: Autonomous window lifecycle management
- **Error Handling**: Robust error handling with graceful fallbacks

### Installation Commands
```bash
# Remote one-liner install
curl -fsSL https://raw.githubusercontent.com/volkovasystems/v5/main/get-v5.sh | bash

# Custom directory install
curl -fsSL https://raw.githubusercontent.com/volkovasystems/v5/main/get-v5.sh | bash -s -- --dir=/custom/path

# System-wide install
curl -fsSL https://raw.githubusercontent.com/volkovasystems/v5/main/get-v5.sh | bash -s -- --system

# Local clone install
git clone https://github.com/volkovasystems/v5
cd v5 && ./install.sh
```

### Version Management
```bash
# Check version from any component
./v5 --version                    # Main executable version check
./v5 -v                          # Short version flag
python3 src/core/v5_system.py -v # Python system version

# Version is automatically displayed during installation
./install.sh                     # Shows: Installing V5 v1.0.0
curl -fsSL https://raw.githubusercontent.com/volkovasystems/v5/main/get-v5.sh | bash
# Remote installer fetches and displays current version

# Single file controls all versions
cat VERSION                      # Contains: 1.0.0
```

### Repository Structure
```
v5/
├── VERSION             # Single source of truth for version number
├── get-v5.sh           # Remote installation script
├── install.sh          # Local installation script
├── v5                  # Main executable
├── requirements.txt    # Python dependencies
├── README.md           # Comprehensive documentation
├── CHANGELOG.md        # This changelog
├── LICENSE             # MIT License
└── src/                # Source code
    ├── core/           # Core system modules
    ├── utils/          # Utility modules
    └── windows/        # Window implementations
```

---

*This is the initial public release of V5. All features listed above represent the complete first version of the tool, ready for production use with full cross-platform support and professional installation system.*
