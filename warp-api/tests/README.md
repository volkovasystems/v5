# Warp API Testing Environment

This directory contains a comprehensive, organized testing environment for the Warp Terminal Control API with pixel-perfect automation capabilities.

## 🏗️ Directory Structure

```
tests/
├── 📁 fixtures/         # Test fixtures and sample data
├── 📁 logs/             # Test execution logs
├── 📁 reports/          # Test reports and summaries  
├── 📁 results/          # Test results (TAP format, archives)
├── 📁 screenshots/      # Screenshots from GUI tests
├── 🔧 test.sh*          # Main test runner script
├── 📚 test_helper.bash  # Reusable test functions (includes sync)
├── 🧪 warp_api.bats     # BATS test scenarios
├── 📦 Vagrantfile       # VirtualBox VM configuration
├── 📋 warp_api.py*      # Synced API file (ignored by Git)
└── 📖 README.md         # This file
```

## 🚀 Quick Start

### First Time Setup (One-time)
```bash
./test.sh vm-init            # Initialize persistent VM (15 minutes)
```

### Run All Tests (Fast - uses snapshots)
```bash
./test.sh                    # Run tests with snapshot restore (30 seconds)
```

### VM Management Commands
```bash
./test.sh vm-status          # Check VM status
./test.sh vm-start           # Start VM
./test.sh vm-stop            # Stop VM
./test.sh vm-list            # List snapshots
./test.sh vm-snapshot clean  # Create snapshot
./test.sh vm-restore clean   # Restore snapshot
./test.sh vm-reset           # Reset VM to clean state (fast)
./test.sh vm-rebuild         # Rebuild VM from scratch
```

### Cleanup and Reset Commands
```bash
./test.sh cleanup            # Interactive cleanup menu
./test.sh cleanup-data basic # Clean old test data (safe)
./test.sh cleanup-data full  # Clean all test data
./test.sh cleanup-vm         # Clean VM test data
./test.sh cleanup-snapshots  # Remove all VM snapshots
./test.sh cleanup-all        # Nuclear reset (destroys everything)
```

### Other Commands
```bash
./test.sh setup              # Set up environment only
./test.sh test -f pretty     # Run with pretty output
./test.sh sync               # Sync API file
```

### Run Tests on Host (Development)
```bash
./test.sh test -m host
```

## 🎯 Key Features

### ✅ Single Source of Truth
- **warp_api.py** is automatically synced from parent directory
- **Test copy is ignored by Git** (not committed to repository)
- **Consolidated sync logic** in test_helper.bash (no separate script needed)
- Ensures consistency between development and testing
- Use `./test.sh sync` to update manually

### 🖥️ Persistent VM Testing  
- **VirtualBox** VM with Ubuntu 22.04 + GUI
- **Pixel-perfect** automation environment
- **One-time setup** with snapshot-based reuse
- **No interference** with your working Warp instance
- **30x faster** subsequent test runs

### 📊 Comprehensive Logging
- **Structured directories** for different artifact types
- **TAP-compliant** output for CI/CD integration
- **Detailed session logs** with timestamps
- **Automatic archiving** of test results

### 🧪 Robust Test Scenarios
- **30+ BATS tests** covering all functionality
- **Dependency handling** and graceful fallbacks
- **Error handling** and robustness testing
- **Performance** and scalability testing

### 🔄 Reset and Cleanup System
- **Multiple cleanup levels** from basic to nuclear reset
- **Interactive cleanup menu** with safety confirmations
- **VM reset capabilities** using snapshots (30-second reset)
- **Full environment rebuild** for corrupted states
- **Safe cleanup policies** that preserve recent data
- **Comprehensive reset guide** - see [RESET_AND_CLEANUP.md](RESET_AND_CLEANUP.md)

## 🔧 Test Infrastructure

### Main Components

1. **test.sh** - Central test runner
   - Handles VM lifecycle management
   - Orchestrates test execution
   - Manages file synchronization
   - Archives results

2. **test_helper.bash** - Reusable functions
   - VM management utilities
   - File operations helpers (including API sync)
   - Logging and reporting functions
   - Color-coded output

3. **warp_api.bats** - Comprehensive test suite
   - Basic API functionality tests
   - Dependency and environment tests  
   - Core functionality validation
   - Error handling and robustness
   - Performance benchmarks

### VM Environment

The VirtualBox VM provides:
- **Ubuntu 22.04** with minimal desktop
- **Warp Terminal** pre-installed
- **Python automation stack** (PyAutoGUI, OpenCV, etc.)
- **GUI automation tools** (xdotool, wmctrl, xtrlock)
- **Organized directory structure**

## 📋 Usage Examples

### Basic Test Execution
```bash
# Run all tests with default settings
./test.sh

# Run tests with verbose output
./test.sh test -v

# Run only BATS tests on host
./test.sh test -m host -f pretty
```

### VM Management
```bash
# Start VM and set up environment
./test.sh setup

# Check VM status
./test.sh vm-status

# Stop VM when done
./test.sh vm-stop

# Clean up test artifacts
./test.sh cleanup -c full
```

### Development Workflow
```bash
# 1. Sync latest API changes
./test.sh sync

# 2. Run quick host tests for development
./test.sh test -m host

# 3. Run full VM tests for validation
./test.sh test

# 4. Check results
ls -la results/ logs/ reports/
```

## 🐛 Troubleshooting

### VM Issues
- **VM won't start**: Check VirtualBox installation and KVM conflicts
- **GUI not available**: Ensure VM started with GUI enabled
- **Tests timeout**: Increase timeout in test_helper.bash

### Common Solutions
```bash
# Fix KVM conflict
sudo modprobe -r kvm_amd kvm

# Quick VM reset (30 seconds)
./test.sh vm-reset

# Rebuild VM from scratch (15 minutes)
./test.sh vm-rebuild

# Clean test data only
./test.sh cleanup-data full

# Nuclear option (destroys everything)
./test.sh cleanup-all
```

### Reset and Cleanup Options
```bash
# Interactive cleanup menu with guidance
./test.sh cleanup

# Quick fixes for common issues
./test.sh vm-reset           # VM behaving strangely
./test.sh cleanup-data basic # Free up disk space
./test.sh vm-rebuild         # VM corrupted
./test.sh cleanup-all        # Start completely fresh
```

> 📚 **Detailed Reset Guide**: See [RESET_AND_CLEANUP.md](RESET_AND_CLEANUP.md) for comprehensive documentation

### Debug Mode
```bash
# Enable verbose output
./test.sh test -v

# Check logs
tail -f logs/test_session_*.log

# Manual VM access
vagrant ssh
```

## 📈 Results and Reports

### Test Artifacts
- **Logs**: `logs/test_session_*.log`
- **TAP Results**: `results/bats_*.tap`
- **Reports**: `reports/test_summary_*.txt`
- **Screenshots**: `screenshots/*.png`
- **Archives**: `results/test_results_*.tar.gz`

### Viewing Results
```bash
# Latest test session
ls -lt logs/ | head -5

# TAP results for CI
cat results/bats_*.tap

# Test reports
cat reports/test_summary_*.txt
```

## 🔄 Integration

### CI/CD Pipeline
```yaml
- name: Run Warp API Tests
  run: |
    cd tests
    ./test.sh test --tap-only > test_results.tap
    
- name: Publish Test Results
  uses: dorny/test-reporter@v1
  with:
    name: Warp API Tests
    path: tests/test_results.tap
    reporter: java-junit
```

### Git Hooks
```bash
# Pre-commit hook
echo './test.sh test -m host' > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## 📚 Architecture

This testing environment follows best practices:

- **Separation of Concerns**: Each script has a specific purpose
- **Single Responsibility**: Helper functions are focused and reusable
- **Error Handling**: Graceful fallbacks and informative error messages
- **Logging**: Comprehensive logging with structured output
- **Isolation**: VM-based testing prevents interference
- **Automation**: Minimal manual intervention required

The design ensures reliable, repeatable, and maintainable testing for pixel-perfect Warp Terminal automation.