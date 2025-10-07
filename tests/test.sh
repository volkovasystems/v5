#!/usr/bin/env bash
# test.sh - V5 Test Runner Script
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
V5_ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TEST_DIR="$SCRIPT_DIR"
RESULTS_DIR="$V5_ROOT_DIR/test-results"
DATE_STAMP="$(date '+%Y-%m-%d')"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S %Z')"
# TAP file will be set based on test suite in generate_tap_filename()
DAILY_TAP_FILE=""

# Default options
RUN_INTEGRATION=false
BUILD_IMAGES=false
CLEAN_UP=false
VERBOSE=false
WATCH_MODE=false
TAP_OUTPUT=false
TAP_ONLY=false
RUN_LOCAL=false

# Help function
show_help() {
    cat << EOF
V5 Test Runner - Run BATS tests in isolated Docker environment

USAGE:
    $0 [OPTIONS] [TEST_SUITE]

OPTIONS:
    -h, --help          Show this help message
    -i, --integration   Run integration tests with RabbitMQ
    -b, --build         Force rebuild of Docker images
    -c, --clean         Clean up containers and volumes after tests
    -v, --verbose       Verbose output
    -w, --watch         Watch mode - rebuild and retest on file changes
    --local             Run tests locally without Docker (requires BATS)
    --tap               Generate TAP (Test Anything Protocol) output
    --tap-only          Output only TAP format (no other output, useful for CI)
    --list              List available test suites

TEST_SUITE:
    install             Run installation tests only
    uninstall           Run uninstallation tests only
    core-tool           Run core tool tests only
    integration         Run integration tests only
    all                 Run all test suites (default)

EXAMPLES:
    $0                              # Run all tests in Docker
    $0 --integration               # Run integration tests with RabbitMQ
    $0 --build --clean             # Rebuild images and clean up after
    $0 install                     # Run only installation tests
    $0 uninstall                   # Run only uninstallation tests
    $0 --local                     # Run tests locally
    $0 --local --tap               # Run tests locally with TAP output
    $0 --local --tap install       # Output only TAP for installation tests
    $0 --local --tap uninstall     # Run uninstallation tests with TAP output
    $0 --local --tap core-tool          # Run core tool tests with TAP output
    $0 --tap --verbose             # Generate TAP reports with verbose output
    $0 --watch                     # Watch for changes and rerun tests

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -i|--integration)
                RUN_INTEGRATION=true
                shift
                ;;
            -b|--build)
                BUILD_IMAGES=true
                shift
                ;;
            -c|--clean)
                CLEAN_UP=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -w|--watch)
                WATCH_MODE=true
                shift
                ;;
            --local)
                RUN_LOCAL=true
                shift
                ;;
            --tap)
                TAP_OUTPUT=true
                shift
                ;;
            --tap-only)
                TAP_OUTPUT=true
                TAP_ONLY=true
                shift
                ;;
            --list)
                list_test_suites
                exit 0
                ;;
            install|uninstall|core-tool|integration|all)
                TEST_SUITE="$1"
                shift
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}" >&2
                show_help
                exit 1
                ;;
        esac
    done
}

# List available test suites
list_test_suites() {
    echo -e "${BLUE}Available Test Suites:${NC}"
    echo "======================"

    if [ -f "$TEST_DIR/integration/test_install.bats" ]; then
        echo -e "${GREEN}• install${NC} - Installation script and functionality tests"
    fi
    
    if [ -f "$TEST_DIR/integration/test_uninstall.bats" ]; then
        echo -e "${GREEN}• uninstall${NC} - Uninstallation script and functionality tests"
    fi

    if [ -f "$TEST_DIR/unit/test_core_tool.bats" ]; then
        echo -e "${GREEN}• core-tool${NC}    - Core Python module and tool tests"
    fi

    echo -e "${GREEN}• integration${NC}  - Full integration tests with RabbitMQ"
    echo -e "${GREEN}• all${NC}          - Run all available test suites"

    # List any additional test files
    echo -e "\n${YELLOW}Additional test files found:${NC}"
    find "$TEST_DIR" -name "*.bats" -type f | while read -r test_file; do
        relative_path=$(realpath --relative-to="$SCRIPT_DIR" "$test_file")
        echo "• $relative_path"
    done
}

# Generate descriptive TAP filename based on test suite
generate_tap_filename() {
    local test_suite="${1:-all}"
    local filename_base
    
    case "$test_suite" in
        "install")
            filename_base="install-tests"
            ;;
        "uninstall")
            filename_base="uninstall-tests"
            ;;
        "core-tool")
            filename_base="core-tool-tests"
            ;;
        "integration")
            filename_base="integration-tests"
            ;;
        "all")
            filename_base="all-tests-combined"
            ;;
        *)
            filename_base="${test_suite}-tests"
            ;;
    esac
    
    echo "$RESULTS_DIR/${filename_base}-${DATE_STAMP}.tap"
}

# Generate TAP output from BATS results (BATS already outputs TAP format)
generate_tap_output() {
    local test_suite="$1"
    local bats_output="$2"
    local exit_code="$3"
    local tap_file="$RESULTS_DIR/${test_suite}.tap"
    
    # Create results directory if it doesn't exist
    mkdir -p "$RESULTS_DIR"
    
    # BATS already outputs TAP format, so we just need to add metadata
    {
        echo "TAP version 13"
        echo "# Test suite: $test_suite"
        echo "$bats_output"
        if [ "$exit_code" -ne 0 ]; then
            echo "# Test suite '$test_suite' failed with exit code: $exit_code"
        fi
    } > "$tap_file"
    
    if [ "$TAP_ONLY" != true ]; then
        echo "TAP report generated: $tap_file"
    fi
}

# Output TAP directly (for TAP-only mode)
output_tap_directly() {
    local test_suite="$1"
    local bats_output="$2"
    local exit_code="$3"
    
    # Output TAP with metadata
    echo "TAP version 13"
    echo "# Test suite: $test_suite"
    echo "$bats_output"
    if [ "$exit_code" -ne 0 ]; then
        echo "# Test suite '$test_suite' failed with exit code: $exit_code"
    fi
}

# Initialize daily TAP file (overwrites existing file for the day)
init_daily_tap() {
    local test_suite="${1:-all}"
    
    # Generate the appropriate filename
    DAILY_TAP_FILE=$(generate_tap_filename "$test_suite")
    
    mkdir -p "$RESULTS_DIR"
    {
        echo "TAP version 13"
        echo "# V5 Test Suite Results"
        echo "# Date: $DATE_STAMP"
        echo "# Generated: $TIMESTAMP"
        echo "#"
    } > "$DAILY_TAP_FILE"
}

# Add test suite results to daily TAP file
add_to_daily_tap() {
    local test_suite="$1"
    local bats_output="$2"
    local exit_code="$3"
    local test_start_time="$4"
    local test_end_time="$5"
    
    # Filter out the individual test plan from BATS output and renumber tests sequentially
    local filtered_output
    filtered_output=$(echo "$bats_output" | grep -v "^1\.\.[0-9]*$")
    
    # Get the current test count to continue numbering
    local current_test_count=0
    if [ -f "$DAILY_TAP_FILE" ]; then
        current_test_count=$(grep -c "^ok \|^not ok " "$DAILY_TAP_FILE" 2>/dev/null) || current_test_count=0
    fi
    
    # Renumber the tests to be sequential
    local renumbered_output
    renumbered_output=$(echo "$filtered_output" | awk -v offset="$current_test_count" '
        /^(ok|not ok) [0-9]+/ {
            # Extract the test result and description
            result = $1
            if ($1 == "not") {
                result = $1 " " $2
                desc_start = 3
            } else {
                desc_start = 2
            }
            # Get the description (everything after the test number)
            desc = ""
            for (i = desc_start + 1; i <= NF; i++) {
                desc = desc " " $i
            }
            # Print with new sequential number
            offset++
            print result " " offset desc
        }
        !/^(ok|not ok) [0-9]+/ {
            print
        }
    ')
    
    {
        echo "#"
        echo "# Test Suite: $test_suite"
        echo "# Started: $test_start_time"
        echo "# Completed: $test_end_time"
        if [ "$exit_code" -ne 0 ]; then
            echo "# Status: FAILED (exit code: $exit_code)"
        else
            echo "# Status: PASSED"
        fi
        echo "#"
        echo "$renumbered_output"
    } >> "$DAILY_TAP_FILE"
}

# Finalize daily TAP file with summary
finalize_daily_tap() {
    local total_tests=0
    local total_passed=0
    local total_failed=0
    local overall_status="$1"
    
    # Count tests from the daily file
    total_tests=$(grep -c "^ok \|^not ok " "$DAILY_TAP_FILE" 2>/dev/null) || total_tests=0
    total_passed=$(grep -c "^ok " "$DAILY_TAP_FILE" 2>/dev/null) || total_passed=0
    total_failed=$(grep -c "^not ok " "$DAILY_TAP_FILE" 2>/dev/null) || total_failed=0
    
    # Add the test plan at the beginning (after the header comments)
    local temp_file="${DAILY_TAP_FILE}.tmp"
    {
        head -5 "$DAILY_TAP_FILE"
        echo "1..$total_tests"
        tail -n +6 "$DAILY_TAP_FILE"
        echo "#"
        echo "# SUMMARY"
        echo "# Total Tests: $total_tests"
        echo "# Passed: $total_passed"
        echo "# Failed: $total_failed"
        if [ "$overall_status" -eq 0 ]; then
            echo "# Overall Status: PASSED"
        else
            echo "# Overall Status: FAILED"
        fi
        echo "# Completed: $TIMESTAMP"
    } > "$temp_file"
    
    mv "$temp_file" "$DAILY_TAP_FILE"
}

# Check if TAP file has only timestamp changes and revert if so
check_and_revert_timestamp_only_changes() {
    local tap_file="$1"
    
    # Only check if we're in a git repository and file exists
    if [ ! -f "$tap_file" ] || ! git rev-parse --git-dir >/dev/null 2>&1; then
        return 0
    fi
    
    # Check if file is tracked by git and has changes
    if ! git ls-files --error-unmatch "$tap_file" >/dev/null 2>&1; then
        return 0  # File not tracked, nothing to revert
    fi
    
    # Check if file has any changes
    if ! git diff --quiet "$tap_file" 2>/dev/null; then
        # File has changes, check if they're only timestamps
        
        # Get all changed lines (excluding diff headers)
        local diff_lines
        diff_lines=$(git diff "$tap_file" | grep "^[+-]" | grep -v "^[+-][+-][+-]" || true)
        
        # Remove timestamp-only changes and see what's left
        local significant_changes
        significant_changes=$(echo "$diff_lines" | grep -v -E "^[+-]# (Generated|Started|Completed): " | grep -v "^$" | tr -d '\n' | tr -d ' ' || true)
        
        if [ -n "$significant_changes" ]; then
            # There are significant changes beyond timestamps
            if [ "$TAP_ONLY" != true ] && [ "$VERBOSE" = true ]; then
                echo -e "${GREEN}💾 TAP file contains meaningful changes, keeping updated version${NC}"
            fi
            return 0
        else
            # Only timestamp changes detected, revert the file
            if git checkout HEAD -- "$tap_file" >/dev/null 2>&1; then
                if [ "$TAP_ONLY" != true ]; then
                    echo -e "${YELLOW}⏰ Only timestamps changed, reverted to preserve original timestamps${NC}"
                fi
                return 0  # Success, but file was reverted
            else
                if [ "$TAP_ONLY" != true ] && [ "$VERBOSE" = true ]; then
                    echo -e "${RED}⚠️  Failed to revert timestamp-only changes${NC}"
                fi
                return 0  # Don't fail the test run
            fi
        fi
    fi
    
    return 0  # No changes or no revert needed
}

# Check prerequisites
check_prerequisites() {
    # Check if Docker is available
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker is required but not installed${NC}" >&2
        exit 1
    fi

    # Check if Docker Compose is available
    if ! command -v docker-compose >/dev/null 2>&1 && \
            ! docker compose version >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker Compose is required but not installed${NC}" >&2
        exit 1
    fi

    # Create results directory
    mkdir -p "$RESULTS_DIR"
}

# Run tests locally (without Docker)
run_tests_local() {
    # Initialize daily TAP file if TAP output is enabled
    if [ "$TAP_OUTPUT" = true ]; then
        init_daily_tap "${TEST_SUITE:-all}"
    fi
    
    if [ "$TAP_ONLY" = true ]; then
        # In TAP-only mode, suppress all non-TAP output
        mkdir -p "$RESULTS_DIR" 2>/dev/null
    elif [ "$TAP_OUTPUT" = true ]; then
        echo -e "${YELLOW}🧪 Running V5 tests locally (TAP output enabled)${NC}"
        echo -e "${CYAN}Daily TAP file: $(basename "$DAILY_TAP_FILE")${NC}"
        mkdir -p "$RESULTS_DIR"
    else
        echo -e "${YELLOW}🧪 Running V5 tests locally${NC}"
    fi

    # Check if BATS is available
    if ! command -v bats >/dev/null 2>&1; then
        echo -e "${RED}❌ BATS is required for local testing but not installed${NC}" >&2
        echo "Install BATS: https://github.com/bats-core/bats-core#installation"
        exit 1
    fi

    # Set up environment
    export PYTHONPATH="$V5_ROOT_DIR/src:${PYTHONPATH:-}"
    export BATS_LIB_PATH="${BATS_LIB_PATH:-/usr/lib/bats}"

    cd "$V5_ROOT_DIR"

    # Run tests
    local exit_code=0

    if [ "${TEST_SUITE:-all}" == "all" ] || \
            [ "${TEST_SUITE:-all}" == "install" ]; then
        
        if [ "$TAP_ONLY" != true ]; then
            echo -e "\n${CYAN}Running installation tests...${NC}"
        fi
        
        local test_start_time
        local test_end_time
        test_start_time="$(date '+%Y-%m-%d %H:%M:%S %Z')"
        
        if [ "$TAP_OUTPUT" = true ]; then
            # Capture BATS output for TAP conversion
            local bats_output
            bats_output=$(bats "$TEST_DIR/integration/test_install.bats" 2>&1)
            local bats_exit_code=$?
            test_end_time="$(date '+%Y-%m-%d %H:%M:%S %Z')"
            
            if [ "$TAP_ONLY" = true ]; then
                # For TAP-only mode, we'll collect all results and output at the end
                add_to_daily_tap "install" "$bats_output" "$bats_exit_code" "$test_start_time" "$test_end_time"
            else
                # Add to combined TAP file
                add_to_daily_tap "install" "$bats_output" "$bats_exit_code" "$test_start_time" "$test_end_time"
                
                # Also display the output if verbose
                if [ "$VERBOSE" = true ]; then
                    echo "$bats_output"
                fi
            fi
            
            if [ $bats_exit_code -ne 0 ]; then
                exit_code=$bats_exit_code
            fi
        else
            bats "$TEST_DIR/integration/test_install.bats" || exit_code=$?
            test_end_time="$(date '+%Y-%m-%d %H:%M:%S %Z')"
        fi
    fi

    if [ "${TEST_SUITE:-all}" == "all" ] || \
            [ "${TEST_SUITE:-all}" == "uninstall" ]; then
        
        if [ "$TAP_ONLY" != true ]; then
            echo -e "\n${CYAN}Running uninstallation tests...${NC}"
        fi
        
        local test_start_time
        local test_end_time
        test_start_time="$(date '+%Y-%m-%d %H:%M:%S %Z')"
        
        if [ "$TAP_OUTPUT" = true ]; then
            # Capture BATS output for TAP conversion
            local bats_output
            bats_output=$(bats "$TEST_DIR/integration/test_uninstall.bats" 2>&1)
            local bats_exit_code=$?
            test_end_time="$(date '+%Y-%m-%d %H:%M:%S %Z')"
            
            if [ "$TAP_ONLY" = true ]; then
                # For TAP-only mode, we'll collect all results and output at the end
                add_to_daily_tap "uninstall" "$bats_output" "$bats_exit_code" "$test_start_time" "$test_end_time"
            else
                # Add to combined TAP file
                add_to_daily_tap "uninstall" "$bats_output" "$bats_exit_code" "$test_start_time" "$test_end_time"
                
                # Also display the output if verbose
                if [ "$VERBOSE" = true ]; then
                    echo "$bats_output"
                fi
            fi
            
            if [ $bats_exit_code -ne 0 ]; then
                exit_code=$bats_exit_code
            fi
        else
            bats "$TEST_DIR/integration/test_uninstall.bats" || exit_code=$?
            test_end_time="$(date '+%Y-%m-%d %H:%M:%S %Z')"
        fi
    fi

    if [ "${TEST_SUITE:-all}" == "all" ] || \
            [ "${TEST_SUITE:-all}" == "core-tool" ]; then
        
        if [ "$TAP_ONLY" != true ]; then
            echo -e "\n${CYAN}Running core tool tests...${NC}"
        fi
        
        local test_start_time
        local test_end_time
        test_start_time="$(date '+%Y-%m-%d %H:%M:%S %Z')"
        
        if [ "$TAP_OUTPUT" = true ]; then
            # Capture BATS output for TAP conversion
            local bats_output
            bats_output=$(bats "$TEST_DIR/unit/test_core_tool.bats" 2>&1)
            local bats_exit_code=$?
            test_end_time="$(date '+%Y-%m-%d %H:%M:%S %Z')"
            
            if [ "$TAP_ONLY" = true ]; then
                # For TAP-only mode, we'll collect all results and output at the end
                add_to_daily_tap "core-tool" "$bats_output" "$bats_exit_code" "$test_start_time" "$test_end_time"
            else
                # Add to combined TAP file
                add_to_daily_tap "core-tool" "$bats_output" "$bats_exit_code" "$test_start_time" "$test_end_time"
                
                # Also display the output if verbose
                if [ "$VERBOSE" = true ]; then
                    echo "$bats_output"
                fi
            fi
            
            if [ $bats_exit_code -ne 0 ]; then
                exit_code=$bats_exit_code
            fi
        else
            bats "$TEST_DIR/unit/test_core_tool.bats" || exit_code=$?
            test_end_time="$(date '+%Y-%m-%d %H:%M:%S %Z')"
        fi
    fi

    # Finalize combined TAP file and display summary
    if [ "$TAP_OUTPUT" = true ]; then
        # Finalize the combined TAP file
        finalize_daily_tap "$exit_code"
        
        if [ "$TAP_ONLY" = true ]; then
            # In TAP-only mode, output the complete daily TAP file
            cat "$DAILY_TAP_FILE"
        else
            # Display summary for regular TAP mode
            echo -e "\n${BLUE}📊 Daily TAP Report Generated:${NC}"
            echo "==================================="
            
            local total_tests
            local total_passed
            local total_failed
            
            total_tests=$(grep -c "^ok \|^not ok " "$DAILY_TAP_FILE" 2>/dev/null) || total_tests=0
            total_passed=$(grep -c "^ok " "$DAILY_TAP_FILE" 2>/dev/null) || total_passed=0
            total_failed=$(grep -c "^not ok " "$DAILY_TAP_FILE" 2>/dev/null) || total_failed=0
            
            if [ "$total_failed" -eq 0 ] && [ "$total_tests" -gt 0 ]; then
                echo -e "${GREEN}✅ All Tests: $total_passed/$total_tests passed${NC}"
            elif [ "$total_tests" -gt 0 ]; then
                echo -e "${RED}❌ Tests: $total_passed/$total_tests passed, $total_failed failed${NC}"
            else
                echo -e "${YELLOW}⚠️  No tests found${NC}"
            fi
            
            echo -e "${CYAN}TAP File: $(realpath "$DAILY_TAP_FILE")${NC}"
            echo -e "${CYAN}Date: $DATE_STAMP${NC}"
            echo -e "${CYAN}File Size: $(du -h "$DAILY_TAP_FILE" | cut -f1)${NC}"
        fi
        
        # Check if only timestamps changed and revert if so
        check_and_revert_timestamp_only_changes "$DAILY_TAP_FILE"
    fi

    return $exit_code
}

# Build Docker images
build_docker_images() {
    echo -e "${BLUE}🔨 Building V5 test Docker images...${NC}"

    cd "$SCRIPT_DIR"

    if [ "$VERBOSE" = true ]; then
        docker-compose -f docker-compose.test.yml build --no-cache
    else
        docker-compose -f docker-compose.test.yml build --no-cache >/dev/null
    fi

    echo -e "${GREEN}✅ Docker images built successfully${NC}"
}

# Run Docker-based tests
run_docker_tests() {
    local service_name="v5-test"

    if [ "$RUN_INTEGRATION" = true ]; then
        service_name="v5-test-integration"
        echo -e "${PURPLE}🔗 Running V5 integration tests with RabbitMQ...${NC}"
    else
        echo -e "${BLUE}🧪 Running V5 tests in isolated Docker environment...${NC}"
    fi
    
    if [ "$TAP_OUTPUT" = true ]; then
        echo -e "${YELLOW}TAP output will be generated${NC}"
    fi

    cd "$SCRIPT_DIR"
    
    # Set environment variables for Docker
    export GENERATE_TAP="$TAP_OUTPUT"

    # Start services
    if [ "$VERBOSE" = true ]; then
        docker-compose -f docker-compose.test.yml up \
            --abort-on-container-exit "$service_name"
    else
        docker-compose -f docker-compose.test.yml up \
            --abort-on-container-exit "$service_name" 2>/dev/null
    fi

    local exit_code=$?

    # Copy test results
    echo -e "\n${CYAN}📋 Copying test results...${NC}"

    # Get container ID
    container_id=$(docker-compose -f docker-compose.test.yml ps -q \
        "$service_name" 2>/dev/null | head -n 1)

    if [ -n "$container_id" ]; then
        # Copy results from container
        docker cp "$container_id:/app/test-results/." "$RESULTS_DIR/" \
            2>/dev/null || true

        # Display results summary
        if [ -d "$RESULTS_DIR" ] && \
                [ -n "$(find "$RESULTS_DIR" -name "*.tap" 2>/dev/null)" ]; then
            echo -e "\n${BLUE}📊 Test Results Summary:${NC}"
            echo "========================"

            for tap_file in "$RESULTS_DIR"/*.tap; do
                if [ -f "$tap_file" ]; then
                    suite=$(basename "$tap_file" .tap)
                    tests=$(grep -c "^ok\|^not ok" "$tap_file" 2>/dev/null || echo "0")
                    passed=$(grep -c "^ok " "$tap_file" 2>/dev/null || echo "0")

                    if [ "$tests" -eq "$passed" ] && [ "$tests" -gt 0 ]; then
                        echo -e "${GREEN}✅ $suite: $passed/$tests tests passed${NC}"
                    else
                        echo -e "${RED}❌ $suite: $passed/$tests tests passed${NC}"
                    fi
                fi
            done
        fi
    fi

    return $exit_code
}

# Clean up Docker resources
cleanup_docker() {
    echo -e "${YELLOW}🧹 Cleaning up Docker resources...${NC}"

    cd "$SCRIPT_DIR"

    # Stop and remove containers
    docker-compose -f docker-compose.test.yml down \
        --volumes --remove-orphans 2>/dev/null || true

    # Remove test images
    images=$(docker images -q -f "label=description=V5 BATS Testing Environment")
    if [ -n "$images" ]; then
        # shellcheck disable=SC2086
        docker rmi $images 2>/dev/null || true
    fi

    echo -e "${GREEN}✅ Cleanup completed${NC}"
}

# Watch mode - rerun tests on file changes
watch_mode() {
    echo -e "${PURPLE}👁️  Watch mode enabled - monitoring for changes...${NC}"
    echo "Press Ctrl+C to stop"

    # Check if inotifywait is available
    if command -v inotifywait >/dev/null 2>&1; then
        while true; do
            echo -e "\n${CYAN}Waiting for file changes...${NC}"

            # Watch for changes in source files and test files
            inotifywait -r -e modify,create,delete \
                --exclude="\.git|__pycache__|\.pyc$|test-results" \
                "$V5_ROOT_DIR/src" "$SCRIPT_DIR" \
                "$V5_ROOT_DIR"/*.sh 2>/dev/null || break

            echo -e "${YELLOW}🔄 Files changed, rebuilding and running tests...${NC}"

            # Rebuild and run tests
            BUILD_IMAGES=true
            build_docker_images
            run_docker_tests
        done
    else
        echo -e "${RED}❌ inotify-tools not available for watch mode${NC}" >&2
        echo "Install with: sudo apt-get install inotify-tools"
        exit 1
    fi
}

# Main execution
main() {
    # Set defaults
    TEST_SUITE="${TEST_SUITE:-all}"

    # Parse arguments
    parse_args "$@"

    # Handle local test execution
    if [ "$RUN_LOCAL" = true ]; then
        run_tests_local
        exit $?
    fi

    echo -e "${BLUE}🚀 V5 Test Runner${NC}"
    echo "=================="

    # Check prerequisites
    check_prerequisites

    # Handle watch mode
    if [ "$WATCH_MODE" = true ]; then
        watch_mode
        return
    fi

    # Build images if requested or if they don't exist
    if [ "$BUILD_IMAGES" = true ] || ! docker images | grep -q "v5.*test"; then
        build_docker_images
    fi

    # Run tests
    local exit_code=0
    run_docker_tests || exit_code=$?

    # Clean up if requested
    if [ "$CLEAN_UP" = true ]; then
        cleanup_docker
    fi

    # Finalize daily TAP file for Docker tests if TAP output enabled
    if [ "$TAP_OUTPUT" = true ]; then
        # For Docker tests, we should also try to finalize if possible
        # This is a best effort as the TAP file might be in containers
        if [ -f "$DAILY_TAP_FILE" ]; then
            finalize_daily_tap "$exit_code"
        fi
    fi

    # Final status
    if [ $exit_code -eq 0 ]; then
        echo -e "\n${GREEN}🎉 All tests completed successfully!${NC}"
    else
        echo -e "\n${RED}💥 Some tests failed (exit code: $exit_code)${NC}"
    fi

    return $exit_code
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
