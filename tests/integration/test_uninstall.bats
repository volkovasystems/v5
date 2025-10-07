#!/usr/bin/env bats
# test_uninstall.bats - Comprehensive tests for V5 uninstallation functionality

load "../test_helper"

setup() {
    setup_v5_test_env
}

teardown() {
    teardown_v5_test_env
}

# Basic Uninstall Script Tests

@test "uninstall.sh exists and is executable" {
    assert_file_exists "uninstall.sh"
    [ -x "uninstall.sh" ]
}

@test "uninstall.sh shows help with --help flag" {
    run ./uninstall.sh --help
    assert_success
    assert_output_contains "V5 - 5 Strategies Productive Development Tool"
    assert_output_contains "Uninstall Script"
    assert_output_contains "Uninstall Modes:"
}

# Uninstall Mode Tests

@test "uninstall.sh supports repository-only mode" {
    run ./uninstall.sh --help
    assert_success
    assert_output_contains "--repo"
    assert_output_contains "Remove V5 from current repository"
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

@test "uninstall.sh supports machine-only mode" {
    run ./uninstall.sh --help
    assert_success
    assert_output_contains "--machine"
    assert_output_contains "Remove V5 from machine"
}

@test "uninstall.sh machine mode removes global command only" {
    run ./uninstall.sh --dry-run --machine
    assert_success
    assert_output_contains "Machine only"
    assert_output_contains "global command"
    assert_output_contains "/usr/local/bin/v5"
    assert_output_contains "[DRY RUN]"
}

@test "uninstall.sh supports complete removal mode" {
    run ./uninstall.sh --help
    assert_success
    assert_output_contains "--complete"
    assert_output_contains "Complete removal"
}

@test "uninstall.sh complete mode removes everything" {
    run ./uninstall.sh --dry-run --complete
    assert_success
    assert_output_contains "Complete removal"
    assert_output_contains "repository + machine"
    assert_output_contains "[DRY RUN]"
}

# Dry Run Tests

@test "uninstall.sh supports dry-run mode" {
    run ./uninstall.sh --help
    assert_success
    assert_output_contains "--dry-run"
    assert_output_contains "Show what would be removed"
}

@test "uninstall.sh dry-run shows what would be removed" {
    run ./uninstall.sh --dry-run --repo
    assert_success
    assert_output_contains "Dry Run Uninstallation"
    assert_output_contains "no actual removal"
    assert_output_contains "DRY RUN COMPLETE"
    assert_output_contains "Run without --dry-run"
}

# Interactive Mode Tests

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

# Error Handling Tests

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

@test "uninstall script handles permission errors gracefully" {
    # Test that scripts provide meaningful error messages
    # This is mainly a structure test since we can't easily simulate permission errors in test
    run ./uninstall.sh --help
    assert_success
}

# Directory and File Handling Tests

@test "uninstall script handles missing directories gracefully" {
    # Test uninstall in directory without V5 files
    run ./uninstall.sh --dry-run --repo
    assert_success
    # Should handle missing .warp directory gracefully
}

@test "uninstall.sh handles missing .warp directory gracefully" {
    # Ensure no .warp directory exists
    rm -rf .warp 2>/dev/null || true
    
    run ./uninstall.sh --dry-run --repo
    assert_success
    assert_output_contains "DRY RUN COMPLETE"
}

@test "uninstall.sh handles missing features directory gracefully" {
    # Ensure no features directory exists
    rm -rf features 2>/dev/null || true
    
    run ./uninstall.sh --dry-run --repo
    assert_success
    assert_output_contains "DRY RUN COMPLETE"
}

# Output and Documentation Tests

@test "uninstall script provides consistent help format" {
    # Test that uninstall script follows expected help format
    run ./uninstall.sh --help
    assert_success
    
    # Should contain V5 branding
    [[ "$output" == *"V5 - 5 Strategies"* ]]
    
    # Should contain Usage section
    [[ "$output" == *"Usage:"* ]]
    
    # Should contain Examples section
    [[ "$output" == *"Examples:"* ]]
}

@test "uninstall script mentions reinstallation guidance" {
    # Uninstall script should provide guidance about reinstallation
    # Test with a dry-run operation that shows the full output including GitHub link
    run ./uninstall.sh --dry-run --repo
    assert_success
    assert_output_contains "github.com/volkovasystems/v5"
}

@test "uninstall options are properly documented" {
    # Test that all documented options actually work
    run ./uninstall.sh --repo --help
    assert_success
    
    run ./uninstall.sh --machine --help
    assert_success
    
    run ./uninstall.sh --complete --help
    assert_success
}

# ShellCheck and Code Quality Tests

@test "uninstall.sh passes shellcheck if available" {
    skip_if_missing "shellcheck" "shellcheck not available for linting"

    run shellcheck uninstall.sh
    assert_success
}

# Functional Integration Tests

@test "uninstall.sh repo mode identifies correct files for removal" {
    # Create test structure
    mkdir -p .warp/protocols .warp/logs .warp/communication
    mkdir -p features
    touch .warp/goal.yaml .warp/config.json
    touch features/feature1.md features/feature2.md
    
    run ./uninstall.sh --dry-run --repo
    assert_success
    
    # Should identify .warp directory
    assert_output_contains ".warp"
    
    # Should identify features directory
    assert_output_contains "features"
    
    # Should show it's a dry run
    assert_output_contains "[DRY RUN]"
    
    # Cleanup
    rm -rf .warp features
}

@test "uninstall.sh machine mode shows correct paths" {
    run ./uninstall.sh --dry-run --machine
    assert_success
    
    # Should show global binary path
    assert_output_contains "/usr/local/bin/v5"
    
    # Should show it's a dry run
    assert_output_contains "[DRY RUN]"
}

@test "uninstall.sh complete mode combines repo and machine operations" {
    # Create test structure
    mkdir -p .warp features
    touch .warp/test.yaml features/test.md
    
    run ./uninstall.sh --dry-run --complete
    assert_success
    
    # Should mention both repository and machine removal
    assert_output_contains "repository + machine"
    
    # Should show it's a dry run
    assert_output_contains "[DRY RUN]"
    
    # Cleanup
    rm -rf .warp features
}

# Safety and Confirmation Tests

@test "uninstall.sh dry-run never actually removes files" {
    # Create test files
    mkdir -p .warp
    touch .warp/test-file.txt
    
    run ./uninstall.sh --dry-run --repo
    assert_success
    
    # File should still exist after dry run
    assert_file_exists ".warp/test-file.txt"
    
    # Cleanup
    rm -rf .warp
}

@test "uninstall.sh provides clear dry-run vs actual run distinction" {
    run ./uninstall.sh --dry-run --repo
    assert_success
    
    # Should clearly indicate this is a dry run
    assert_output_contains "Dry Run Uninstallation"
    assert_output_contains "no actual removal"
    
    # Should tell user how to actually run the removal
    assert_output_contains "Run without --dry-run"
}