#!/usr/bin/env python3
"""
V5 Development Automation Tool
5-Window Development Strategy with RabbitMQ Integration

Core tool controller for managing all 5 windows and coordination.
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

class V5System:
    """Main controller for the V5 development automation tool"""
    
    def __init__(self, target_repository: str):
        self.target_repo = Path(target_repository).absolute()
        self.system_platform = platform.system().lower()
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
            f"v5_system_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        )
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file),
                logging.StreamHandler(sys.stdout)
            ]
        )
        
        self.logger = logging.getLogger('V5System')
        self.logger.info(f"V5 System version: {self.version}")
    
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
        goal_file = self.warp_dir / 'goal.txt'
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
            self.logger.info("Created initial goal.txt with structured format")
        
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
            if subprocess.run(['which', dep], capture_output=True).returncode != 0:
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
        python_deps = [dep.replace('python-', '') for dep in missing if dep.startswith('python-')]
        if python_deps:
            cmd = [sys.executable, '-m', 'pip', 'install'] + python_deps
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode == 0:
                self.logger.info(f"Installed Python packages: {python_deps}")
            else:
                self.logger.error(f"Failed to install Python packages: {result.stderr}")
                return False
        
        # External dependencies need manual installation
        external_deps = [dep for dep in missing if not dep.startswith('python-')]
        if external_deps:
            self.logger.warning(f"Please install external dependencies manually: {external_deps}")
            if 'rabbitmq-server' in external_deps:
                self.logger.info("To install RabbitMQ:")
                if self.system_platform == 'linux':
                    self.logger.info("  sudo apt-get install rabbitmq-server")
                elif self.system_platform == 'darwin':
                    self.logger.info("  brew install rabbitmq")
                elif self.system_platform == 'windows':
                    self.logger.info("  Download from: https://www.rabbitmq.com/download.html")
        
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
    
    def launch_window(self, window_id: str, title: str, script_path: Path) -> Optional[int]:
        """Launch a single window based on the platform"""
        try:
            if self.system_platform == 'darwin':  # macOS
                # Try Warp first, fall back to Terminal
                cmd = [
                    'open', '-a', 'Warp',
                    f'--args', '--title', title,
                    '--command', f'cd {self.target_repo} && python3 {script_path}'
                ]
            elif self.system_platform == 'linux':
                # Try various terminals
                terminals = [
                    ('warp-terminal', ['--title', title, '--', 'python3', str(script_path)]),
                    ('gnome-terminal', ['--title', title, '--', 'python3', str(script_path)]),
                    ('xterm', ['-title', title, '-e', f'cd {self.target_repo} && python3 {script_path}']),
                ]
                
                for terminal, args in terminals:
                    if subprocess.run(['which', terminal], capture_output=True).returncode == 0:
                        cmd = [terminal] + args
                        break
                else:
                    self.logger.error("No suitable terminal found")
                    return None
            elif self.system_platform == 'windows':
                # Windows PowerShell or Command Prompt
                cmd = [
                    'powershell', '-Command', 
                    f'Start-Process -FilePath "python" -ArgumentList "{script_path}" -WindowStyle Normal'
                ]
            else:
                self.logger.error(f"Unsupported platform: {self.system_platform}")
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
                if self.system_platform == 'windows':
                    subprocess.run(['taskkill', '/PID', str(pid), '/F'], check=True)
                else:
                    subprocess.run(['kill', str(pid)], check=True)
                self.logger.info(f"Stopped {window_id} (PID: {pid})")
            except subprocess.CalledProcessError:
                self.logger.warning(f"Failed to stop {window_id} (PID: {pid}) - may already be stopped")
        
        # Clean up PID file
        pid_file.unlink()
        self.logger.info("V5 tool stopped")

def main():
    """Main entry point for V5 tool"""
    # Handle version flag first (no repo path needed)
    if len(sys.argv) >= 2 and sys.argv[1] in ['--version', '-v', 'version']:
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
    
    if len(sys.argv) < 2:
        print("Usage: python3 v5_system.py <target_repository_path> [command]")
        print("Commands: init, start, stop, status, version")
        print("Options: --version, -v")
        sys.exit(1)
    
    target_repo = sys.argv[1]
    command = sys.argv[2] if len(sys.argv) > 2 else 'start'
    
    try:
        v5 = V5System(target_repo)
        
        if command == 'init':
            v5.initialize_repository()
            if v5.install_dependencies():
                print("✅ V5 tool initialized successfully")
            else:
                print("⚠️ V5 tool initialized with missing dependencies")
        
        elif command == 'start':
            v5.initialize_repository()
            if v5.install_dependencies():
                launched = v5.launch_windows()
                print(f"✅ V5 tool started with {len(launched)} windows")
            else:
                print("❌ Failed to start - missing dependencies")
        
        elif command == 'stop':
            v5.stop_tool()
            print("✅ V5 tool stopped")
        
        elif command == 'status':
            # Check tool status
            pid_file = v5.warp_dir / 'communication' / 'pids.json'
            if pid_file.exists():
                with open(pid_file) as f:
                    pids = json.load(f)
                print(f"✅ V5 tool running with {len(pids)} windows")
                for window_id, pid in pids.items():
                    print(f"  {window_id}: PID {pid}")
            else:
                print("❌ V5 tool is not running")
        
        else:
            print(f"Unknown command: {command}")
            sys.exit(1)
    
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()