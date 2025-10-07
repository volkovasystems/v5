# Test Results

This directory contains TAP (Test Anything Protocol) compliant test results from the V5 test suite.

## File Format

Test results are stored in descriptive daily TAP files with the format:
```
{test-suite-name}-YYYY-MM-DD.tap
```

Examples:
- `installation-tests-2025-10-07.tap` - Installation tests only
- `core-system-tests-2025-10-07.tap` - Core system tests only
- `all-tests-combined-2025-10-07.tap` - All test suites combined
- `integration-tests-2025-10-07.tap` - Integration tests only

Each file contains the test results for the specified test suite(s) for that specific date. If the same test suite is run multiple times on the same day, the file is overwritten with the most recent results.

## TAP Format

Each file contains:
- TAP version declaration
- Test suite metadata with timestamps
- All test results from installation and core-system suites
- Summary information and failure details

## Usage

These files can be:
- Analyzed by TAP-compatible tools
- Integrated into CI/CD pipelines
- Stored for historical test result tracking
- Used for test trend analysis

## Repository Tracking and File Retention

- Test result files are tracked as part of the repository for compliance and audit purposes
- Each day's test results overwrite previous runs from that same day, maintaining one file per date
- Files accumulate over time, creating a historical record of test results
- The most recent test results for each date are preserved in the repository
- Consider periodic cleanup of older files if the repository becomes too large

## Latest Results

The most recent test results are always available in the file for the current date.
