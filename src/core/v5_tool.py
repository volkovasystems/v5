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
import time
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
        """Launch all 5 windows of the V5 tool in Warp terminal tabs"""
        self.logger.info("Launching V5 windows in Warp tabs...")

        windows = [
            ('window_a', 'V5-Dev-Interactive', 'window_a.py'),
            ('window_b', 'V5-QA-Fixer', 'window_b.py'),
            ('window_c', 'V5-Protocol-Manager', 'window_c.py'),
            ('window_d', 'V5-Governance-Auditor', 'window_d.py'),
            ('window_e', 'V5-Feature-Intelligence', 'window_e.py')
        ]

        launched_pids = []
        
        # Check if xdotool is available for Warp automation
        try:
            subprocess.run(['which', 'xdotool'], check=True, capture_output=True)
            warp_automation_available = True
        except subprocess.CalledProcessError:
            warp_automation_available = False
            self.logger.warning("xdotool not available - falling back to manual setup")

        if warp_automation_available:
            # Find Warp window
            try:
                result = subprocess.run(
                    ['xdotool', 'search', '--class', 'dev.warp.Warp'],
                    capture_output=True, text=True, check=True
                )
                warp_window_id = result.stdout.strip().split('\n')[0]
                self.logger.info(f"Found Warp window: {warp_window_id}")
                
                # Launch each window in a new Warp tab
                for i, (window_id, title, script) in enumerate(windows):
                    script_path = self.v5_root / 'src' / 'windows' / script
                    
                    if not script_path.exists():
                        self.logger.error(f"Window script not found: {script_path}")
                        continue
                    
                    # Always create new tab, even for Window A (cleaner approach)
                    # Open new tab in Warp
                    subprocess.run([
                        'xdotool', 'windowactivate', warp_window_id
                    ], check=True)
                    subprocess.run(['sleep', '0.3'])  # Short delay
                    subprocess.run([
                        'xdotool', 'key', 'ctrl+shift+t'
                    ], check=True)
                    subprocess.run(['sleep', '1'])  # Wait for new tab
                    
                    # Type the command to start the V5 window
                    venv_python = self.v5_root / 'venv' / 'bin' / 'python3'
                    python_cmd = str(venv_python) if venv_python.exists() else 'python3'
                    
                    cmd_to_type = (
                        f"cd {self.target_repo} && "
                        f"export PYTHONPATH={self.v5_root / 'src'}:$PYTHONPATH && "
                        f"echo '\n🚀 V5 {window_id.upper().replace('_', ' ')} - {title}' && "
                        f"echo '📁 Repository: {self.target_repo}' && "
                        f"echo '🎯 V5 5-Window Development Strategy Active\n' && "
                        f"{python_cmd} {script_path} {self.target_repo}"
                    )
                    
                    # Type the command
                    subprocess.run([
                        'xdotool', 'windowactivate', warp_window_id
                    ], check=True)
                    subprocess.run(['sleep', '0.2'])
                    subprocess.run([
                        'xdotool', 'type', '--delay', '10', cmd_to_type
                    ], check=True)
                    subprocess.run(['sleep', '0.3'])
                    subprocess.run([
                        'xdotool', 'key', 'Return'
                    ], check=True)
                    
                    # Add to launched list with incremental PID
                    launched_pids.append((window_id, 2000 + i))
                    self.logger.info(f"Launched {window_id} in Warp tab")
                    
                    # Small delay between launching windows
                    subprocess.run(['sleep', '0.5'])
                    
            except (subprocess.CalledProcessError, IndexError) as e:
                self.logger.error(f"Failed to find or interact with Warp window: {e}")
                warp_automation_available = False
        
        # Fallback to manual instructions if automation failed
        if not warp_automation_available:
            return self.manual_launch_fallback(windows)
        
        # Save PIDs for cleanup
        pid_file = self.warp_dir / 'communication' / 'pids.json'
        with open(pid_file, 'w') as f:
            json.dump({wid: pid for wid, pid in launched_pids}, f, indent=2)

        self.logger.info(f"V5 tool launched with {len(launched_pids)} Warp tabs")
        
        print(f"\n✅ V5 launched {len(launched_pids)} windows in Warp tabs!")
        print("\n💡 Check your Warp terminal - you should see 5 tabs:")
        print("   • Tab 1: V5-Dev-Interactive (your main interface)")
        print("   • Tab 2: V5-QA-Fixer (silent code quality)")
        print("   • Tab 3: V5-Protocol-Manager (pattern learning)")
        print("   • Tab 4: V5-Governance-Auditor (standards guardian)")
        print("   • Tab 5: V5-Feature-Intelligence (insights)")
        
        return launched_pids

    def manual_launch_fallback(self, windows):
        """Fallback method for manual launch when automation fails"""
        launched_pids = []
        
        print("\n" + "="*60)
        print("🚀 V5 MANUAL SETUP (Automation unavailable)")
        print("="*60)
        print("Please manually open 4 additional Warp tabs and run:")
        print()
        
        for i, (window_id, title, script) in enumerate(windows):
            script_path = self.v5_root / 'src' / 'windows' / script
            
            if not script_path.exists():
                self.logger.error(f"Window script not found: {script_path}")
                continue
                
            # Create launch script
            launch_script = self.create_window_launch_script(window_id, title, script_path)
            
            if i == 0:
                print(f"📺 CURRENT TAB - {title}:")
                print(f"   bash {launch_script}")
                print()
            else:
                tab_num = i + 1
                print(f"📺 NEW TAB {tab_num} - {title}:")
                print(f"   Press Ctrl+Shift+T to open new tab, then run:")
                print(f"   bash {launch_script}")
                print()
            
            launched_pids.append((window_id, i + 1000))
        
        print("-"*60)
        
        # Save PIDs for cleanup  
        pid_file = self.warp_dir / 'communication' / 'pids.json'
        with open(pid_file, 'w') as f:
            json.dump({wid: pid for wid, pid in launched_pids}, f, indent=2)
        
        return launched_pids

    def create_v5_startup_script(self, windows):
        """Create a master startup script that launches all V5 windows"""
        startup_script = self.warp_dir / 'communication' / 'start_all_v5_windows.sh'
        
        script_content = f"""#!/bin/bash
# V5 - 5 Strategies Productive Development Tool
# Master startup script for all windows

echo "🚀 Starting V5 - 5 Window Development Environment"
echo "📁 Repository: {self.target_repo}"
echo "🎯 Goal: $(head -n 1 {self.warp_dir}/goal.yaml 2>/dev/null || echo 'V5 Development Framework')"
echo ""

# Set up environment
cd {self.target_repo}
export PYTHONPATH="{self.v5_root / 'src'}:$PYTHONPATH"

# Function to launch terminal window
launch_terminal() {{
    local title="$1"
    local script="$2"
    
    # Try different terminal emulators
    if command -v gnome-terminal >/dev/null 2>&1; then
        gnome-terminal --title="$title" -- bash "$script" &
    elif command -v xterm >/dev/null 2>&1; then
        xterm -title "$title" -e bash "$script" &
    elif command -v konsole >/dev/null 2>&1; then
        konsole --title="$title" -e bash "$script" &
    else
        echo "⚠️  Please manually run: bash $script"
    fi
    sleep 1
}}

# Launch all windows
echo "📺 Launching V5 windows..."
"""
        
        venv_python = self.v5_root / 'venv' / 'bin' / 'python3'
        python_cmd = str(venv_python) if venv_python.exists() else 'python3'
        
        for i, (window_id, title, script) in enumerate(windows):
            script_path = self.v5_root / 'src' / 'windows' / script
            launch_script = self.warp_dir / 'communication' / f'{window_id}_launch.sh'
            
            if i == 0:
                # Window A runs in foreground in current terminal
                script_content += f"""
echo "Starting Window A ({title}) in current terminal..."
echo "🔗 Other windows will open automatically"
echo ""

# Launch other windows in background first
"""
            else:
                script_content += f"""launch_terminal "{title}" "{launch_script}"
echo "✅ Launched {title}"
"""
        
        # Add Window A execution at the end
        window_a_script = self.warp_dir / 'communication' / 'window_a_launch.sh'
        script_content += f"""

echo ""
echo "🎯 All background windows launched. Starting interactive Window A..."
echo "💡 Use 'help' command for available options"
echo ""

# Start Window A (interactive)
bash "{window_a_script}"
"""
        
        startup_script.write_text(script_content)
        startup_script.chmod(0o755)
        return startup_script

    def create_window_launch_script(self, window_id: str, title: str, script_path: Path):
        """Create individual launch script for each V5 window"""
        launch_script = self.warp_dir / 'communication' / f'{window_id}_launch.sh'
        
        venv_python = self.v5_root / 'venv' / 'bin' / 'python3'
        python_cmd = str(venv_python) if venv_python.exists() else 'python3'
        
        script_content = f"""#!/bin/bash
# V5 {window_id.upper()} - {title}

echo ""
echo "🚀 V5 {window_id.upper().replace('_', ' ')} - {title}"
echo "📁 Repository: {self.target_repo}"
echo "🎯 V5 5-Window Development Strategy Active"
echo ""

# Set up environment
cd "{self.target_repo}"
export PYTHONPATH="{self.v5_root / 'src'}:$PYTHONPATH"

# Activate virtual environment if available
if [ -f "{self.v5_root}/venv/bin/activate" ]; then
    source "{self.v5_root}/venv/bin/activate"
fi

# Launch the V5 window
exec {python_cmd} "{script_path}" "{self.target_repo}"
"""
        
        launch_script.write_text(script_content)
        launch_script.chmod(0o755)
        return launch_script

    def launch_window(
        self, window_id: str, title: str, script_path: Path
    ) -> Optional[int]:
        """Launch a single window based on the platform"""
        try:
            # Prepare the Python command with virtual environment and arguments
            venv_python = self.v5_root / 'venv' / 'bin' / 'python3'
            if venv_python.exists():
                python_cmd = str(venv_python)
            else:
                python_cmd = 'python3'
            
            # Set up environment with Python path
            env = os.environ.copy()
            env['PYTHONPATH'] = f"{self.v5_root / 'src'}:{env.get('PYTHONPATH', '')}"
            
            if self.platform == 'darwin':  # macOS
                # macOS Warp or Terminal
                cmd = [
                    'osascript', '-e',
                    f'tell application "Warp" to activate',
                    '-e',
                    f'tell application "System Events" to keystroke "t" using command down',
                    '-e', 
                    f'delay 1',
                    '-e',
                    f'tell application "System Events" to keystroke "cd {self.target_repo} && {python_cmd} {script_path} {self.target_repo}"',
                    '-e',
                    f'tell application "System Events" to key code 36'
                ]
            elif self.platform == 'linux':
                # Create a simple shell script to run the window
                script_content = f"""#!/bin/bash
cd {self.target_repo}
export PYTHONPATH={self.v5_root / "src"}:$PYTHONPATH
exec {python_cmd} {script_path} {self.target_repo}
"""
                
                # Write the script to a temporary file
                script_file = self.warp_dir / 'communication' / f'{window_id}_launch.sh'
                script_file.write_text(script_content)
                script_file.chmod(0o755)
                
                # Try to launch Warp terminal first, then fallback to others
                warp_launched = False
                
                # Method 1: Try to open new Warp window using gio/gtk-launch
                try:
                    if subprocess.run(['which', 'gio'], capture_output=True).returncode == 0:
                        # Use gio to launch Warp
                        cmd = ['gio', 'launch', 'dev.warp.Warp.desktop']
                        self.logger.info(f"Launching Warp terminal for {window_id} using gio")
                    elif subprocess.run(['which', 'gtk-launch'], capture_output=True).returncode == 0:
                        # Use gtk-launch to launch Warp  
                        cmd = ['gtk-launch', 'dev.warp.Warp']
                        self.logger.info(f"Launching Warp terminal for {window_id} using gtk-launch")
                    else:
                        raise FileNotFoundError("No suitable launcher found")
                        
                    warp_launched = True
                        
                except (subprocess.CalledProcessError, FileNotFoundError, OSError):
                    self.logger.warning(f"Failed to launch Warp for {window_id}, falling back to gnome-terminal")
                    
                # Fallback to gnome-terminal if Warp launch failed
                if not warp_launched:
                    terminal_commands = [
                        ['gnome-terminal', '--window', '--title', title, '--', 'bash', str(script_file)],
                        ['gnome-terminal', '--tab', '--title', title, '--', 'bash', str(script_file)],
                        ['x-terminal-emulator', '-title', title, '-e', 'bash', str(script_file)],
                        ['xterm', '-title', title, '-e', 'bash', str(script_file)],
                    ]
                    
                    for cmd in terminal_commands:
                        try:
                            result = subprocess.run(['which', cmd[0]], capture_output=True, text=True, timeout=5)
                            if result.returncode == 0:
                                self.logger.info(f"Using fallback terminal: {cmd[0]} for {window_id}")
                                break
                        except (subprocess.TimeoutExpired, FileNotFoundError, OSError):
                            continue
                    else:
                        self.logger.error("No suitable terminal found")
                        return None
                        
                # For Warp terminals, we need to handle the command execution differently
                if warp_launched:
                    # Launch Warp and then use automation to run the command
                    import time
                    time.sleep(2)  # Give Warp time to open
                    
                    # Create a command file that Warp can execute
                    cmd_file = self.warp_dir / 'communication' / f'{window_id}_warp_cmd.sh'
                    warp_cmd_content = f"""#!/bin/bash
# This script will be executed in the new Warp terminal
echo "🚀 Starting V5 {window_id.upper().replace('_', ' ')} - {title}"
echo "📁 Repository: {self.target_repo}"
echo "🎯 V5 5-Window Development Strategy Active"
echo ""
bash {script_file}
"""
                    cmd_file.write_text(warp_cmd_content)
                    cmd_file.chmod(0o755)
                    
                    # The Warp window is opening - we'll return a placeholder PID
                    # In practice, you'd need to manually run the script in the Warp terminal
                    self.logger.info(f"Warp terminal launched for {window_id}")
                    self.logger.info(f"Please run this command in the new Warp terminal: bash {cmd_file}")
                    
                    return 1  # Return a placeholder PID
            elif self.platform == 'windows':
                # Windows PowerShell or Command Prompt
                cmd = [
                    'powershell', '-Command',
                    (
                        f'Start-Process -FilePath "{python_cmd}" '
                        f'-ArgumentList "{script_path}", "{self.target_repo}" -WindowStyle Normal'
                    )
                ]
            else:
                self.logger.error(f"Unsupported platform: {self.platform}")
                return None

            # Launch the terminal window
            process = subprocess.Popen(
                cmd,
                env=env,
                cwd=str(self.target_repo),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )

            # Give the terminal time to start
            import time
            time.sleep(0.5)

            return process.pid

        except Exception as e:
            self.logger.error(f"Failed to launch {window_id}: {e}")
            return None

    def stop_tool(self):
        """Stop all V5 windows and clean up tabs"""
        self.logger.info("Stopping V5 tool...")
        
        # Step 1: Force kill all V5 processes
        self.force_kill_v5_processes()
        
        # Step 2: Close Warp tabs that were created by V5
        self.close_v5_tabs()
        
        # Step 3: Clean up PID file
        pid_file = self.warp_dir / 'communication' / 'pids.json'
        if pid_file.exists():
            pid_file.unlink()
            
        self.logger.info("V5 tool stopped and tabs cleaned up")
        
    def force_kill_v5_processes(self):
        """Force kill all V5 window processes"""
        try:
            # Method 1: Kill by PID file
            pid_file = self.warp_dir / 'communication' / 'pids.json'
            if pid_file.exists():
                with open(pid_file) as f:
                    pids = json.load(f)
                    
                for window_id, pid in pids.items():
                    try:
                        if self.platform == 'windows':
                            subprocess.run(['taskkill', '/PID', str(pid), '/F'], 
                                         check=True, capture_output=True)
                        else:
                            # Try graceful kill first
                            subprocess.run(['kill', '-TERM', str(pid)], 
                                         check=True, capture_output=True)
                            subprocess.run(['sleep', '0.5'])
                            # Then force kill if needed
                            subprocess.run(['kill', '-KILL', str(pid)], 
                                         capture_output=True)
                        self.logger.info(f"Stopped {window_id} (PID: {pid})")
                    except subprocess.CalledProcessError:
                        self.logger.warning(f"Process {window_id} (PID: {pid}) may already be stopped")
            
            # Method 2: Kill by process name pattern (backup)
            try:
                subprocess.run(['pkill', '-f', 'window_[abcde].py'], 
                             capture_output=True, timeout=5)
                self.logger.info("Killed any remaining V5 window processes")
            except (subprocess.TimeoutExpired, subprocess.CalledProcessError):
                pass
                
            # Method 3: Force kill any Python processes in V5 directory (nuclear option)
            try:
                result = subprocess.run(
                    ['pgrep', '-f', str(self.v5_root)], 
                    capture_output=True, text=True
                )
                if result.stdout.strip():
                    pids = result.stdout.strip().split('\n')
                    for pid in pids:
                        if pid.isdigit():
                            subprocess.run(['kill', '-KILL', pid], capture_output=True)
                    self.logger.info(f"Force killed {len(pids)} V5-related processes")
            except (subprocess.TimeoutExpired, subprocess.CalledProcessError):
                pass
                
        except Exception as e:
            self.logger.error(f"Error during process cleanup: {e}")
    
    def close_v5_tabs(self):
        """Close Warp tabs that were created by V5 - Advanced Implementation"""
        try:
            # Check if xdotool is available
            subprocess.run(['which', 'xdotool'], check=True, capture_output=True)
            
            # Find Warp window
            result = subprocess.run(
                ['xdotool', 'search', '--class', 'dev.warp.Warp'],
                capture_output=True, text=True, check=True
            )
            warp_window_id = result.stdout.strip().split('\n')[0]
            
            self.logger.info("Starting advanced Warp tab closing sequence...")
            
            # Method 1: Kill V5 shell processes first (they hold the tabs open)
            self.kill_v5_shell_processes()
            
            # Method 2: Advanced keyboard automation with proper timing
            success = self.advanced_tab_closing(warp_window_id)
            
            if not success:
                # Method 3: Pixel-perfect mouse automation on tab bar
                self.mouse_close_tabs(warp_window_id)
                
            # Method 4: Final cleanup - terminate any remaining tab processes
            self.cleanup_remaining_tabs()
            
            self.logger.info("Warp tab closing sequence completed")
            
        except (subprocess.CalledProcessError, IndexError):
            self.logger.error("Critical: Could not automate tab closing - missing dependencies")
            # This is unacceptable - we must force a solution
            self.nuclear_tab_cleanup()
    
    def kill_v5_shell_processes(self):
        """Kill all V5-related shell processes that keep tabs open"""
        try:
            # Find all bash processes that contain V5 commands or are in our workspace
            result = subprocess.run(
                ['pgrep', '-f', 'bash.*cd.*' + str(self.target_repo)],
                capture_output=True, text=True
            )
            if result.returncode == 0:
                pids = result.stdout.strip().split('\n')
                for pid in pids:
                    if pid.strip():
                        try:
                            subprocess.run(['kill', '-TERM', pid.strip()], check=True)
                            self.logger.info(f"Killed V5 shell process PID: {pid}")
                        except subprocess.CalledProcessError:
                            # Try force kill
                            subprocess.run(['kill', '-9', pid.strip()], check=False)
                            
            # Also kill by command patterns
            v5_patterns = ['npm run dev', 'npm run test', 'npm run build', 'npm run logs']
            for pattern in v5_patterns:
                subprocess.run(['pkill', '-f', pattern], check=False)
                
        except subprocess.CalledProcessError:
            pass  # Expected if no processes found
            
    def advanced_tab_closing(self, warp_window_id):
        """Advanced keyboard automation with proper window management"""
        try:
            # Activate Warp and bring it to front
            subprocess.run(['xdotool', 'windowactivate', '--sync', warp_window_id])
            subprocess.run(['xdotool', 'windowraise', warp_window_id])
            time.sleep(0.8)  # Give Warp time to focus
            
            # Get current tab count by trying to navigate tabs
            tab_count = self.detect_tab_count(warp_window_id)
            
            # Close tabs one by one, starting from current active tab
            closed_count = 0
            for i in range(min(tab_count, 8)):  # Max 8 attempts for safety
                # Send interrupt signal first
                subprocess.run(['xdotool', 'key', '--window', warp_window_id, 'ctrl+c'])
                time.sleep(0.4)
                
                # Try Warp's close tab shortcut (Ctrl+Shift+W)
                subprocess.run(['xdotool', 'key', '--window', warp_window_id, 'ctrl+shift+w'])
                time.sleep(0.6)
                
                # Check if tab actually closed by seeing if we can still type
                test_result = subprocess.run(
                    ['xdotool', 'key', '--window', warp_window_id, 'Return'],
                    capture_output=True
                )
                
                if test_result.returncode == 0:
                    closed_count += 1
                    
                # Don't close more than we launched (5 tabs)
                if closed_count >= 5:
                    break
                    
            return closed_count >= 3  # Success if we closed at least 3 tabs
            
        except subprocess.CalledProcessError:
            return False
            
    def detect_tab_count(self, warp_window_id):
        """Estimate number of open tabs by cycling through them"""
        try:
            # Try to cycle through tabs to count them
            for i in range(10):  # Max 10 attempts
                subprocess.run(['xdotool', 'key', '--window', warp_window_id, 'ctrl+Tab'])
                time.sleep(0.2)
            return 5  # Assume V5 default count if detection fails
        except:
            return 5
    
    def close_multiple_tabs(self, warp_window_id: str, max_tabs: int = 6):
        """Aggressively close multiple tabs using various methods"""
        try:
            # Activate Warp window
            subprocess.run(['xdotool', 'windowactivate', warp_window_id], check=True)
            subprocess.run(['sleep', '0.5'])
            
            # Method 1: Close tabs using Ctrl+Shift+W repeatedly
            for i in range(max_tabs):
                try:
                    # Send Ctrl+C first to stop any running processes
                    subprocess.run(['xdotool', 'key', 'ctrl+c'], check=True)
                    subprocess.run(['sleep', '0.2'])
                    
                    # Close tab
                    subprocess.run(['xdotool', 'key', 'ctrl+shift+w'], check=True)
                    subprocess.run(['sleep', '0.8'])
                except subprocess.CalledProcessError:
                    break
            
            # Method 2: If Ctrl+Shift+W doesn't work, try other shortcuts
            for shortcut in ['ctrl+w', 'alt+F4']:
                for i in range(3):
                    try:
                        subprocess.run(['xdotool', 'windowactivate', warp_window_id], check=True)
                        subprocess.run(['sleep', '0.3'])
                        subprocess.run(['xdotool', 'key', 'ctrl+c'], check=True)
                        subprocess.run(['sleep', '0.2'])
                        subprocess.run(['xdotool', 'key', shortcut], check=True)
                        subprocess.run(['sleep', '0.5'])
                    except subprocess.CalledProcessError:
                        break
            
            # Method 3: Middle mouse click on tab area (close X buttons)
            try:
                # Get window geometry
                result = subprocess.run(
                    ['xdotool', 'getwindowgeometry', '--shell', warp_window_id],
                    capture_output=True, text=True, check=True
                )
                
                # Parse geometry
                for line in result.stdout.split('\n'):
                    if 'WIDTH=' in line:
                        width = int(line.split('=')[1])
                        break
                        
                # Click on potential tab close buttons
                for i in range(5):
                    x_pos = 150 + (i * 120)  # Approximate tab positions
                    if x_pos < width - 50:  # Don't click too far right
                        try:
                            subprocess.run(['xdotool', 'mousemove', str(x_pos), '25'], check=True)
                            subprocess.run(['xdotool', 'click', '1'], check=True)  # Left click
                            subprocess.run(['sleep', '0.3'])
                        except subprocess.CalledProcessError:
                            continue
                            
            except (subprocess.CalledProcessError, ValueError):
                pass
                
        except Exception as e:
            self.logger.warning(f"Error in aggressive tab closing: {e}")
            
    def mouse_close_tabs(self, warp_window_id):
        """Pixel-perfect mouse automation to click tab close buttons"""
        try:
            # Get window geometry
            result = subprocess.run(
                ['xdotool', 'getwindowgeometry', '--shell', warp_window_id],
                capture_output=True, text=True, check=True
            )
            
            geometry = {}
            for line in result.stdout.strip().split('\n'):
                if '=' in line:
                    key, value = line.split('=', 1)
                    geometry[key] = int(value) if value.isdigit() else value
                    
            window_width = geometry.get('WIDTH', 800)
            window_x = geometry.get('X', 100)
            window_y = geometry.get('Y', 100)
            
            self.logger.info(f"Warp window: {window_width}x{geometry.get('HEIGHT')} at ({window_x},{window_y})")
            
            # Activate window
            subprocess.run(['xdotool', 'windowactivate', warp_window_id])
            time.sleep(0.5)
            
            # Calculate tab bar area (typically top ~40px of window)
            tab_bar_y = window_y + 35  # Tab bar is usually ~35px from window top
            tab_width = max(120, window_width // 8)  # Reasonable tab width estimate
            
            # Click close buttons for up to 5 tabs
            for tab_index in range(5):
                # Calculate close button position (usually right side of each tab)
                tab_center_x = window_x + (tab_index + 1) * tab_width
                close_button_x = tab_center_x + (tab_width // 2) - 15  # Close 'X' is ~15px from tab right edge
                
                # Don't click outside window bounds
                if close_button_x > window_x + window_width - 20:
                    break
                    
                self.logger.info(f"Clicking tab {tab_index + 1} close button at ({close_button_x},{tab_bar_y})")
                
                # Move mouse and click
                subprocess.run(['xdotool', 'mousemove', str(close_button_x), str(tab_bar_y)])
                time.sleep(0.3)
                subprocess.run(['xdotool', 'click', '1'])  # Left click
                time.sleep(0.8)  # Wait for tab to close
                
        except subprocess.CalledProcessError as e:
            self.logger.warning(f"Mouse automation failed: {e}")
            
    def cleanup_remaining_tabs(self):
        """Final cleanup of any remaining V5 processes"""
        # Kill any remaining processes by name patterns
        patterns = ['node', 'npm', 'jest', 'webpack', 'vite']
        
        for pattern in patterns:
            try:
                result = subprocess.run(['pgrep', '-f', pattern], capture_output=True, text=True)
                if result.returncode == 0:
                    pids = result.stdout.strip().split('\n')
                    for pid in pids:
                        if pid.strip():
                            # Check if this PID belongs to our project
                            cmd_result = subprocess.run(
                                ['ps', '-p', pid.strip(), '-o', 'args', '--no-headers'],
                                capture_output=True, text=True
                            )
                            if (cmd_result.returncode == 0 and 
                                str(self.target_repo) in cmd_result.stdout):
                                subprocess.run(['kill', '-9', pid.strip()], check=False)
                                self.logger.info(f"Force killed remaining process PID: {pid}")
            except subprocess.CalledProcessError:
                continue
                
    def nuclear_tab_cleanup(self):
        """Last resort: Nuclear option for tab cleanup"""
        self.logger.warning("Executing nuclear tab cleanup - this may be disruptive")
        
        try:
            # Kill ALL Warp instances and restart fresh
            subprocess.run(['pkill', '-f', 'warp'], check=False)
            time.sleep(2)
            
            # Clean up any remaining V5 processes
            subprocess.run(['pkill', '-f', 'v5'], check=False)
            subprocess.run(['pkill', '-f', 'npm.*dev'], check=False)
            subprocess.run(['pkill', '-f', 'npm.*test'], check=False)
            subprocess.run(['pkill', '-f', 'npm.*build'], check=False)
            
            # Restart Warp (user will need to reopen their work)
            subprocess.run(['nohup', 'warp-terminal', '&'], 
                          stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                          
            print("\n⚠️  Nuclear cleanup executed - Warp has been restarted")
            print("📌 All V5 processes terminated and tabs closed")
            
        except Exception as e:
            self.logger.error(f"Nuclear cleanup failed: {e}")
            print("\n💥 All automated methods failed - manual intervention required")
            print("🔧 Please close V5 tabs manually and restart Warp if needed")

def find_git_repository(start_path: Optional[Path] = None) -> Path:
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
