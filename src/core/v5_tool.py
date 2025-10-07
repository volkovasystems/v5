#!/usr/bin/env python3
"""
V5 - 5 Strategies Productive Development Tool
5-Window Development Strategy with RabbitMQ Integration

Core tool controller for managing all 5 windows and coordination.
Lean, concise, performant productive development tool.
"""

import os
import sys
import json
import subprocess
import platform
from pathlib import Path
from typing import Dict, List, Optional
import logging
from datetime import datetime

class V5Tool:
    """Main controller for the V5 productive development tool"""

    def __init__(self, target_repository: str):
        """Initialize the V5Tool with target repository path."""
        self.target_repo = Path(target_repository).absolute()
        self.platform = platform.system().lower()
        self.warp_dir = self.target_repo / '.warp'
        self.v5_root = Path(__file__).parent.parent.parent

        # Read version
        self.version = self.read_version()

        # Setup logging
        self.setup_logging()

        # Validate target repository
        if not self.target_repo.exists():
            raise ValueError(
                f"Target repository does not exist: {self.target_repo}"
            )

        self.logger.info(f"Initializing V5 tool for: {self.target_repo}")

    def read_version(self) -> str:
        """Read version from VERSION file"""
        try:
            version_file = self.v5_root / 'VERSION'
            if version_file.exists():
                return version_file.read_text().strip()
        except Exception:
            pass
        return "unknown"

    def setup_logging(self):
        """Configure logging for the V5 tool"""
        log_dir = self.v5_root / 'logs'
        log_dir.mkdir(exist_ok=True)

        log_file = log_dir / (
            f"v5_tool_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        )

        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file),
                logging.StreamHandler(sys.stdout)
            ]
        )

        self.logger = logging.getLogger('V5Tool')
        self.logger.info(f"V5 Tool version: {self.version}")

    def initialize_repository(self):
        """Initialize the target repository with .warp structure"""
        self.logger.info("Setting up .warp directory structure...")

        # Create .warp structure
        directories = [
            self.warp_dir,
            self.warp_dir / 'protocols',
            self.warp_dir / 'logs',
            self.warp_dir / 'communication'
        ]

        for directory in directories:
            directory.mkdir(exist_ok=True)
            self.logger.info(f"Created directory: {directory}")

        # Create initial configuration files
        self.create_initial_config()

        # Create features directory in repository root
        features_dir = self.target_repo / 'features'
        features_dir.mkdir(exist_ok=True)
        self.logger.info(f"Created features directory: {features_dir}")

    def create_initial_config(self):
        """Create initial configuration files"""

        # Repository goal file
        goal_file = self.warp_dir / 'goal.yaml'
        if not goal_file.exists():
            goal_content = f"""# V5 Repository Goal Configuration
# Format: YAML-like structure for optimal AI parsing
# Version: 1.0

goal:
    primary: "Define your main repository objective here"
    description: |
        Detailed explanation of what this repository aims to achieve.
        Keep this concise but comprehensive.

success_criteria:
    - "Measurable outcome 1"
    - "Measurable outcome 2"
    - "Measurable outcome 3"

constraints:
    performance: "Performance requirements (e.g., < 100ms response time)"
    quality: "Quality standards (e.g., 95% test coverage)"
    maintainability: "Maintainability goals (e.g., clear documentation)"

stakeholders:
    primary: "Who benefits most from this repository"
    secondary: "Other interested parties"

scope:
    included: |
        What IS included in this repository's responsibility
    excluded: |
        What is explicitly NOT included (prevents scope creep)

# Example Configuration:
# goal:
#   primary: "Build a high-performance JSON API server"
#   description: |
#     Create a scalable REST API that handles customer data efficiently
#     with excellent developer experience and robust error handling.
#
# success_criteria:
#   - "Handle 1000+ concurrent requests per second"
#   - "Maintain 99.9% uptime in production"
#   - "Average response time under 50ms"
#
# constraints:
#   performance: "Sub-100ms response times for all endpoints"
#   quality: "90% test coverage with integration tests"
#   maintainability: "Auto-generated API documentation"

# Metadata
created: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
last_updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
version: "1.0"
"""
            goal_file.write_text(goal_content)
            self.logger.info("Created initial goal.yaml with structured format")

        # Essential rules configuration
        rules_file = self.warp_dir / 'protocols' / 'essential_rules.json'
        if not rules_file.exists():
            rules_content = {
                "version": "1.0.0",
                "created": datetime.now().isoformat(),
                "repository_goal_focus": True,
                "max_rules_limit": 10,
                "rules": {
                    "goal_alignment": (
                        "Every change must serve the repository goal"
                    ),
                    "simplicity_first": (
                        "Choose simple solutions over complex ones"
                    ),
                    "user_friendly": (
                        "Use clear, understandable language "
                        "in all communications"
                    )
                },
                "auto_fix_patterns": {
                    "enabled": True,
                    "performance_first": True,
                    "escalate_complex": True
                }
            }

            with open(rules_file, 'w') as f:
                json.dump(rules_content, f, indent=2)
            self.logger.info("Created initial essential_rules.json")

        # Communication configuration
        comm_config = self.warp_dir / 'communication' / 'config.json'
        if not comm_config.exists():
            comm_content = {
                "rabbitmq": {
                    "host": "localhost",
                    "port": 5672,
                    "virtual_host": "/",
                    "username": "guest",
                    "password": "guest",
                    "exchanges": {
                        "window.activities": "topic",
                        "code.changes": "topic",
                        "protocol.updates": "topic",
                        "governance.reviews": "topic",
                        "feature.insights": "topic"
                    }
                },
                "windows": {
                    "window_a": {
                        "terminal": "warp", "title": "V5-Dev-Interactive"
                    },
                    "window_b": {
                        "terminal": "warp", "title": "V5-QA-Fixer"
                    },
                    "window_c": {
                        "terminal": "warp", "title": "V5-Protocol-Manager"
                    },
                    "window_d": {
                        "terminal": "warp", "title": "V5-Governance-Auditor"
                    },
                    "window_e": {
                        "terminal": "warp", "title": "V5-Feature-Intelligence"
                    }
                }
            }

            with open(comm_config, 'w') as f:
                json.dump(comm_content, f, indent=2)
            self.logger.info("Created communication config")

    def check_dependencies(self) -> List[str]:
        """Check if required dependencies are available"""
        missing_deps = []

        # Check Python dependencies
        required_python_packages = ['pika', 'psutil', 'watchdog', 'PyYAML']
        for package in required_python_packages:
            try:
                __import__(package)
            except ImportError:
                missing_deps.append(f"python-{package}")

        # Check external dependencies
        external_deps = ['rabbitmq-server']
        for dep in external_deps:
            try:
                result = subprocess.run(
                    ['which', dep], capture_output=True, text=True, timeout=10
                )
                if result.returncode != 0:
                    missing_deps.append(dep)
            except (subprocess.TimeoutExpired, FileNotFoundError, OSError) as e:
                self.logger.warning(f"Could not check dependency {dep}: {e}")
                missing_deps.append(dep)

        return missing_deps

    def install_dependencies(self):
        """Install missing dependencies"""
        missing = self.check_dependencies()

        if not missing:
            self.logger.info("All dependencies are available")
            return True

        self.logger.warning(f"Missing dependencies: {missing}")

        # Install Python packages
        python_deps = [
            dep.replace('python-', '') for dep in missing 
            if dep.startswith('python-')
        ]
        if python_deps:
            try:
                cmd = [sys.executable, '-m', 'pip', 'install'] + python_deps
                result = subprocess.run(
                    cmd, capture_output=True, text=True, timeout=300
                )
                if result.returncode == 0:
                    self.logger.info(f"Installed Python packages: {python_deps}")
                else:
                    self.logger.error(
                        f"Failed to install Python packages: {result.stderr}"
                    )
                    return False
            except (subprocess.TimeoutExpired, FileNotFoundError, OSError) as e:
                self.logger.error(f"Failed to run pip install: {e}")
                return False

        # External dependencies need manual installation
        external_deps = [dep for dep in missing if not dep.startswith('python-')]
        if external_deps:
            self.logger.warning(
                f"Please install external dependencies manually: {external_deps}"
            )
            if 'rabbitmq-server' in external_deps:
                self.logger.info("To install RabbitMQ:")
                if self.platform == 'linux':
                    self.logger.info("  sudo apt-get install rabbitmq-server")
                elif self.platform == 'darwin':
                    self.logger.info("  brew install rabbitmq")
                elif self.platform == 'windows':
                    download_url = (
                        "https://github.com/rabbitmq/rabbitmq-server/releases"
                    )
                    self.logger.info(f"  Download from: {download_url}")

        return len(external_deps) == 0

    def launch_windows(self):
        """Launch all 5 windows of the V5 tool"""
        self.logger.info("Launching V5 windows...")

        windows = [
            ('window_a', 'V5-Dev-Interactive', 'window_a.py'),
            ('window_b', 'V5-QA-Fixer', 'window_b.py'),
            ('window_c', 'V5-Protocol-Manager', 'window_c.py'),
            ('window_d', 'V5-Governance-Auditor', 'window_d.py'),
            ('window_e', 'V5-Feature-Intelligence', 'window_e.py')
        ]

        launched_pids = []

        for window_id, title, script in windows:
            script_path = self.v5_root / 'src' / 'windows' / script

            if not script_path.exists():
                self.logger.error(f"Window script not found: {script_path}")
                continue

            # Launch window based on platform
            pid = self.launch_window(window_id, title, script_path)
            if pid:
                launched_pids.append((window_id, pid))
                self.logger.info(f"Launched {window_id} (PID: {pid})")

        # Save PIDs for cleanup
        pid_file = self.warp_dir / 'communication' / 'pids.json'
        with open(pid_file, 'w') as f:
            json.dump({wid: pid for wid, pid in launched_pids}, f, indent=2)

        self.logger.info(f"V5 tool launched with {len(launched_pids)} windows")
        return launched_pids

    def launch_window(
        self, window_id: str, title: str, script_path: Path
    ) -> Optional[int]:
        """Launch a single window based on the platform"""
        try:
            if self.platform == 'darwin':  # macOS
                # Try Warp first, fall back to Terminal
                cmd = [
                    'open', '-a', 'Warp',
                    f'--args', '--title', title,
                    '--command', f'cd {self.target_repo} && python3 {script_path}'
                ]
            elif self.platform == 'linux':
                # Try various terminals
                terminals = [
                    (
                        'warp-terminal',
                        ['--title', title, '--', 'python3', str(script_path)]
                    ),
                    (
                        'gnome-terminal',
                        ['--title', title, '--', 'python3', str(script_path)]
                    ),
                    (
                        'xterm',
                        ['-title', title, '-e',
                         f'cd {self.target_repo} && python3 {script_path}']
                    ),
                ]

                for terminal, args in terminals:
                    try:
                        result = subprocess.run(
                            ['which', terminal],
                            capture_output=True, text=True, timeout=5
                        )
                        if result.returncode == 0:
                            cmd = [terminal] + args
                            break
                    except (subprocess.TimeoutExpired, FileNotFoundError, OSError):
                        continue
                else:
                    self.logger.error("No suitable terminal found")
                    return None
            elif self.platform == 'windows':
                # Windows PowerShell or Command Prompt
                cmd = [
                    'powershell', '-Command',
                    (
                        f'Start-Process -FilePath "python" '
                        f'-ArgumentList "{script_path}" -WindowStyle Normal'
                    )
                ]
            else:
                self.logger.error(f"Unsupported platform: {self.platform}")
                return None

            # Set working directory
            process = subprocess.Popen(
                cmd,
                cwd=str(self.target_repo),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )

            return process.pid

        except Exception as e:
            self.logger.error(f"Failed to launch {window_id}: {e}")
            return None

    def stop_tool(self):
        """Stop all V5 windows"""
        pid_file = self.warp_dir / 'communication' / 'pids.json'

        if not pid_file.exists():
            self.logger.warning("No PID file found - tool may not be running")
            return

        with open(pid_file) as f:
            pids = json.load(f)

        self.logger.info("Stopping V5 tool...")

        for window_id, pid in pids.items():
            try:
                if self.platform == 'windows':
                    subprocess.run(['taskkill', '/PID', str(pid), '/F'], check=True)
                else:
                    subprocess.run(['kill', str(pid)], check=True)
                self.logger.info(f"Stopped {window_id} (PID: {pid})")
            except subprocess.CalledProcessError:
                self.logger.warning(
                    f"Failed to stop {window_id} (PID: {pid}) - may already be stopped"
                )

        # Clean up PID file
        pid_file.unlink()
        self.logger.info("V5 tool stopped")

def find_git_repository(start_path: Path = None) -> Path:
    """Find the root of a git repository starting from the given path.
    
    Args:
        start_path: Path to start searching from (defaults to current directory)
        
    Returns:
        Path to the git repository root
        
    Raises:
        ValueError: If no git repository is found
    """
    if start_path is None:
        start_path = Path.cwd()
    
    current = start_path.absolute()
    
    # Walk up the directory tree looking for .git
    while current != current.parent:
        if (current / '.git').exists():
            return current
        current = current.parent
    
    # Check the root directory as well
    if (current / '.git').exists():
        return current
    
    raise ValueError(f"No git repository found in {start_path} or its parent directories")

def parse_arguments():
    """Parse command line arguments with flexible syntax.
    
    Returns:
        tuple: (target_repo, command)
    """
    args = sys.argv[1:]
    
    # Handle version flags
    if args and args[0] in ['--version', '-v', 'version']:
        # Create minimal instance just to get version
        v5_root = Path(__file__).parent.parent.parent
        try:
            version_file = v5_root / 'VERSION'
            if version_file.exists():
                version = version_file.read_text().strip()
            else:
                version = "unknown"
        except Exception:
            version = "unknown"
        print(f"V5 - 5 Strategies Productive Development Tool v{version}")
        sys.exit(0)
    
    # Handle help flag
    if args and args[0] in ['--help', '-h', 'help']:
        print("V5 - 5 Strategies Productive Development Tool")
        print("")
        print("Usage:")
        print("  v5                              # Initialize and start in current git repo")
        print("  v5 [command]                    # Run command in current git repo")
        print("  v5 <path> [command]             # Run command in specified repo")
        print("")
        print("Commands:")
        print("  init     - Initialize repository with V5 structure")
        print("  start    - Start the V5 tool (default)")
        print("  stop     - Stop all V5 windows")
        print("  status   - Check tool status")
        print("  version  - Show version information")
        print("")
        print("Options:")
        print("  --version, -v    - Show version and exit")
        print("  --help, -h       - Show this help message")
        print("")
        print("Examples:")
        print("  v5                    # Start V5 in current git repository")
        print("  v5 init               # Initialize current git repository")
        print("  v5 /path/to/repo      # Start V5 in specified repository")
        print("  v5 /path/to/repo init # Initialize specified repository")
        sys.exit(0)
    
    # If no arguments, use current directory with 'start' command
    if not args:
        try:
            return find_git_repository(), 'start'
        except ValueError as e:
            print(f"❌ Error: {e}")
            print("")
            print("Hint: Navigate to a git repository or specify a path:")
            print("  cd /path/to/your/git/repo && v5")
            print("  v5 /path/to/your/git/repo")
            sys.exit(1)
    
    # Check if first argument is a command (not a path)
    commands = ['init', 'start', 'stop', 'status']
    if args[0] in commands:
        # First argument is a command, use current directory
        try:
            return find_git_repository(), args[0]
        except ValueError as e:
            print(f"❌ Error: {e}")
            print("")
            print("Hint: Navigate to a git repository or specify a path:")
            print(f"  cd /path/to/your/git/repo && v5 {args[0]}")
            print(f"  v5 /path/to/your/git/repo {args[0]}")
            sys.exit(1)
    
    # First argument is a path
    target_repo = Path(args[0])
    command = args[1] if len(args) > 1 else 'start'
    
    return target_repo, command

def main():
    """Main entry point for V5 tool"""    
    target_repo, command = parse_arguments()
    
    # Display what we're doing
    repo_name = target_repo.name
    current_dir = Path.cwd()
    
    if target_repo == current_dir:
        print(f"🚀 V5 - Preparing productive development environment in '{repo_name}'")
    else:
        print(f"🚀 V5 - Preparing productive development environment")
        print(f"   Repository: {target_repo}")

    try:
        v5 = V5Tool(str(target_repo))

        if command == 'init':
            print(f"🔧 Initializing V5 structure in {repo_name}...")
            v5.initialize_repository()
            if v5.install_dependencies():
                print(f"✅ {repo_name} is now ready for 5 strategies productive development!")
                print("")
                print("💡 Next steps:")
                print("   1. Edit .warp/goal.yaml to define your repository objective")
                print("   2. Run 'v5 start' to launch the 5-window environment")
                print("   3. Work in Window A - other windows assist automatically")
            else:
                print("⚠️ V5 structure created, but some dependencies are missing")
                print("   The tool will work in offline mode")

        elif command == 'start':
            print(f"🔄 Initializing and starting V5 environment...")
            v5.initialize_repository()
            if v5.install_dependencies():
                launched = v5.launch_windows()
                print(f"✅ V5 productive development environment active!")
                print(f"   → {len(launched)} windows launched for {repo_name}")
                print("")
                print("💡 How to use:")
                print("   • Window A: Your main development interface")
                print("   • Other windows: Working silently to enhance your productivity")
                print("   • Focus on coding - V5 handles quality, patterns & insights")
            else:
                print("❌ Failed to start - missing dependencies")
                print("   Try running the installation again or install dependencies manually")

        elif command == 'stop':
            print(f"🛑 Stopping V5 environment for {repo_name}...")
            v5.stop_tool()
            print("✅ V5 tool stopped - all windows closed")

        elif command == 'status':
            print(f"🔍 Checking V5 status for {repo_name}...")
            # Check tool status
            pid_file = v5.warp_dir / 'communication' / 'pids.json'
            if pid_file.exists():
                with open(pid_file) as f:
                    pids = json.load(f)
                print(f"✅ V5 tool is running with {len(pids)} active windows:")
                for window_id, pid in pids.items():
                    print(f"   • {window_id}: PID {pid}")
            else:
                print("😴 V5 tool is not currently running")
                print("   Use 'v5 start' to launch the productive development environment")

        else:
            print(f"Unknown command: {command}")
            sys.exit(1)

    except Exception as e:
        print(f"❌ Error: {e}")
        if "does not exist" in str(e):
            print("")
            print("Hint: Make sure the repository path exists and is accessible")
        sys.exit(1)

if __name__ == '__main__':
    main()
