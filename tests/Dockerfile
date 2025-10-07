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
    && rm -rf /var/lib/apt/lists/* \
    && update-rc.d rabbitmq-server disable

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

# Create test runner script
RUN cat > /usr/local/bin/run-v5-tests << 'EOF'
#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 V5 BATS Test Suite Runner${NC}"
echo "================================="

# Activate Python virtual environment
source /home/tester/venv/bin/activate

# Change to app directory
cd /app/v5

# Export test environment variables
export PATH="/home/tester/venv/bin:$PATH"
export BATS_LIB_PATH="/usr/lib/bats"

# Function to run test suite
run_test_suite() {
    local suite_name="$1"
    local test_file="$2"
    
    echo -e "\n${YELLOW}Running $suite_name tests...${NC}"
    
    if bats --tap "$test_file" > "/app/test-results/${suite_name}.tap" 2>&1; then
        echo -e "${GREEN}✅ $suite_name tests: PASSED${NC}"
        return 0
    else
        echo -e "${RED}❌ $suite_name tests: FAILED${NC}"
        cat "/app/test-results/${suite_name}.tap"
        return 1
    fi
}

# Initialize results directory
mkdir -p /app/test-results
rm -f /app/test-results/*.tap

# Run test suites
failures=0

# Installation tests
if [ -f "tests/integration/test_installation.bats" ]; then
    run_test_suite "installation" "tests/integration/test_installation.bats" || ((failures++))
fi

# Core system tests  
if [ -f "tests/unit/test_core_system.bats" ]; then
    run_test_suite "core-system" "tests/unit/test_core_system.bats" || ((failures++))
fi

# Run any additional test files found
for test_file in tests/unit/*.bats tests/integration/*.bats; do
    if [ -f "$test_file" ] && [[ "$test_file" != *"test_installation.bats" ]] && [[ "$test_file" != *"test_core_system.bats" ]]; then
        suite_name=$(basename "$test_file" .bats)
        run_test_suite "$suite_name" "$test_file" || ((failures++))
    fi
done

# Generate summary report
echo -e "\n${BLUE}📊 Test Results Summary${NC}"
echo "========================"

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
            echo -e "${GREEN}✅ $suite: $passed/$tests tests passed${NC}"
        else
            echo -e "${RED}❌ $suite: $passed/$tests tests passed${NC}"
        fi
    fi
done

echo "------------------------"
if [ "$failures" -eq 0 ] && [ "$total_tests" -gt 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED: $passed_tests/$total_tests${NC}"
    exit 0
else
    echo -e "${RED}💥 TESTS FAILED: $passed_tests/$total_tests passed, $failures suites failed${NC}"
    exit 1
fi
EOF

# Make test runner executable
RUN chmod +x /usr/local/bin/run-v5-tests

# Create entrypoint script
RUN cat > /docker-entrypoint.sh << 'EOF'
#!/bin/bash
set -e

# Start RabbitMQ in background if needed for integration tests
if [ "${START_RABBITMQ:-false}" = "true" ]; then
    service rabbitmq-server start
    sleep 5
fi

# Change ownership of app directory to tester
chown -R tester:tester /app

# Switch to tester user and run command
if [ "$#" -eq 0 ]; then
    exec su tester -c "run-v5-tests"
else
    exec su tester -c "$*"
fi
EOF

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
