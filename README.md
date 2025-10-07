# V5 - 5 Strategies Productive Development Tool

**The Ultimate 5-Window Development Strategy**

A productive development tool that transforms how you code using five specialized window strategies: intelligent assistance, automatic quality assurance, self-improving governance, strategic insights, and infinite extensibility.

## 🎯 Core Concept

**One repository. Five specialized autonomous agents. Zero distractions. Maximum productivity.**

### The 5 Windows:

- **Window A**: Your Interactive Development Hub (Human + AI)
- **Window B**: Silent Code Fixer (Autonomous QA)
- **Window C**: Pattern Learning Governor (Protocol Creator)
- **Window D**: Governance QA Auditor (Standards Guardian)
- **Window E**: Feature Insight Documentarian (Strategic Intelligence)

## 🚀 Installation

### Supported Platforms
- ✅ **Linux** (Ubuntu/Debian, CentOS/RHEL, Fedora)
- ✅ **macOS** (with Homebrew)
- ✅ **Windows WSL** (Windows Subsystem for Linux)
- ⚠️ **Windows Native** (requires manual RabbitMQ installation)

### Remote Install (Recommended)
```bash
# One-liner install (downloads and installs automatically)
curl -fsSL https://raw.githubusercontent.com/volkovasystems/v5/main/get-v5.sh | bash

# Install to specific directory
curl -fsSL https://raw.githubusercontent.com/volkovasystems/v5/main/get-v5.sh | bash -s -- --dir=/custom/path

# System-wide install (adds to PATH)
curl -fsSL https://raw.githubusercontent.com/volkovasystems/v5/main/get-v5.sh | bash -s -- --system
```

### Local Install
```bash
# If you prefer to clone first
git clone https://github.com/volkovasystems/v5
cd v5
./install.sh
```

### What gets installed:
- Python3 and pip (if missing)
- Virtual environment setup
- Python dependencies: `pika`, `psutil`, `watchdog`, `PyYAML`
- RabbitMQ server (Linux/macOS only)
- Cross-platform terminal compatibility

### Installation Options

#### Remote Install Options:
- **Default**: Installs to `~/v5-tool/`
- **System**: `--system` flag installs to `~/.local/share/v5` and adds to PATH
- **Custom**: `--dir=PATH` installs to specified directory

#### How remote installation works:
1. **Smart Download**: Uses git clone if available, falls back to curl
2. **Auto Dependencies**: Installs Python packages in virtual environment
3. **RabbitMQ Setup**: Automatically installs and configures (Linux/macOS/WSL)
4. **Cross-Platform**: Works on Linux, macOS, WSL, and Windows
5. **PATH Management**: System install adds `v5` command globally

### Manual Installation (if needed)
If automatic installation fails:
```bash
# Install Python dependencies
pip3 install pika psutil watchdog PyYAML

# Install RabbitMQ (choose your platform)
# Ubuntu/Debian:
sudo apt-get install rabbitmq-server

# CentOS/RHEL:
sudo yum install rabbitmq-server

# macOS:
brew install rabbitmq

# Windows: Download from https://www.rabbitmq.com/download.html
```

### Troubleshooting

**Installation fails with "command not found":**
```bash
# Install required tools first
# Ubuntu/Debian:
sudo apt-get install curl git

# macOS:
brew install curl git
```

**RabbitMQ not working:**
- V5 works in offline mode without RabbitMQ
- Install RabbitMQ manually for full functionality
- On WSL, you may need to start services manually

**Permission denied errors:**
```bash
# Try installation with different directory
curl -fsSL https://raw.githubusercontent.com/volkovasystems/v5/main/get-v5.sh | bash -s -- --dir=~/my-v5
```

## 🚀 Quick Start

After installation, follow these steps:

### 1. Initialize a Repository
```bash
# For system install (if you used --system flag)
v5 /path/to/your/project init

# For local install
./v5 /path/to/your/project init
```

### 2. Start the V5 Tool
```bash
# For system install
v5 /path/to/your/project start

# For local install  
./v5 /path/to/your/project start
```

### 3. Work in Window A
- Window A opens as your interactive terminal
- All other windows run silently in background
- Type your development requests naturally
- The tool handles quality, patterns, and insights automatically

## 📋 Tool Commands

```bash
./v5 <repository_path> [command]
./v5 --version  # Show version information

Commands:
  init     - Initialize repository with V5 structure
  start    - Start the V5 tool (default)
  stop     - Stop all V5 windows
  status   - Check tool status
  version  - Show version information
  
Options:
  --version, -v  - Show version and exit
```

## 🏗️ Architecture Overview

### Window Responsibilities

| Window | Role | Human Interaction | File Access |
|--------|------|-------------------|-------------|
| **A** | Interactive Development | ✅ Primary Interface | ✅ Repository Code |
| **B** | Autonomous Code Fixer | ❌ Silent Operation | ✅ Repository Code |
| **C** | Protocol Manager | ❌ Silent Operation | ✅ .warp/ Directory Only |
| **D** | Governance Auditor | ❌ Silent Operation | ❌ Communication Only |
| **E** | Feature Intelligence | ❌ Silent Operation | ✅ features/ Directory |

### Communication Flow

```
Window A (Human) ←→ RabbitMQ Message Bus ←→ All Other Windows
                          ↓
               External Integrations
                (CI/CD, Analytics, etc.)
```

## 📁 Repository Structure

After initialization, your repository will have:

```
your-project/
├── .warp/                 # V5 tool directory
│   ├── goal.txt          # Repository objective
│   ├── protocols/        # Rules and patterns (Window C only)
│   ├── logs/            # Tool activity logs
│   └── communication/   # RabbitMQ config and PIDs
├── features/            # Feature documentation (Window E)
└── [your existing code] # Your project files
```

## 🎯 Key Principles

### Repository Goal First
Every action must directly serve your repository's main objective. Define this clearly in `.warp/goal.txt`.

### Strict Boundaries
- **Window A**: Only responds to your exact prompts
- **Window B**: Only fixes issues, never adds features
- **Window C**: Only observes A↔B interactions
- **Window D**: Only applies industry standards
- **Window E**: Only suggests features based on patterns

### Lean & Simple
- Maximum 10 rules at any time
- Plain language - no technical jargon
- Immediate rule application
- User-friendly for all skill levels

## 💡 Usage Examples

### Working in Window A
```bash
# Tool commands
help          # Show available commands
status        # Check tool status
goal          # Show repository goal
rules         # Show current protocols
exit          # Stop V5 tool

# Development requests (examples)
"Add user authentication"
"Fix the slow database query"
"Optimize the API performance"
"Add tests for the payment module"
```

### What Happens Automatically
- **Window B**: Detects and fixes code issues
- **Window C**: Learns your patterns and creates rules
- **Window D**: Ensures rules follow best practices
- **Window E**: Documents feature opportunities
- **RabbitMQ**: Captures everything for integrations

## 🔧 Configuration

### Repository Goal (.warp/goal.txt)
V5 uses a structured YAML format for repository goals that enables optimal AI understanding and prevents scope creep:

```yaml
# V5 Repository Goal Configuration
goal:
  primary: "Build a high-performance task management API"
  description: |
    RESTful API for task creation, assignment, and tracking with 
    real-time updates and robust authentication.

success_criteria:
  - "Handle 500+ concurrent users without performance degradation"
  - "API response times under 100ms for 95% of requests"
  - "99.5% uptime in production environment"

constraints:
  performance: "Sub-100ms response times, efficient database queries"
  quality: "85% test coverage with unit and integration tests"
  security: "JWT authentication, input validation, SQL injection protection"

stakeholders:
  primary: "Development teams using the API"
  secondary: "System administrators, end users"

scope:
  included: |
    Task CRUD operations, user authentication, team management, 
    real-time notifications, API documentation
  excluded: |
    Frontend UI, mobile applications, email notifications, 
    third-party calendar integrations, reporting dashboards
```

#### Required Fields
- `goal.primary` - Single sentence describing main objective
- `success_criteria` - List of measurable outcomes
- `scope.included` - What IS included in repository scope
- `scope.excluded` - What is NOT included (prevents scope creep)

#### Optional Fields
- `goal.description` - Detailed explanation
- `constraints` - Technical and quality requirements
- `stakeholders` - Who benefits from this repository

#### AI Benefits
- **Goal alignment checking** - Warns when requests don't match repository objectives
- **Keyword extraction** - Identifies key concepts for pattern matching
- **Scope enforcement** - Prevents feature creep through clear boundaries
- **Context-aware responses** - All 5 windows consider goals in their operations

#### Best Practices
- **Specific criteria**: "API response < 50ms" vs "Fast performance"
- **Clear scope**: Explicitly state what's excluded to prevent feature creep
- **Measurable constraints**: "Memory < 512MB" vs "Should be efficient"
- **Update regularly**: Keep goals aligned with project evolution

### RabbitMQ Integration
The tool automatically broadcasts all activities to RabbitMQ exchanges:
- `window.activities` - All window actions
- `code.changes` - Repository modifications
- `protocol.updates` - Rule changes
- `governance.reviews` - Audit results
- `feature.insights` - Feature suggestions

## 🛠️ Extending V5

### External Integrations
Connect any system to the RabbitMQ message bus:

```python
# Example: CI/CD trigger on code changes
import pika

def trigger_build(ch, method, properties, body):
    message = json.loads(body)
    if message['routing_key'] == 'window_b.code.automatic_fix':
        # Trigger your CI/CD pipeline
        subprocess.run(['your-ci-command'])

# Subscribe to code changes
connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
channel = connection.channel()
channel.queue_bind(exchange='code.changes', queue='ci_trigger', routing_key='window_b.*')
channel.basic_consume(queue='ci_trigger', on_message_callback=trigger_build)
channel.start_consuming()
```

## 🤝 Contributing

V5 is designed to be lean and focused. Contributions should:
1. Serve the core 5-window strategy
2. Maintain strict scope boundaries
3. Keep the tool simple and fast
4. Use clear, non-technical language

## 📄 License

See LICENSE file for details.

---

**V5: Where autonomous development meets human creativity** 🚀
