# Test Results

This directory contains TAP (Test Anything Protocol) compliant test results from the V5 test suite.

## File Format

Test results are stored in descriptive daily TAP files with the format:
```
{test-suite-name}-YYYY-MM-DD.tap
```

Examples:
- `install-tests-2025-10-08.tap` - Installation functionality tests (33 tests)
- `uninstall-tests-2025-10-08.tap` - Uninstallation functionality tests (26 tests)
- `core-tool-tests-2025-10-08.tap` - Core tool tests (13 tests)
- `integration-tests-2025-10-08.tap` - Integration tests with RabbitMQ
- `all-tests-combined-2025-10-08.tap` - All test suites combined (72 tests)

Each file contains the test results for the specified test suite(s) for that specific date. If the same test suite is run multiple times on the same day, the file is overwritten with the most recent results.

## TAP Format

Each file contains:
- TAP version declaration
- Test suite metadata with timestamps
- Test results from specific suites (install, uninstall, core-tool)
- Sequential test numbering across combined suites
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

## Automatic Timestamp Preservation

V5 includes intelligent timestamp management to keep the repository clean:

### How It Works
- After test completion, the system automatically analyzes changes in TAP files
- If only timestamps have changed (Generated, Started, Completed fields), the file is reverted
- Files with meaningful changes (new tests, different results, modified test counts) are preserved
- This prevents routine test runs from creating unnecessary repository noise

### Benefits for Repository Tracking
- **Cleaner Git History**: Only meaningful test changes appear in commits
- **Focused Diffs**: Reviewers see actual test changes, not timestamp updates
- **Reduced Noise**: Routine test runs don't pollute the repository with timestamp-only changes
- **Audit Trail Integrity**: Real test changes are still tracked and preserved

### User Experience
```bash
# Running the same tests multiple times
./test --local --tap install
⏰ Only timestamps changed, reverted to preserve original timestamps

# git status remains clean - no unnecessary TAP file modifications
```

## Latest Results

The most recent test results are always available in the file for the current date.
