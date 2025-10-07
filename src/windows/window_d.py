#!/usr/bin/env python3
"""
V5 Window D: Governance QA Auditor
Audits Window C's decisions and ensures industry standards
"""

import sys
import time
import logging
from pathlib import Path

# Add src directory to Python path
sys.path.insert(0, str(Path(__file__).parent.parent))

from utils.messaging import create_messenger

# Configuration constants
MAIN_LOOP_INTERVAL = 1  # seconds for main loop sleep

class WindowD:
    """Window D - Governance QA Auditor"""

    def __init__(self, target_repository: str):
        """Initialize WindowD with target repository path."""
        self.target_repo = Path(target_repository).absolute()
        self.warp_dir = self.target_repo / '.warp'
        self.window_id = 'window_d'
        self.running = True

        # Setup logging
        self.setup_logging()

        # Initialize messaging
        config_path = self.warp_dir / 'communication' / 'config.json'
        self.messenger = create_messenger(self.window_id, config_path)

        self.logger.info("Window D initialized - Governance QA Auditor")
        self.show_status()

    def setup_logging(self):
        """Setup logging for Window D"""
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

    def show_status(self):
        """Show Window D status"""
        print("\n" + "="*60)
        print("⚖️ V5 WINDOW D - GOVERNANCE QA AUDITOR")
        print("   Industry Standards Guardian")
        print("="*60)
        print(f"📁 Repository: {self.target_repo.name}")
        print(f"🎯 Mode: Window C Oversight")
        print()
        print("🔍 Operations:")
        print("   • Monitor Window C decisions")
        print("   • Apply industry best practices")
        print("   • Review protocol quality")
        print("   • Instruct Window C on fixes")
        print("   • No direct file modifications")
        print("-"*60)

    def run(self):
        """Main execution loop"""
        try:
            self.messenger.send_activity('startup', {
                'repository': str(self.target_repo),
                'mode': 'governance_auditing'
            })

            self.logger.info("Window D running - auditing governance...")
            print("⚖️ Governance auditing started - monitoring Window C")

            # Keep running
            while self.running:
                time.sleep(MAIN_LOOP_INTERVAL)

        except KeyboardInterrupt:
            self.running = False
        finally:
            print("🛑 V5 Window D stopped")

def main():
    """Main entry point for Window D."""
    if len(sys.argv) < 2:
        print("Usage: python3 window_d.py <target_repository_path>")
        sys.exit(1)

    try:
        window_d = WindowD(sys.argv[1])
        window_d.run()
    except KeyboardInterrupt:
        print("\n🛑 V5 Window D interrupted")

if __name__ == '__main__':
    main()
