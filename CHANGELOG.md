# Changelog

All notable changes to the V5 - 5 Strategies Productive Development Tool will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [1.0.0] - 2025-10-07 (Development Version)

**Development Release**: V5 - 5 Strategies Productive Development Tool

*This version is under active development and not yet publicly released.*

### Latest Development Updates (2025-10-08)

**Test Suite Reorganization:**
- Separated installation and uninstallation tests into dedicated files
- `test_install.bats` (33 tests) and `test_uninstall.bats` (26 tests)
- Updated test commands: `./test install`, `./test uninstall`, `./test core-tool`
- TAP output files aligned with new structure
- Improved test maintainability with focused responsibilities

**Unified Installation & Uninstall Scripts:**
- Single `install.sh` with global installation as default
- Comprehensive `uninstall.sh` with repository, machine, and complete removal options
- Interactive uninstall menu and dry-run support
- Enhanced error handling and cross-platform compatibility

**Global Installation Support:**
- System-wide `v5` command installation
- Automatic git repository detection
- Enhanced CLI interface with improved argument parsing
- Smart directory navigation within git repositories

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

### Current Test Commands (Development)

```bash
# Run individual test suites
./test install      # 33 installation functionality tests
./test uninstall    # 26 uninstallation functionality tests
./test core-tool    # 13 core Python module tests

# Run all tests
./test all          # 72 total tests

# Generate TAP output
./test --local --tap install    # Generate install-tests-YYYY-MM-DD.tap
./test --local --tap uninstall  # Generate uninstall-tests-YYYY-MM-DD.tap
```

---

*V5: Where productive development meets human creativity* 🚀
