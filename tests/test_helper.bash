#!/usr/bin/env bash
# test_helper.bash - Common helper functions for V5 BATS tests
set -euo pipefail

# Test configuration
export BATS_TEST_TIMEOUT=30
export TEST_TEMP_DIR="${BATS_TMPDIR}/v5_test_$$"

# V5 Test Environment Setup
setup_v5_test_env() {
    # Create isolated test directory
    mkdir -p "$TEST_TEMP_DIR"
    
    # Find the V5 project root (go up from tests directory)
    # Handle both cases: when running from project root and from tests directory
    if [ -n "${BATS_TEST_DIRNAME:-}" ]; then
        # BATS_TEST_DIRNAME could be tests/integration or tests/unit
        # Check if we need to go up one level (from tests) or two levels (from tests/subdir)
        if [ -f "$BATS_TEST_DIRNAME/../v5" ] && [ -f "$BATS_TEST_DIRNAME/../VERSION" ]; then
            V5_PROJECT_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
        elif [ -f "$BATS_TEST_DIRNAME/../../v5" ] && [ -f "$BATS_TEST_DIRNAME/../../VERSION" ]; then
            V5_PROJECT_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
        else
            echo "Error: Could not locate V5 project root from BATS_TEST_DIRNAME=$BATS_TEST_DIRNAME"
            return 1
        fi
    else
        # Fallback: assume we're in project root or tests directory
        if [ -f "v5" ] && [ -f "VERSION" ]; then
            V5_PROJECT_ROOT="$(pwd)"
        elif [ -f "../v5" ] && [ -f "../VERSION" ]; then
            V5_PROJECT_ROOT="$(cd .. && pwd)"
        else
            echo "Error: Could not locate V5 project root from $(pwd)"
            return 1
        fi
    fi
    
    # Verify we found the right directory
    if [ ! -f "$V5_PROJECT_ROOT/v5" ] || [ ! -f "$V5_PROJECT_ROOT/VERSION" ]; then
        echo "Error: Could not locate V5 project root. Looking in: $V5_PROJECT_ROOT"
        echo "Contents:"
        ls -la "$V5_PROJECT_ROOT" 2>/dev/null || echo "Directory not accessible"
        echo "BATS_TEST_DIRNAME: ${BATS_TEST_DIRNAME:-unset}"
        echo "Current directory: $(pwd)"
        return 1
    fi
    
    cd "$TEST_TEMP_DIR" || return 1

    # Copy essential files individually to avoid glob expansion issues
    cp "$V5_PROJECT_ROOT/v5" . 2>/dev/null || echo "Warning: Could not copy v5"
    cp "$V5_PROJECT_ROOT/VERSION" . 2>/dev/null || echo "Warning: Could not copy VERSION"
    cp "$V5_PROJECT_ROOT/README.md" . 2>/dev/null || echo "Warning: Could not copy README.md"
    cp "$V5_PROJECT_ROOT/LICENSE" . 2>/dev/null || echo "Warning: Could not copy LICENSE"
    cp "$V5_PROJECT_ROOT/CHANGELOG.md" . 2>/dev/null || echo "Warning: Could not copy CHANGELOG.md"
    cp "$V5_PROJECT_ROOT/requirements.txt" . 2>/dev/null || echo "Warning: Could not copy requirements.txt"
    cp "$V5_PROJECT_ROOT/pyproject.toml" . 2>/dev/null || echo "Warning: Could not copy pyproject.toml"
    
    # Copy shell scripts
    cp "$V5_PROJECT_ROOT/install.sh" . 2>/dev/null || echo "Warning: Could not copy install.sh"
    cp "$V5_PROJECT_ROOT/uninstall.sh" . 2>/dev/null || echo "Warning: Could not copy uninstall.sh"
    cp "$V5_PROJECT_ROOT/get-v5.sh" . 2>/dev/null || echo "Warning: Could not copy get-v5.sh"
    cp "$V5_PROJECT_ROOT/test" . 2>/dev/null || echo "Warning: Could not copy test script"
    
    # Copy source directory
    if [ -d "$V5_PROJECT_ROOT/src" ]; then
        cp -r "$V5_PROJECT_ROOT/src" . || echo "Warning: Could not copy src directory"
    else
        echo "Warning: src directory not found in $V5_PROJECT_ROOT"
    fi
    
    # Copy tests directory (for completeness)
    if [ -d "$V5_PROJECT_ROOT/tests" ]; then
        cp -r "$V5_PROJECT_ROOT/tests" . 2>/dev/null || echo "Warning: Could not copy tests directory"
    fi

    # Ensure executables have correct permissions
    chmod +x v5 install.sh uninstall.sh get-v5.sh test 2>/dev/null || true

    # Set up Python path
    export PYTHONPATH="$TEST_TEMP_DIR/src:${PYTHONPATH:-}"

    # Create test repository structure
    mkdir -p test_repo/.warp/{protocols,communication,logs}
    
    # Test environment setup complete
}

# Cleanup test environment
teardown_v5_test_env() {
    cd "$BATS_TEST_DIRNAME" || return
    rm -rf "$TEST_TEMP_DIR" 2>/dev/null || true
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Wait for process with timeout
wait_for_process() {
    local pid="$1"
    local timeout="${2:-10}"
    local count=0

    while [ "$count" -lt "$timeout" ]; do
        if ! kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
        sleep 1
        count=$((count + 1))
    done
    return 1
}

# Check if port is listening
port_is_listening() {
    local port="$1"
    netstat -ln 2>/dev/null | grep -q ":$port "
}

# Start mock RabbitMQ service (for testing without real RabbitMQ)
start_mock_rabbitmq() {
    local port="${1:-5672}"
    # Simple netcat-based mock for basic connectivity tests
    if command_exists nc; then
        nc -l -p "$port" -k >/dev/null 2>&1 &
        echo $!
    else
        return 1
    fi
}

# Create test goal.yaml file
create_test_goal() {
    local goal_text="${1:-Test repository goal}"
    cat > .warp/goal.yaml << EOF
goal:
  primary: "$goal_text"
  description: |
    Test goal for BATS testing
constraints:
  scope: testing
  methodology: automated
success_criteria:
  - Tests pass
  - Code works
last_updated: $(date '+%Y-%m-%d %H:%M:%S')
EOF
}

# Assert output contains expected string
assert_output_contains() {
    local expected="$1"
    # shellcheck disable=SC2154
    if [[ "$output" != *"$expected"* ]]; then
        echo "Expected output to contain: $expected"
        echo "Actual output: $output"
        return 1
    fi
}

# Assert file exists
assert_file_exists() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "Expected file to exist: $file"
        return 1
    fi
}

# Assert directory exists
assert_dir_exists() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "Expected directory to exist: $dir"
        return 1
    fi
}

# Assert command succeeds
assert_success() {
    # shellcheck disable=SC2154
    if [ "$status" -ne 0 ]; then
        echo "Expected command to succeed but got status: $status"
        echo "Output: $output"
        return 1
    fi
}

# Assert command fails
assert_failure() {
    # shellcheck disable=SC2154
    if [ "$status" -eq 0 ]; then
        echo "Expected command to fail but it succeeded"
        echo "Output: $output"
        return 1
    fi
}

# Skip test if dependency missing
skip_if_missing() {
    local cmd="$1"
    local reason="${2:-$cmd not available}"
    if ! command_exists "$cmd"; then
        skip "$reason"
    fi
}

# Load BATS testing library if available
if [ -f "/usr/lib/bats/bats-assert/load.bash" ]; then
    load "/usr/lib/bats/bats-assert/load.bash"
fi

if [ -f "/usr/lib/bats/bats-support/load.bash" ]; then
    load "/usr/lib/bats/bats-support/load.bash"
fi
