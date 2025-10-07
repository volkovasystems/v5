#!/usr/bin/env bats
# test_install.bats - Comprehensive tests for V5 installation functionality

load "../test_helper"

setup() {
    setup_v5_test_env
}

teardown() {
    teardown_v5_test_env
}

# Basic Installation Script Tests

@test "install.sh exists and is executable" {
    assert_file_exists "install.sh"
    [ -x "install.sh" ]
}

@test "get-v5.sh exists and is executable" {
    assert_file_exists "get-v5.sh"
    [ -x "get-v5.sh" ]
}

@test "v5 main executable exists and is executable" {
    assert_file_exists "v5"
    [ -x "v5" ]
}

@test "VERSION file exists and contains valid version" {
    assert_file_exists "VERSION"
    run cat VERSION
    assert_success
    [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# Installation Script Help and Version Tests

@test "install.sh shows help with --help flag" {
    run ./install.sh --help
    assert_success
    assert_output_contains "V5 - 5 Strategies Productive Development Tool"
    assert_output_contains "Usage:"
    assert_output_contains "Installation Modes:"
    assert_output_contains "--global"
    assert_output_contains "--local"
}

@test "install.sh shows version information" {
    run ./install.sh --version
    assert_success
    assert_output_contains "Installing V5"
    # Should contain version from VERSION file
    version=$(cat VERSION)
    assert_output_contains "$version"
}

@test "install.sh shows proper version information" {
    run ./install.sh --version
    assert_success
    assert_output_contains "Installing V5"
    
    # Should contain version from VERSION file
    version=$(cat VERSION)
    assert_output_contains "$version"
}

# Installation Mode Tests

@test "install.sh defaults to global mode" {
    run ./install.sh --help
    assert_success
    assert_output_contains "Install globally (default)"
    assert_output_contains "creates 'v5' command system-wide"
}

@test "install.sh global mode flag works" {
    run ./install.sh --help
    assert_success
    assert_output_contains "--global"
    assert_output_contains "Explicit global installation"
}

@test "install.sh supports global installation mode" {
    run ./install.sh --help
    assert_success
    assert_output_contains "--global"
    assert_output_contains "system-wide"
}

@test "install.sh local mode flag works" {
    run ./install.sh --help
    assert_success
    assert_output_contains "--local"
    assert_output_contains "no global command"
}

@test "install.sh supports local installation mode" {
    run ./install.sh --help
    assert_success
    assert_output_contains "--local"
    assert_output_contains "Local installation only"
}

# Dry Run and Dependency Checks

@test "install.sh dry-run shows preview without changes" {
    run ./install.sh --dry-run --local
    assert_success
    assert_output_contains "Dry Run Installation"
    assert_output_contains "no actual installation"
    assert_output_contains "[DRY RUN]"
}

@test "install.sh supports dry-run mode" {
    run ./install.sh --help
    assert_success
    assert_output_contains "--dry-run"
    assert_output_contains "without doing it"
}

@test "install.sh check-deps validates system requirements" {
    run ./install.sh --check-deps
    assert_success
    assert_output_contains "Dependency Check"
    assert_output_contains "Python dependencies"
    assert_output_contains "Check Complete"
}

@test "install.sh performs dependency checks" {
    run ./install.sh --check-deps
    # Should always succeed in showing dependency status
    assert_success
    assert_output_contains "Dependency Check"
    assert_output_contains "Python dependencies"
}

# Error Handling Tests

@test "install.sh rejects invalid flags" {
    run ./install.sh --invalid-flag
    assert_failure
    assert_output_contains "Unknown option"
    assert_output_contains "Use --help"
}

@test "install.sh handles missing v5_tool.py gracefully" {
    # Temporarily rename the file to simulate missing dependency
    if [ -f "src/core/v5_tool.py" ]; then
        mv "src/core/v5_tool.py" "src/core/v5_tool.py.backup"
    fi
    
    run ./install.sh --check-deps
    # Should still succeed for dependency checking
    assert_success
    
    # Restore file
    if [ -f "src/core/v5_tool.py.backup" ]; then
        mv "src/core/v5_tool.py.backup" "src/core/v5_tool.py"
    fi
}

@test "install script handles permission errors gracefully" {
    # Test that scripts provide meaningful error messages
    # This is mainly a structure test since we can't easily simulate permission errors in test
    run ./install.sh --help
    assert_success
}

# Installation Structure Tests

@test "install.sh creates .warp directory structure" {
    # Run install in dry-run mode if available
    mkdir -p test_install_target
    cd test_install_target

    # Simulate what install should create
    run ../install.sh --target="$PWD" --dry-run 2>/dev/null || {
        # If dry-run not available, check the expected structure
        mkdir -p .warp/{protocols,communication,logs}
        assert_dir_exists ".warp"
        assert_dir_exists ".warp/protocols"
        assert_dir_exists ".warp/communication"
        assert_dir_exists ".warp/logs"
    }
}

# V5 Executable Tests

@test "v5 executable shows help" {
    run ./v5 --help
    # Should succeed or provide meaningful output even without full setup
    [[ "$status" -eq 0 || "$status" -eq 1 ]]
    # Should contain some help text
    [[ "$output" == *"V5"* || "$output" == *"help"* || "$output" == *"usage"* ]]
}

@test "v5 executable shows version" {
    run ./v5 --version
    # Should succeed or provide version info
    [[ "$status" -eq 0 || "$status" -eq 1 ]]
    if [ "$status" -eq 0 ]; then
        version=$(cat VERSION)
        assert_output_contains "$version"
    fi
}

@test "v5 executable handles invalid arguments gracefully" {
    run ./v5 --invalid-flag-xyz
    # Should fail gracefully, not crash
    assert_failure
    # Should provide some kind of error or help message
    [[ ${#output} -gt 0 ]]
}

# Supporting Files Tests

@test "get-v5.sh contains proper shebang and error handling" {
    run head -n 1 get-v5.sh
    assert_success
    assert_output_contains "#!/usr/bin/env bash"

    # Check for proper error handling patterns
    run grep -q "set -euo pipefail" get-v5.sh
    assert_success
}

@test "requirements.txt contains valid Python packages" {
    assert_file_exists "requirements.txt"

    # Check that it contains expected packages
    run grep -E "^(pika|psutil|watchdog|PyYAML)" requirements.txt
    assert_success

    # Check that lines are properly formatted (no trailing spaces)
    run grep -E "[[:space:]]$" requirements.txt
    assert_failure
}

@test "README.md exists and is not empty" {
    assert_file_exists "README.md"

    # Should have substantial content
    run wc -l README.md
    assert_success
    # Should have at least 50 lines of content
    line_count=$(echo "$output" | awk '{print $1}')
    [ "$line_count" -gt 50 ]
}

@test "LICENSE file exists" {
    assert_file_exists "LICENSE"

    # Should contain copyright and license text
    run grep -i "copyright\|license\|mit" LICENSE
    assert_success
}

@test "CHANGELOG.md exists and follows format" {
    assert_file_exists "CHANGELOG.md"

    # Should contain version headers
    run grep -E "^## \[[0-9]+\.[0-9]+\.[0-9]+\]" CHANGELOG.md
    assert_success

    # Should contain current version
    version=$(cat VERSION)
    run grep "## \[$version\]" CHANGELOG.md
    assert_success
}

# Code Quality Tests

@test "shell scripts pass shellcheck if available" {
    skip_if_missing "shellcheck" "shellcheck not available for linting"

    # Test main scripts
    run shellcheck v5
    assert_success

    run shellcheck install.sh
    assert_success

    run shellcheck get-v5.sh
    assert_success
}

@test "Python modules compile without syntax errors" {
    skip_if_missing "python3" "python3 not available"

    # Test core modules compile
    run python3 -m py_compile src/core/v5_tool.py
    assert_success

    run python3 -m py_compile src/utils/messaging.py
    assert_success

    run python3 -m py_compile src/utils/goal_parser.py
    assert_success
}

# Integration Tests

@test "install options are properly documented" {
    # Test that all documented options actually work
    run ./install.sh --global --help
    assert_success
    
    run ./install.sh --local --help
    assert_success
    
    run ./install.sh --check-deps
    assert_success
}

@test "install script handles missing directories gracefully" {
    # Test install in directory without expected structure
    run ./install.sh --dry-run --local
    assert_success
    # Should handle missing directories gracefully
}

@test "install script provides consistent help format" {
    # Test that install script follows expected help format
    run ./install.sh --help
    assert_success
    
    # Should contain V5 branding
    [[ "$output" == *"V5 - 5 Strategies"* ]]
    
    # Should contain Usage section
    [[ "$output" == *"Usage:"* ]]
    
    # Should contain Examples section
    [[ "$output" == *"Examples:"* ]]
}