# Dockerfile for V5 BATS Testing Environment
FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    bash \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    python3-venv \
    python3-yaml \
    shellcheck \
    netcat \
    procps \
    net-tools \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install BATS (Bash Automated Testing System)
RUN git clone https://github.com/bats-core/bats-core.git /tmp/bats-core \
    && cd /tmp/bats-core \
    && ./install.sh /usr/local \
    && rm -rf /tmp/bats-core

# Install BATS helpers for better assertions
RUN git clone https://github.com/bats-core/bats-support.git /usr/lib/bats/bats-support \
    && git clone https://github.com/bats-core/bats-assert.git /usr/lib/bats/bats-assert

# Install RabbitMQ for integration testing (optional)
RUN apt-get update && apt-get install -y \
    rabbitmq-server \
    && rm -rf /var/lib/apt/lists/*

# Disable RabbitMQ auto-start (Docker-friendly approach)
RUN service rabbitmq-server stop || true

# Create test user and directories
RUN useradd -m -s /bin/bash tester \
    && mkdir -p /app/v5 /app/test-results \
    && chown -R tester:tester /app

# Set up Python virtual environment
USER tester
WORKDIR /home/tester
RUN python3 -m venv /home/tester/venv

# Switch back to root for final setup
USER root

# Install Python test dependencies
COPY requirements.txt /tmp/requirements.txt
RUN /home/tester/venv/bin/pip install --upgrade pip \
    && /home/tester/venv/bin/pip install -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt

# Create test runner script (using COPY approach for VS Code compatibility)
COPY <<'SCRIPT' /usr/local/bin/run-v5-tests
#!/bin/bash
set -euo pipefail
echo "V5 BATS Test Suite Runner"
echo "========================="
source /home/tester/venv/bin/activate
cd /app/v5
export PATH="/home/tester/venv/bin:$PATH"
export BATS_LIB_PATH="/usr/lib/bats"
run_test_suite() {
    local suite_name="$1"
    local test_file="$2"
    echo "Running $suite_name tests..."
    if bats --tap "$test_file" > "/app/test-results/${suite_name}.tap" 2>&1; then
        echo "PASSED: $suite_name tests"
        return 0
    else
        echo "FAILED: $suite_name tests"
        cat "/app/test-results/${suite_name}.tap"
        return 1
    fi
}
mkdir -p /app/test-results
rm -f /app/test-results/*.tap
failures=0
if [ -f "tests/integration/test_install.bats" ]; then
    run_test_suite "install" "tests/integration/test_install.bats" || ((failures++))
fi
if [ -f "tests/integration/test_uninstall.bats" ]; then
    run_test_suite "uninstall" "tests/integration/test_uninstall.bats" || ((failures++))
fi
if [ -f "tests/unit/test_core_system.bats" ]; then
    run_test_suite "core-system" "tests/unit/test_core_system.bats" || ((failures++))
fi
for test_file in tests/unit/*.bats tests/integration/*.bats; do
    if [ -f "$test_file" ]; then
        case "$test_file" in
            *"test_install.bats"*) continue ;;
            *"test_uninstall.bats"*) continue ;;
            *"test_core_system.bats"*) continue ;;
            *) 
                suite_name=$(basename "$test_file" .bats)
                run_test_suite "$suite_name" "$test_file" || ((failures++))
                ;;
        esac
    fi
done
echo "Test Results Summary"
echo "===================="
total_tests=0
passed_tests=0
for tap_file in /app/test-results/*.tap; do
    if [ -f "$tap_file" ]; then
        suite=$(basename "$tap_file" .tap)
        tests=$(grep -c "^ok\|^not ok" "$tap_file" 2>/dev/null || echo "0")
        passed=$(grep -c "^ok " "$tap_file" 2>/dev/null || echo "0")
        total_tests=$((total_tests + tests))
        passed_tests=$((passed_tests + passed))
        if [ "$tests" -eq "$passed" ] && [ "$tests" -gt 0 ]; then
            echo "PASS: $suite: $passed/$tests tests passed"
        else
            echo "FAIL: $suite: $passed/$tests tests passed"
        fi
    fi
done
echo "------------------------"
if [ "$failures" -eq 0 ] && [ "$total_tests" -gt 0 ]; then
    echo "ALL TESTS PASSED: $passed_tests/$total_tests"
    exit 0
else
    echo "TESTS FAILED: $passed_tests/$total_tests passed, $failures suites failed"
    exit 1
fi
SCRIPT

# Make test runner executable
RUN chmod +x /usr/local/bin/run-v5-tests

# Create entrypoint script (using COPY approach for VS Code compatibility)
COPY <<'ENTRYPOINT' /docker-entrypoint.sh
#!/bin/bash
set -e
if [ "${START_RABBITMQ:-false}" = "true" ]; then
    service rabbitmq-server start
    sleep 5
fi
chown -R tester:tester /app
if [ "$#" -eq 0 ]; then
    exec su tester -c "run-v5-tests"
else
    exec su tester -c "$*"
fi
ENTRYPOINT

RUN chmod +x /docker-entrypoint.sh

# Set working directory
WORKDIR /app/v5

# Expose any necessary ports (RabbitMQ management)
EXPOSE 15672 5672

# Set default entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD bats --version > /dev/null || exit 1

# Labels for documentation
LABEL maintainer="V5 Development Team"
LABEL description="V5 BATS Testing Environment"
LABEL version="1.0.0"
