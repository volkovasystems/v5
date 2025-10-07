# TAP (Test Anything Protocol) Output

V5 test suite now supports generating daily, combined TAP-compliant output for integration with CI/CD systems and test result analyzers. All test results are consolidated into a single daily file for easy tracking and analysis.

## What is TAP?

TAP (Test Anything Protocol) is a simple text-based format for test output that's widely supported by testing tools, CI systems, and result analyzers. It provides a standardized way to report test results that can be parsed by various tools.

## Usage

### Generate Daily TAP Files

Generate daily, combined TAP output files alongside regular test output:

```bash
# Generate daily TAP file for all tests
./test --local --tap

# Generate daily TAP file for specific test suite
./test --local --tap installation
./test --local --tap core-system
```

Descriptive TAP files are saved in the `test-results/` directory:
- `test-results/all-tests-combined-2025-10-07.tap` - All test suites combined
- `test-results/installation-tests-2025-10-07.tap` - Installation tests only
- `test-results/core-system-tests-2025-10-07.tap` - Core system tests only
- Each file contains results from the specified test suite(s) with timing information
- Running the same test suite multiple times on the same day overwrites that specific file

### TAP-Only Output

Output only TAP format to stdout (useful for CI integration):

```bash
# Output only TAP format for all tests
./test --local --tap-only

# Output only TAP format for specific test suite
./test --local --tap-only installation
./test --local --tap-only core-system
```

This mode suppresses all other output and only prints TAP-formatted results to stdout.

## TAP Format Example

```tap
TAP version 13
# V5 Test Suite Results
# Date: 2025-10-07
# Generated: 2025-10-07 13:04:33 PST
#
1..31
#
# Test Suite: installation
# Started: 2025-10-07 13:04:33 PST
# Completed: 2025-10-07 13:04:35 PST
# Status: PASSED
#
1..18
ok 1 install.sh exists and is executable
ok 2 get-v5.sh exists and is executable
# ... more installation tests
#
# Test Suite: core-system
# Started: 2025-10-07 13:04:35 PST
# Completed: 2025-10-07 13:04:37 PST
# Status: PASSED
#
1..13
ok 1 Python modules can be imported successfully
# ... more core-system tests
#
# SUMMARY
# Total Tests: 31
# Passed: 31
# Failed: 0
# Overall Status: PASSED
# Completed: 2025-10-07 13:04:37 PST
```

## CI Integration

### GitHub Actions

```yaml
- name: Run tests with TAP output
  run: ./test --local --tap-only > test-results.tap

- name: Parse TAP results
  uses: pxeger/tap-results@v1
  if: always()
  with:
    path: test-results.tap
```

### Jenkins

```groovy
pipeline {
    agent any
    stages {
        stage('Test') {
            steps {
                sh './test --local --tap-only > test-results.tap'
            }
        }
    }
    post {
        always {
            publishTAPResults testResults: 'test-results.tap'
        }
    }
}
```

### GitLab CI

```yaml
test:
  script:
    - ./test --local --tap-only > test-results.tap
  artifacts:
    reports:
      junit: test-results.tap
    when: always
```

## Benefits

1. **Standardized Format**: TAP is widely supported by testing tools
2. **CI Integration**: Easy integration with continuous integration systems  
3. **Test Analysis**: Compatible with test result analyzers and dashboards
4. **Automation**: Enables automated test result parsing and reporting
5. **Historical Tracking**: TAP files can be stored for test result history

## Options Summary

| Option | Description |
|--------|-------------|
| `--tap` | Generate TAP files in `test-results/` directory |
| `--tap-only` | Output only TAP format to stdout (no other output) |
| `--local --tap` | Run tests locally and generate TAP files |
| `--local --tap-only` | Run tests locally with TAP-only output |

## File Locations

- Descriptive TAP files: `test-results/{suite-name}-YYYY-MM-DD.tap`
- Examples:
  - `test-results/all-tests-combined-2025-10-07.tap` - All test suites combined
  - `test-results/installation-tests-2025-10-07.tap` - Installation tests only
  - `test-results/core-system-tests-2025-10-07.tap` - Core system tests only
- Files include comprehensive metadata, timing, and summary information

## Automatic Timestamp Preservation

V5 includes intelligent timestamp management to keep your repository clean and prevent meaningless diffs:

### How It Works

When tests complete, the system automatically analyzes TAP files for changes:

1. **Detects timestamp-only changes** in fields like `Generated:`, `Started:`, and `Completed:`
2. **Preserves meaningful changes** like new tests, different results, or modified test counts
3. **Automatically reverts files** that only have timestamp differences
4. **Provides feedback** when timestamp-only changes are reverted

### Example Behavior

```bash
# Run tests multiple times - only timestamps change
./test --local --tap installation
⏰ Only timestamps changed, reverted to preserve original timestamps

# Add a new test - meaningful changes are preserved
./test --local --tap installation
💾 TAP file contains meaningful changes, keeping updated version
```

### Benefits

- **Clean Repository**: No commit noise from routine test runs
- **Focused Diffs**: Only see actual test changes in git diffs
- **Audit Trail**: Meaningful test changes are still tracked
- **Automatic**: No manual intervention required

## Features

- **Descriptive Names**: File names clearly indicate which test suite was executed
- **Date-based Organization**: One file per test suite per day, overwritten on subsequent runs
- **Flexible Results**: Individual test suites or combined results as needed
- **Rich Metadata**: Includes start/end times, test suite status, and summary statistics
- **Repository Integration**: Files are tracked in the repository for historical analysis
- **Compliance Ready**: TAP format suitable for audit trails and compliance requirements
- **Timestamp Preservation**: Automatic reversion of timestamp-only changes to keep repository clean
