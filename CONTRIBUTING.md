# Contributing to V5

Thank you for your interest in contributing to V5 - 5 Strategies Productive Development Tool! This guide will help you get started with contributing to our lean, focused development automation tool.

## 🎯 Contributing Philosophy

V5 is designed around core principles that all contributions must honor:

1. **Serve the 5-window strategy** - All changes must support the core Window A-E architecture
2. **Maintain strict boundaries** - Each window has specific responsibilities that must not overlap
3. **Keep it simple and fast** - Lean implementation with minimal dependencies
4. **Use clear, non-technical language** - Accessible to developers of all skill levels
5. **Development version focus** - We're currently in v1.0.0 development phase

## 🚀 Quick Start

### Prerequisites

- **Python 3.8+** (3.8, 3.9, 3.10, 3.11, 3.12 supported)
- **Git** for version control
- **Bash** for shell scripts (Linux/macOS/WSL)
- **Docker** (optional, for isolated testing)

### Development Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/your-username/v5.git
   cd v5
   ```

2. **Set up Development Environment**
   ```bash
   # Create Python virtual environment
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   
   # Install development dependencies
   pip install -r requirements.txt
   pip install -e .[dev]  # Installs black, flake8, mypy, pytest
   ```

3. **Verify Setup**
   ```bash
   # Run all tests to ensure everything works
   ./test --local
   
   # Should show: ✅ All 72 tests passing
   ```

## 📁 Project Structure

Understanding the V5 architecture is crucial for contributions:

```
v5/
├── src/                          # Core Python implementation
│   ├── core/                     # Main tool logic
│   │   └── v5_tool.py           # V5Tool class - main controller
│   ├── utils/                    # Utilities and helpers  
│   │   ├── messaging.py         # RabbitMQ message bus (V5MessageBus)
│   │   └── goal_parser.py       # Goal parsing (GoalParser)
│   └── windows/                  # Window implementations
│       ├── window_a.py          # Interactive Development Hub
│       ├── window_b.py          # Code Quality Enhancer
│       ├── window_c.py          # Pattern Learning Governor
│       ├── window_d.py          # Standards Guardian
│       └── window_e.py          # Feature Intelligence
├── tests/                        # Comprehensive test suite
│   ├── unit/                     # Unit tests (13 tests)
│   │   └── test_core_tool.bats  # Core Python module tests
│   ├── integration/              # Integration tests (59 tests)
│   │   ├── test_install.bats    # Installation tests (33 tests)
│   │   └── test_uninstall.bats  # Uninstallation tests (26 tests)
│   ├── fixtures/                 # Test data
│   ├── Dockerfile               # Test environment
│   └── test_helper.bash         # Test utilities
├── docs/                         # Additional documentation
├── install.sh                    # Main installation script
├── uninstall.sh                  # Comprehensive uninstall script
├── get-v5.sh                     # Remote installation script
├── v5                           # Main executable wrapper
└── test                         # Test runner wrapper
```

## 🔧 Development Workflow

### 1. Choose Your Contribution Type

**🐛 Bug Fixes**
- Fix issues without changing functionality
- Must include test cases reproducing the bug
- Should maintain backward compatibility

**✨ Feature Enhancements** 
- Improve existing window functionality
- Must align with 5-window strategy
- Require documentation updates

**📚 Documentation**
- README updates, code comments, examples
- Must stay aligned across all documentation
- Include practical examples

**🧪 Testing**
- New test cases, improved coverage
- Follow BATS testing framework
- Generate TAP-compliant output

### 2. Branch Strategy

```bash
# Create feature branch from main
git checkout main
git pull origin main
git checkout -b feature/your-feature-name

# For bug fixes
git checkout -b fix/issue-description

# For documentation
git checkout -b docs/documentation-update
```

### 3. Development Standards

#### Python Code Standards

**Code Formatting:**
```bash
# Use Black formatter (88 character line length)
black src/ tests/

# Lint with flake8
flake8 src/ tests/

# Type checking with mypy
mypy src/
```

**Code Style:**
- Follow PEP 8 conventions
- Use type hints for function parameters and return values
- Include docstrings for all public functions and classes
- Keep functions focused and single-purpose

**Example:**
```python
def create_messenger(
    window_id: str, config_path: Path
) -> Union[WindowMessenger, OfflineMessenger]:
    """Factory function to create appropriate messenger.
    
    Args:
        window_id: Unique identifier for the window (e.g., 'window_a')
        config_path: Path to the messaging configuration file
        
    Returns:
        WindowMessenger if RabbitMQ is available, OfflineMessenger otherwise
    """
    try:
        message_bus = V5MessageBus(config_path)
        if message_bus.is_connected:
            return WindowMessenger(window_id, message_bus)
        else:
            return OfflineMessenger(window_id)
    except Exception:
        return OfflineMessenger(window_id)
```

#### Shell Script Standards

**ShellCheck Compliance:**
```bash
# All scripts must pass ShellCheck
shellcheck install.sh uninstall.sh get-v5.sh v5 test tests/test.sh
```

**Style Requirements:**
- Use `#!/usr/bin/env bash` shebang
- Include `set -euo pipefail` for safety
- Use `"${variable}"` quoting for all variables
- Include comprehensive error handling
- Add descriptive comments for complex logic

**Example:**
```bash
#!/usr/bin/env bash
set -euo pipefail

# Function to handle errors gracefully
handle_error() {
    local exit_code=$?
    echo "❌ Error occurred in ${FUNCNAME[1]} at line ${BASH_LINENO[0]}" >&2
    exit $exit_code
}

trap handle_error ERR
```

### 4. Testing Requirements

All contributions must include comprehensive tests:

#### Running Tests

```bash
# Run all tests (recommended)
./test --local

# Run specific test suites
./test --local install     # 33 installation tests
./test --local uninstall   # 26 uninstallation tests  
./test --local core-tool   # 13 core tool tests

# Run with TAP output
./test --local --tap install

# Run in Docker (if available)
./test --build --clean
```

#### Writing New Tests

**BATS Test Structure:**
```bash
#!/usr/bin/env bats
# test_new_feature.bats

load "../test_helper"

setup() {
    setup_v5_test_env
}

teardown() {
    teardown_v5_test_env
}

@test "feature does what it should do" {
    # Arrange
    create_test_goal "Test goal for feature"
    
    # Act
    run your_command --option value
    
    # Assert
    assert_success
    assert_output_contains "expected result"
    assert_file_exists "output.txt"
}

@test "feature handles errors gracefully" {
    run your_command --invalid-option
    assert_failure
    assert_output_contains "error message"
}
```

**Available Test Helpers:**
- `setup_v5_test_env()` - Initialize isolated test environment
- `teardown_v5_test_env()` - Clean up after tests
- `assert_success()` - Assert command succeeded (exit code 0)
- `assert_failure()` - Assert command failed (exit code != 0)
- `assert_output_contains(text)` - Assert output contains specific text
- `assert_file_exists(file)` - Assert file exists
- `create_test_goal(text)` - Create test goal.yaml file
- `skip_if_missing(cmd)` - Skip test if dependency missing

#### Test Coverage Goals

- **New Features**: 100% test coverage with positive and negative test cases
- **Bug Fixes**: Include test case that reproduces the original bug
- **Python Code**: Unit tests for all public functions and classes
- **Shell Scripts**: Integration tests for all user-facing functionality

## 📝 Documentation Requirements

### 1. Code Documentation

**Python Docstrings:**
```python
class V5Tool:
    """Main V5 tool controller implementing 5-window architecture.
    
    This class coordinates the five specialized windows:
    - Window A: Interactive Development Hub
    - Window B: Code Quality Enhancer
    - Window C: Pattern Learning Governor
    - Window D: Standards Guardian
    - Window E: Feature Intelligence
    
    Attributes:
        repository_path: Path to the target repository
        config: Tool configuration dictionary
        windows: Active window instances
    """
```

**Shell Script Comments:**
```bash
# Install V5 globally by creating system-wide command
install_global() {
    local install_dir="${1:-/usr/local/bin}"
    
    # Verify we have write permissions
    if [[ ! -w "$install_dir" ]]; then
        echo "❌ No write permissions for $install_dir" >&2
        return 1
    fi
    
    # Create wrapper script that calls main v5 executable
    # This allows 'v5' command to work from any directory
    cat > "$install_dir/v5" << 'EOF'
#!/usr/bin/env bash
exec "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../share/v5/v5" "$@"
EOF
}
```

### 2. Documentation Updates

When making changes, update relevant documentation:

**README.md Sections:**
- Installation instructions (if adding install options)
- Usage examples (if changing commands)
- Test documentation (if adding test types)
- Architecture overview (if modifying windows)

**CHANGELOG.md:**
- Add entry under current development version (1.0.0)
- Use clear, user-focused language
- Include before/after examples for breaking changes

**docs/TAP_OUTPUT.md:**
- Update if changing test output format
- Include new TAP file examples
- Update test count documentation

### 3. Inline Documentation

- **Comments**: Explain *why*, not *what* (code shows what)
- **TODO Comments**: Include issue numbers when relevant
- **Type Hints**: Use for all Python function parameters and returns
- **Error Messages**: User-friendly, actionable error messages

## 🔄 Pull Request Process

### 1. Pre-submission Checklist

Before submitting a pull request, ensure:

- [ ] **All tests pass**: `./test --local` shows 72/72 passing
- [ ] **Code is formatted**: `black src/ tests/` runs cleanly
- [ ] **Linting passes**: `flake8 src/ tests/` shows no errors
- [ ] **ShellCheck passes**: All shell scripts pass validation
- [ ] **Documentation updated**: README, CHANGELOG, and relevant docs
- [ ] **Type hints added**: All new Python functions have type hints
- [ ] **Tests included**: New features have comprehensive test coverage

### 2. Commit Message Format

Use clear, descriptive commit messages:

```
type: brief description

Detailed explanation of the change, if needed.

- Key changes made
- Rationale for the changes  
- Any breaking changes or migration notes

Fixes #123
```

**Types:**
- `feat:` - New features or enhancements
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `test:` - Test additions or improvements
- `refactor:` - Code restructuring without behavior changes
- `style:` - Code formatting or style changes
- `chore:` - Build process or tooling changes

**Examples:**
```bash
# Good commit messages
feat: add dry-run support to uninstall script

fix: resolve ShellCheck SC2162 warning on read command

docs: update TAP output examples to reflect new test structure

test: add comprehensive uninstallation test coverage
```

### 3. Pull Request Template

When opening a PR, include:

**Description:**
- What does this PR do?
- Why is this change needed?
- How does it align with V5's principles?

**Testing:**
- What tests were added/modified?
- How was the change verified?
- Any manual testing performed?

**Documentation:**
- What documentation was updated?
- Are there any breaking changes?

**Checklist:**
- [ ] Tests pass locally
- [ ] Code is properly formatted
- [ ] Documentation is updated
- [ ] Commit messages are clear

### 4. Review Process

**Reviewer Guidelines:**
- Focus on V5's core principles alignment
- Verify test coverage is comprehensive
- Check documentation accuracy and clarity
- Ensure changes maintain simplicity
- Validate cross-platform compatibility

**Common Review Points:**
- Does this serve the 5-window strategy?
- Are window boundaries respected?
- Is the implementation lean and focused?
- Are error messages user-friendly?
- Does it maintain backward compatibility?

## 🐛 Reporting Issues

### Bug Reports

Use the following template for bug reports:

```markdown
## Bug Description
Clear description of what's wrong

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What should happen

## Actual Behavior
What actually happened

## Environment
- OS: [e.g., Ubuntu 22.04, macOS 13.0]
- Python Version: [e.g., 3.10.8]
- V5 Version: [e.g., 1.0.0]
- Installation Method: [e.g., local install, remote curl]

## Additional Context
Any other relevant information, logs, or screenshots
```

### Feature Requests

Before requesting features, consider:

1. **Does this align with the 5-window strategy?**
2. **Which window would this belong to?**
3. **Does this maintain V5's simplicity?**
4. **Is this generally useful or very specific?**

Use this template:

```markdown
## Feature Description
Clear description of the proposed feature

## Motivation
Why is this feature needed?

## Window Alignment
Which of the 5 windows would this feature belong to?

## Implementation Ideas
Any thoughts on how this could be implemented?

## Alternatives Considered
Other ways to achieve the same goal
```

## 🏗️ Architecture Guidelines

### Window Responsibilities

Understanding window boundaries is crucial for contributions:

**Window A - Interactive Development Hub**
- **Role**: Primary human interface
- **Scope**: Direct user commands and responses
- **Files**: `src/windows/window_a.py`, main `v5` executable
- **Restrictions**: Only responds to explicit user prompts

**Window B - Code Quality Enhancer**
- **Role**: Autonomous code fixing
- **Scope**: Bug fixes, code improvements, optimization
- **Files**: `src/windows/window_b.py`
- **Restrictions**: Only fixes issues, never adds features

**Window C - Pattern Learning Governor**
- **Role**: Protocol and rule management
- **Scope**: Learning from A↔B interactions, creating rules
- **Files**: `src/windows/window_c.py`, `.warp/protocols/`
- **Restrictions**: Only observes and creates governance rules

**Window D - Standards Guardian**
- **Role**: Governance and quality assurance
- **Scope**: Applying industry standards, rule validation
- **Files**: `src/windows/window_d.py`
- **Restrictions**: Only applies standards, communicates via messaging

**Window E - Feature Intelligence**
- **Role**: Feature suggestion and documentation
- **Scope**: Pattern analysis, feature recommendations
- **Files**: `src/windows/window_e.py`, `features/` directory
- **Restrictions**: Only suggests, never implements

### Core Classes

**V5Tool (`src/core/v5_tool.py`)**
- Main controller coordinating all windows
- Handles repository detection and initialization
- Manages window lifecycle and communication

**V5MessageBus (`src/utils/messaging.py`)**
- RabbitMQ integration for inter-window communication
- Graceful fallback to offline mode
- Message routing and queue management

**GoalParser (`src/utils/goal_parser.py`)**
- Repository goal parsing and validation
- Request alignment checking
- YAML configuration handling

### Design Patterns

**Dependency Injection:**
```python
# Good: Dependencies injected
def create_window(window_id: str, message_bus: V5MessageBus) -> Window:
    return WindowImplementation(window_id, message_bus)

# Bad: Hard-coded dependencies
def create_window(window_id: str) -> Window:
    message_bus = V5MessageBus('/hardcoded/path')  # Bad!
    return WindowImplementation(window_id, message_bus)
```

**Graceful Degradation:**
```python
# Handle optional dependencies gracefully
try:
    import pika
    PIKA_AVAILABLE = True
except ImportError:
    PIKA_AVAILABLE = False
    # Provide fallback functionality
```

**Factory Pattern:**
```python
# Use factories for complex object creation
def create_messenger(window_id: str, config_path: Path) -> Messenger:
    """Factory creates appropriate messenger based on environment"""
    if can_connect_rabbitmq(config_path):
        return OnlineMessenger(window_id, config_path)
    else:
        return OfflineMessenger(window_id)
```

## 🚀 Release Process

### Development Version (Current: 1.0.0)

We're currently in development phase. All contributions go to v1.0.0:

- **Branch**: `main`
- **Version**: `1.0.0` (development)
- **Status**: Pre-marketing, active development
- **Focus**: Core functionality, testing, documentation

### Future Release Planning

When ready for public release:

1. **Version Bump**: Update to 1.1.0 or higher
2. **Documentation**: Remove "(Development Version)" markers
3. **Marketing**: Ready for public announcement
4. **Changelog**: Convert development notes to release notes

### Contributing to Releases

- All PRs target `main` branch
- Version stays at 1.0.0 until public release
- CHANGELOG entries go under development section
- Test coverage must remain at 100% (72/72 tests passing)

## 💬 Community

### Communication Channels

- **GitHub Issues**: Bug reports, feature requests
- **GitHub Discussions**: General questions, ideas
- **Pull Requests**: Code contributions, documentation

### Code of Conduct

- **Be Respectful**: Treat all contributors with respect
- **Be Constructive**: Provide helpful, actionable feedback  
- **Be Collaborative**: Work together toward shared goals
- **Be Patient**: Remember we're all learning and growing
- **Stay Focused**: Keep discussions relevant to V5

### Getting Help

**Before asking for help:**
1. Check existing documentation (README, this guide)
2. Search existing issues and discussions
3. Try running the test suite to isolate the problem

**When asking for help:**
1. Provide specific, actionable questions
2. Include relevant code snippets or error messages
3. Mention your environment (OS, Python version, etc.)
4. Describe what you've already tried

## 📚 Additional Resources

### Learning V5 Architecture

- **README.md** - Complete overview and usage guide
- **docs/TAP_OUTPUT.md** - Testing and TAP format details
- **CHANGELOG.md** - Development history and changes
- **Source Code** - Well-documented Python classes and functions

### Development Tools

- **Black** - Code formatting: `black src/ tests/`
- **Flake8** - Linting: `flake8 src/ tests/`
- **MyPy** - Type checking: `mypy src/`
- **BATS** - Test framework for shell scripts
- **ShellCheck** - Shell script analysis
- **Docker** - Isolated testing environment

### External Resources

- [Python Type Hints](https://docs.python.org/3/library/typing.html)
- [BATS Testing Framework](https://github.com/bats-core/bats-core)
- [ShellCheck Documentation](https://github.com/koalaman/shellcheck)
- [TAP Protocol Specification](https://testanything.org/)
- [Semantic Versioning](https://semver.org/)

---

## 🎉 Thank You

Thank you for contributing to V5! Your contributions help make development more productive and enjoyable for everyone. Whether you're fixing bugs, adding features, improving documentation, or helping other contributors, every contribution matters.

**Remember V5's core mission: Where autonomous development meets human creativity.** 🚀

---

*This contributing guide is aligned with V5 v1.0.0 development version. For questions or suggestions about this guide, please open an issue or discussion.*