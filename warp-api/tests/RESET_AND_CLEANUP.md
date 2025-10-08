# Reset and Cleanup Guide

This document describes the comprehensive reset and cleanup capabilities available in the Warp API test suite.

## Overview

The test suite now provides multiple levels of cleanup and reset operations to handle different scenarios:

- **Data cleanup**: Remove test artifacts and logs
- **VM cleanup**: Clean test data inside the VM
- **VM reset**: Reset VM to a clean snapshot state
- **VM rebuild**: Completely rebuild the VM from scratch
- **Full reset**: Nuclear option that destroys everything

## Available Commands

### Interactive Cleanup Menu
```bash
./test.sh cleanup
```
Provides an interactive menu with all cleanup options and safety confirmations.

### Data Cleanup Commands

#### Basic Test Data Cleanup
```bash
./test.sh cleanup-data basic
./test.sh cleanup-data          # default is basic
```
- Removes old log files (older than 1 day)
- Removes old test results (older than 1 day)
- Removes old screenshots (older than 1 day)
- Removes test result archives
- **Safe**: Keeps recent test data

#### Full Test Data Cleanup
```bash
./test.sh cleanup-data full
```
- Removes all logs, reports, results, and screenshots
- Removes test result archives
- Removes synced API files
- **Destructive**: All test data is lost

### VM Cleanup Commands

#### VM Test Data Cleanup
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
- Removes all VM snapshots
- **Warning**: You will lose all saved VM states
- Requires confirmation

### VM Reset Commands

#### Reset VM to Clean State
```bash
./test.sh vm-reset
```
- Restores VM from the 'clean' snapshot
- Stops VM, restores snapshot, then restarts
- Fast way to get back to a pristine testing environment
- **Requires**: 'clean' snapshot must exist (created by `vm-init`)

#### Rebuild VM from Scratch
```bash
./test.sh vm-rebuild
```
- Completely destroys and recreates the VM
- Downloads and provisions VM from scratch
- Creates new 'clean' snapshot
- **Destructive**: All VM data and snapshots are lost
- Takes longer than reset (full VM provisioning)

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
- Requires confirmation

## Usage Scenarios

### After Failed Tests
```bash
# Quick cleanup of test data
./test.sh cleanup-data basic

# Or reset VM to clean state
./test.sh vm-reset
```

### Before Important Test Run
```bash
# Full reset to ensure clean environment
./test.sh vm-reset
```

### When VM is Corrupted
```bash
# Rebuild VM completely
./test.sh vm-rebuild
```

### When Everything is Broken
```bash
# Nuclear option - start fresh
./test.sh cleanup-all
./test.sh vm-init
```

### Regular Maintenance
```bash
# Interactive menu for guided cleanup
./test.sh cleanup
```

## Safety Features

### Confirmation Prompts
- Destructive operations require explicit confirmation
- Interactive menu shows consequences before action
- Color-coded warnings (🚨 for nuclear options)

### Graceful Fallbacks
- Functions handle missing snapshots gracefully
- VM operations check VM state before proceeding
- File operations use safe deletion patterns

### Progress Indication
- Clear progress messages with emojis
- Success/failure indicators
- Helpful next-step suggestions

## Best Practices

### 1. Create Clean Snapshots
Always run `./test.sh vm-init` after major changes to create a clean baseline:
```bash
./test.sh vm-init    # Creates 'clean' snapshot
```

### 2. Use Appropriate Cleanup Level
- **Basic cleanup**: For routine maintenance
- **Full cleanup**: When switching test contexts
- **VM reset**: When tests behave unexpectedly
- **VM rebuild**: When VM is corrupted or needs major changes
- **Full reset**: Last resort for broken environments

### 3. Regular Maintenance
```bash
# Weekly maintenance
./test.sh cleanup-data basic

# Before important test runs
./test.sh vm-reset
```

### 4. Backup Important Results
Archive important test results before cleanup:
```bash
# Results are automatically archived, but you can save them
cp -r results/ important_results_$(date +%Y%m%d)/
```

## Troubleshooting

### "No 'clean' snapshot found"
```bash
./test.sh vm-init    # Recreate clean snapshot
```

### VM Won't Start After Reset
```bash
./test.sh vm-rebuild  # Rebuild from scratch
```

### Disk Space Issues
```bash
./test.sh cleanup-data full       # Clean test data
./test.sh cleanup-snapshots       # Remove old snapshots
```

### Complete Environment Issues
```bash
./test.sh cleanup-all   # Nuclear reset
./test.sh vm-init       # Reinitialize
```

## Implementation Details

### Function Hierarchy
```
Interactive Menu (interactive_cleanup)
├── Basic Cleanup (cleanup_test_data "basic")
├── Full Data Cleanup (cleanup_test_data "full") 
├── VM Data Cleanup (cleanup_vm_data)
├── VM Reset (reset_vm_to_clean)
├── Snapshot Cleanup (cleanup_vm_snapshots)
├── VM Rebuild (rebuild_vm)
└── Full Reset (reset_full_environment)
```

### File Locations
- **Test data**: `logs/`, `reports/`, `results/`, `screenshots/`
- **VM data**: `/home/vagrant/warp-testing/` (inside VM)
- **Snapshots**: VirtualBox snapshot storage
- **VM files**: `.vagrant/` directory

### Safety Mechanisms
- Multiple confirmation prompts for destructive operations
- Graceful handling of missing files/VMs/snapshots
- Clear error messages and recovery suggestions
- Non-destructive operations by default

## Integration with Test Runner

All cleanup and reset functions are integrated into the main test runner (`test.sh`) and test helper (`test_helper.bash`), ensuring:

- Consistent behavior across all operations
- Proper error handling and logging
- Integration with existing VM management
- Compatibility with existing test workflows

## Future Enhancements

Potential future additions:
- Scheduled cleanup jobs
- Cleanup policies (retain N days, N runs)
- Backup/restore of test configurations
- Integration with CI/CD pipelines
- Cleanup metrics and reporting