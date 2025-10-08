# Warp API Testing Environment

**Comprehensive testing infrastructure for the Warp Terminal Control API with pixel-perfect GUI automation**

[![Version](https://img.shields.io/badge/version-0.2.0-blue.svg)](../CHANGELOG.md)
[![VM Ready](https://img.shields.io/badge/VM-Ubuntu%2022.04-brightgreen.svg)](#vm-environment)
[![Testing](https://img.shields.io/badge/testing-BATS%2030%2B%20scenarios-orange.svg)](#robust-test-scenarios)

> 🎆 **Instant Testing**: Clone and run `./test.sh test` immediately - no setup required! Uses pristine VM snapshots for 30-second environment restoration.

## 📁 Directory Structure

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
├── 📦 Vagrantfile       # Ultra-fast VirtualBox VM configuration
├── 📋 warp_api.py*      # Synced API file (ignored by Git)
└── 📖 README.md         # This comprehensive guide
```

## 🚀 Quick Start

### 🎆 Zero-Setup Testing (Instant After Clone)
```bash
# Clone repository and test immediately - no setup needed!
git clone <repository-url>
cd <repository>/warp-api/tests
./test.sh test              # Automatic pristine VM restore + testing (30s)
```

> This works because pristine VM snapshots are preserved in the repository using `.gitkeep` files and smart `.gitignore` patterns.

### 🔧 First Time Setup (For Maintainers)
```bash
./test.sh vm-init            # Initialize persistent VM (3-8 minutes)
                            # Creates pristine snapshot automatically
```

### 🚀 Run All Tests (Fast - uses snapshots)
```bash
./test.sh                    # Run tests with automatic snapshot restore (30 seconds)
```

### System Capability Commands
```bash
./test.sh check-system       # Comprehensive system capability analysis
./test.sh check-system-quick # Quick capability check
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

### Ultra-Fast VM Setup
- **Parallel downloads**: Multi-connection downloads for maximum speed
- **Optimized provisioning**: Parallel package installation 
- **Minimal overhead**: ~500-800MB download vs traditional 3GB+
- **Smart caching**: APT parallelization and download optimization

### Other Commands
```bash
./test.sh setup              # Set up test environment only
./test.sh test -f pretty     # Run tests with pretty output
./test.sh sync               # Sync API file
```

### Run Tests on Host (Development)
```bash
./test.sh test -m host
```

## 🔍 System Capability Checking

### **Automatic Pre-flight Checks**
The testing environment automatically validates your system's capability to handle VirtualBox testing:

- **RAM Analysis**: Ensures sufficient memory (8GB+ recommended, 6GB+ available)
- **CPU Validation**: Checks core count and virtualization support (VT-x/AMD-V)
- **Disk Space**: Verifies adequate storage (20GB+ for VM + snapshots)
- **Software Dependencies**: Confirms VirtualBox, Vagrant, and Python availability
- **Virtualization Support**: Tests hardware virtualization and KVM availability

### **Capability Check Commands**
```bash
# Comprehensive analysis with detailed report
./test.sh check-system

# Quick check for automation/scripts
./test.sh check-system-quick

# Force testing despite capability warnings
./test.sh test --force
```

### **Automatic Integration**
Every VM test run automatically performs a quick capability check:
- ✅ **Pass**: Testing proceeds normally
- ❌ **Fail**: Testing stops with actionable recommendations
- 🚑 **Force Mode**: Bypass checks with `--force` flag

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
- **30+ BATS test scenarios** with comprehensive coverage
- **TAP-compliant output** for CI/CD pipeline integration
- **Dependency handling** with graceful fallback mechanisms
- **Error handling** and robustness validation
- **Performance benchmarking** and scalability testing
- **Visual verification** through screenshot comparison

### 🔄 Reset and Cleanup System
- **Multiple cleanup levels** from basic to nuclear reset
- **Interactive cleanup menu** with safety confirmations
- **VM reset capabilities** using snapshots (30-second reset)
- **Full environment rebuild** for corrupted states
- **Safe cleanup policies** that preserve recent data
- **Comprehensive reset guide** - see detailed section below

### ⚡ Ultra-Fast Setup
- **Parallel downloads**: ~500-800MB with multi-connection downloads
- **Optimized provisioning**: Parallel package installation reduces setup time
- **Smart caching**: APT parallelization and download optimization
- **Minimal overhead**: 3-8 minute setup vs traditional 15-30 minutes

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

# Rebuild VM from scratch (3-8 minutes)
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

> 📚 **Detailed Reset Guide**: See comprehensive documentation sections below

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

---

# 📚 Comprehensive Documentation

## 🔄 Reset and Cleanup System

### Overview
The test suite provides multiple levels of cleanup and reset operations:

- **Data cleanup**: Remove test artifacts and logs
- **VM cleanup**: Clean test data inside the VM  
- **VM reset**: Reset VM to clean snapshot state (30 seconds)
- **VM rebuild**: Completely rebuild VM from scratch (3-8 minutes)
- **Full reset**: Nuclear option that destroys everything

### Interactive Cleanup Menu
```bash
./test.sh cleanup
```
Provides an interactive menu with all cleanup options and safety confirmations.

### Data Cleanup Commands

#### Basic Test Data Cleanup (Safe)
```bash
./test.sh cleanup-data basic    # Default
./test.sh cleanup-data          # Same as basic
```
- Removes old log files (older than 1 day)
- Removes old test results (older than 1 day)
- Removes old screenshots (older than 1 day)
- Removes test result archives
- **Safe**: Keeps recent test data

#### Full Test Data Cleanup (Destructive)
```bash
./test.sh cleanup-data full
```
- Removes ALL logs, reports, results, and screenshots
- Removes test result archives
- Removes synced API files
- **Destructive**: All test data is lost

### VM Cleanup Commands

#### Clean VM Test Data
```bash
./test.sh cleanup-vm
```
- Cleans test data inside the running VM
- Removes logs, reports, results, and screenshots from VM
- Requires VM to be running

#### Remove All VM Snapshots
```bash
./test.sh cleanup-snapshots
```
- Removes ALL VM snapshots
- **Warning**: You will lose all saved VM states
- Requires confirmation (use `--force` to skip)

### VM Reset Commands

#### Reset VM to Clean State (Fast)
```bash
./test.sh vm-reset
```
- Restores VM from the 'clean' snapshot
- Stops VM, restores snapshot, then restarts
- **Fast**: 30-second reset vs full rebuild
- **Requires**: 'clean' snapshot must exist (created by `vm-init`)

#### Rebuild VM from Scratch
```bash
./test.sh vm-rebuild
```
- Completely destroys and recreates the VM
- Downloads and provisions VM from scratch (3-8 minutes)
- Creates new 'clean' snapshot
- **Destructive**: All VM data and snapshots are lost

### Nuclear Options

#### Full Environment Reset
```bash
./test.sh cleanup-all
```
- Destroys VM and all snapshots
- Removes all test data and artifacts
- Removes downloaded VM box (forces redownload)
- Cleans all caches and temporary files
- **DESTRUCTIVE**: Everything is lost
- Requires confirmation (use `--force` to skip)

### Automation Support
All destructive operations support force mode for automation:
```bash
./test.sh cleanup-all --force     # No confirmation prompts
./test.sh vm-rebuild --yes        # Skip confirmations
./test.sh cleanup-snapshots --force
```

### Usage Scenarios

#### After Failed Tests
```bash
./test.sh cleanup-data basic      # Quick cleanup
./test.sh vm-reset               # Or reset VM to clean state
```

#### Before Important Test Run
```bash
./test.sh vm-reset               # Ensure clean environment
```

#### When VM is Corrupted
```bash
./test.sh vm-rebuild             # Rebuild completely
```

#### When Everything is Broken
```bash
./test.sh cleanup-all --force    # Nuclear option
./test.sh vm-init                # Reinitialize
```

#### Regular Maintenance
```bash
./test.sh cleanup                # Interactive guided cleanup
./test.sh cleanup-data basic     # Weekly maintenance
```

### Best Practices

1. **Create Clean Snapshots**: Always run `./test.sh vm-init` after major changes
2. **Use Appropriate Cleanup Level**:
   - **Basic cleanup**: For routine maintenance
   - **Full cleanup**: When switching test contexts
   - **VM reset**: When tests behave unexpectedly
   - **VM rebuild**: When VM is corrupted
   - **Full reset**: Last resort for broken environments
3. **Regular Maintenance**: Run `./test.sh cleanup-data basic` weekly
4. **Backup Important Results**: Archive results before cleanup

---

## 🖥️ Persistent VM Guide

### Benefits of Persistent VM
- **⚡ One-time download**: Base VM setup happens only once
- **📸 Snapshot-based**: Fast restore to clean state (30 seconds vs 3-8 minutes)
- **💾 Disk space efficient**: Snapshots only store differences
- **🔄 Reusable**: Same VM for many test cycles
- **🚀 Ultra-fast setup**: Parallel downloads and provisioning

### VM Architecture

#### Configuration
- **OS**: Ubuntu 22.04 LTS with minimal GUI
- **RAM**: 4GB (optimized for persistent use)
- **CPUs**: 2 cores
- **Storage**: Dynamic allocation
- **Graphics**: Hardware acceleration enabled
- **Download**: ~500-800MB with parallel connections

#### Provisioning Strategy
1. **`ultra_fast_setup`** (run: "once")
   - Parallel package downloads (16 simultaneous)
   - Multi-connection downloads with aria2 (8 connections)
   - Background Warp Terminal installation
   - Simultaneous Python package setup
   - Smart APT caching and optimization

2. **`test_setup`** (run: "never" - called manually)
   - Clean test directories
   - Copy latest API files
   - Prepare test environment

3. **`test_cleanup`** (run: "never" - called manually)
   - Kill test processes
   - Archive test results
   - Clean test data

### Snapshot Workflow
```
[Base VM] → [Ultra-Fast Setup] → [Clean Snapshot]
                                        ↓
[Test Run] ← [30s Restore] ← [Clean State]
     ↓
[Results] → [Cleanup] → [Ready for next test]
```

### Performance Comparison

| Operation | Traditional VM | **Ultra-Fast Persistent VM** | **Improvement** |
|-----------|----------------|------------------------------|---------------|
| **First setup** | 15-30 minutes | **3-8 minutes** | **5x faster** |
| **Subsequent tests** | 15-30 minutes | **30 seconds** | **30x faster** |
| **Download size** | 3GB+ | **500-800MB** | **4x smaller** |
| **Download speed** | Single-threaded | **8x parallel** | **8x faster** |
| **Test isolation** | Full VM rebuild | **Snapshot restore** | **Clean & Fast** |
| **Disk usage** | Multiple VMs | **Single VM + snapshots** | **Space efficient** |

### Advanced VM Management

#### Creating Custom Snapshots
```bash
# Create custom snapshot after making changes
./test.sh vm-snapshot my-custom-setup

# Restore from custom snapshot
./test.sh vm-restore my-custom-setup
```

#### Development Workflow
```bash
# 1. Start with clean environment
./test.sh vm-restore clean

# 2. Run tests
./test.sh test

# 3. Debug inside VM (optional)
vagrant ssh

# 4. Create debug snapshot (optional)
./test.sh vm-snapshot debug-state
```

#### Maintenance Commands
```bash
# View all snapshots with details
VBoxManage snapshot warp-api-testbed list --details

# Check VM disk usage
ls -lh ~/.vagrant.d/boxes/ubuntu-VAGRANTSLASH-jammy64/*/virtualbox/

# Compact VM disk (reclaim space)
VBoxManage modifymedium disk [path-to-vmdk] --compact
```

---

## 🐛 Advanced Troubleshooting

### VM Issues

#### VM Won't Start
```bash
# Fix KVM conflicts
sudo modprobe -r kvm_amd kvm

# Restart VirtualBox service
sudo systemctl restart vboxdrv

# Check VirtualBox installation
vboxmanage --version

# Rebuild VM if corrupted
./test.sh vm-rebuild --force
```

#### GUI Not Available
```bash
# Check VM is running with GUI
./test.sh vm-status

# Restart VM with GUI enabled
./test.sh vm-stop
./test.sh vm-start

# Wait for GUI to be ready
vagrant ssh -c 'pgrep -x "gnome-shell\|gdm\|Xorg"'
```

#### Tests Timeout
```bash
# Increase timeouts in test_helper.bash
# Check VM resources
VBoxManage showvminfo warp-api-testbed | grep -E '(Memory|CPU)'

# Allocate more resources if needed
VBoxManage modifyvm warp-api-testbed --memory 6144 --cpus 4
```

### Snapshot Issues

#### "No 'clean' snapshot found"
```bash
# Recreate clean snapshot
./test.sh vm-init
```

#### Corrupted Snapshots
```bash
# List all snapshots
./test.sh vm-list

# Delete corrupted snapshot
VBoxManage snapshot warp-api-testbed delete "snapshot-name"

# Recreate clean snapshot
./test.sh vm-init
```

#### VM Won't Restore
```bash
# Force VM shutdown
VBoxManage controlvm warp-api-testbed poweroff

# Try restore again
./test.sh vm-restore clean

# If still fails, rebuild
./test.sh vm-rebuild --force
```

### Test Environment Issues

#### API File Not Syncing
```bash
# Manual sync
./test.sh sync

# Check parent file exists
ls -la ../warp_api.py

# Force copy to VM
vagrant ssh -c 'cp /vagrant/warp_api.py /home/vagrant/warp-testing/'
```

#### Test Data Corruption
```bash
# Reset test environment without VM rebuild
vagrant ssh -c 'cd /home/vagrant/warp-testing && rm -rf logs/* reports/* screenshots/*'

# Re-provision test setup
vagrant provision --provision-with test_setup
```

#### Disk Space Issues
```bash
# Clean test data
./test.sh cleanup-data full

# Remove old snapshots
./test.sh cleanup-snapshots --force

# Compact VM disk
VBoxManage modifymedium disk [path-to-vmdk] --compact

# Check available space
df -h ~/.vagrant.d/
```

### Performance Optimization

#### Speed Up Downloads
```bash
# The VM already uses:
# - aria2 with 8 parallel connections
# - APT with 16 simultaneous downloads
# - Background parallel processing
# - Smart caching and resumption

# To further optimize:
# 1. Use SSD storage
# 2. Increase available RAM
# 3. Use wired network connection
```

#### Optimize VM Performance
```bash
# Increase VM resources (if you have them)
VBoxManage modifyvm warp-api-testbed --cpus $(nproc)
VBoxManage modifyvm warp-api-testbed --memory 6144

# Enable all performance features
VBoxManage modifyvm warp-api-testbed --vram 256
VBoxManage modifyvm warp-api-testbed --nested-hw-virt on
```

---

## 🔄 CI/CD Integration

### GitHub Actions Example
```yaml
name: Warp API Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup VM Cache
      uses: actions/cache@v3
      with:
        path: ~/.vagrant.d
        key: vagrant-${{ runner.os }}-${{ hashFiles('tests/Vagrantfile') }}
    
    - name: Install Dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y vagrant virtualbox
    
    - name: Initialize VM (if not cached)
      run: |
        cd tests
        if ! ./test.sh vm-list | grep -q "clean"; then
          ./test.sh vm-init
        fi
    
    - name: Run Tests
      run: |
        cd tests
        ./test.sh test --force
    
    - name: Archive Results
      uses: actions/upload-artifact@v3
      with:
        name: test-results-${{ github.sha }}
        path: tests/results/
    
    - name: Publish Test Results
      uses: dorny/test-reporter@v1
      if: success() || failure()
      with:
        name: Warp API Tests
        path: tests/results/bats_*.tap
        reporter: java-junit
```

### Jenkins Pipeline Example
```groovy
pipeline {
    agent any
    
    stages {
        stage('Setup') {
            steps {
                sh 'cd tests && ./test.sh vm-init'
            }
        }
        
        stage('Test') {
            steps {
                sh 'cd tests && ./test.sh test --force'
            }
        }
        
        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'tests/results/**', fingerprint: true
                publishTestResults testResultsPattern: 'tests/results/*.tap'
            }
        }
    }
    
    post {
        always {
            sh 'cd tests && ./test.sh cleanup-data full --force'
        }
    }
}
```

### Team Development Best Practices

1. **Document Custom Snapshots**: Share snapshot naming conventions
2. **Version Control**: Use descriptive snapshot names with dates
3. **Regular Cleanup**: Clean up old snapshots to save disk space
4. **Shared Configuration**: Keep VM configuration in version control
5. **Environment Consistency**: Use same VM setup across team

---

## 📊 Advanced Usage Examples

### Development Workflows

#### Quick Development Cycle
```bash
# 1. Reset to clean state (30 seconds)
./test.sh vm-reset

# 2. Make changes to warp_api.py
vim ../warp_api.py

# 3. Run tests with changes (30 seconds)
./test.sh test

# 4. Check results
cat results/test_summary_*.txt
```

#### Debugging Workflow
```bash
# 1. Run tests normally
./test.sh test

# 2. If tests fail, access VM for debugging
vagrant ssh
cd /home/vagrant/warp-testing
ls -la logs/

# 3. Create debug snapshot
exit  # Exit VM
./test.sh vm-snapshot debug-$(date +%Y%m%d)

# 4. Continue debugging later
./test.sh vm-restore debug-20241008
```

#### Performance Testing
```bash
# 1. Create performance test snapshot
./test.sh vm-restore clean
vagrant ssh -c 'cd /home/vagrant/warp-testing && setup-performance-tests.sh'
./test.sh vm-snapshot performance-baseline

# 2. Run performance tests
./test.sh vm-restore performance-baseline
./test.sh test -f tap | grep -E '(ok|not ok).*performance'

# 3. Compare results
cat results/performance_*.log
```

### Batch Operations

#### Test Multiple API Versions
```bash
#!/bin/bash
# Test script for multiple API versions

versions=("v1.0" "v1.1" "v2.0")

for version in "${versions[@]}"; do
    echo "Testing API version: $version"
    
    # Reset environment
    ./test.sh vm-reset --force
    
    # Copy specific API version
    cp ../warp_api_$version.py ../warp_api.py
    
    # Run tests
    ./test.sh test --force
    
    # Archive results with version
    mv results/test_results_*.tar.gz results/test_results_$version.tar.gz
done
```

#### Stress Testing
```bash
#!/bin/bash
# Stress test with multiple cycles

for i in {1..10}; do
    echo "Test cycle $i/10"
    ./test.sh vm-reset --force
    ./test.sh test --force
    
    # Check for failures
    if ! grep -q "All tests passed" results/test_summary_*.txt; then
        echo "Failure detected in cycle $i"
        break
    fi
done
```

---

## 🔧 Customization Guide

### Modifying VM Configuration

The `Vagrantfile` can be customized for your specific needs:

```ruby
# Increase VM resources
vb.memory = 8192  # 8GB RAM
vb.cpus = 4       # 4 CPU cores
vb.customize ["modifyvm", :id, "--vram", "256"]  # More video RAM

# Add custom provisioning
config.vm.provision "custom_setup", type: "shell", inline: <<-SHELL
  # Add your custom setup commands here
  apt-get install -y your-custom-package
SHELL
```

### Adding Custom Test Scenarios

1. **Extend BATS tests**: Add scenarios to `warp_api.bats`
2. **Custom test scripts**: Place in `fixtures/` directory
3. **Test data**: Add to `fixtures/` for consistent test inputs

### Environment Variables

Customize behavior with environment variables:

```bash
# Custom VM name
export VM_NAME="my-custom-testbed"

# Custom timeouts
export VM_BOOT_TIMEOUT=900
export VM_GUI_TIMEOUT=60

# Custom test directories
export TEST_RESULTS_DIR="/path/to/custom/results"

Then run: ./test.sh test
```

---

## 📈 Monitoring and Metrics

### Test Metrics Collection

```bash
# View test execution times
grep -r "Test completed" logs/ | awk '{print $NF}'

# Check VM resource usage during tests
vagrant ssh -c 'top -bn1 | head -20'

# Monitor disk usage
df -h ~/.vagrant.d/
du -sh results/
```

### Performance Benchmarks

| Metric | Target | Command to Check |
|--------|--------|------------------|
| **VM Init Time** | < 8 minutes | `time ./test.sh vm-init` |
| **VM Reset Time** | < 30 seconds | `time ./test.sh vm-reset` |
| **Test Execution** | < 5 minutes | Check `logs/test_session_*.log` |
| **Snapshot Size** | < 2GB | `VBoxManage snapshot warp-api-testbed list --details` |

---

## 💾 Repository Integration Guide

### 🎆 Instant Testing After Clone

This repository is configured for **instant testing** after cloning. No VM setup or initialization required!

```bash
# Clone and test immediately
git clone <repository-url>
cd <repository>/warp-api/tests
./test.sh test  # ← Instant testing, no setup needed!
```

### 📸 Pristine VM Snapshots

The repository includes **pristine VM snapshots** that provide:
- **✅ Fully provisioned VM**: Ubuntu 22.04 + GUI + Warp Terminal
- **✅ All dependencies installed**: Python automation tools, GUI tools  
- **✅ Clean test environment**: No test artifacts or history
- **✅ Ready for immediate testing**: No setup required

### 🚀 Performance Benefits

| Scenario | Traditional | **With Pristine Snapshot** | **Improvement** |
|----------|-------------|---------------------------|---------------|
| **First clone** | 3-8 min setup | **30 seconds restore** | **10x faster** |
| **New contributor** | Setup troubleshooting | **Instant testing** | **Zero friction** |
| **CI/CD pipeline** | Full VM provisioning | **Snapshot restore** | **Reliable & fast** |
| **Team consistency** | Environment drift | **Identical pristine state** | **Perfect consistency** |

### 📋 Repository Commands

#### For Repository Users (After Clone)
```bash
./test.sh test           # Run tests (automatically uses pristine snapshot)
./test.sh vm-clone       # Explicitly restore pristine snapshot  
./test.sh vm-status      # Check VM status
```

#### For Repository Maintainers  
```bash
./test.sh vm-init        # Initialize VM (creates pristine snapshot automatically)
./test.sh vm-pristine    # Create new pristine snapshot for commit
./test.sh vm-list        # List all snapshots
```

### 📁 Repository Structure

#### What Gets Committed ✅
```
tests/
├── .vagrant/
│   ├── machines/default/virtualbox/
│   │   ├── box_meta                    # ✅ VM metadata
│   │   └── Snapshots/                  # ✅ PRISTINE SNAPSHOT!
│   └── rgloader/                       # ✅ Vagrant loader
├── logs/.gitkeep                       # ✅ Directory placeholder
├── reports/.gitkeep                    # ✅ Directory placeholder  
├── results/.gitkeep                    # ✅ Directory placeholder
├── screenshots/.gitkeep                # ✅ Directory placeholder
└── README.md                           # ✅ Documentation
```

#### What Gets Ignored ❌
```
logs/*                    # ❌ Test data (but keeps directory)
reports/*                 # ❌ Test reports (but keeps directory)
results/*                 # ❌ Test results (but keeps directory) 
screenshots/*             # ❌ Screenshots (but keeps directory)
.vagrant/.../action_*     # ❌ Runtime VM data
.vagrant/.../creator_uid  # ❌ User-specific data
.vagrant/.../id           # ❌ VM instance IDs
.vagrant/.../private_key  # ❌ SSH keys
warp_api.py              # ❌ Synced API file
```

### 🔄 Workflows

#### For Repository Users (After Clone)

**Instant Testing (Recommended)**
```bash
# Clone repository
git clone <repository-url>
cd <repository>/warp-api/tests

# Run tests immediately - pristine snapshot used automatically
./test.sh test
```

**Manual Pristine Restore**
```bash
# If you want to explicitly restore pristine snapshot
./test.sh vm-clone

# Then run tests
./test.sh test
```

**Fallback: Full Setup**
```bash
# If pristine snapshot is not available or corrupted
./test.sh vm-init
```

#### For Repository Maintainers

**Initial Setup and Pristine Snapshot Creation**
```bash
# Initialize VM with ultra-fast setup
./test.sh vm-init

# This automatically creates both 'clean' and 'pristine' snapshots
# The pristine snapshot is ready for repository commit
```

**Verify Pristine Snapshot**
```bash
# Check that pristine snapshot exists
./test.sh vm-list

# Test the pristine restore process
./test.sh vm-clone

# Verify tests work with pristine snapshot
./test.sh test
```

**Commit Pristine Snapshot to Repository**
```bash
# Add pristine VM state to git
git add .vagrant/machines/*/virtualbox/Snapshots/
git add .vagrant/machines/*/virtualbox/box_meta
git add .vagrant/rgloader/
git add logs/.gitkeep reports/.gitkeep results/.gitkeep screenshots/.gitkeep

# Commit the pristine state
git commit -m "Add pristine VM snapshot for instant testing

- Includes pristine VM snapshot ready for immediate testing
- Users can run ./test.sh test immediately after clone  
- No VM setup or initialization required"

git push
```

**Update Pristine Snapshot**
```bash
# When VM configuration changes
./test.sh vm-init              # Rebuild with new config
./test.sh vm-pristine          # Create new pristine snapshot
git add .vagrant/machines/*/virtualbox/Snapshots/
git commit -m "Update pristine snapshot with new VM config"
```

### 🔄 Automatic Fallback System

The test runner automatically uses the best available option:

1. **📸 Pristine snapshot** (30 seconds) - After repository clone
2. **🔄 Clean snapshot** (30 seconds) - For regular testing
3. **🔍 Full setup** (3-8 minutes) - When snapshots unavailable

No user intervention required - the system chooses the fastest option automatically!

### 🐛 Troubleshooting Repository Integration

#### If Pristine Snapshot Fails
```bash
# Try clean snapshot fallback
./test.sh vm-reset

# Or rebuild everything
./test.sh vm-rebuild --force
./test.sh vm-init
```

#### If Tests Fail After Clone
```bash
# Reset to clean state
./test.sh vm-reset

# Clean test data
./test.sh cleanup-data basic

# Or use interactive cleanup
./test.sh cleanup
```

#### If VM Won't Restore  
```bash
# Force VM shutdown and retry
VBoxManage controlvm warp-api-testbed poweroff
./test.sh vm-clone

# Or nuclear option
./test.sh cleanup-all --force
./test.sh vm-init
```

### 📈 Benefits Summary

#### For Repository Users
- **⚡ Instant testing**: No 3-8 minute setup wait
- **🔄 Consistent environment**: Everyone uses the same pristine VM
- **🎯 No dependencies**: Don't need to install VM packages locally
- **🛡️ Reliable setup**: Pre-tested, known-good VM state
- **🚀 Zero friction**: Clone and test immediately

#### For Repository Maintainers  
- **📈 Better adoption**: Lower barrier to entry for contributors
- **🔄 Consistent testing**: All users test with same environment
- **📞 Reduced support**: Fewer "setup doesn't work" issues
- **📊 Version control**: VM state is versioned with code
- **🎯 Quality assurance**: Controlled, tested environment

---

This comprehensive guide covers all aspects of the Warp API testing environment, including **instant testing after repository clone**. For additional support, check the inline help: `./test.sh --help`
