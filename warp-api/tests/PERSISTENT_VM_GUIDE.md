# Persistent VM Setup Guide

This guide explains how to use the persistent VirtualBox VM setup for efficient, reusable Warp API testing.

## 🎯 **Benefits of Persistent VM**

- **⚡ One-time download**: Base VM setup happens only once
- **📸 Snapshot-based**: Fast restore to clean state (seconds vs minutes)
- **💾 Disk space efficient**: Snapshots only store differences
- **🔄 Reusable**: Same VM can be used many times without re-provisioning
- **🚀 Faster test cycles**: No need to wait for OS installation and package downloads

## 🚀 **Quick Start**

### 1. Initial Setup (One-time)
```bash
# Initialize the persistent VM (downloads and sets up everything)
./test.sh vm-init
```

This will:
- Download Ubuntu 22.04 VM image (only once)
- Install all dependencies (Warp, Python, GUI tools)
- Create a "clean" snapshot for future use
- Takes ~10-15 minutes initially

### 2. Run Tests (Fast)
```bash
# Run tests using the persistent VM (fast)
./test.sh test
```

This will:
- Restore VM from "clean" snapshot (5-10 seconds)
- Set up fresh test environment
- Run your tests
- Clean up test data
- Ready for next test run

## 📋 **VM Management Commands**

### Basic VM Operations
```bash
./test.sh vm-status        # Check VM status
./test.sh vm-start         # Start the VM
./test.sh vm-stop          # Stop the VM
./test.sh vm-init          # Initialize VM (first time setup)
```

### Snapshot Management
```bash
./test.sh vm-list          # List all snapshots
./test.sh vm-snapshot      # Create 'clean' snapshot
./test.sh vm-snapshot dev  # Create 'dev' snapshot
./test.sh vm-restore clean # Restore from 'clean' snapshot
./test.sh vm-restore dev   # Restore from 'dev' snapshot
```

### Test Operations
```bash
./test.sh test             # Run full tests (with snapshot restore)
./test.sh setup            # Set up test environment only
./test.sh cleanup          # Clean up test artifacts
```

## 🏗️ **VM Architecture**

### VM Configuration
- **OS**: Ubuntu 22.04 LTS with GUI
- **RAM**: 4GB (optimized for persistent use)
- **CPUs**: 2 cores
- **Storage**: Dynamic allocation
- **Graphics**: Hardware acceleration enabled

### Provisioning Strategy
The VM uses multiple provisioners:

1. **`initial_setup`** (run: "once")
   - System updates
   - Package installation
   - Warp Terminal installation
   - Base environment setup

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
[Base VM] → [Initial Setup] → [Clean Snapshot]
                                      ↓
[Test Run] ← [Restore] ← [Clean State]
    ↓
[Results] → [Cleanup] → [Ready for next test]
```

## 📊 **Performance Comparison**

| Operation | Traditional VM | Persistent VM | Improvement |
|-----------|----------------|---------------|-------------|
| First setup | ~15 minutes | ~15 minutes | Same |
| Subsequent tests | ~15 minutes | ~30 seconds | **30x faster** |
| Test isolation | Full VM rebuild | Snapshot restore | **Clean & Fast** |
| Disk usage | Multiple VMs | Single VM + snapshots | **Space efficient** |

## 🔧 **Advanced Usage**

### Creating Custom Snapshots
```bash
# After making changes to the VM, create a custom snapshot
./test.sh vm-snapshot my-custom-setup

# Later, restore from your custom snapshot
./test.sh vm-restore my-custom-setup
```

### Development Workflow
```bash
# 1. Start with clean environment
./test.sh vm-restore clean

# 2. Run tests
./test.sh test

# 3. If you need to debug inside the VM
vagrant ssh

# 4. Create snapshot of debug state (optional)
./test.sh vm-snapshot debug-state
```

### Maintenance Commands
```bash
# View all snapshots with details
VBoxManage snapshot warp-api-testbed list --details

# Check VM disk usage
VBoxManage showhdinfo ~/.vagrant.d/boxes/ubuntu-VAGRANTSLASH-jammy64/*/virtualbox/box-disk001.vmdk

# Compact VM disk (reclaim space)
VBoxManage modifymedium disk ~/.vagrant.d/boxes/ubuntu-VAGRANTSLASH-jammy64/*/virtualbox/box-disk001.vmdk --compact
```

## 🐛 **Troubleshooting**

### VM Won't Start
```bash
# Check VirtualBox conflicts
sudo modprobe -r kvm_amd kvm

# Restart VirtualBox service
sudo systemctl restart vboxdrv

# Rebuild VM if corrupted
vagrant destroy -f && ./test.sh vm-init
```

### Snapshot Issues
```bash
# List all snapshots to verify names
./test.sh vm-list

# Delete corrupted snapshot
VBoxManage snapshot warp-api-testbed delete "snapshot-name"

# Recreate clean snapshot
./test.sh vm-restore clean  # if it exists
./test.sh vm-snapshot clean
```

### Test Environment Issues
```bash
# Reset test environment without full VM rebuild
vagrant ssh -c "cd /home/vagrant/warp-testing && rm -rf logs/* reports/* screenshots/*"

# Re-sync API files
./test.sh sync
vagrant provision --provision-with test_setup
```

### Performance Optimization
```bash
# Enable all CPU cores for VM (if needed)
VBoxManage modifyvm warp-api-testbed --cpus $(nproc)

# Increase video memory
VBoxManage modifyvm warp-api-testbed --vram 256

# Enable nested virtualization (if supported)
VBoxManage modifyvm warp-api-testbed --nested-hw-virt on
```

## 📁 **File Structure**

```
tests/
├── Vagrantfile           # VM configuration with provisioners
├── test.sh               # Main test runner with VM commands
├── test_helper.bash      # VM snapshot management functions
├── warp_api.py           # Synced API file (ignored by Git)
├── .vagrant/             # Vagrant metadata
│   └── machines/
│       └── default/
│           └── virtualbox/
│               ├── box-disk001.vmdk  # VM disk
│               └── Snapshots/        # VM snapshots
└── results/              # Test results from VM
    └── test_results_*.tar.gz
```

> **Note**: The `warp_api.py` file in the tests directory is automatically synced from the parent directory and is ignored by Git to avoid duplication in the repository.

## 💡 **Best Practices**

### For Development
1. Use `./test.sh vm-init` once per project setup
2. Use `./test.sh test` for regular testing
3. Create custom snapshots for specific test scenarios
4. Use `./test.sh vm-restore clean` to reset to known good state

### For CI/CD
```yaml
# Example CI pipeline
- name: Setup VM (cached)
  run: |
    if ! ./test.sh vm-list | grep -q "clean"; then
      ./test.sh vm-init
    fi

- name: Run Tests
  run: ./test.sh test

- name: Archive Results
  uses: actions/upload-artifact@v2
  with:
    name: test-results
    path: results/
```

### For Team Development
1. Document custom snapshots in team wiki
2. Share snapshot naming conventions
3. Use descriptive snapshot names with dates
4. Regularly clean up old snapshots to save disk space

## 🔄 **Migration from Traditional VM**

If you have an existing VM setup:

1. **Stop current VM**: `vagrant halt`
2. **Backup important data**: Copy any custom test data
3. **Initialize persistent VM**: `./test.sh vm-init`
4. **Test functionality**: `./test.sh test`
5. **Remove old VM**: `vagrant destroy old-vm-name`

The persistent VM approach is backward compatible and provides the same functionality with better performance.