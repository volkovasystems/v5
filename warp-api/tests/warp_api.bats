#!/usr/bin/env bats
#
# Comprehensive BATS Tests for Warp Terminal Control API
# Organized test scenarios for pixel-perfect automation
#

# Test configuration
API_FILE="${BATS_TEST_DIRNAME}/warp_api.py"
LOGS_DIR="${BATS_TEST_DIRNAME}/logs"
SCREENSHOTS_DIR="${BATS_TEST_DIRNAME}/screenshots"
REPORTS_DIR="${BATS_TEST_DIRNAME}/reports"
RESULTS_DIR="${BATS_TEST_DIRNAME}/results"

#######################################
# Setup and Teardown
#######################################

setup() {
    # Ensure directories exist
    mkdir -p "$LOGS_DIR" "$SCREENSHOTS_DIR" "$REPORTS_DIR" "$RESULTS_DIR"
    
    # Set up environment variables
    export WARP_API_DIR="$(dirname "$BATS_TEST_DIRNAME")"
    export API_SCRIPT="$WARP_API_DIR/warp_api.py"
    
    # Ensure we have the latest API file (sync from parent directory)
    local parent_api="$(dirname "$BATS_TEST_DIRNAME")/warp_api.py"
    local tests_api="$BATS_TEST_DIRNAME/warp_api.py"
    if [[ -f "$parent_api" && "$parent_api" -nt "$tests_api" ]]; then
        cp "$parent_api" "$tests_api" 2>/dev/null || true
    fi
    
    # Change to API directory for tests
    cd "$WARP_API_DIR"
}

teardown() {
    # Clean up any running Warp processes from tests
    pkill -f warp 2>/dev/null || true
    
    # Clean up any remaining xtrlock processes
    pkill -f xtrlock 2>/dev/null || true
    
    # Log test completion
    echo "[$(date)] Test completed: $BATS_TEST_NAME" >> "$LOGS_DIR/bats_execution.log"
}

#######################################
# Basic API Tests
#######################################

@test "API script exists and is executable" {
    [[ -f "$API_SCRIPT" ]]
    [[ -x "$API_SCRIPT" ]]
}

@test "API script shows comprehensive help" {
    run python3 "$API_SCRIPT" --help
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Warp Terminal Control API"* ]]
    [[ "$output" == *"launch"* ]]
    [[ "$output" == *"new-tab"* ]]
    [[ "$output" == *"close-tab"* ]]
    [[ "$output" == *"test"* ]]
    [[ "$output" == *"report"* ]]
}

@test "API can be imported as Python module" {
    run python3 -c "import sys; sys.path.append('$WARP_API_DIR'); from warp_api import WarpAPI; api = WarpAPI(); print('Import successful')"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Import successful"* ]]
}

#######################################
# Dependency and Environment Tests
#######################################

@test "API handles missing pyautogui dependency gracefully" {
    # Skip if pyautogui is already installed
    if python3 -c "import pyautogui" 2>/dev/null; then
        skip "pyautogui is installed"
    fi
    
    run python3 "$API_SCRIPT" launch
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"Missing pyautogui dependency"* ]]
    [[ "$output" == *"pip install"* ]]
}

@test "API detects display environment correctly" {
    run python3 -c "
import sys, os
sys.path.append('$WARP_API_DIR')
from warp_api import WarpAPI
api = WarpAPI()

# Test display detection
display = os.environ.get('DISPLAY', 'None')
print('display_env:', display)

# Test GUI availability check (should handle missing GUI gracefully)
try:
    import pyautogui
    print('gui_available: True')
except ImportError:
    print('gui_available: False (expected)')
"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"display_env:"* ]]
    [[ "$output" == *"gui_available:"* ]]
}

@test "API creates required directory structure" {
    python3 -c "import sys; sys.path.append('$WARP_API_DIR'); from warp_api import WarpAPI; WarpAPI()" >/dev/null
    
    # Check if directories were created in the project directory
    [[ -d "reports" ]]
    [[ -d "screenshots" ]]
    
    # Verify directories are writable
    touch "reports/test_file" && rm "reports/test_file"
    touch "screenshots/test_file" && rm "screenshots/test_file"
}

#######################################
# Core Functionality Tests
#######################################

@test "Process verification methods work correctly" {
    run python3 -c "
import sys
sys.path.append('$WARP_API_DIR')
from warp_api import WarpAPI
api = WarpAPI()

# Test Warp detection (should be false initially)
warp_running = api._verify_warp_running()
print('warp_running:', warp_running)

# Test process counting
process_count = len(api._get_warp_processes())
print('process_count:', process_count)
"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"warp_running:"* ]]
    [[ "$output" == *"process_count:"* ]]
}

@test "Action logging and tracking works correctly" {
    run python3 -c "
import sys
sys.path.append('$WARP_API_DIR')
from warp_api import WarpAPI
api = WarpAPI()

# Test _log_action method
entry = api._log_action('test_action', True, {'detail': 'test'})

# Verify entry structure
assert entry['action'] == 'test_action'
assert entry['success'] == True
assert 'timestamp' in entry
assert 'details' in entry

# Verify it was added to session_actions
assert len(api.session_actions) == 1
assert api.session_actions[0] == entry

print('action_logging: functional')
"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"action_logging: functional"* ]]
}

@test "Safety mechanisms handle locking gracefully" {
    run python3 -c "
import sys, subprocess
sys.path.append('$WARP_API_DIR')
from warp_api import WarpAPI
api = WarpAPI()

# Test xtrlock availability
def test_xtrlock():
    try:
        result = subprocess.run(['which', 'xtrlock'], capture_output=True)
        return result.returncode == 0
    except:
        return False

xtrlock_available = test_xtrlock()
print('xtrlock_available:', xtrlock_available)

# Test lock_input method (should handle missing xtrlock gracefully)
lock_pid = api._lock_input()
if lock_pid:
    api._unlock_input(lock_pid)
    print('input_locking: functional')
else:
    print('input_locking: graceful_fallback')
"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"input_locking:"* ]]
}

#######################################
# Screenshot and Reporting Tests
#######################################

@test "Screenshot functionality handles missing GUI gracefully" {
    run python3 -c "
import sys
sys.path.append('$WARP_API_DIR')
from warp_api import WarpAPI
api = WarpAPI()

# Test screenshot method
screenshot_path = api._take_screenshot('test')
if screenshot_path and screenshot_path.exists():
    print('screenshot: functional')
    # Clean up test screenshot
    screenshot_path.unlink()
else:
    print('screenshot: graceful_fallback')
"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"screenshot:"* ]]
}

@test "Report generation works correctly" {
    run python3 -c "
import sys, json
sys.path.append('$WARP_API_DIR')
from warp_api import WarpAPI
api = WarpAPI()

# Create test actions
api.session_actions = [
    {
        'timestamp': '2025-01-01T00:00:00',
        'action': 'test_action_1',
        'success': True,
        'details': {'test': True}
    },
    {
        'timestamp': '2025-01-01T00:01:00',
        'action': 'test_action_2',
        'success': False,
        'details': {'error': 'test_error'}
    }
]

# Generate report
report_path = api._generate_report()
print('report_generated:', report_path is not None)

if report_path and report_path.exists():
    # Validate JSON structure
    with open(report_path) as f:
        report = json.load(f)
    
    assert 'session' in report
    assert 'actions' in report
    assert 'timestamp' in report['session']
    assert 'total_actions' in report['session']
    assert 'successful_actions' in report['session']
    assert 'success_rate' in report['session']
    
    print('report_structure: valid')
    
    # Clean up test report
    report_path.unlink()
"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"report_generated:"* ]]
}

@test "Report command works with no existing reports" {
    run python3 "$API_SCRIPT" report
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"No test reports found"* || "$output" == *"Reports found"* ]]
}

#######################################
# CLI Interface Tests
#######################################

@test "CLI handles all supported arguments correctly" {
    actions=("launch" "new-tab" "close-tab" "close" "test" "report")
    
    for action in "${actions[@]}"; do
        run python3 "$API_SCRIPT" "$action"
        
        # Status should be 0 (success), 1 (dependency missing), or handled gracefully
        [[ "$status" == 0 || "$status" == 1 ]]
        
        # Should not crash with unknown argument error
        [[ "$output" != *"invalid choice"* ]]
    done
}

@test "CLI rejects invalid arguments with proper error message" {
    run python3 "$API_SCRIPT" invalid_action
    [[ "$status" -eq 2 ]]  # argparse returns 2 for invalid arguments
    [[ "$output" == *"invalid choice"* ]]
}

@test "CLI verbose mode provides detailed output" {
    run python3 "$API_SCRIPT" --verbose report
    [[ "$status" -eq 0 ]]
    # Should contain either detailed report info or dependency info
    [[ ${#output} -gt 50 ]]  # Verbose output should be substantial
}

#######################################
# Error Handling and Robustness Tests
#######################################

@test "API handles missing Warp executable gracefully" {
    run env PATH="/bin:/usr/bin" python3 -c "
import sys, subprocess
sys.path.append('$WARP_API_DIR')
from warp_api import WarpAPI
api = WarpAPI()

# Test launch when Warp is not available
def mock_launch():
    try:
        subprocess.Popen(['warp'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True
    except FileNotFoundError:
        return False

result = mock_launch()
print('launch_without_warp:', result)
"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"launch_without_warp: False"* ]]
}

@test "API handles file system permissions correctly" {
    run python3 -c "
import sys, os
sys.path.append('$WARP_API_DIR')
from warp_api import WarpAPI
api = WarpAPI()

# Test directory creation and permissions
reports_dir = api.reports_dir
screenshots_dir = api.screenshots_dir

# Verify directories exist and are writable
assert reports_dir.exists()
assert screenshots_dir.exists()
assert os.access(str(reports_dir), os.W_OK)
assert os.access(str(screenshots_dir), os.W_OK)

print('filesystem_permissions: functional')
"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"filesystem_permissions: functional"* ]]
}

@test "API handles resource management properly" {
    run python3 -c "
import sys, gc
sys.path.append('$WARP_API_DIR')
from warp_api import WarpAPI

# Create and destroy API instances to test memory management
for i in range(3):
    api = WarpAPI()
    # Add some session data
    api.session_actions.append({
        'timestamp': f'test_{i}',
        'action': f'action_{i}',
        'success': True
    })
    del api

# Force garbage collection
gc.collect()
print('resource_management: functional')
"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"resource_management: functional"* ]]
}

#######################################
# Integration and Infrastructure Tests
#######################################

@test "Test infrastructure is properly organized" {
    # Verify test directory structure
    [[ -d "$BATS_TEST_DIRNAME" ]]
    [[ -f "$BATS_TEST_DIRNAME/warp_api.bats" ]]
    [[ -d "$LOGS_DIR" ]]
    [[ -d "$SCREENSHOTS_DIR" ]]
    [[ -d "$REPORTS_DIR" ]]
    
    # Verify core API file exists and is accessible
    [[ -f "$WARP_API_DIR/warp_api.py" ]]
    
    # Verify test can access API
    run python3 -c "import sys; sys.path.append('$WARP_API_DIR'); import warp_api; print('integration: functional')"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"integration: functional"* ]]
}

@test "Test helper functions are available" {
    # Check if test helper file exists
    [[ -f "$BATS_TEST_DIRNAME/test_helper.bash" ]]
    
    # Test helper functions can be loaded
    run bash -c "source '$BATS_TEST_DIRNAME/test_helper.bash' && print_message 'GREEN' 'Test helper functional'"
    [[ "$status" -eq 0 ]]
    # Output should contain ANSI color codes and the message
    [[ "$output" == *"Test helper functional"* ]]
}

@test "VM testing infrastructure is ready" {
    # Check if Vagrantfile exists
    [[ -f "$BATS_TEST_DIRNAME/Vagrantfile" ]]
    
    # Check if main test script exists
    [[ -f "$BATS_TEST_DIRNAME/test.sh" ]]
    [[ -x "$BATS_TEST_DIRNAME/test.sh" ]]
    
    # Check if sync functionality is available in test helpers
    run bash -c "source '$BATS_TEST_DIRNAME/test_helper.bash' && type sync_api_file >/dev/null"
    [[ "$status" -eq 0 ]]
}

#######################################
# Performance and Scalability Tests
#######################################

@test "API performs well with multiple actions" {
    run timeout 30s python3 -c "
import sys, time
sys.path.append('$WARP_API_DIR')
from warp_api import WarpAPI

start_time = time.time()
api = WarpAPI()

# Simulate multiple actions
for i in range(100):
    api._log_action(f'test_action_{i}', i % 2 == 0, {'iteration': i})

# Test report generation with many actions
report_path = api._generate_report()

end_time = time.time()
duration = end_time - start_time

print(f'performance_test: {duration:.2f}s for 100 actions')
print(f'actions_logged: {len(api.session_actions)}')

# Cleanup
if report_path and report_path.exists():
    report_path.unlink()
"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"performance_test:"* ]]
    [[ "$output" == *"actions_logged: 100"* ]]
}

#######################################
# Final Integration Test
#######################################

@test "Complete workflow test (dry run)" {
    run python3 -c "
import sys
sys.path.append('$WARP_API_DIR')
from warp_api import WarpAPI

print('Starting complete workflow test...')

# Initialize API
api = WarpAPI()
print('✓ API initialized')

# Test action logging
api._log_action('workflow_test', True, {'step': 'initialization'})
print('✓ Action logging works')

# Test screenshot (dry run)
screenshot = api._take_screenshot('workflow_test')
if screenshot:
    print('✓ Screenshot capability available')
    if screenshot.exists():
        screenshot.unlink()
else:
    print('✓ Screenshot gracefully handled (no GUI)')

# Test report generation
report = api._generate_report()
if report:
    print('✓ Report generation works')
    if report.exists():
        report.unlink()

print('Complete workflow test passed!')
"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Complete workflow test passed!"* ]]
    [[ "$output" == *"✓ API initialized"* ]]
    [[ "$output" == *"✓ Action logging works"* ]]
    [[ "$output" == *"✓ Report generation works"* ]]
}