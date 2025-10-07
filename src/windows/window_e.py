#!/usr/bin/env python3
"""
V5 Window E: Feature Insight Documentarian
Monitors all windows and suggests optimal future features
"""

import sys
import time
import logging
from pathlib import Path

# Add src directory to Python path
sys.path.insert(0, str(Path(__file__).parent.parent))

from utils.messaging import create_messenger

class WindowE:
    """Window E - Feature Insight Documentarian"""

    def __init__(self, target_repository: str):
        self.target_repo = Path(target_repository).absolute()
        self.warp_dir = self.target_repo / '.warp'
        self.window_id = 'window_e'
        self.running = True

        # Setup logging
        self.setup_logging()

        # Initialize messaging
        config_path = self.warp_dir / 'communication' / 'config.json'
        self.messenger = create_messenger(self.window_id, config_path)

        # Ensure features directory exists
        self.features_dir = self.target_repo / 'features'
        self.features_dir.mkdir(exist_ok=True)

        self.logger.info("Window E initialized - Feature Insight Documentarian")
        self.show_status()

    def setup_logging(self):
        """Setup logging for Window E"""
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
        """Show Window E status"""
        print("\n" + "="*60)
        print("💡 V5 WINDOW E - FEATURE INSIGHT DOCUMENTARIAN")
        print("   Strategic Feature Intelligence")
        print("="*60)
        print(f"📁 Repository: {self.target_repo.name}")
        print(f"🎯 Mode: System-wide Observer")
        print(f"📄 Features Dir: {self.features_dir}")
        print()
        print("🔮 Operations:")
        print("   • Monitor all windows independently")
        print("   • Detect feature opportunities")
        print("   • Generate feature documentation")
        print("   • Provide pros/cons analysis")
        print("   • Strategic development insights")
        print("-"*60)

    def run(self):
        """Main execution loop"""
        try:
            self.messenger.send_activity('startup', {
                'repository': str(self.target_repo),
                'mode': 'feature_intelligence',
                'features_directory': str(self.features_dir)
            })

            self.logger.info("Window E running - generating feature insights...")
            print("💡 Feature intelligence started - observing all windows")

            # Keep running
            while self.running:
                time.sleep(1)

        except KeyboardInterrupt:
            self.running = False
        finally:
            print("🛑 V5 Window E stopped")

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 window_e.py <target_repository_path>")
        sys.exit(1)

    try:
        window_e = WindowE(sys.argv[1])
        window_e.run()
    except KeyboardInterrupt:
        print("\n🛑 V5 Window E interrupted")

if __name__ == '__main__':
    main()
