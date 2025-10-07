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

# Default options
RUN_INTEGRATION=false
BUILD_IMAGES=false
CLEAN_UP=false
VERBOSE=false
WATCH_MODE=false

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
    --list              List available test suites

TEST_SUITE:
    installation        Run installation tests only
    core-system         Run core system tests only
    integration         Run integration tests only
    all                 Run all test suites (default)

EXAMPLES:
    $0                              # Run all tests in Docker
    $0 --integration               # Run integration tests with RabbitMQ
    $0 --build --clean             # Rebuild images and clean up after
    $0 installation                # Run only installation tests
    $0 --local                     # Run tests locally
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
                run_tests_local
                exit $?
                ;;
            --list)
                list_test_suites
                exit 0
                ;;
            installation|core-system|integration|all)
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

    if [ -f "$TEST_DIR/integration/test_installation.bats" ]; then
        echo -e "${GREEN}• installation${NC} - Installation script and executable tests"
    fi

    if [ -f "$TEST_DIR/unit/test_core_system.bats" ]; then
        echo -e "${GREEN}• core-system${NC}  - Core Python module and system tests"
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

# Check prerequisites
check_prerequisites() {
    # Check if Docker is available
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker is required but not installed${NC}" >&2
        exit 1
    fi

    # Check if Docker Compose is available
    if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker Compose is required but not installed${NC}" >&2
        exit 1
    fi

    # Create results directory
    mkdir -p "$RESULTS_DIR"
}

# Run tests locally (without Docker)
run_tests_local() {
    echo -e "${YELLOW}🧪 Running V5 tests locally${NC}"

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

    if [ "${TEST_SUITE:-all}" == "all" ] || [ "${TEST_SUITE:-all}" == "installation" ]; then
        echo -e "\n${CYAN}Running installation tests...${NC}"
        bats "$TEST_DIR/integration/test_installation.bats" || exit_code=$?
    fi

    if [ "${TEST_SUITE:-all}" == "all" ] || [ "${TEST_SUITE:-all}" == "core-system" ]; then
        echo -e "\n${CYAN}Running core system tests...${NC}"
        bats "$TEST_DIR/unit/test_core_system.bats" || exit_code=$?
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

    cd "$SCRIPT_DIR"

    # Start services
    if [ "$VERBOSE" = true ]; then
        docker-compose -f docker-compose.test.yml up --abort-on-container-exit "$service_name"
    else
        docker-compose -f docker-compose.test.yml up --abort-on-container-exit "$service_name" 2>/dev/null
    fi

    local exit_code=$?

    # Copy test results
    echo -e "\n${CYAN}📋 Copying test results...${NC}"

    # Get container ID
    container_id=$(docker-compose -f docker-compose.test.yml ps -q "$service_name" 2>/dev/null | head -n 1)

    if [ -n "$container_id" ]; then
        # Copy results from container
        docker cp "$container_id:/app/test-results/." "$RESULTS_DIR/" 2>/dev/null || true

        # Display results summary
        if [ -d "$RESULTS_DIR" ] && [ "$(ls -A "$RESULTS_DIR"/*.tap 2>/dev/null)" ]; then
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
    docker-compose -f docker-compose.test.yml down --volumes --remove-orphans 2>/dev/null || true

    # Remove test images
    images=$(docker images -q -f "label=description=V5 BATS Testing Environment")
    if [ -n "$images" ]; then
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
                "$V5_ROOT_DIR/src" "$SCRIPT_DIR" "$V5_ROOT_DIR"/*.sh 2>/dev/null || break

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
