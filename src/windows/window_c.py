#!/usr/bin/env python3
"""
V5 Window C: Pattern Learning Governor
Monitors A & B interactions and creates/updates protocols
"""

import sys
import json
import logging
import time
from pathlib import Path
from datetime import datetime

# Add src directory to Python path
sys.path.insert(0, str(Path(__file__).parent.parent))

from utils.messaging import create_messenger

# Configuration constants
MAIN_LOOP_INTERVAL = 1  # seconds for main loop sleep

class WindowC:
    """Window C - Pattern Learning Governor"""

    def __init__(self, target_repository: str):
        """Initialize WindowC with target repository path."""
        self.target_repo = Path(target_repository).absolute()
        self.warp_dir = self.target_repo / '.warp'
        self.window_id = 'window_c'
        self.running = True

        # Setup logging
        self.setup_logging()

        # Initialize messaging
        config_path = self.warp_dir / 'communication' / 'config.json'
        self.messenger = create_messenger(self.window_id, config_path)

        # Pattern tracking
        self.patterns = {}
        self.rule_count = 0

        self.logger.info("Window C initialized - Pattern Learning Governor")
        self.show_status()

    def setup_logging(self):
        """Setup logging for Window C"""
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
        """Show Window C status"""
        print("\n" + "="*60)
        print("📊 V5 WINDOW C - PATTERN LEARNING GOVERNOR")
        print("   Protocol & Rules Manager")
        print("="*60)
        print(f"📁 Repository: {self.target_repo.name}")
        print(f"🎯 Mode: A↔B Interaction Observer")
        print(f"📋 Current Rules: {self.rule_count}")
        print()
        print("🧠 Operations:")
        print("   • Monitor Window A and B activities")
        print("   • Detect development patterns")
        print("   • Create and update protocols")
        print("   • Exclusive .warp directory access")
        print("   • Notify A & B of rule changes")
        print("-"*60)

    def run(self):
        """Main execution loop"""
        try:
            self.messenger.send_activity('startup', {
                'repository': str(self.target_repo),
                'mode': 'pattern_learning'
            })

            self.logger.info("Window C running - learning patterns...")
            print("🧠 Pattern learning started - monitoring A↔B interactions")

            # Keep running
            while self.running:
                time.sleep(MAIN_LOOP_INTERVAL)

        except KeyboardInterrupt:
            self.running = False
        finally:
            print("🛑 V5 Window C stopped")

def main():
    """Main entry point for Window C."""
    if len(sys.argv) < 2:
        print("Usage: python3 window_c.py <target_repository_path>")
        sys.exit(1)

    try:
        window_c = WindowC(sys.argv[1])
        window_c.run()
    except KeyboardInterrupt:
        print("\n🛑 V5 Window C interrupted")

if __name__ == '__main__':
    main()
