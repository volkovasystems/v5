# Changelog

All notable changes to the Warp Terminal Control API project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2025-10-08

### Fixed
- **Critical API Issues**: Added missing `_get_warp_processes()` method referenced in tests
- **Path Handling**: Standardized to use pathlib.Path objects consistently throughout
- **Process Detection**: Improved Warp process detection with fallback mechanisms
- **Test Isolation**: Enhanced BATS tests with proper test isolation and cleanup
- **VM Resource Detection**: Dynamic VM resource allocation based on host capabilities
- **Warp Installation**: Simplified and more reliable Warp Terminal installation with fallbacks

### Enhanced
- **Configuration Management**: Added WarpConfig class for better executable detection
- **Error Handling**: Consolidated error handling with safe_execute() method
- **Logging**: Comprehensive logging system with configurable levels
- **VM Performance**: Dynamic resource allocation (1/3 host RAM, half host CPUs)
- **Documentation**: Fixed version mismatches and updated system requirements

### Technical Improvements
- Improved BATS test reliability with unique test environments
- Better Warp executable detection (warp-terminal vs warp)
- Enhanced VM provisioning with graceful fallbacks
- Standardized JSON serialization for Path objects

## [0.2.0] - 2025-10-08

### Added
- **Comprehensive Testing Environment**: Complete VirtualBox-based testing infrastructure
  - Ubuntu 22.04 GUI environment for isolated testing
  - Vagrant configuration for reproducible VM setup
  - BATS test suite with 30+ comprehensive test scenarios
  - TAP-compliant output for CI/CD integration

- **Advanced VM Management**:
  - Persistent VM with snapshot management for fast test cycles (30-second resets)
  - Pristine VM snapshots for instant testing after repository clone
  - Multi-level reset and cleanup system with safety mechanisms
  - Interactive cleanup menu with guided options and confirmations

- **Enhanced Test Infrastructure**:
  - Central test runner (`test.sh`) with VM lifecycle management
  - Reusable test helper functions (`test_helper.bash`)
  - Single source of truth with automatic API file synchronization
  - Pixel-perfect GUI automation testing framework

- **Comprehensive Documentation**:
  - Complete testing environment setup guide
  - Reset and cleanup procedures documentation
  - Persistent VM management guide
  - Troubleshooting guides with fallback procedures

### Enhanced
- **Safety Features**: Nuclear reset option with confirmation prompts
- **User Experience**: Zero-setup testing immediately after repository clone
- **Maintenance**: Automated snapshot restoration and fallback mechanisms

### Technical Details
- VM Environment: Ubuntu 22.04 LTS with GNOME desktop
- Testing Framework: BATS (Bash Automated Testing System)
- VM Technology: VirtualBox with Vagrant orchestration
- Reset Capabilities: Snapshot-based 30-second VM reset
- Documentation: Consolidated single-source README approach

## [0.1.0] - 2025-10-08

### Added
- **Core Warp Terminal Control API** (`warp_api.py`)
  - Launch and close Warp terminal windows
  - Add and remove tabs programmatically
  - Keyboard shortcut automation (Ctrl+Shift+T, Ctrl+Shift+W)

- **Safety and Verification Features**:
  - Human input locking using `xtrlock` during automation
  - Screenshot capture before and after each action
  - Process verification to confirm Warp terminal state
  - Emergency unlock procedures (Ctrl+Alt+F3 + pkill)

- **Comprehensive Reporting**:
  - JSON reports with timestamps and success rates
  - Visual verification through before/after screenshots  
  - Session summaries with detailed action logging
  - Test result persistence in reports directory

- **Command Line Interface**:
  - Direct action execution (`launch`, `new-tab`, `close-tab`, `close`)
  - Built-in test suite (`test` command)
  - Report viewing (`report` command)
  - Graceful dependency handling with user guidance

- **Error Handling and Resilience**:
  - Graceful fallback when GUI automation unavailable
  - Proper cleanup of locked input sessions
  - Force-kill capabilities for stuck processes
  - Detailed error logging and user feedback

### Requirements
- Linux with X11 (Ubuntu 20.04+)
- Python 3.7+ with optional pyautogui for GUI automation
- Warp Terminal installation
- System utilities: xdotool, wmctrl, xtrlock

### File Structure
```
warp-api/
├── warp_api.py          # Main API implementation (single file)
├── README.md            # Project documentation
└── tests/               # Testing environment (added in v0.2.0)
```

### Use Cases
- Development workflow automation
- GUI testing for Warp terminal
- Reproducible terminal demonstrations  
- Programmatic analysis of Warp GUI behavior

---

## Development Notes

### Version Strategy
- **v0.1.0**: Core API functionality with basic testing
- **v0.2.0**: Comprehensive testing environment and infrastructure
- **Future**: Enhanced automation features and broader terminal support

### Contribution Guidelines
- Follow semantic versioning for releases
- Update changelog with all notable changes
- Ensure backward compatibility within major versions
- Include comprehensive testing for new features

### Testing Philosophy
The project emphasizes **pixel-perfect GUI automation** with comprehensive verification:
- Visual confirmation through screenshots
- Process state validation
- Human input isolation during automation
- Reproducible testing environments

For detailed setup and usage instructions, see the [README.md](README.md) and [tests/README.md](tests/README.md).