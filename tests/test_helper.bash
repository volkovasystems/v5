#!/usr/bin/env bash
# test_helper.bash - Common helper functions for V5 BATS tests

# Test configuration
export BATS_TEST_TIMEOUT=30
export TEST_TEMP_DIR="${BATS_TMPDIR}/v5_test_$$"

# V5 Test Environment Setup
setup_v5_test_env() {
    # Create isolated test directory
    mkdir -p "$TEST_TEMP_DIR"
    cd "$TEST_TEMP_DIR"

    # Copy V5 files to test environment
    cp -r "$BATS_TEST_DIRNAME/../"* . 2>/dev/null || true

    # Ensure executables are available
    chmod +x v5 install.sh get-v5.sh 2>/dev/null || true

    # Set up Python path
    export PYTHONPATH="$TEST_TEMP_DIR/src:$PYTHONPATH"

    # Create test repository structure
    mkdir -p test_repo/.warp/{protocols,communication,logs}
}

# Cleanup test environment
teardown_v5_test_env() {
    cd "$BATS_TEST_DIRNAME"
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

    while [ $count -lt $timeout ]; do
        if ! kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
        sleep 1
        ((count++))
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
    if [ "$status" -ne 0 ]; then
        echo "Expected command to succeed but got status: $status"
        echo "Output: $output"
        return 1
    fi
}

# Assert command fails
assert_failure() {
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
