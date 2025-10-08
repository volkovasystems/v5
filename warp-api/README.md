# Warp Terminal Control API

**Pixel-perfect GUI automation for Warp terminal with comprehensive testing infrastructure**

[![Version](https://img.shields.io/badge/version-0.2.0-blue.svg)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Testing](https://img.shields.io/badge/testing-BATS-orange.svg)](tests/)

## Overview

A focused API for programmatic Warp terminal control with production-ready testing infrastructure. Features pixel-perfect GUI automation, comprehensive verification, and a complete VirtualBox-based testing environment.

## Goals
1. **Control Warp GUI programmatically** (launch/close windows, add/remove tabs)  
2. **Suspend human interaction during control** (xtrlock input locking)
3. **Verify each action comprehensively** (screenshots + process verification)  
4. **Generate detailed per-action reports** (JSON with timestamps)
5. **Provide comprehensive testing environment** (VirtualBox + VM snapshots)

## 🚀 Quick Start

**VirtualBox Testing Environment (Recommended)**
```bash
cd tests/
./test.sh test              # Zero-setup testing with VM automation
./test.sh vm-status         # Check VM state
./test.sh vm-clone          # Clone pristine environment
```

**Direct Host Testing**  
```bash
python3 warp_api.py test    # Run basic test suite on host
python3 warp_api.py report  # Show latest results
```

**Instant Testing After Clone**
```bash
git clone <repository>
cd warp-api/tests
./test.sh test              # Automatic pristine VM restore + testing
```

## 📋 Basic Operations

```bash
python3 warp_api.py launch     # Launch Warp window
python3 warp_api.py new-tab    # Add new tab
python3 warp_api.py close-tab  # Close current tab
python3 warp_api.py close      # Close Warp window
python3 warp_api.py test       # Run test suite
python3 warp_api.py report     # Show latest report
```

## 🔧 API Usage

```python
from warp_api import WarpAPI

api = WarpAPI()
api.launch_warp()      # Launch Warp
api.new_tab()          # Add tab  
api.close_tab()        # Close tab
api.run_basic_test()   # Run tests
```

## 📊 What You Get

**Comprehensive Testing Infrastructure:**
- **30+ BATS test scenarios** with TAP-compliant output
- **VirtualBox VM environment** (Ubuntu 22.04 + GUI) for isolated testing
- **Pristine VM snapshots** for instant 30-second environment resets
- **Multi-level cleanup system** with interactive menus and safety confirmations

**Detailed Test Results:**
- JSON reports with timestamps and success rates
- Before/after screenshots for visual verification
- Process verification (confirms Warp is running)
- Human input locking during automation to prevent interference

**Example Test Report:**
```json
{
  "session": {
    "timestamp": "2025-10-08T14:15:30.123456",
    "total_actions": 4,
    "successful_actions": 4,
    "failed_actions": 0,
    "success_rate": "100.0%"
  },
  "actions": [
    {
      "timestamp": "2025-10-08T14:15:30.123456",
      "action": "launch_warp",
      "success": true,
      "details": {
        "before_screenshot": "screenshots/before_launch_20251008_141530.png",
        "after_screenshot": "screenshots/after_launch_20251008_141533.png"
      }
    }
  ]
}
```

## 🛡️ Safety Features

- **Input Locking**: `xtrlock` prevents human interference during automation
- **Screenshots**: Visual verification of each action
- **Process Checks**: Confirms Warp is running
- **Emergency Unlock**: `Ctrl+Alt+F3` then `pkill -f xtrlock`

## ⚠️ System Requirements

### **Recommended Host System**
- **RAM**: 8GB+ total (6GB+ available recommended)
- **CPU**: 4+ cores (Intel VT-x/AMD-V virtualization support required)
- **Disk**: 20GB+ available space
- **OS**: Linux with X11 (Ubuntu 20.04+)
- **Virtualization**: Hardware virtualization enabled in BIOS

### **Required Software**
- **VirtualBox**: 6.1+ with kernel modules loaded
- **Vagrant**: 2.2+ for VM orchestration
- **Python**: 3.7+ with pip
- **Git**: For repository cloning and version control

### **VM Specifications** (Auto-configured)
- **RAM**: 4GB allocated to VM
- **CPUs**: 2 cores allocated to VM
- **OS**: Ubuntu 22.04 LTS with GNOME desktop
- **Storage**: ~8GB for VM image + snapshots

### **Auto-installed in VM**
- Warp Terminal (latest version)
- System utilities: xdotool, wmctrl, xtrlock
- Python packages: pyautogui, pillow
- BATS testing framework

### **Development Dependencies** (Optional)
- pyautogui (for GUI automation): `pip install pyautogui`
- pytest for additional testing

### **🔍 System Capability Check**
```bash
cd tests/
./test.sh check-system          # Comprehensive capability analysis
./test.sh check-system-quick     # Quick capability check
```

## 📁 Project Structure

```
warp-api/
├── warp_api.py          # Main API implementation (single file)
├── CHANGELOG.md         # Version history and release notes
├── README.md            # This file
└── tests/               # Comprehensive testing environment
    ├── test.sh          # Central test runner with VM lifecycle
    ├── test_helper.bash # Reusable test functions
    ├── warp_api.bats    # BATS test scenarios (30+ tests)
    ├── Vagrantfile      # VM configuration (Ubuntu 22.04 + GUI)
    ├── README.md        # Detailed testing documentation
    ├── .gitignore       # Test artifacts management
    ├── fixtures/        # Test data and configurations
    ├── logs/            # Test execution logs
    ├── reports/         # JSON test reports
    ├── results/         # Test results and summaries
    └── screenshots/     # Visual verification captures
```

## 🛠️ Troubleshooting

### **System Capability Issues**

**❌ Insufficient RAM**
- **Problem**: Less than 8GB total RAM or 6GB available
- **Solution**: Close other applications or add more RAM
- **Command**: `./test.sh check-system` for detailed analysis

**❌ Hardware Virtualization Disabled**
- **Problem**: VT-x/AMD-V not enabled in BIOS
- **Solution**: Enable virtualization in BIOS/UEFI settings
- **Check**: `grep -q "vmx\|svm" /proc/cpuinfo && echo "Supported" || echo "Not supported"`

**❌ VirtualBox Issues**
- **Problem**: VirtualBox not installed or kernel modules not loaded
- **Solution**: Install/reinstall VirtualBox: `sudo apt install virtualbox virtualbox-ext-pack`
- **Module fix**: `sudo modprobe vboxdrv`

**❌ Low Disk Space**
- **Problem**: Less than 20GB available space
- **Solution**: Free up disk space or use different storage location
- **Check**: `df -h .`

### **VM Performance Issues**
- Use `./test.sh vm-reset` to restore clean VM state
- Check system capability: `./test.sh check-system`
- Force testing despite warnings: `./test.sh test --force`

## 🎯 Use Cases

- **Development Workflows** - Automated terminal environment setup and management
- **GUI Testing** - Comprehensive automation testing for Warp terminal functionality  
- **Continuous Integration** - TAP-compliant test results for CI/CD pipelines
- **System Validation** - Pre-flight checks for VirtualBox testing capability
- **Demonstrations** - Reproducible terminal presentations and tutorials
- **Quality Assurance** - Pixel-perfect verification of GUI behavior
- **Research & Analysis** - Programmatic analysis of terminal GUI interactions

## 🔗 Documentation

- **[CHANGELOG.md](CHANGELOG.md)** - Version history and release notes
- **[tests/README.md](tests/README.md)** - Comprehensive testing environment guide
- **API Reference** - Inline documentation in `warp_api.py`

## 🤝 Contributing

Contributions are welcome! Please:

1. Follow [semantic versioning](https://semver.org/) for releases
2. Update the [CHANGELOG.md](CHANGELOG.md) with notable changes
3. Ensure comprehensive testing using the VM environment
4. Maintain backward compatibility within major versions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Ready to start?** 
- **New users**: `cd tests && ./test.sh test` (zero-setup with VM automation)
- **Quick host test**: `python3 warp_api.py test`
- **View results**: `python3 warp_api.py report`
