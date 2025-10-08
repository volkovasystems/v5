#!/bin/bash
#
# Warp API Test Runner
# Main script for running all Warp API tests in isolated VM environment
#

set -e

# Load test helper functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helper.bash"

# Configuration
BATS_FILE="warp_api.bats"
DEFAULT_MODE="vm"
DEFAULT_FORMAT="tap"
CLEANUP_LEVEL="basic"

# Safety: NEVER allow host mode by default to prevent terminal shutdown
FORCE_VM_MODE="true"

#######################################
# Display usage information
#######################################
usage() {
    cat << EOF
Usage: $0 [OPTIONS] [COMMAND]

Warp API Test Runner - Runs pixel-perfect Warp Terminal API tests

COMMANDS:
  test              Run all tests (default)
  setup             Set up test environment only
  cleanup           Clean up test artifacts (interactive menu)
  check-system      Check host system capability for VirtualBox testing
  check-system-quick Quick system capability check
  vm-start          Start the VM
  vm-stop           Stop the VM
  vm-status         Show VM status
  vm-init           Initialize VM for first time (with snapshot)
  vm-restart        Force restart VM and re-provision (handles interrupted setups)
  vm-reset          Reset VM to clean snapshot state
  vm-rebuild        Destroy and rebuild VM from scratch
  vm-snapshot       Create a new VM snapshot
  vm-restore        Restore VM from snapshot
  vm-list           List available VM snapshots
  sync              Sync API file from parent directory
  
  # Repository Integration:
  vm-pristine   Create pristine snapshot for repository commit
  vm-clone      Restore pristine snapshot (after repository clone)
  
  # Cleanup Commands:
  cleanup-data       Clean test data (basic|full)
  cleanup-vm         Clean VM test data
  cleanup-snapshots  Remove all VM snapshots
  cleanup-all        Full environment reset (nuclear)

OPTIONS:
  -m, --mode MODE       Test mode: vm|host (default: vm)
  -f, --format FORMAT   Output format: tap|pretty (default: tap)
  -c, --cleanup LEVEL   Cleanup level: basic|full (default: basic)
  -v, --verbose         Enable verbose output
  -y, --yes, --force    Skip interactive prompts (for automation)
  -h, --help            Show this help message

EXAMPLES:
  $0                       # Run all tests in VM with TAP output
  $0 test -f pretty        # Run tests with pretty output
  $0 check-system          # Check if system can handle VirtualBox testing
  $0 check-system-quick    # Quick system capability check
  $0 vm-init               # Initialize VM for first time (one-time setup)
  $0 vm-restart            # Force restart VM (perfect after interruptions)
  $0 setup                 # Set up test environment only
  $0 cleanup               # Interactive cleanup menu
  $0 cleanup-data basic # Basic test data cleanup
  $0 cleanup-data full  # Full test data cleanup
  $0 vm-reset           # Reset VM to clean state
  $0 vm-rebuild         # Rebuild VM from scratch
  $0 cleanup-all        # Nuclear reset (destroys everything)
  $0 vm-snapshot clean  # Create 'clean' snapshot
  $0 vm-restore clean   # Restore from 'clean' snapshot
  $0 vm-list            # List available snapshots
  
  # Repository Integration:
  $0 vm-pristine        # Create pristine snapshot for git commit
  $0 vm-clone           # Restore pristine snapshot (after git clone)
  
  # Automation Examples (no prompts):
  $0 cleanup-all --force     # Full reset without confirmation
  $0 vm-rebuild --yes        # Rebuild VM without confirmation
  $0 cleanup --force         # Show automation commands
  
  # VM optimized for ultra-fast downloads with parallel processing

ENVIRONMENT:
  The script automatically:
  - Syncs warp_api.py from parent directory
  - Ensures VM is running (in vm mode)
  - Waits for GUI to be ready
  - Runs BATS tests with proper logging
  - Archives results for analysis

EOF
}

#######################################
# Parse command line arguments
#######################################
parse_args() {
    local command=""
    local mode="$DEFAULT_MODE"
    local format="$DEFAULT_FORMAT"
    local cleanup="$CLEANUP_LEVEL"
    local verbose=false
    local force=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            test|setup|cleanup|cleanup-data|cleanup-vm|cleanup-snapshots|cleanup-all|check-system|check-system-quick|vm-start|vm-stop|vm-status|vm-init|vm-restart|vm-reset|vm-rebuild|vm-snapshot|vm-restore|vm-list|vm-pristine|vm-clone|sync)
                command="$1"
                # For vm-snapshot and vm-restore, capture the snapshot name
                if [[ "$1" == "vm-snapshot" ]] || [[ "$1" == "vm-restore" ]]; then
                    shift
                    if [[ $# -gt 0 && ! "$1" =~ ^- ]]; then
                        export SNAPSHOT_NAME="$1"
                        shift
                    else
                        export SNAPSHOT_NAME="clean"
                    fi
                # For cleanup-data, capture the level
                elif [[ "$1" == "cleanup-data" ]]; then
                    shift
                    if [[ $# -gt 0 && ! "$1" =~ ^- ]]; then
                        export CLEANUP_DATA_LEVEL="$1"
                        shift
                    else
                        export CLEANUP_DATA_LEVEL="basic"
                    fi
                else
                    shift
                fi
                ;;
            -m|--mode)
                mode="$2"
                shift 2
                ;;
            -f|--format)
                format="$2"
                shift 2
                ;;
            -c|--cleanup)
                cleanup="$2"
                shift 2
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -y|--yes|--force)
                force=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                print_message "RED" "❌ Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # Default command is test
    command="${command:-test}"
    
    # Validate arguments
    # Safety check: Prevent host mode unless explicitly forced with special flag
    if [[ "$mode" == "host" ]] && [[ "$FORCE_VM_MODE" == "true" ]]; then
        print_message "RED" "🚨 HOST MODE DISABLED FOR SAFETY!"
        print_message "YELLOW" "⚠️ Host mode can shut down your active Warp terminal."
        print_message "BLUE" "💡 Use VM mode instead: ./test.sh test"
        print_message "BLUE" "💡 To force host mode (dangerous): export FORCE_VM_MODE=false && ./test.sh test -m host"
        exit 1
    fi
    
    case "$mode" in
        vm|host) ;;
        *) 
            print_message "RED" "❌ Invalid mode: $mode"
            exit 1
            ;;
    esac
    
    case "$format" in
        tap|pretty) ;;
        *)
            print_message "RED" "❌ Invalid format: $format"
            exit 1
            ;;
    esac
    
    case "$cleanup" in
        basic|full) ;;
        *)
            print_message "RED" "❌ Invalid cleanup level: $cleanup"
            exit 1
            ;;
    esac
    
    # Set global variables
    export TEST_COMMAND="$command"
    export TEST_MODE="$mode"
    export TEST_FORMAT="$format"
    export TEST_CLEANUP="$cleanup"
    export TEST_VERBOSE="$verbose"
    export TEST_FORCE="$force"
}

#######################################
# Set up test environment
#######################################
setup_environment() {
    print_header "Setting up Test Environment"
    
    # Ensure directories exist
    ensure_directories
    
    # Check dependencies
    if ! check_dependencies; then
        print_message "RED" "❌ Please install missing dependencies and try again"
        exit 1
    fi
    
    # Sync API file
    if ! sync_api_file; then
        print_message "RED" "❌ Failed to sync API file"
        exit 1
    fi
    
    # Clean up previous artifacts
    cleanup_artifacts "$TEST_CLEANUP"
    
    print_message "GREEN" "✅ Test environment set up successfully"
}

#######################################
# Set up VM environment (persistent approach)
#######################################
setup_vm_environment() {
    print_header "Setting up VM Environment"
    
    # Check if clean snapshot exists
    if snapshot_exists "clean"; then
        print_message "BLUE" "🔄 Restoring from clean snapshot..."
        if restore_vm_snapshot "clean"; then
            # Start VM after restore
            if ! ensure_vm_running; then
                print_message "RED" "❌ Failed to start VM after snapshot restore"
                exit 1
            fi
        else
            print_message "YELLOW" "⚠️ Failed to restore snapshot, using current VM state"
            if ! ensure_vm_running; then
                exit 1
            fi
        fi
    else
        print_message "YELLOW" "⚠️ No 'clean' snapshot found, using current VM state"
        print_message "BLUE" "💡 Consider running: ./test.sh vm-init to create a clean base"
        
        # Ensure VM is running
        if ! ensure_vm_running; then
            print_message "RED" "❌ Failed to start VM"
            exit 1
        fi
    fi
    
    # Wait for GUI to be ready
    if ! wait_for_vm_gui; then
        print_message "RED" "❌ VM GUI not ready"
        exit 1
    fi
    
    # Setup clean test environment
    if ! setup_vm_test_environment; then
        print_message "RED" "❌ Failed to set up test environment"
        exit 1
    fi
    
    print_message "GREEN" "✅ VM environment ready for testing"
}

#######################################
# Run tests in VM mode
#######################################
run_vm_tests() {
    print_header "Running Tests in VM"
    
    local session_log=$(create_session_log)
    local timestamp=$(timestamp)
    
    print_message "BLUE" "📝 Session log: $session_log"
    
    # Sync API file to VM first
    print_message "BLUE" "📄 Syncing warp_api.py to VM..."
    if ! provision_vm "test_setup"; then
        print_message "RED" "❌ Failed to sync test files to VM"
        return 1
    fi
    
    # Run the automated tests using Vagrant provision
    print_message "BLUE" "🚀 Starting automated tests in VM..."
    print_message "BLUE" "💡 This will run the tests inside the VM automatically"
    
    local vm_exit_code=0
    if ! provision_vm "run_tests"; then
        vm_exit_code=$?
        print_message "YELLOW" "⚠️ VM tests completed with errors (exit code: $vm_exit_code)"
    else
        print_message "GREEN" "✅ VM tests completed successfully"
    fi
    
    # Copy results back from VM
    print_message "BLUE" "📋 Retrieving test results from VM..."
    
    # Copy all generated files from VM to host
    local vm_test_dir="/home/vagrant/warp-testing"
    
    # Copy logs
    if vm_exec "ls '$vm_test_dir'/logs/*.log >/dev/null 2>&1"; then
        vm_exec "ls '$vm_test_dir'/logs/*.log" | while read -r logfile; do
            if [[ -n "$logfile" ]]; then
                local basename=$(basename "$logfile")
                copy_from_vm "$logfile" "$LOGS_DIR/$basename" 2>/dev/null || true
            fi
        done
    fi
    
    # Copy reports
    if vm_exec "ls '$vm_test_dir'/reports/* >/dev/null 2>&1"; then
        vm_exec "ls '$vm_test_dir'/reports/*" | while read -r reportfile; do
            if [[ -n "$reportfile" ]]; then
                local basename=$(basename "$reportfile")
                copy_from_vm "$reportfile" "$REPORTS_DIR/$basename" 2>/dev/null || true
            fi
        done
    fi
    
    # Copy results  
    if vm_exec "ls '$vm_test_dir'/results/* >/dev/null 2>&1"; then
        vm_exec "ls '$vm_test_dir'/results/*" | while read -r resultfile; do
            if [[ -n "$resultfile" ]]; then
                local basename=$(basename "$resultfile")
                copy_from_vm "$resultfile" "$RESULTS_DIR/$basename" 2>/dev/null || true
            fi
        done
    fi
    
    # Copy screenshots
    if vm_exec "ls '$vm_test_dir'/screenshots/*.png >/dev/null 2>&1"; then
        vm_exec "ls '$vm_test_dir'/screenshots/*.png" | while read -r screenshot; do
            if [[ -n "$screenshot" ]]; then
                local basename=$(basename "$screenshot")
                copy_from_vm "$screenshot" "$SCREENSHOTS_DIR/$basename" 2>/dev/null || true
            fi
        done
    fi
    
    # Create a test summary
    local summary_file="$REPORTS_DIR/test_summary_${timestamp}.txt"
    cat > "$summary_file" << EOF
=== WARP API TEST SUMMARY ===
Date: $(date)
Host: $(hostname)
VM: warp-api-testbed
Test Mode: VM (automated)
Exit Code: $vm_exit_code
Session Log: $session_log

Results Location:
- Logs: $LOGS_DIR
- Reports: $REPORTS_DIR
- Results: $RESULTS_DIR  
- Screenshots: $SCREENSHOTS_DIR
EOF
    
    print_message "BLUE" "📊 Test session logged to: $session_log"
    print_message "BLUE" "📋 Test summary: $summary_file"
    
    if [[ $vm_exit_code -eq 0 ]]; then
        print_message "GREEN" "✅ All automated tests passed successfully!"
    else
        print_message "YELLOW" "⚠️ Some tests failed - check logs for details"
    fi
    
    return $vm_exit_code
}

#######################################
# Run tests in host mode (for development/debugging)
#######################################
run_host_tests() {
    print_header "Running Tests on Host"
    
    print_message "RED" "🚨 DANGER: Running tests on host machine!"
    print_message "YELLOW" "⚠️ Warning: This WILL shut down your active Warp terminal!"
    print_message "BLUE" "💡 Consider using VM mode instead: ./test.sh test"
    
    local session_log=$(create_session_log)
    
    print_message "BLUE" "📝 Session log: $session_log"
    print_message "BLUE" "🧪 Running BATS tests on host..."
    
    # Run BATS tests directly
    if run_bats_tests "$BATS_FILE" "$TEST_FORMAT"; then
        print_message "GREEN" "✅ Host tests completed successfully"
        return 0
    else
        local exit_code=$?
        print_message "RED" "❌ Host tests failed"
        return $exit_code
    fi
}

#######################################
# Main execution flow
#######################################
main() {
    # Parse command line arguments
    parse_args "$@"
    
    print_header "Warp API Test Runner"
    print_message "BLUE" "📋 Command: $TEST_COMMAND"
    print_message "BLUE" "📋 Mode: $TEST_MODE"
    print_message "BLUE" "📋 Format: $TEST_FORMAT"
    print_message "BLUE" "📋 Working Directory: $SCRIPT_DIR"
    
    # Show VM optimization info for VM-related commands
    if [[ "$TEST_MODE" == "vm" ]] || [[ "$TEST_COMMAND" =~ ^vm- ]]; then
        show_vm_optimization_info
    fi
    
    case "$TEST_COMMAND" in
        setup)
            setup_environment
            if [[ "$TEST_MODE" == "vm" ]]; then
                setup_vm_environment
            fi
            ;;
        cleanup)
            print_header "Cleaning up Test Environment"
            interactive_cleanup
            ;;
        cleanup-data)
            local level="${CLEANUP_DATA_LEVEL:-basic}"
            print_header "Cleaning Test Data ($level)"
            cleanup_test_data "$level"
            ;;
        cleanup-vm)
            print_header "Cleaning VM Test Data"
            cleanup_vm_data
            ;;
        cleanup-snapshots)
            print_header "Removing VM Snapshots"
            cleanup_vm_snapshots
            ;;
        cleanup-all)
            print_header "Full Environment Reset"
            if [[ "$TEST_FORCE" == "true" ]]; then
                print_message "YELLOW" "🚨 Force mode: Performing full environment reset without confirmation"
                reset_full_environment
            else
                print_message "RED" "🚨 This will destroy EVERYTHING! Are you sure? (y/N)"
                read -p "Confirm full reset: " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    reset_full_environment
                else
                    print_message "BLUE" "Operation cancelled"
                fi
            fi
            ;;
        vm-start)
            ensure_vm_running
            ;;
        vm-stop)
            stop_vm
            ;;
        vm-status)
            local status=$(get_vm_status)
            print_message "BLUE" "🖥️ VM Status: $status"
            ;;
        vm-init)
            print_header "Initializing VM for First Time"
            
            # Ensure VM is running and fully provisioned
            print_message "BLUE" "🚀 Starting initial VM setup..."
            if ! vagrant up --provision; then
                print_message "RED" "❌ Failed to initialize VM"
                exit 1
            fi
            
            # Wait for GUI
            if ! wait_for_vm_gui; then
                print_message "RED" "❌ VM GUI not ready"
                exit 1
            fi
            
            # Create clean snapshot
            print_message "BLUE" "📸 Creating 'clean' snapshot for reuse..."
            if create_vm_snapshot "clean" "Base clean state after initial setup"; then
                print_message "GREEN" "✅ VM initialized successfully with 'clean' snapshot!"
                
                # Also create pristine snapshot for repository
                print_message "BLUE" "📸 Creating pristine snapshot for repository..."
                if create_pristine_snapshot; then
                    print_message "GREEN" "✅ Pristine snapshot created for repository!"
                    print_message "BLUE" "💡 You can now run tests with: ./test.sh test"
                    print_message "BLUE" "💾 Pristine snapshot is ready for git commit"
                else
                    print_message "YELLOW" "⚠️ Pristine snapshot creation failed, but VM is ready"
                    print_message "BLUE" "💡 You can still run tests with: ./test.sh test"
                fi
            else
                print_message "YELLOW" "⚠️ VM setup complete but snapshot creation failed"
            fi
            ;;
        vm-restart)
            print_header "Force Restarting VM and Re-provisioning"
            print_message "BLUE" "🔄 This will stop the VM, restart it, and re-run provisioning"
            print_message "BLUE" "💡 Perfect for recovering from interrupted setups!"
            
            # Stop VM if running (force stop)
            print_message "YELLOW" "⏹️ Force stopping VM..."
            vagrant halt -f >/dev/null 2>&1 || true
            
            # Kill any VirtualBox processes that might be hanging
            print_message "BLUE" "🔧 Cleaning up any hanging processes..."
            pkill -f "$VM_NAME" >/dev/null 2>&1 || true
            
            # Wait a moment for complete shutdown
            sleep 3
            
            # Start VM with fresh provisioning
            print_message "BLUE" "🚀 Starting VM with fresh provisioning..."
            if vagrant up --provision; then
                print_message "GREEN" "✅ VM restarted and provisioned successfully"
                
                # Wait for GUI to be ready
                if wait_for_vm_gui; then
                    print_message "GREEN" "🎯 VM is ready for testing!"
                    
                    # Optionally create/update clean snapshot
                    if [[ "$TEST_FORCE" != "true" ]]; then
                        print_message "BLUE" "📸 Update clean snapshot? (y/N)"
                        read -p "Create snapshot: " create_snap
                        if [[ "$create_snap" =~ ^[Yy]$ ]]; then
                            create_vm_snapshot "clean" "Clean state after restart $(date)"
                        fi
                    fi
                else
                    print_message "YELLOW" "⚠️ VM restarted but GUI may not be fully ready"
                fi
            else
                print_message "RED" "❌ Failed to restart and provision VM"
                print_message "BLUE" "💡 Try: ./test.sh vm-rebuild for a complete rebuild"
                exit 1
            fi
            ;;
        vm-reset)
            print_header "Resetting VM to Clean State"
            print_message "BLUE" "🔄 Resetting VM to known clean state..."
            
            # If reset fails, offer alternatives
            if reset_vm_to_clean; then
                print_message "GREEN" "✅ VM reset completed successfully"
            else
                print_message "YELLOW" "⚠️ Clean snapshot reset failed"
                
                if [[ "$TEST_FORCE" != "true" ]]; then
                    print_message "BLUE" "💡 Would you like to try a force restart instead? (y/N)"
                    read -p "Force restart: " restart_choice
                    if [[ "$restart_choice" =~ ^[Yy]$ ]]; then
                        print_message "BLUE" "🔄 Switching to force restart..."
                        # Stop VM and restart with provisioning
                        vagrant halt -f >/dev/null 2>&1 || true
                        sleep 2
                        if vagrant up --provision; then
                            if wait_for_vm_gui; then
                                print_message "GREEN" "✅ VM force restart completed successfully"
                            else
                                print_message "YELLOW" "⚠️ VM restarted but GUI may not be ready"
                            fi
                        else
                            print_message "RED" "❌ Force restart also failed"
                            exit 1
                        fi
                    else
                        print_message "RED" "❌ VM reset failed"
                        print_message "BLUE" "💡 Try: ./test.sh vm-restart or ./test.sh vm-rebuild"
                        exit 1
                    fi
                else
                    print_message "RED" "❌ VM reset failed in force mode"
                    exit 1
                fi
            fi
            ;;
        vm-rebuild)
            print_header "Rebuilding VM from Scratch"
            if [[ "$TEST_FORCE" == "true" ]]; then
                print_message "YELLOW" "⚠️ Force mode: Rebuilding VM without confirmation"
                if rebuild_vm; then
                    print_message "GREEN" "✅ VM rebuild completed successfully"
                else
                    print_message "RED" "❌ VM rebuild failed"
                    exit 1
                fi
            else
                print_message "YELLOW" "⚠️ This will destroy the current VM. Are you sure? (y/N)"
                read -p "Confirm VM rebuild: " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    if rebuild_vm; then
                        print_message "GREEN" "✅ VM rebuild completed successfully"
                    else
                        print_message "RED" "❌ VM rebuild failed"
                        exit 1
                    fi
                else
                    print_message "BLUE" "Operation cancelled"
                fi
            fi
            ;;
        vm-snapshot)
            local snapshot_name="${SNAPSHOT_NAME:-clean}"
            print_header "Creating VM Snapshot"
            create_vm_snapshot "$snapshot_name" "Manual snapshot created at $(date)"
            ;;
        vm-restore)
            local snapshot_name="${SNAPSHOT_NAME:-clean}"
            print_header "Restoring VM Snapshot"
            restore_vm_snapshot "$snapshot_name"
            ;;
        vm-list)
            print_header "VM Snapshots"
            list_vm_snapshots
            ;;
        vm-pristine)
            print_header "Creating Pristine Snapshot"
            if create_pristine_snapshot; then
                print_message "GREEN" "✅ Pristine snapshot ready for repository commit"
                print_message "BLUE" "💡 You can now commit .vagrant/machines/.../Snapshots/ to git"
            else
                print_message "RED" "❌ Failed to create pristine snapshot"
                exit 1
            fi
            ;;
        vm-clone)
            print_header "Restoring Pristine Snapshot"
            if restore_pristine_snapshot; then
                print_message "GREEN" "🎉 Ready for testing! VM restored from pristine snapshot."
            else
                print_message "YELLOW" "⚠️ No pristine snapshot found. Running full VM initialization..."
                if ! vagrant up; then
                    print_message "RED" "❌ Failed to initialize VM"
                    exit 1
                fi
                
                if ! wait_for_vm_gui; then
                    print_message "RED" "❌ VM GUI not ready"
                    exit 1
                fi
                
                if create_vm_snapshot "clean" "Base clean state after initialization"; then
                    print_message "GREEN" "✅ VM initialized and clean snapshot created"
                else
                    print_message "YELLOW" "⚠️ VM initialized but snapshot creation failed"
                fi
            fi
            ;;
        check-system)
            print_header "System Capability Check"
            if check_system_capabilities; then
                print_message "GREEN" "🎉 System is fully ready for VirtualBox testing!"
                exit 0
            else
                local exit_code=$?
                if [[ $exit_code -eq 1 ]]; then
                    print_message "RED" "❌ Critical issues found - please address before testing"
                    exit 1
                else
                    print_message "YELLOW" "⚠️ System can run tests but has warnings - consider addressing for optimal performance"
                    exit 0
                fi
            fi
            ;;
        check-system-quick)
            print_header "Quick System Check"
            if check_system_quick; then
                print_message "GREEN" "✅ System ready for VirtualBox testing!"
                exit 0
            else
                print_message "RED" "❌ System issues found - run './test.sh check-system' for details"
                exit 1
            fi
            ;;
        sync)
            sync_api_file
            ;;
        test)
            # Set up environment
            setup_environment
            
            local test_exit_code=0
            
            if [[ "$TEST_MODE" == "vm" ]]; then
                # Quick system capability check before VM operations
                print_message "BLUE" "🔍 Checking system capability for VM testing..."
                if ! check_system_quick; then
                    if [[ "$TEST_FORCE" == "true" ]]; then
                        print_message "YELLOW" "🚑 Force mode: Proceeding despite system capability warnings"
                    else
                        print_message "RED" "❌ System capability issues detected!"
                        print_message "BLUE" "📄 Run './test.sh check-system' for detailed analysis"
                        print_message "BLUE" "💡 Or use '--force' to proceed anyway"
                        exit 1
                    fi
                else
                    print_message "GREEN" "✅ System capability check passed"
                fi
                echo
                # Try to use pristine snapshot first for fastest startup
                if snapshot_exists "pristine" && ! snapshot_exists "clean"; then
                    print_message "BLUE" "📸 Using pristine snapshot for fastest startup..."
                    if restore_pristine_snapshot; then
                        print_message "GREEN" "✅ Pristine snapshot restored, ready for testing"
                    else
                        setup_vm_environment
                    fi
                else
                    setup_vm_environment
                fi
                
                if ! run_vm_tests; then
                    test_exit_code=$?
                fi
            else
                if ! run_host_tests; then
                    test_exit_code=$?
                fi
            fi
            
            # Archive results
            archive_results
            
            if [[ $test_exit_code -eq 0 ]]; then
                print_header "✅ All Tests Passed"
            else
                print_header "❌ Some Tests Failed"
            fi
            
            exit $test_exit_code
            ;;
        *)
            print_message "RED" "❌ Unknown command: $TEST_COMMAND"
            usage
            exit 1
            ;;
    esac
}

# Trap to ensure cleanup on exit
trap 'cleanup_artifacts basic >/dev/null 2>&1' EXIT

# Run main function with all arguments
main "$@"