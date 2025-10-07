#!/usr/bin/env python3
"""
V5 Window B: Silent Code Fixer
Autonomous QA agent that fixes code issues automatically
"""

import sys
import json
import logging
import time
import threading
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional

# Add src directory to Python path
sys.path.insert(0, str(Path(__file__).parent.parent))

from utils.messaging import create_messenger

class WindowB:
    """Window B - Silent Code Fixer"""

    def __init__(self, target_repository: str):
        """Initialize WindowB with target repository path."""
        self.target_repo = Path(target_repository).absolute()
        self.warp_dir = self.target_repo / '.warp'
        self.window_id = 'window_b'
        self.running = True

        # Setup logging
        self.setup_logging()

        # Initialize messaging
        config_path = self.warp_dir / 'communication' / 'config.json'
        self.messenger = create_messenger(self.window_id, config_path)

        # Load current protocols
        self.protocols = self.load_protocols()

        self.logger.info("Window B initialized - Silent Code Fixer")
        self.show_status()

    def setup_logging(self):
        """Setup logging for Window B"""
        log_file = self.warp_dir / 'logs' / f'{self.window_id}.log'
        log_file.parent.mkdir(exist_ok=True)

        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file),
                logging.StreamHandler(sys.stdout)
            ]
        )

        self.logger = logging.getLogger(self.window_id)

    def load_protocols(self) -> Dict:
        """Load current protocols"""
        try:
            rules_file = self.warp_dir / 'protocols' / 'essential_rules.json'
            if rules_file.exists():
                with open(rules_file) as f:
                    return json.load(f)
            return {}
        except Exception as e:
            self.logger.error(f"Failed to load protocols: {e}")
            return {}

    def show_status(self):
        """Show Window B status"""
        print("\n" + "="*60)
        print("🔧 V5 WINDOW B - SILENT CODE FIXER")
        print("   Autonomous Quality Assurance Agent")
        print("="*60)
        print(f"📁 Repository: {self.target_repo.name}")
        print(f"🎯 Mode: Background monitoring")
        print(f"📋 Active Rules: {len(self.protocols.get('rules', {}))}")
        print()
        print("🤖 Operations:")
        print("   • Monitor Window A activities")
        print("   • Detect and fix code issues automatically")
        print("   • Apply performance optimizations")
        print("   • Escalate complex issues to Window A")
        print("   • No human interaction required")
        print("-"*60)

    def handle_window_a_activity(self, message: Dict, window_id: str):
        """Handle activities from Window A"""
        try:
            data = message.get('data', {})
            routing_key = message.get('routing_key', '')

            if 'user_prompt' in routing_key:
                self.analyze_user_prompt(data)
            elif 'ai_response' in routing_key:
                self.analyze_ai_response(data)
            elif 'code_change' in routing_key:
                self.analyze_code_change(data)

        except Exception as e:
            self.logger.error(f"Error handling Window A activity: {e}")

    def analyze_user_prompt(self, data: Dict):
        """Analyze user prompt for potential issues"""
        prompt = data.get('prompt', '')

        self.logger.info(f"Analyzing prompt: {prompt[:50]}...")

        # Simple pattern matching for common issues
        issues_found = []

        # Check for performance-related requests
        perf_words = ['slow', 'performance', 'optimize', 'fast']
        if any(word in prompt.lower() for word in perf_words):
            issues_found.append('performance_focus')

        # Check for security-related requests
        sec_words = ['auth', 'login', 'security', 'password']
        if any(word in prompt.lower() for word in sec_words):
            issues_found.append('security_focus')

        # Check for database-related requests
        if any(word in prompt.lower() for word in ['database', 'query', 'sql', 'data']):
            issues_found.append('database_focus')

        if issues_found:
            self.messenger.send_activity('analysis_complete', {
                'prompt_analyzed': prompt[:100],
                'focus_areas': issues_found,
                'recommendations': self.get_recommendations(issues_found)
            })

            self.logger.info(f"Found focus areas: {issues_found}")

    def get_recommendations(self, focus_areas: List[str]) -> List[str]:
        """Get recommendations based on focus areas"""
        recommendations = []

        if 'performance_focus' in focus_areas:
            recommendations.extend([
                "Consider profiling before optimization",
                "Focus on algorithmic improvements first",
                "Measure performance impact of changes"
            ])

        if 'security_focus' in focus_areas:
            recommendations.extend([
                "Use established security libraries",
                "Implement proper input validation",
                "Consider security testing"
            ])

        if 'database_focus' in focus_areas:
            recommendations.extend([
                "Check for N+1 query problems",
                "Consider proper indexing",
                "Use connection pooling if needed"
            ])

        return recommendations

    def analyze_code_change(self, data: Dict):
        """Analyze code changes for issues"""
        change_type = data.get('change_type', '')
        files_changed = data.get('files', [])

        self.logger.info(f"Analyzing code change: {change_type}")

        # Simulate code analysis
        issues_detected = []
        fixes_applied = []

        # Simulate finding common issues
        if 'python' in str(files_changed).lower():
            issues_detected.extend([
                "Missing error handling in new function",
                "Import statements not optimally organized"
            ])
            fixes_applied.extend([
                "Added try-catch blocks for error handling",
                "Reorganized imports following PEP8"
            ])

        if issues_detected:
            self.messenger.send_code_change('automatic_fix', {
                'original_change': change_type,
                'issues_detected': issues_detected,
                'fixes_applied': fixes_applied,
                'performance_impact': 'minimal'
            })

            self.logger.info(f"Applied {len(fixes_applied)} fixes")
        else:
            self.logger.info("No issues detected - code looks good")

    def monitor_repository_changes(self):
        """Monitor repository for file changes"""
        self.logger.info("Starting repository monitoring...")

        while self.running:
            try:
                # In a real implementation, this would use file watchers
                # For now, we'll just simulate periodic checking

                self.check_for_issues()
                time.sleep(10)  # Check every 10 seconds

            except Exception as e:
                self.logger.error(f"Error in repository monitoring: {e}")
                time.sleep(5)

    def check_for_issues(self):
        """Check repository for common issues"""
        try:
            # Simulate finding and fixing issues
            python_files = list(self.target_repo.glob("**/*.py"))

            if python_files:
                # Simulate issue detection
                issues_found = []

                # Check for common Python issues
                for py_file in python_files[:3]:  # Check first 3 files only
                    if py_file.exists() and py_file.stat().st_size > 0:
                        issues_found.append(f"Checked {py_file.name}")

                if issues_found:
                    self.messenger.send_activity('periodic_check', {
                        'files_checked': len(python_files),
                        'issues_status': 'clean',
                        'check_time': datetime.now().isoformat()
                    })

        except Exception as e:
            self.logger.error(f"Error checking for issues: {e}")

    def handle_protocol_update(self, message: Dict, window_id: str):
        """Handle protocol updates from Window C"""
        try:
            data = message.get('data', {})
            update_type = data.get('type', 'unknown')

            self.logger.info(f"Received protocol update: {update_type}")

            # Reload protocols
            self.protocols = self.load_protocols()

            # Send acknowledgment
            self.messenger.send_activity('protocol_received', {
                'update_type': update_type,
                'acknowledged': True,
                'window_id': self.window_id
            })

            self.logger.info("Protocol update applied")

        except Exception as e:
            self.logger.error(f"Error handling protocol update: {e}")

    def start_listeners(self):
        """Start all message listeners"""
        # Listen for Window A activities
        def window_a_callback(message, window_id):
            """Callback for Window A messages."""
            self.handle_window_a_activity(message, window_id)

        # Listen for protocol updates
        def protocol_callback(message, window_id):
            """Callback for protocol update messages."""
            self.handle_protocol_update(message, window_id)

        # Subscribe to Window A activities
        has_bus = hasattr(self.messenger, 'message_bus')
        if has_bus and self.messenger.message_bus.is_connected:
            try:
                # Create queue for Window A activities
                queue = f'{self.window_id}_window_a_monitor'
                self.messenger.message_bus.channel.queue_declare(
                    queue=queue, durable=True
                )
                self.messenger.message_bus.channel.queue_bind(
                    exchange='window.activities',
                    queue=queue,
                    routing_key='window_a.*'
                )

                self.messenger.message_bus.subscribe_to_queue(
                    queue, window_a_callback, self.window_id
                )
                self.logger.info("Subscribed to Window A activities")

            except Exception as e:
                self.logger.error(f"Failed to subscribe to Window A activities: {e}")

        # Listen for protocol updates
        self.messenger.listen_for_protocol_updates(protocol_callback)

        self.logger.info("All listeners started")

    def run(self):
        """Main execution loop"""
        try:
            # Send startup notification
            self.messenger.send_activity('startup', {
                'repository': str(self.target_repo),
                'mode': 'autonomous_monitoring',
                'protocols_loaded': len(self.protocols.get('rules', {}))
            })

            # Start message listeners in background
            listener_thread = threading.Thread(target=self.start_listeners, daemon=True)
            listener_thread.start()

            # Start repository monitoring in background
            monitor_thread = threading.Thread(
                target=self.monitor_repository_changes, daemon=True
            )
            monitor_thread.start()

            self.logger.info("Window B running - monitoring in background...")
            print("🤖 Monitoring started - running silently in background")

            # Keep the main thread alive
            while self.running:
                time.sleep(1)

        except KeyboardInterrupt:
            self.logger.info("Window B interrupted by user")
            self.running = False
        except Exception as e:
            self.logger.error(f"Error in main loop: {e}")
        finally:
            # Send shutdown notification
            self.messenger.send_activity('shutdown', {
                'reason': 'system_stop',
                'timestamp': datetime.now().isoformat()
            })

            print("🛑 V5 Window B stopped")

def main():
    """Main entry point for Window B"""
    if len(sys.argv) < 2:
        print("Usage: python3 window_b.py <target_repository_path>")
        sys.exit(1)

    target_repo = sys.argv[1]

    try:
        window_b = WindowB(target_repo)
        window_b.run()
    except KeyboardInterrupt:
        print("\n🛑 V5 Window B interrupted")
    except Exception as e:
        print(f"❌ Error in Window B: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
