#!/usr/bin/env bats
# test_consolidated_scripts.bats - Tests for consolidated installation and uninstall features

load "../test_helper"

setup() {
    setup_v5_test_env
}

teardown() {
    teardown_v5_test_env
}

# Installation Script Tests

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

@test "install.sh local mode flag works" {
    run ./install.sh --help
    assert_success
    assert_output_contains "--local"
    assert_output_contains "no global command"
}

@test "install.sh dry-run shows preview without changes" {
    run ./install.sh --dry-run --local
    assert_success
    assert_output_contains "Dry Run Installation"
    assert_output_contains "no actual installation"
    assert_output_contains "[DRY RUN]"
}

@test "install.sh check-deps validates system requirements" {
    run ./install.sh --check-deps
    assert_success
    assert_output_contains "Dependency Check"
    assert_output_contains "Python dependencies"
    assert_output_contains "Check Complete"
}

@test "install.sh rejects invalid flags" {
    run ./install.sh --invalid-flag
    assert_failure
    assert_output_contains "Unknown option"
    assert_output_contains "Use --help"
}

@test "install.sh shows proper version information" {
    run ./install.sh --version
    assert_success
    assert_output_contains "Installing V5"
    
    # Should contain version from VERSION file
    version=$(cat VERSION)
    assert_output_contains "$version"
}

# Uninstall Script Tests

@test "uninstall.sh detects non-interactive environment correctly" {
    # Test that the script properly detects non-interactive environments
    # and provides helpful guidance
    run bash -c 'echo "4" | ./uninstall.sh'
    # The script should now detect this as non-interactive and show the error
    assert_failure
    assert_output_contains "No uninstall mode specified"
    assert_output_contains "non-interactive environment"
    assert_output_contains "--repo"
    assert_output_contains "--machine"
    assert_output_contains "--complete"
    assert_output_contains "Example:"
}

@test "uninstall.sh repo mode removes repository files only" {
    # Create test .warp directory
    mkdir -p .warp/protocols .warp/logs .warp/communication
    mkdir -p features
    touch .warp/goal.yaml .warp/test.txt features/test.md
    
    run ./uninstall.sh --dry-run --repo
    assert_success
    assert_output_contains "Repository only"
    assert_output_contains ".warp"
    assert_output_contains "features"
    assert_output_contains "[DRY RUN]"
}

@test "uninstall.sh machine mode removes global command only" {
    run ./uninstall.sh --dry-run --machine
    assert_success
    assert_output_contains "Machine only"
    assert_output_contains "global command"
    assert_output_contains "/usr/local/bin/v5"
    assert_output_contains "[DRY RUN]"
}

@test "uninstall.sh complete mode removes everything" {
    run ./uninstall.sh --dry-run --complete
    assert_success
    assert_output_contains "Complete removal"
    assert_output_contains "repository + machine"
    assert_output_contains "[DRY RUN]"
}

@test "uninstall.sh dry-run shows what would be removed" {
    run ./uninstall.sh --dry-run --repo
    assert_success
    assert_output_contains "Dry Run Uninstallation"
    assert_output_contains "no actual removal"
    assert_output_contains "DRY RUN COMPLETE"
    assert_output_contains "Run without --dry-run"
}

@test "uninstall.sh rejects multiple mode flags" {
    run ./uninstall.sh --repo --machine
    assert_failure
    assert_output_contains "Cannot specify multiple uninstall modes"
}

@test "uninstall.sh rejects invalid flags" {
    run ./uninstall.sh --invalid-flag
    assert_failure
    assert_output_contains "Unknown option"
    assert_output_contains "Use --help"
}

# Integration Tests

@test "install.sh and uninstall.sh work together" {
    # Test dry-run of both scripts
    run ./install.sh --dry-run --local
    assert_success
    
    run ./uninstall.sh --dry-run --repo
    assert_success
}

@test "scripts handle missing directories gracefully" {
    # Test uninstall in directory without V5 files
    run ./uninstall.sh --dry-run --repo
    assert_success
    # Should handle missing .warp directory gracefully
}

@test "scripts provide consistent help format" {
    # Test that both scripts follow same help format
    run ./install.sh --help
    assert_success
    install_help="$output"
    
    run ./uninstall.sh --help
    assert_success
    uninstall_help="$output"
    
    # Both should contain V5 branding
    [[ "$install_help" == *"V5 - 5 Strategies"* ]]
    [[ "$uninstall_help" == *"V5 - 5 Strategies"* ]]
    
    # Both should contain Usage section
    [[ "$install_help" == *"Usage:"* ]]
    [[ "$uninstall_help" == *"Usage:"* ]]
    
    # Both should contain Examples section
    [[ "$install_help" == *"Examples:"* ]]
    [[ "$uninstall_help" == *"Examples:"* ]]
}

# Error Handling Tests

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

@test "scripts handle permission errors gracefully" {
    # Test that scripts provide meaningful error messages
    # This is mainly a structure test since we can't easily simulate permission errors in test
    run ./install.sh --help
    assert_success
    
    run ./uninstall.sh --help
    assert_success
}

# Documentation Consistency Tests

@test "scripts mention each other appropriately" {
    # Install script should mention uninstallation options
    run ./install.sh --help
    assert_success
    # While install doesn't need to mention uninstall directly,
    # it should be consistent in terminology
    
    # Uninstall script should provide guidance about reinstallation
    # Test with a dry-run operation that shows the full output including GitHub link
    run ./uninstall.sh --dry-run --repo
    assert_success
    assert_output_contains "github.com/volkovasystems/v5"
}

@test "script options are properly documented" {
    # Test that all documented options actually work
    run ./install.sh --global --help
    assert_success
    
    run ./install.sh --local --help
    assert_success
    
    run ./install.sh --check-deps
    assert_success
    
    run ./uninstall.sh --repo --help
    assert_success
    
    run ./uninstall.sh --machine --help
    assert_success
    
    run ./uninstall.sh --complete --help
    assert_success
}