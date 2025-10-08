#!/usr/bin/env python3
"""
Warp Terminal Control API - Streamlined Implementation

Goals:
1. Control Warp GUI programmatically (open/close window, add/remove tabs)
2. Suspend human interaction during control (xtrlock)
3. Analyze each action for completion (screenshots + process check)
4. Generate comprehensive per-action reports (JSON)
5. Support VirtualBox testing environment

Usage:
    python3 warp_api.py launch          # Launch Warp window
    python3 warp_api.py new-tab         # Add new tab
    python3 warp_api.py close-tab       # Close current tab
    python3 warp_api.py test             # Run basic test suite
    python3 warp_api.py report           # Show latest results
"""

import os
import sys
import time
import json
import subprocess
import argparse
import shutil
import logging
from datetime import datetime
from pathlib import Path

# Optional GUI automation imports
try:
    import pyautogui
    GUI_AVAILABLE = True
    pyautogui.FAILSAFE = True
    pyautogui.PAUSE = 0.1
except ImportError:
    GUI_AVAILABLE = False
    print("Warning: pyautogui not available. Install with: pip install pyautogui")

class WarpConfig:
    """Configuration management for Warp API"""
    def __init__(self):
        self.screenshots_dir = Path("./screenshots")
        self.reports_dir = Path("./reports")
        self.warp_executable = self._detect_warp_executable()
        
    def _detect_warp_executable(self):
        """Detect correct Warp executable name"""
        for exe in ['warp-terminal', 'warp']:
            if shutil.which(exe):
                return exe
        return 'warp'  # fallback

class WarpAPI:
    """Simple, focused Warp Terminal Control API"""
    
    def __init__(self, log_level=logging.INFO):
        # Set up logging
        logging.basicConfig(
            level=log_level,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)
        
        # Initialize configuration
        self.config = WarpConfig()
        self.reports_dir = self.config.reports_dir
        self.screenshots_dir = self.config.screenshots_dir
        
        # Create directories
        self.reports_dir.mkdir(exist_ok=True)
        self.screenshots_dir.mkdir(exist_ok=True)
        
        # Session tracking
        self.session_actions = []
        
        self.logger.info(f"WarpAPI initialized with executable: {self.config.warp_executable}")
        
    def _log_action(self, action, success, details=None):
        """Log action with timestamp"""
        entry = {
            "timestamp": datetime.now().isoformat(),
            "action": action,
            "success": success,
            "details": details or {}
        }
        self.session_actions.append(entry)
        status = "✅ SUCCESS" if success else "❌ FAILED"
        print(f"[{entry['timestamp']}] {action}: {status}")
        return entry
        
    def _take_screenshot(self, name):
        """Take screenshot for verification"""
        if not GUI_AVAILABLE:
            return None
            
        filename = self.screenshots_dir / f"{name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.png"
        try:
            screenshot = pyautogui.screenshot()
            screenshot.save(filename)  # Path objects work directly
            self.logger.debug(f"Screenshot saved: {filename}")
            return filename  # Return Path object consistently
        except Exception as e:
            self.logger.error(f"Screenshot failed: {e}")
            print(f"Screenshot failed: {e}")
            return None
            
    def _lock_input(self):
        """Lock human input using xtrlock"""
        try:
            proc = subprocess.Popen(['xtrlock'], 
                                  stdin=subprocess.PIPE,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE)
            time.sleep(0.3)  # Let lock engage
            return proc.pid
        except:
            print("Warning: xtrlock not available - no input locking")
            return None
            
    def _unlock_input(self, lock_pid):
        """Unlock human input"""
        if lock_pid:
            try:
                subprocess.run(['kill', str(lock_pid)], check=False)
                subprocess.run(['pkill', '-f', 'xtrlock'], check=False)  # Cleanup
                time.sleep(0.2)
            except:
                pass
                
    def _get_warp_processes(self):
        """Get list of Warp processes"""
        try:
            result = subprocess.run(['pgrep', '-f', 'warp'], capture_output=True, text=True)
            processes = result.stdout.strip().split('\n') if result.stdout.strip() else []
            self.logger.debug(f"Found Warp processes: {processes}")
            return processes
        except Exception as e:
            self.logger.error(f"Failed to get Warp processes: {e}")
            return []
            
    def _verify_warp_running(self):
        """Check if Warp is running using consistent method"""
        try:
            # First try to find specific warp-terminal process
            result = subprocess.run(['pgrep', '-f', 'warp-terminal'], capture_output=True)
            if result.returncode == 0:
                self.logger.debug("Found warp-terminal process")
                return True
            
            # Fallback to generic warp process
            result = subprocess.run(['pgrep', '-f', 'warp'], capture_output=True)
            is_running = result.returncode == 0
            self.logger.debug(f"Warp running status: {is_running}")
            return is_running
        except Exception as e:
            self.logger.error(f"Failed to verify Warp running: {e}")
            return False
            
    def safe_execute(self, operation_name, operation_func, *args):
        """Consolidated error handling for all operations"""
        try:
            self.logger.info(f"Executing operation: {operation_name}")
            result = operation_func(*args)
            self._log_action(operation_name, True, {"result": str(result)})
            return result
        except Exception as e:
            self.logger.error(f"Operation {operation_name} failed: {e}")
            self._log_action(operation_name, False, {"error": str(e)})
            return False
            
    def _execute_action(self, action_name, action_func, *args):
        """Execute action with full safety and verification"""
        print(f"\n🔄 Executing: {action_name}")
        self.logger.info(f"Starting action: {action_name}")
        
        # Lock input
        lock_pid = self._lock_input()
        
        try:
            # Before screenshot
            before_shot = self._take_screenshot(f"before_{action_name}")
            
            # Execute action
            result = action_func(*args)
            
            # After screenshot  
            after_shot = self._take_screenshot(f"after_{action_name}")
            
            # Convert Path objects to strings for JSON serialization
            details = {
                "before_screenshot": str(before_shot) if before_shot else None,
                "after_screenshot": str(after_shot) if after_shot else None
            }
            
            # Log result
            return self._log_action(action_name, result, details)
            
        except Exception as e:
            self.logger.error(f"Action {action_name} failed: {e}")
            return self._log_action(action_name, False, {"error": str(e)})
            
        finally:
            # Always unlock
            self._unlock_input(lock_pid)
            
    # Core Warp Operations
    def launch_warp(self):
        """Launch Warp terminal window"""
        def _launch():
            try:
                # Use the detected executable
                self.logger.info(f"Launching Warp with executable: {self.config.warp_executable}")
                subprocess.Popen([self.config.warp_executable], 
                                stdout=subprocess.DEVNULL, 
                                stderr=subprocess.DEVNULL)
                time.sleep(3)  # Wait for launch
                return self._verify_warp_running()
            except Exception as e:
                self.logger.error(f"Launch failed: {e}")
                print(f"Launch failed: {e}")
                return False
                
        return self._execute_action("launch_warp", _launch)
        
    def new_tab(self):
        """Add new tab (Ctrl+Shift+T)"""
        def _new_tab():
            if not GUI_AVAILABLE:
                print("GUI automation not available")
                return False
            try:
                pyautogui.hotkey('ctrl', 'shift', 't')
                time.sleep(1)
                return True
            except:
                return False
                
        return self._execute_action("new_tab", _new_tab)
        
    def close_tab(self):
        """Close current tab (Ctrl+Shift+W)"""  
        def _close_tab():
            if not GUI_AVAILABLE:
                print("GUI automation not available")
                return False
            try:
                pyautogui.hotkey('ctrl', 'shift', 'w')
                time.sleep(1)
                return True
            except:
                return False
                
        return self._execute_action("close_tab", _close_tab)
        
    def close_warp(self):
        """Close Warp window"""
        def _close():
            try:
                # Try graceful close first
                if GUI_AVAILABLE:
                    pyautogui.hotkey('alt', 'f4')
                    time.sleep(2)
                    
                # Force kill if still running
                if self._verify_warp_running():
                    subprocess.run(['pkill', '-f', 'warp'], check=False)
                    time.sleep(1)
                    
                return not self._verify_warp_running()
            except:
                return False
                
        return self._execute_action("close_warp", _close)
        
    # Test Suite
    def run_basic_test(self):
        """Run basic Warp operations test"""
        print("🧪 Running Basic Warp API Test")
        print("=" * 40)
        
        # Test sequence
        tests = [
            ("Launch Warp", self.launch_warp),
            ("Add Tab", self.new_tab), 
            ("Add Another Tab", self.new_tab),
            ("Close Tab", self.close_tab),
        ]
        
        for test_name, test_func in tests:
            print(f"\n📋 Test: {test_name}")
            test_func()
            time.sleep(1)
            
        self._generate_report()
        
    def _generate_report(self):
        """Generate test session report"""
        if not self.session_actions:
            print("No actions to report")
            return
            
        successful = len([a for a in self.session_actions if a["success"]])
        total = len(self.session_actions)
        success_rate = (successful / total * 100) if total > 0 else 0
        
        report = {
            "session": {
                "timestamp": datetime.now().isoformat(),
                "total_actions": total,
                "successful_actions": successful,
                "failed_actions": total - successful,
                "success_rate": f"{success_rate:.1f}%"
            },
            "actions": self.session_actions
        }
        
        # Save report
        report_file = self.reports_dir / f"warp_test_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
            
        # Print summary
        print("\n" + "=" * 40)
        print("📊 TEST RESULTS SUMMARY")
        print("=" * 40)
        print(f"Total Actions: {total}")
        print(f"Successful: {successful}")
        print(f"Failed: {total - successful}")  
        print(f"Success Rate: {success_rate:.1f}%")
        print(f"Report saved: {report_file}")
        
        return str(report_file)
        
    def show_latest_report(self):
        """Show latest test report"""
        report_files = sorted(self.reports_dir.glob("warp_test_*.json"), 
                            key=lambda x: x.stat().st_mtime, reverse=True)
        
        if not report_files:
            print("No test reports found")
            return
            
        latest_report = report_files[0]
        with open(latest_report) as f:
            report = json.load(f)
            
        session = report["session"]
        print("\n📊 Latest Test Report")
        print("=" * 30)
        print(f"Date: {session['timestamp']}")
        print(f"Total Actions: {session['total_actions']}")
        print(f"Success Rate: {session['success_rate']}")
        
        print("\n📋 Individual Actions:")
        for i, action in enumerate(report["actions"], 1):
            status = "✅" if action["success"] else "❌"
            print(f"  {i}. {status} {action['action']}")
            
def main():
    """CLI interface"""
    parser = argparse.ArgumentParser(description="Warp Terminal Control API")
    parser.add_argument("action", choices=["launch", "new-tab", "close-tab", "close", "test", "report"],
                       help="Action to perform")
    
    args = parser.parse_args()
    api = WarpAPI()
    
    if args.action == "launch":
        api.launch_warp()
    elif args.action == "new-tab":
        api.new_tab()
    elif args.action == "close-tab":
        api.close_tab()
    elif args.action == "close":
        api.close_warp()
    elif args.action == "test":
        api.run_basic_test()
    elif args.action == "report":
        api.show_latest_report()
        
if __name__ == "__main__":
    # Allow help and report without dependencies
    if not GUI_AVAILABLE and len(sys.argv) > 1 and sys.argv[1] not in ["report", "--help", "-h"]:
        print("❌ Missing pyautogui dependency.")
        print("Install with one of:")
        print("  pip install pyautogui                    # If using venv")
        print("  pip install --user pyautogui            # User install")
        print("  sudo apt install python3-pyautogui     # System package")
        sys.exit(1)
    main()
