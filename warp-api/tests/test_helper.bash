#!/bin/bash
#
# Test Helper Functions for Warp API Testing
# Provides reusable functions for VM management, file operations, and test utilities
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="$SCRIPT_DIR/logs"
REPORTS_DIR="$SCRIPT_DIR/reports"
RESULTS_DIR="$SCRIPT_DIR/results"
SCREENSHOTS_DIR="$SCRIPT_DIR/screenshots"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

# VM configuration
VM_NAME="warp-api-testbed"
VM_USER="vagrant"
VM_TEST_DIR="/home/vagrant/warp-testing"

#######################################
# Print colored messages
# Arguments:
#   $1: color (RED, GREEN, YELLOW, BLUE)
#   $2: message
#######################################
print_message() {
    local color=${!1}
    local message="$2"
    echo -e "${color}${message}${NC}"
}

#######################################
# Print header with borders
# Arguments:
#   $1: header text
#######################################
print_header() {
    local header="$1"
    local length=${#header}
    local border=$(printf "═%.0s" $(seq 1 $((length + 4))))
    
    echo
    print_message "BLUE" "╔${border}╗"
    print_message "BLUE" "║  ${header}  ║"
    print_message "BLUE" "╚${border}╝"
    echo
}

#######################################
# Ensure all required directories exist
#######################################
ensure_directories() {
    print_message "BLUE" "📁 Ensuring test directories exist..."
    
    local dirs=("$LOGS_DIR" "$REPORTS_DIR" "$RESULTS_DIR" "$SCREENSHOTS_DIR" "$FIXTURES_DIR")
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            print_message "GREEN" "✅ Created directory: $dir"
        fi
    done
}

#######################################
# Clean up previous test artifacts
# Arguments:
#   $1: clean level (basic|full)
#######################################
clean_artifacts() {
    local level="${1:-basic}"
    
    print_message "BLUE" "🧹 Cleaning test artifacts ($level)..."
    
    # Basic cleanup - remove log and result files
    find "$LOGS_DIR" -name "*.log" -mtime +1 -delete 2>/dev/null || true
    find "$RESULTS_DIR" -name "*.tap" -mtime +1 -delete 2>/dev/null || true
    
    if [[ "$level" == "full" ]]; then
        # Full cleanup - remove all artifacts
        rm -rf "$LOGS_DIR"/* "$REPORTS_DIR"/* "$RESULTS_DIR"/* "$SCREENSHOTS_DIR"/* 2>/dev/null || true
        print_message "GREEN" "✅ Full cleaning completed"
    else
        print_message "GREEN" "✅ Basic cleaning completed"
    fi
}

#######################################
# Sync API file from parent directory
# Ensures single source of truth for warp_api.py
#######################################
sync_api_file() {
    print_message "BLUE" "🔄 Syncing API file..."
    
    local parent_api="$SCRIPT_DIR/../warp_api.py"
    local tests_api="$SCRIPT_DIR/warp_api.py"
    
    if [[ -f "$parent_api" ]]; then
        print_message "BLUE" "📋 Syncing warp_api.py from parent directory..."
        
        # Use rsync for robust file synchronization
        if command -v rsync >/dev/null 2>&1; then
            if rsync -av "$parent_api" "$tests_api" >/dev/null 2>&1; then
                print_message "GREEN" "✅ API file synced successfully with rsync"
                return 0
            else
                print_message "YELLOW" "⚠️ rsync failed, falling back to cp"
            fi
        fi
        
        # Fallback to cp if rsync is not available or fails
        if cp "$parent_api" "$tests_api"; then
            print_message "GREEN" "✅ API file synced successfully with cp"
            return 0
        else
            print_message "RED" "❌ Failed to sync API file"
            return 1
        fi
    else
        print_message "RED" "❌ Source API file not found at $parent_api"
        print_message "YELLOW" "💡 Expected location: $parent_api"
        return 1
    fi
}

#######################################
# Check if required tools are available
#######################################
check_dependencies() {
    print_message "BLUE" "🔍 Checking dependencies..."
    
    local deps=("vagrant" "VBoxManage" "bats" "python3")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -eq 0 ]]; then
        print_message "GREEN" "✅ All dependencies available"
        return 0
    else
        print_message "RED" "❌ Missing dependencies: ${missing[*]}"
        return 1
    fi
}

#######################################
# Show VM optimization information
#######################################
show_vm_optimization_info() {
    print_message "GREEN" "⚡ VM: Ultra-fast setup with parallel downloads (~500-800MB, 3-8 min)"
}

#######################################
# Get VM status
# Returns: running|stopped|not_found
#######################################
get_vm_status() {
    if VBoxManage showvminfo "$VM_NAME" >/dev/null 2>&1; then
        local state=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "VMState=" | cut -d'"' -f2)
        if [[ "$state" == "running" ]]; then
            echo "running"
        else
            echo "stopped"
        fi
    else
        echo "not_found"
    fi
}

#######################################
# Start VM if not running
#######################################
ensure_vm_running() {
    print_message "BLUE" "🖥️ Checking VM status..."
    
    local status=$(get_vm_status)
    
    case "$status" in
        "running")
            print_message "GREEN" "✅ VM is already running"
            return 0
            ;;
        "stopped")
            print_message "YELLOW" "⏳ Starting VM..."
            if vagrant up; then
                print_message "GREEN" "✅ VM started successfully"
                return 0
            else
                print_message "RED" "❌ Failed to start VM"
                return 1
            fi
            ;;
        "not_found")
            print_message "YELLOW" "⏳ VM not found, creating..."
            if vagrant up; then
                print_message "GREEN" "✅ VM created and started"
                return 0
            else
                print_message "RED" "❌ Failed to create VM"
                return 1
            fi
            ;;
    esac
}

#######################################
# Stop VM gracefully
#######################################
stop_vm() {
    print_message "BLUE" "🛑 Stopping VM..."
    
    if vagrant halt; then
        print_message "GREEN" "✅ VM stopped successfully"
        return 0
    else
        print_message "RED" "❌ Failed to stop VM"
        return 1
    fi
}

#######################################
# Execute command in VM
# Arguments:
#   $1: command to execute
#######################################
vm_exec() {
    local command="$1"
    vagrant ssh -c "$command"
}

#######################################
# Copy files to VM
# Arguments:
#   $1: source file/directory
#   $2: destination in VM
#######################################
copy_to_vm() {
    local src="$1"
    local dest="$2"
    
    print_message "BLUE" "📋 Copying $src to VM:$dest"
    
    # Use vagrant's built-in file sharing or scp
    if [[ -f "$src" ]]; then
        vagrant ssh -c "mkdir -p $(dirname '$dest')"
        if scp -P 2222 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$src" vagrant@127.0.0.1:"$dest" >/dev/null 2>&1; then
            print_message "GREEN" "✅ File copied successfully"
            return 0
        else
            # Fallback to cp via shared folder
            local filename=$(basename "$src")
            cp "$src" "/tmp/$filename"
            vm_exec "cp '/vagrant/../tmp/$filename' '$dest'"
            rm "/tmp/$filename"
        fi
    else
        print_message "RED" "❌ Source file not found: $src"
        return 1
    fi
}

#######################################
# Copy files from VM
# Arguments:
#   $1: source file/directory in VM
#   $2: destination on host
#######################################
copy_from_vm() {
    local src="$1"
    local dest="$2"
    
    print_message "BLUE" "📋 Copying VM:$src to $dest"
    
    if scp -P 2222 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vagrant@127.0.0.1:"$src" "$dest" >/dev/null 2>&1; then
        print_message "GREEN" "✅ File copied successfully"
        return 0
    else
        print_message "RED" "❌ Failed to copy file from VM"
        return 1
    fi
}

#######################################
# Generate timestamp for logs
#######################################
timestamp() {
    date '+%Y-%m-%d_%H-%M-%S'
}

#######################################
# Create test session log file
#######################################
create_session_log() {
    local session_id=$(timestamp)
    local log_file="$LOGS_DIR/test_session_${session_id}.log"
    
    echo "Test session started: $(date)" > "$log_file"
    echo "Session ID: $session_id" >> "$log_file"
    echo "Working directory: $SCRIPT_DIR" >> "$log_file"
    echo "VM Status: $(get_vm_status)" >> "$log_file"
    echo "----------------------------------------" >> "$log_file"
    
    echo "$log_file"
}

#######################################
# Archive test results
# Arguments:
#   $1: test run identifier
#######################################
archive_results() {
    local run_id="${1:-$(timestamp)}"
    local archive_file="$RESULTS_DIR/test_results_${run_id}.tar.gz"
    
    print_message "BLUE" "📦 Archiving test results..."
    
    # Create archive with logs, reports, and screenshots
    tar -czf "$archive_file" \
        -C "$SCRIPT_DIR" \
        logs/ reports/ screenshots/ \
        --exclude="*.tmp" \
        >/dev/null 2>&1
    
    if [[ $? -eq 0 ]]; then
        print_message "GREEN" "✅ Results archived to: $archive_file"
        return 0
    else
        print_message "RED" "❌ Failed to archive results"
        return 1
    fi
}

#######################################
# Wait for VM to be ready for GUI operations
# Arguments:
#   $1: timeout in attempts (optional, default: 30 for tests, 5 for setup)
#######################################
wait_for_vm_gui() {
    local max_attempts="${1:-30}"
    local attempt=0
    
    # Adjust timeout based on TEST_COMMAND if available
    if [[ "$TEST_COMMAND" == "setup" ]] || [[ "$TEST_COMMAND" == "vm-restart" ]] || [[ "$TEST_COMMAND" == "vm-init" ]]; then
        max_attempts="${1:-5}"  # Default to 5 attempts (10 seconds) for setup-like commands
        print_message "BLUE" "⏳ Waiting for VM GUI to be ready (quick setup mode)..."
    else
        print_message "BLUE" "⏳ Waiting for VM GUI to be ready..."
    fi
    
    while [[ $attempt -lt $max_attempts ]]; do
        if vm_exec "pgrep -x 'gnome-shell\|gdm\|Xorg' >/dev/null"; then
            print_message "GREEN" "✅ VM GUI is ready"
            return 0
        fi
        
        ((attempt++))
        if [[ "$TEST_COMMAND" == "setup" ]] || [[ "$TEST_COMMAND" == "vm-restart" ]] || [[ "$TEST_COMMAND" == "vm-init" ]]; then
            print_message "YELLOW" "⏳ Waiting for GUI... ($attempt/$max_attempts) - setup mode"
        else
            print_message "YELLOW" "⏳ Waiting for GUI... ($attempt/$max_attempts)"
        fi
        sleep 2
    done
    
    if [[ "$TEST_COMMAND" == "setup" ]] || [[ "$TEST_COMMAND" == "vm-restart" ]] || [[ "$TEST_COMMAND" == "vm-init" ]]; then
        print_message "YELLOW" "⚠️ VM GUI not ready yet (setup mode timeout) - continuing anyway"
        print_message "BLUE" "💡 VM is being set up, GUI may take longer to fully initialize"
        return 0  # Don't fail on setup-like commands, just continue
    else
        print_message "RED" "❌ VM GUI failed to start within timeout"
        return 1
    fi
}

#######################################
# VM Snapshot Management Functions
#######################################

#######################################
# Create VM snapshot
# Arguments:
#   $1: snapshot name
#   $2: description (optional)
#######################################
create_vm_snapshot() {
    local snapshot_name="$1"
    local description="${2:-Snapshot created at $(date)}"
    
    print_message "BLUE" "📸 Creating VM snapshot: $snapshot_name"
    
    if VBoxManage snapshot "$VM_NAME" take "$snapshot_name" --description "$description" >/dev/null 2>&1; then
        print_message "GREEN" "✅ Snapshot '$snapshot_name' created successfully"
        return 0
    else
        print_message "RED" "❌ Failed to create snapshot '$snapshot_name'"
        return 1
    fi
}

#######################################
# Restore VM snapshot
# Arguments:
#   $1: snapshot name
#######################################
restore_vm_snapshot() {
    local snapshot_name="$1"
    
    print_message "BLUE" "🔄 Restoring VM snapshot: $snapshot_name"
    
    # Stop VM if running
    local vm_status=$(get_vm_status)
    if [[ "$vm_status" == "running" ]]; then
        print_message "YELLOW" "⏸️ Stopping VM for snapshot restore..."
        vagrant halt >/dev/null 2>&1 || VBoxManage controlvm "$VM_NAME" poweroff >/dev/null 2>&1
        sleep 5
    fi
    
    if VBoxManage snapshot "$VM_NAME" restore "$snapshot_name" >/dev/null 2>&1; then
        print_message "GREEN" "✅ Snapshot '$snapshot_name' restored successfully"
        return 0
    else
        print_message "RED" "❌ Failed to restore snapshot '$snapshot_name'"
        return 1
    fi
}

#######################################
# List VM snapshots
#######################################
list_vm_snapshots() {
    print_message "BLUE" "📋 Listing VM snapshots..."
    
    local snapshots
    if snapshots=$(VBoxManage snapshot "$VM_NAME" list 2>/dev/null); then
        if [[ -n "$snapshots" ]]; then
            echo "$snapshots"
        else
            print_message "YELLOW" "📭 No snapshots found"
        fi
        return 0
    else
        print_message "RED" "❌ Failed to list snapshots"
        return 1
    fi
}

#######################################
# Delete VM snapshot
# Arguments:
#   $1: snapshot name
#######################################
delete_vm_snapshot() {
    local snapshot_name="$1"
    
    print_message "BLUE" "🗑️ Deleting VM snapshot: $snapshot_name"
    
    if VBoxManage snapshot "$VM_NAME" delete "$snapshot_name" >/dev/null 2>&1; then
        print_message "GREEN" "✅ Snapshot '$snapshot_name' deleted successfully"
        return 0
    else
        print_message "RED" "❌ Failed to delete snapshot '$snapshot_name'"
        return 1
    fi
}

#######################################
# Check if snapshot exists
# Arguments:
#   $1: snapshot name
# Returns: 0 if exists, 1 if not
#######################################
snapshot_exists() {
    local snapshot_name="$1"
    
    VBoxManage snapshot "$VM_NAME" list 2>/dev/null | grep -q "Name: $snapshot_name" 2>/dev/null
}

#######################################
# Setup clean test environment in VM
#######################################
setup_vm_test_environment() {
    print_message "BLUE" "🧪 Setting up clean test environment in VM..."
    
    # Ensure VM is running
    if ! ensure_vm_running; then
        return 1
    fi
    
    # Run test setup provisioner
    if vagrant provision --provision-with test_setup >/dev/null 2>&1; then
        print_message "GREEN" "✅ Test environment set up successfully"
        return 0
    else
        print_message "RED" "❌ Failed to set up test environment"
        return 1
    fi
}

#######################################
# Clean test environment in VM
#######################################
clean_vm_test_environment() {
    print_message "BLUE" "🧹 Cleaning test environment in VM..."
    
    local vm_status=$(get_vm_status)
    if [[ "$vm_status" != "running" ]]; then
        print_message "YELLOW" "⚠️ VM not running, skipping cleaning"
        return 0
    fi
    
    # Run test cleanup provisioner
    if vagrant provision --provision-with test_cleanup >/dev/null 2>&1; then
        print_message "GREEN" "✅ Test environment cleaned successfully"
        
        # Copy any archived results
        local archives=(test_results_*.tar.gz)
        if [[ -f "${archives[0]}" ]]; then
            mv test_results_*.tar.gz "$RESULTS_DIR/" 2>/dev/null || true
            print_message "BLUE" "📦 Test results moved to results directory"
        fi
        
        return 0
    else
        print_message "RED" "❌ Failed to clean test environment"
        return 1
    fi
}

#######################################
# Environment Reset and Clean Functions
#######################################

#######################################
# Clean test data only (lightest cleaning)
# Arguments:
#   $1: clean level (basic|full) - optional, defaults to basic
#######################################
clean_test_data() {
    local level="${1:-basic}"
    
    print_message "BLUE" "🧹 Cleaning test data ($level)..."
    
    if [[ "$level" == "full" ]]; then
        # Full data cleanup - remove all artifacts
        rm -rf "$LOGS_DIR"/* "$REPORTS_DIR"/* "$RESULTS_DIR"/* "$SCREENSHOTS_DIR"/* 2>/dev/null || true
        rm -f test_results_*.tar.gz 2>/dev/null || true
        rm -f warp_api.py 2>/dev/null || true
        print_message "GREEN" "✅ Full test data cleaning completed"
    else
        # Basic cleaning - keep recent files
        find "$LOGS_DIR" -name "*.log" -mtime +1 -delete 2>/dev/null || true
        find "$RESULTS_DIR" -name "*.tap" -mtime +1 -delete 2>/dev/null || true
        find "$SCREENSHOTS_DIR" -name "*.png" -mtime +1 -delete 2>/dev/null || true
        rm -f test_results_*.tar.gz 2>/dev/null || true
        print_message "GREEN" "✅ Basic test data cleaning completed"
    fi
}

#######################################
# Clean VM test environment (medium cleaning)
#######################################
clean_vm_data() {
    print_message "BLUE" "🧹 Cleaning VM test data..."
    
    local vm_status=$(get_vm_status)
    if [[ "$vm_status" == "running" ]]; then
        # Clean test data inside VM
        vm_exec "cd /home/vagrant/warp-testing && rm -rf logs/* reports/* results/* screenshots/* *.log *.txt 2>/dev/null || true"
        print_message "GREEN" "✅ VM test data cleaned"
    else
        print_message "YELLOW" "⚠️ VM not running, skipping VM data cleaning"
    fi
}

#######################################
# Reset VM to clean snapshot (VM reset)
#######################################
reset_vm_to_clean() {
    print_message "BLUE" "🔄 Resetting VM to clean state..."
    
    # Check if clean snapshot exists
    if snapshot_exists "clean"; then
        print_message "BLUE" "📸 Restoring VM from 'clean' snapshot..."
        
        # Stop VM if running
        local vm_status=$(get_vm_status)
        if [[ "$vm_status" == "running" ]]; then
            print_message "YELLOW" "⏸️ Stopping VM for reset..."
            vagrant halt >/dev/null 2>&1
        fi
        
        # Restore from clean snapshot
        if restore_vm_snapshot "clean"; then
            print_message "GREEN" "✅ VM reset to clean state successfully"
            
            # Start VM
            if ensure_vm_running; then
                print_message "GREEN" "✅ VM started and ready"
                return 0
            else
                print_message "RED" "❌ VM restored but failed to start"
                return 1
            fi
        else
            print_message "RED" "❌ Failed to restore VM from clean snapshot"
            return 1
        fi
    else
        print_message "RED" "❌ No 'clean' snapshot found"
        print_message "BLUE" "💡 Run './test.sh vm-init' to create a clean snapshot"
        return 1
    fi
}

#######################################
# Remove all VM snapshots (destructive)
#######################################
clean_vm_snapshots() {
    print_message "BLUE" "🗑️ Removing all VM snapshots..."
    
    # Get list of snapshots
    local snapshots
    if snapshots=$(VBoxManage snapshot "$VM_NAME" list 2>/dev/null); then
        if [[ -n "$snapshots" ]]; then
            # Extract snapshot names and delete them
            echo "$snapshots" | grep "Name:" | sed 's/.*Name: \([^(]*\).*/\1/' | while read -r snapshot_name; do
                if [[ -n "$snapshot_name" ]]; then
                    print_message "YELLOW" "🗑️ Deleting snapshot: $snapshot_name"
                    VBoxManage snapshot "$VM_NAME" delete "$snapshot_name" >/dev/null 2>&1 || true
                fi
            done
            print_message "GREEN" "✅ All VM snapshots removed"
        else
            print_message "YELLOW" "📭 No snapshots to remove"
        fi
    else
        print_message "YELLOW" "⚠️ Could not list snapshots (VM may not exist)"
    fi
}

#######################################
# Destroy and recreate VM (full VM reset)
#######################################
rebuild_vm() {
    print_message "BLUE" "🔨 Rebuilding VM from scratch..."
    
    # Destroy existing VM
    print_message "YELLOW" "💥 Destroying existing VM..."
    vagrant destroy -f >/dev/null 2>&1 || true
    
    # Remove any lingering VirtualBox VM
    VBoxManage unregistervm "$VM_NAME" --delete >/dev/null 2>&1 || true
    
    # Clean up vagrant files
    rm -rf .vagrant >/dev/null 2>&1 || true
    
    print_message "GREEN" "✅ Old VM destroyed"
    
    # Create new VM
    print_message "BLUE" "🚀 Creating new VM..."
    if vagrant up; then
        print_message "GREEN" "✅ New VM created successfully"
        
        # Wait for GUI
        if wait_for_vm_gui; then
            # Create clean snapshot
            if create_vm_snapshot "clean" "Fresh VM after rebuild"; then
                print_message "GREEN" "🎉 VM rebuild completed with clean snapshot"
                return 0
            else
                print_message "YELLOW" "⚠️ VM rebuilt but snapshot creation failed"
                return 0
            fi
        else
            print_message "RED" "❌ VM created but GUI not ready"
            return 1
        fi
    else
        print_message "RED" "❌ Failed to create new VM"
        return 1
    fi
}

#######################################
# Full environment reset (nuclear option)
#######################################
reset_full_environment() {
    print_message "BLUE" "☢️ Performing full environment reset..."
    
    # Clean all test data
    clean_test_data "full"
    
    # Remove VM and all snapshots
    print_message "BLUE" "💥 Removing VM and all data..."
    vagrant destroy -f >/dev/null 2>&1 || true
    VBoxManage unregistervm "$VM_NAME" --delete >/dev/null 2>&1 || true
    
    # Clean vagrant files and caches
    rm -rf .vagrant >/dev/null 2>&1 || true
    
    # Clean host test directories
    clean_test_data "full"
    
    # Remove downloaded box (forces redownload)
    print_message "YELLOW" "📦 Removing downloaded VM box (will redownload)..."
    vagrant box remove ubuntu/jammy64 --force >/dev/null 2>&1 || true
    
    print_message "GREEN" "✅ Full environment reset completed"
    print_message "BLUE" "💡 Run './test.sh vm-init' to reinitialize the environment"
}

#######################################
# Create pristine snapshot for repository
# This creates a clean snapshot that can be committed to git
# for instant testing after repository clone
#######################################
create_pristine_snapshot() {
    print_message "BLUE" "📸 Creating pristine snapshot for repository..."
    
    # First, ensure we have a clean VM state
    local vm_status=$(get_vm_status)
    if [[ "$vm_status" != "running" ]]; then
        if ! ensure_vm_running; then
            print_message "RED" "❌ Failed to start VM for pristine snapshot"
            return 1
        fi
        
        # Wait for GUI to be ready
        if ! wait_for_vm_gui; then
            print_message "RED" "❌ VM GUI not ready for pristine snapshot"
            return 1
        fi
    fi
    
    # Clean any test data inside VM
    print_message "BLUE" "🧹 Cleaning VM for pristine state..."
    vm_exec "cd /home/vagrant/warp-testing && rm -rf logs/* reports/* results/* screenshots/* *.log *.txt *.tar.gz 2>/dev/null || true"
    
    # Kill any running test processes
    vm_exec "pkill -f warp 2>/dev/null || true"
    vm_exec "pkill -f xtrlock 2>/dev/null || true"
    
    # Clear shell history for pristine state
    vm_exec "history -c && rm -f ~/.bash_history ~/.python_history 2>/dev/null || true"
    
    # Shutdown VM cleanly for snapshot
    print_message "BLUE" "⏹️ Shutting down VM for pristine snapshot..."
    vagrant halt >/dev/null 2>&1
    
    # Wait for complete shutdown
    sleep 5
    
    # Remove any existing pristine snapshot
    if VBoxManage snapshot "$VM_NAME" list 2>/dev/null | grep -q "Name: pristine"; then
        print_message "BLUE" "🗑️ Removing existing pristine snapshot..."
        VBoxManage snapshot "$VM_NAME" delete "pristine" >/dev/null 2>&1
    fi
    
    # Create pristine snapshot
    if VBoxManage snapshot "$VM_NAME" take "pristine" --description "Pristine clean state for repository - ready for immediate testing" >/dev/null 2>&1; then
        print_message "GREEN" "✅ Pristine snapshot created successfully!"
        print_message "BLUE" "💾 Snapshot 'pristine' is ready for repository commit"
        print_message "BLUE" "💡 After cloning, users can run './test.sh test' immediately"
        return 0
    else
        print_message "RED" "❌ Failed to create pristine snapshot"
        return 1
    fi
}

#######################################
# Restore to pristine snapshot (for after clone)
#######################################
restore_pristine_snapshot() {
    print_message "BLUE" "📸 Checking for pristine snapshot..."
    
    if snapshot_exists "pristine"; then
        print_message "GREEN" "🎉 Found pristine snapshot! Restoring for immediate testing..."
        
        # Stop VM if running
        local vm_status=$(get_vm_status)
        if [[ "$vm_status" == "running" ]]; then
            vagrant halt >/dev/null 2>&1
        fi
        
        # Restore pristine snapshot
        if restore_vm_snapshot "pristine"; then
            print_message "GREEN" "✅ Pristine snapshot restored"
            
            # Start VM
            if ensure_vm_running && wait_for_vm_gui; then
                print_message "GREEN" "🚀 VM ready for testing! No setup needed."
                return 0
            else
                print_message "RED" "❌ VM restored but failed to start properly"
                return 1
            fi
        else
            print_message "RED" "❌ Failed to restore pristine snapshot"
            return 1
        fi
    else
        print_message "YELLOW" "⚠️ No pristine snapshot found"
        print_message "BLUE" "💡 Run './test.sh vm-init' to set up VM and create pristine snapshot"
        return 1
    fi
}

#######################################
# Interactive clean menu
#######################################
interactive_clean() {
    # Skip interactive menu in force mode
    if [[ "${TEST_FORCE:-false}" == "true" ]]; then
        print_message "YELLOW" "🚨 Force mode: Skipping interactive menu"
        print_message "BLUE" "💡 Use specific clean commands for automation:"
        print_message "BLUE" "   ./test.sh clean-data [basic|full]"
        print_message "BLUE" "   ./test.sh clean-vm"
        print_message "BLUE" "   ./test.sh vm-reset"
        print_message "BLUE" "   ./test.sh vm-rebuild --force"
        print_message "BLUE" "   ./test.sh clean-all --force"
        return 0
    fi
    
    print_header "Interactive Clean Menu"
    
    echo "Please select clean level:"
    echo "1) Basic test data cleaning (safe)"
    echo "2) Full test data cleaning"
    echo "3) VM test data cleaning"
    echo "4) Reset VM to clean state"
    echo "5) Remove all VM snapshots"
    echo "6) Rebuild VM from scratch"
    echo "7) Full environment reset (nuclear)"
    echo "8) Cancel"
    echo ""
    
    read -p "Enter your choice [1-8]: " choice
    
    case $choice in
        1)
            clean_test_data "basic"
            ;;
        2)
            clean_test_data "full"
            ;;
        3)
            clean_vm_data
            ;;
        4)
            reset_vm_to_clean
            ;;
        5)
            if [[ "${TEST_FORCE:-false}" == "true" ]]; then
                print_message "YELLOW" "🚨 Force mode: Removing all VM snapshots"
                clean_vm_snapshots
            else
                print_message "YELLOW" "⚠️ This will remove ALL VM snapshots. Are you sure? (y/N)"
                read -p "Confirm: " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    clean_vm_snapshots
                else
                    print_message "BLUE" "Operation cancelled"
                fi
            fi
            ;;
        6)
            if [[ "${TEST_FORCE:-false}" == "true" ]]; then
                print_message "YELLOW" "🚨 Force mode: Rebuilding VM"
                rebuild_vm
            else
                print_message "YELLOW" "⚠️ This will destroy and recreate the VM. Are you sure? (y/N)"
                read -p "Confirm: " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    rebuild_vm
                else
                    print_message "BLUE" "Operation cancelled"
                fi
            fi
            ;;
        7)
            if [[ "${TEST_FORCE:-false}" == "true" ]]; then
                print_message "YELLOW" "🚨 Force mode: Performing full environment reset"
                reset_full_environment
            else
                print_message "RED" "🚨 This will reset EVERYTHING and force redownload. Are you sure? (y/N)"
                read -p "Confirm: " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    reset_full_environment
                else
                    print_message "BLUE" "Operation cancelled"
                fi
            fi
            ;;
        8)
            print_message "BLUE" "Operation cancelled"
            ;;
        *)
            print_message "RED" "Invalid choice"
            return 1
            ;;
    esac
}

#######################################
# Run BATS tests with proper logging
# Arguments:
#   $1: BATS file to run
#   $2: output format (tap|pretty)
#######################################
run_bats_tests() {
    local bats_file="${1:-warp_api.bats}"
    local format="${2:-tap}"
    local timestamp=$(timestamp)
    local log_file="$LOGS_DIR/bats_${timestamp}.log"
    local results_file="$RESULTS_DIR/bats_${timestamp}.${format}"
    
    print_message "BLUE" "🧪 Running BATS tests: $bats_file"
    
    if [[ ! -f "$bats_file" ]]; then
        print_message "RED" "❌ BATS file not found: $bats_file"
        return 1
    fi
    
    # Run BATS with specified format
    local bats_cmd="bats"
    if [[ "$format" == "tap" ]]; then
        bats_cmd="bats --tap"
    fi
    
    if $bats_cmd "$bats_file" > "$results_file" 2> "$log_file"; then
        print_message "GREEN" "✅ BATS tests completed successfully"
        print_message "BLUE" "📊 Results: $results_file"
        print_message "BLUE" "📝 Logs: $log_file"
        return 0
    else
        local exit_code=$?
        print_message "RED" "❌ BATS tests failed (exit code: $exit_code)"
        print_message "BLUE" "📝 Check logs: $log_file"
        return $exit_code
    fi
}

#######################################
# System Capability Checking Functions
#######################################

#######################################
# Check if the host system can handle VirtualBox VM requirements
# Returns: 0=all good, 1=critical issues, 2=warnings only
#######################################
check_system_capabilities() {
    local min_memory_gb=8
    local min_free_memory_gb=6  
    local min_cpus=4
    local min_disk_space_gb=20
    local vm_memory_mb=4096
    local vm_cpus=2
    
    print_header "System Capability Check"
    print_message "BLUE" "🔍 Checking if host system can handle VirtualBox testing..."
    echo
    
    local issues=0
    local warnings=0
    local report_file="$REPORTS_DIR/system_capability_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "WARP API VIRTUALBOX SYSTEM CAPABILITY REPORT"
        echo "Generated: $(date)"
        echo "Host: $(hostname) ($(uname -s) $(uname -r))"
        echo "==========================================="
        echo
        
        # Memory Check
        echo "📊 MEMORY ANALYSIS"
        echo "------------------"
        local total_memory_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        local available_memory_kb=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        local total_memory_gb=$((total_memory_kb / 1024 / 1024))
        local available_memory_gb=$((available_memory_kb / 1024 / 1024))
        
        echo "Total RAM: ${total_memory_gb} GB (${total_memory_kb} KB)"
        echo "Available RAM: ${available_memory_gb} GB (${available_memory_kb} KB)"
        echo "VM Requirements: ${vm_memory_mb} MB ($(($vm_memory_mb / 1024)) GB)"
        echo "Recommended Host RAM: ${min_memory_gb} GB minimum"
        echo "Recommended Available: ${min_free_memory_gb} GB minimum"
        
        if [ $total_memory_gb -lt $min_memory_gb ]; then
            echo "❌ CRITICAL: Insufficient total RAM"
            echo "   - Current: ${total_memory_gb} GB"
            echo "   - Required: ${min_memory_gb} GB"
            echo "   - Action: Add more RAM or use a machine with at least ${min_memory_gb}GB"
            issues=$((issues + 1))
        elif [ $available_memory_gb -lt $min_free_memory_gb ]; then
            echo "⚠️ WARNING: Low available RAM"
            echo "   - Available: ${available_memory_gb} GB"
            echo "   - Recommended: ${min_free_memory_gb} GB"
            echo "   - Action: Close other applications or add more RAM"
            warnings=$((warnings + 1))
        else
            echo "✅ RAM: Sufficient (${total_memory_gb} GB total, ${available_memory_gb} GB available)"
        fi
        echo
        
        # CPU Check
        echo "⚙️ CPU ANALYSIS"
        echo "---------------"
        local cpu_cores=$(nproc)
        local cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
        
        echo "CPU Model: ${cpu_model}"
        echo "CPU Cores: ${cpu_cores}"
        echo "VM Requirements: ${vm_cpus} cores"
        echo "Recommended Host: ${min_cpus} cores minimum"
        
        if [ $cpu_cores -lt $min_cpus ]; then
            echo "⚠️ WARNING: Low CPU core count"
            echo "   - Current: ${cpu_cores} cores"
            echo "   - Recommended: ${min_cpus} cores"
            echo "   - Action: VM may run slowly. Consider upgrading CPU or reducing VM cores"
            warnings=$((warnings + 1))
        elif [ $cpu_cores -lt $vm_cpus ]; then
            echo "⚠️ WARNING: CPU cores less than VM allocation"
            echo "   - Available: ${cpu_cores} cores"
            echo "   - VM needs: ${vm_cpus} cores"
            echo "   - Action: Performance may be degraded"
            warnings=$((warnings + 1))
        else
            echo "✅ CPU: Sufficient (${cpu_cores} cores available)"
        fi
        echo
        
        # Virtualization Support Check
        echo "🔧 VIRTUALIZATION SUPPORT"
        echo "------------------------"
        if grep -q "vmx\|svm" /proc/cpuinfo; then
            local virt_type=$(grep -o "vmx\|svm" /proc/cpuinfo | head -1)
            echo "✅ Hardware virtualization: Supported (${virt_type})"
            
            # Check if KVM is available
            if [ -e /dev/kvm ]; then
                echo "✅ KVM: Available (/dev/kvm exists)"
            else
                echo "⚠️ WARNING: KVM not available"
                echo "   - Action: May need to enable in BIOS or install kvm modules"
                warnings=$((warnings + 1))
            fi
        else
            echo "❌ CRITICAL: Hardware virtualization not supported or not enabled"
            echo "   - Action: Enable VT-x/AMD-V in BIOS settings"
            echo "   - Without this, VirtualBox performance will be severely impacted"
            issues=$((issues + 1))
        fi
        echo
        
        # Disk Space Check
        echo "💾 DISK SPACE ANALYSIS"
        echo "---------------------"
        local disk_info=$(df -h . | tail -1)
        local available_space=$(echo $disk_info | awk '{print $4}' | sed 's/[^0-9.]*//g')
        local available_unit=$(echo $disk_info | awk '{print $4}' | sed 's/[0-9.]*//g')
        local filesystem=$(echo $disk_info | awk '{print $1}')
        local total_space=$(echo $disk_info | awk '{print $2}')
        
        echo "Filesystem: ${filesystem}"
        echo "Total space: ${total_space}"
        echo "Available space: ${available_space}${available_unit}"
        echo "VM Requirements: ~${min_disk_space_gb} GB (VM image + snapshots + test data)"
        
        # Convert to GB for comparison
        local available_gb=0
        if [[ $available_unit == "G" ]]; then
            available_gb=${available_space%.*}  # Remove decimal part
        elif [[ $available_unit == "T" ]]; then
            available_gb=$((${available_space%.*} * 1024))
        elif [[ $available_unit == "M" ]]; then
            available_gb=$((${available_space%.*} / 1024))
        fi
        
        if [ "$available_gb" -lt "$min_disk_space_gb" ]; then
            echo "❌ CRITICAL: Insufficient disk space"
            echo "   - Available: ${available_space}${available_unit}"
            echo "   - Required: ${min_disk_space_gb} GB minimum"
            echo "   - Action: Free up disk space or use a drive with more space"
            issues=$((issues + 1))
        else
            echo "✅ Disk space: Sufficient (${available_space}${available_unit} available)"
        fi
        echo
        
        # VirtualBox Check
        echo "📦 VIRTUALBOX INSTALLATION"
        echo "-------------------------"
        if command -v VBoxManage >/dev/null 2>&1; then
            local vbox_version=$(VBoxManage --version 2>/dev/null | head -1)
            echo "✅ VirtualBox: Installed (${vbox_version})"
            
            # Check VirtualBox kernel modules
            if lsmod | grep -q vboxdrv; then
                echo "✅ VirtualBox kernel modules: Loaded"
            else
                echo "⚠️ WARNING: VirtualBox kernel modules not loaded"
                echo "   - Action: Run 'sudo modprobe vboxdrv' or reinstall VirtualBox"
                warnings=$((warnings + 1))
            fi
        else
            echo "❌ CRITICAL: VirtualBox not installed"
            echo "   - Action: Install VirtualBox 6.1+ from https://www.virtualbox.org/"
            echo "   - Ubuntu: sudo apt install virtualbox virtualbox-ext-pack"
            issues=$((issues + 1))
        fi
        echo
        
        # Vagrant Check
        echo "📦 VAGRANT INSTALLATION"
        echo "----------------------"
        if command -v vagrant >/dev/null 2>&1; then
            local vagrant_version=$(vagrant --version 2>/dev/null)
            echo "✅ Vagrant: Installed (${vagrant_version})"
        else
            echo "❌ CRITICAL: Vagrant not installed"
            echo "   - Action: Install Vagrant 2.2+ from https://www.vagrantup.com/"
            echo "   - Ubuntu: sudo apt install vagrant"
            issues=$((issues + 1))
        fi
        echo
        
        # Display Checks (for GUI VM)
        echo "🖥️ DISPLAY SYSTEM"
        echo "----------------"
        if [ -n "$DISPLAY" ]; then
            echo "✅ X11 Display: Available ($DISPLAY)"
        else
            echo "⚠️ WARNING: No X11 display detected"
            echo "   - Action: Ensure you're running in a graphical environment"
            echo "   - For headless: VirtualBox can still run but GUI testing may fail"
            warnings=$((warnings + 1))
        fi
        
        if command -v xdpyinfo >/dev/null 2>&1; then
            local display_info=$(xdpyinfo 2>/dev/null | grep dimensions | head -1 || echo "Display info unavailable")
            echo "Display info: ${display_info}"
        fi
        echo
        
        # Summary
        echo "📋 CAPABILITY SUMMARY"
        echo "===================="
        echo "Critical Issues: ${issues}"
        echo "Warnings: ${warnings}"
        echo
        
        if [ $issues -eq 0 ] && [ $warnings -eq 0 ]; then
            echo "🎉 EXCELLENT: Your system is fully capable of running VirtualBox testing"
            echo "   You can proceed with confidence using the VM testing environment."
        elif [ $issues -eq 0 ]; then
            echo "✅ GOOD: Your system can run VirtualBox testing"
            echo "   There are ${warnings} warning(s) that may affect performance."
            echo "   Consider addressing them for optimal experience."
        else
            echo "❌ ISSUES FOUND: ${issues} critical issue(s) must be resolved"
            echo "   VirtualBox testing may fail or perform poorly."
            echo "   Please address critical issues before proceeding."
        fi
        
    } | tee "$report_file"
    
    echo
    print_message "BLUE" "📄 Detailed report saved: $report_file"
    
    # Display console summary
    echo
    if [ $issues -eq 0 ] && [ $warnings -eq 0 ]; then
        print_message "GREEN" "🎉 System fully ready for VirtualBox testing!"
    elif [ $issues -eq 0 ]; then
        print_message "YELLOW" "⚠️ System ready with ${warnings} warning(s)"
    else
        print_message "RED" "❌ ${issues} critical issue(s) found - please fix before testing"
    fi
    
    # Return appropriate exit code
    if [ $issues -gt 0 ]; then
        return 1  # Critical issues found
    elif [ $warnings -gt 0 ]; then
        return 2  # Warnings found
    else
        return 0  # All good
    fi
}

#######################################
# Quick system capability check (minimal output)
#######################################
check_system_quick() {
    local total_memory_gb=$(($(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024 / 1024))
    local cpu_cores=$(nproc)
    local issues=0
    
    print_message "BLUE" "🔍 Quick system check..."
    
    # Basic checks
    if [ $total_memory_gb -lt 8 ]; then
        print_message "RED" "❌ RAM: ${total_memory_gb}GB (need 8GB+)"
        issues=$((issues + 1))
    fi
    
    if [ $cpu_cores -lt 4 ]; then
        print_message "YELLOW" "⚠️ CPU: ${cpu_cores} cores (recommend 4+)"
    fi
    
    if ! command -v VBoxManage >/dev/null 2>&1; then
        print_message "RED" "❌ VirtualBox not installed"
        issues=$((issues + 1))
    fi
    
    if ! command -v vagrant >/dev/null 2>&1; then
        print_message "RED" "❌ Vagrant not installed"
        issues=$((issues + 1))
    fi
    
    if ! grep -q "vmx\|svm" /proc/cpuinfo; then
        print_message "RED" "❌ Hardware virtualization not available"
        issues=$((issues + 1))
    fi
    
    if [ $issues -eq 0 ]; then
        print_message "GREEN" "✅ System ready for VirtualBox testing"
        return 0
    else
        print_message "RED" "❌ ${issues} critical issues found. Run './test.sh check-system' for details."
        return 1
    fi
}
