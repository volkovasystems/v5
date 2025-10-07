#!/usr/bin/env bats
# test_core_system.bats - Unit tests for V5 core system components

load "../test_helper"

setup() {
    setup_v5_test_env
    cd test_repo
    create_test_goal "Test development project"
}

teardown() {
    teardown_v5_test_env
}

@test "Python modules can be imported successfully" {
    skip_if_missing "python3" "python3 not available"

    # Test core module imports
    run python3 -c "
import sys
sys.path.insert(0, '../src')
try:
    from core.v5_system import V5System
    print('V5System import: SUCCESS')
except ImportError as e:
    print(f'V5System import failed: {e}')
    exit(1)
"
    assert_success
    assert_output_contains "SUCCESS"
}

@test "messaging module imports without pika dependency" {
    skip_if_missing "python3" "python3 not available"

    run python3 -c "
import sys
sys.path.insert(0, '../src')
try:
    from utils.messaging import create_messenger
    print('Messaging import: SUCCESS')
except ImportError as e:
    print(f'Messaging import failed: {e}')
    exit(1)
"
    assert_success
    assert_output_contains "SUCCESS"
}

@test "goal parser handles valid YAML goal files" {
    skip_if_missing "python3" "python3 not available"

    run python3 -c "
import sys
sys.path.insert(0, '../src')
from utils.goal_parser import GoalParser, parse_goal_file
from pathlib import Path

goal_file = Path('.warp/goal.yaml')
if goal_file.exists():
    parser = GoalParser(goal_file)
    goal = parser.parse()
    if goal and goal.primary:
        print(f'Goal parsing: SUCCESS - {goal.primary}')
    else:
        print('Goal parsing: FAILED - No goal found')
        exit(1)
else:
    print('Goal parsing: FAILED - No goal file')
    exit(1)
"
    assert_success
    assert_output_contains "SUCCESS"
    assert_output_contains "Test development project"
}

@test "goal parser validates request alignment" {
    skip_if_missing "python3" "python3 not available"

    run python3 -c "
import sys
sys.path.insert(0, '../src')
from utils.goal_parser import check_request_alignment
from pathlib import Path

goal_file = Path('.warp/goal.yaml')
alignment = check_request_alignment(goal_file, 'Add test functionality')

print(f'Alignment check: {alignment[\"aligned\"]}')
print(f'Confidence: {alignment[\"confidence\"]:.2f}')
"
    assert_success
    assert_output_contains "Alignment check:"
    assert_output_contains "Confidence:"
}

@test "V5System initializes with valid repository" {
    skip_if_missing "python3" "python3 not available"

    run timeout 10 python3 -c "
import sys
sys.path.insert(0, '../src')
from core.v5_system import V5System
from pathlib import Path

try:
    system = V5System(Path('.').absolute())
    print('V5System initialization: SUCCESS')
    print(f'Repository: {system.target_repo}')
    print(f'Warp dir exists: {system.warp_dir.exists()}')
except Exception as e:
    print(f'V5System initialization failed: {e}')
    exit(1)
"
    assert_success
    assert_output_contains "SUCCESS"
}

@test "window implementations exist and are valid Python" {
    skip_if_missing "python3" "python3 not available"

    # Test each window file exists and compiles
    for window in a b c d e; do
        run python3 -m py_compile "../src/windows/window_${window}.py"
        assert_success
    done
}

@test "goal YAML file structure is valid" {
    skip_if_missing "python3" "python3 not available"

    run python3 -c "
import yaml
import sys

try:
    with open('.warp/goal.yaml', 'r') as f:
        data = yaml.safe_load(f)

    # Check required structure
    if 'goal' not in data:
        print('YAML validation: FAILED - no goal section')
        exit(1)

    if 'primary' not in data['goal']:
        print('YAML validation: FAILED - no primary goal')
        exit(1)

    print('YAML validation: SUCCESS')
    print(f'Primary goal: {data[\"goal\"][\"primary\"]}')

except yaml.YAMLError as e:
    print(f'YAML validation: FAILED - {e}')
    exit(1)
except Exception as e:
    print(f'YAML validation: ERROR - {e}')
    exit(1)
"
    assert_success
    assert_output_contains "SUCCESS"
}

@test ".warp directory structure is created correctly" {
    assert_dir_exists ".warp"
    assert_dir_exists ".warp/protocols"
    assert_dir_exists ".warp/communication"
    assert_dir_exists ".warp/logs"
    assert_file_exists ".warp/goal.yaml"
}

@test "messaging configuration can be created" {
    skip_if_missing "python3" "python3 not available"

    run python3 -c "
import sys, json
sys.path.insert(0, '../src')
from utils.messaging import create_default_config

config = create_default_config()
print(f'Config created: {\"host\" in config}')
print(f'Default host: {config.get(\"host\", \"missing\")}')

# Save config to test location
with open('.warp/communication/config.json', 'w') as f:
    json.dump({'rabbitmq': config}, f, indent=2)

print('Config file saved successfully')
"
    assert_success
    assert_output_contains "Config created: True"
    assert_file_exists ".warp/communication/config.json"
}

@test "version information is accessible from Python modules" {
    skip_if_missing "python3" "python3 not available"

    run python3 -c "
import sys
sys.path.insert(0, '../src')
from pathlib import Path

# Read version from VERSION file
version_file = Path('../VERSION')
if version_file.exists():
    version = version_file.read_text().strip()
    print(f'Version from file: {version}')

    # Validate version format
    import re
    if re.match(r'^[0-9]+\.[0-9]+\.[0-9]+$', version):
        print('Version format: VALID')
    else:
        print('Version format: INVALID')
        exit(1)
else:
    print('Version file not found')
    exit(1)
"
    assert_success
    assert_output_contains "Version from file:"
    assert_output_contains "Version format: VALID"
}

@test "error handling works without crashing" {
    skip_if_missing "python3" "python3 not available"

    # Test graceful handling of missing dependencies
    run python3 -c "
import sys
sys.path.insert(0, '../src')

try:
    from utils.messaging import V5MessageBus
    # This should handle missing pika gracefully
    bus = V5MessageBus({})
    connected = bus.connect()
    print(f'Connection attempt handled gracefully: {not connected}')
except Exception as e:
    print(f'Error handling test failed: {e}')
    exit(1)
"
    assert_success
    assert_output_contains "gracefully"
}

@test "goal summary generation works correctly" {
    skip_if_missing "python3" "python3 not available"

    run python3 -c "
import sys
sys.path.insert(0, '../src')
from utils.goal_parser import GoalParser
from pathlib import Path

parser = GoalParser(Path('.warp/goal.yaml'))
goal = parser.parse()

if goal:
    summary = parser.get_summary_for_ai()
    print(f'Summary generated: {len(summary) > 0}')
    print(f'Contains primary goal: {\"PRIMARY GOAL\" in summary}')
    print(f'Summary: {summary[:100]}...')
else:
    print('Goal parsing failed')
    exit(1)
"
    assert_success
    assert_output_contains "Summary generated: True"
    assert_output_contains "PRIMARY GOAL"
}

@test "Python path and imports work in isolated environment" {
    skip_if_missing "python3" "python3 not available"

    # Test that our test environment setup works correctly
    run python3 -c "
import sys
print(f'Python path includes test dir: {\"$TEST_TEMP_DIR/src\" in sys.path}')

# Test relative imports work
try:
    sys.path.insert(0, '../src')
    import core, utils, windows
    print('Package imports: SUCCESS')
except ImportError as e:
    print(f'Package imports: FAILED - {e}')
    exit(1)
"
    assert_success
    assert_output_contains "Package imports: SUCCESS"
}
