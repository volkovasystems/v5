#!/usr/bin/env python3
"""
V5 Window A: Human Interactive Development Hub
The only window where humans interact with the V5 tool
"""

import os
import sys
import json
import logging
import threading
from pathlib import Path
from datetime import datetime
from typing import Dict, Any

# Add src directory to Python path
sys.path.insert(0, str(Path(__file__).parent.parent))

from utils.messaging import create_messenger
from utils.goal_parser import (
    GoalParser, check_request_alignment
)

class WindowA:
    """Window A - Human Interactive Development Hub"""

    def __init__(self, target_repository: str):
        """Initialize WindowA with target repository path."""
        self.target_repo = Path(target_repository).absolute()
        self.warp_dir = self.target_repo / '.warp'
        self.window_id = 'window_a'

        # Setup logging
        self.setup_logging()

        # Initialize messaging
        config_path = self.warp_dir / 'communication' / 'config.json'
        self.messenger = create_messenger(self.window_id, config_path)

        # Load current protocols
        self.protocols = self.load_protocols()

        # Repository goal
        self.goal = self.load_repository_goal()

        self.logger.info(
            "Window A initialized - Human Interactive Development Hub"
        )
        self.show_welcome()

    def setup_logging(self):
        """Setup logging for Window A"""
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
        """Load current protocols from .warp directory"""
        try:
            rules_file = self.warp_dir / 'protocols' / 'essential_rules.json'
            if rules_file.exists():
                with open(rules_file) as f:
                    return json.load(f)
            return {}
        except Exception as e:
            self.logger.error(f"Failed to load protocols: {e}")
            return {}

    def load_repository_goal(self) -> str:
        """Load repository goal using structured parser"""
        try:
            goal_file = self.warp_dir / 'goal.yaml'
            if goal_file.exists():
                # Use the structured parser (V5 format only)
                parser = GoalParser(goal_file)
                parsed_goal = parser.parse()

                if parsed_goal and parsed_goal.primary:
                    return parsed_goal.primary
                else:
                    return (
                    "Invalid goal.yaml format - please use V5 structured format"
                    )

            return (
                "Define your repository goal in .warp/goal.yaml using V5 format"
            )
        except Exception as e:
            self.logger.error(f"Failed to load repository goal: {e}")
            return "Repository goal format invalid - use V5 structured format"

    def show_welcome(self):
        """Show welcome message with current context"""
        print("\n" + "="*60)
        print("🚀 V5 DEVELOPMENT TOOL - WINDOW A")
        print("   Human Interactive Development Hub")
        print("="*60)
        print(f"📁 Repository: {self.target_repo.name}")
        print(f"🎯 Goal: {self.goal}")
        print()

        if self.protocols.get('rules'):
            print("📋 Current Rules:")
            for key, rule in self.protocols['rules'].items():
                print(f"   • {rule}")
            print()

        print("💡 This is your interactive workspace.")
        print("   - All your prompts and development work happen here")
        print("   - Windows B, C, D, E work silently in the background")
        print("   - Type 'help' for available commands")
        print("   - Type 'exit' to stop the V5 tool")
        print("-"*60)

    def handle_protocol_update(self, message: Dict, window_id: str):
        """Handle protocol updates from Window C"""
        try:
            data = message.get('data', {})
            update_type = data.get('type', 'unknown')

            print(f"\n🔄 PROTOCOL UPDATE: {update_type}")
            print(f"   {data.get('description', 'Protocol updated')}")

            if data.get('new_rule'):
                print(f"   New Rule: {data['new_rule']}")

            # Reload protocols
            self.protocols = self.load_protocols()

            # Send acknowledgment
            self.messenger.send_activity('protocol_received', {
                'update_type': update_type,
                'acknowledged': True,
                'timestamp': datetime.now().isoformat()
            })

            print("   ✅ Applied to current session")
            print("-"*60)

        except Exception as e:
            self.logger.error(f"Error handling protocol update: {e}")

    def start_protocol_listener(self):
        """Start listening for protocol updates from Window C"""
        def protocol_callback(message, window_id):
            """Callback for protocol update messages."""
            self.handle_protocol_update(message, window_id)

        self.messenger.listen_for_protocol_updates(protocol_callback)

    def send_user_prompt(self, prompt: str):
        """Send user prompt activity to the system"""
        self.messenger.send_activity('user_prompt', {
            'prompt': prompt,
            'repository_goal': self.goal,
            'timestamp': datetime.now().isoformat(),
            'working_directory': str(os.getcwd())
        })

    def send_code_change(self, change_type: str, details: Dict):
        """Send code change notification"""
        self.messenger.send_code_change(change_type, {
            **details,
            'timestamp': datetime.now().isoformat(),
            'repository_goal': self.goal
        })

    def process_command(self, user_input: str):
        """Process user commands and prompts"""
        user_input = user_input.strip()

        if not user_input:
            return True

        # Handle tool commands
        if user_input.lower() in ['exit', 'quit', 'stop']:
            return False

        elif user_input.lower() == 'help':
            self.show_help()

        elif user_input.lower() == 'status':
            self.show_status()

        elif user_input.lower() == 'goal':
            self.show_goal()

        elif user_input.lower() == 'rules':
            self.show_rules()

        elif user_input.startswith('goal '):
            # Update repository goal
            new_goal = user_input[5:].strip()
            self.update_goal(new_goal)

        else:
            # Regular development prompt - check goal alignment first
            goal_file = self.warp_dir / 'goal.yaml'
            alignment = check_request_alignment(goal_file, user_input)

            if not alignment['aligned'] and alignment['confidence'] > 0.7:
                print(f"\n⚠️  Goal Alignment Warning:")
                print(f"   {alignment['reason']}")
                print(f"   Consider if this aligns with: {self.goal}")
                response = input("   Continue anyway? (y/N): ").strip().lower()
                if response not in ['y', 'yes']:
                    print("   Request cancelled.")
                    return True
            elif alignment['aligned'] and alignment['confidence'] > 0.5:
                matching = alignment.get('matching_keywords', [])
                if matching:
                    keywords_str = ', '.join(matching[:3])
                    print(f"✅ Goal-aligned request (keywords: {keywords_str})")

            # Send to tool
            self.send_user_prompt(user_input)
            truncated = user_input[:50] + ('...' if len(user_input) > 50 else '')
            print(f"✅ Processing: {truncated}")

            # Simulate AI response (in real implementation, this would be actual AI)
            self.simulate_ai_response(user_input)

        return True

    def simulate_ai_response(self, prompt: str):
        """Simulate AI response (placeholder for actual AI integration)"""
        print("\n🤖 AI Assistant Response:")
        print("   [This is where the AI would respond to your prompt]")
        print("   [Following current protocols and repository goal]")

        # Send activity about AI response
        self.messenger.send_activity('ai_response', {
            'original_prompt': prompt,
            'response_type': 'simulated',
            'follows_protocols': True
        })

    def show_help(self):
        """Show available commands"""
        print("\n📖 V5 WINDOW A COMMANDS:")
        print("   help     - Show this help message")
        print("   status   - Show tool status")
        print("   goal     - Show current repository goal")
        print("   rules    - Show current protocols/rules")
        print("   goal <text> - Update repository goal")
        print("   exit     - Stop the V5 tool")
        print("\n💡 For development:")
        print("   - Type any development request or question")
        print("   - Example: 'Add user authentication'")
        print("   - Example: 'Fix the bug in login function'")
        print("   - Example: 'Optimize database queries'")

    def show_status(self):
        """Show current tool status"""
        print(f"\n📊 V5 TOOL STATUS:")
        print(f"   Repository: {self.target_repo}")
        print(f"   Goal: {self.goal}")
        print(f"   Active Rules: {len(self.protocols.get('rules', {}))}")
        messaging_status = (
            'Connected' if hasattr(self.messenger, 'message_bus') else 'Offline'
        )
        print(f"   Messaging: {messaging_status}")

        # Check if other windows are running
        pid_file = self.warp_dir / 'communication' / 'pids.json'
        if pid_file.exists():
            try:
                with open(pid_file) as f:
                    pids = json.load(f)
                print(f"   Running Windows: {list(pids.keys())}")
            except Exception as e:
                self.logger.warning(f"Error reading PID file: {e}")
                print("   Running Windows: Unknown")
        else:
            print("   Running Windows: PID file not found")

    def show_goal(self):
        """Show current repository goal"""
        print(f"\n🎯 REPOSITORY GOAL:")
        print(f"   {self.goal}")

        goal_file = self.warp_dir / 'goal.yaml'
        if goal_file.exists():
            print(f"\n   📄 Full goal description in: {goal_file}")

    def show_rules(self):
        """Show current protocols/rules"""
        print(f"\n📋 CURRENT PROTOCOLS:")

        if not self.protocols.get('rules'):
            print("   No specific rules defined yet")
            return

        for key, rule in self.protocols['rules'].items():
            print(f"   • {key}: {rule}")

        print(f"\n   📄 Full protocols in: {self.warp_dir}/protocols/")
        print(f"   🔄 Rules updated automatically by Window C")

    def update_goal(self, new_goal: str):
        """Update repository goal"""
        try:
            goal_file = self.warp_dir / 'goal.yaml'

            # Read current content
            if goal_file.exists():
                content = goal_file.read_text()
            else:
                content = ""

            # Update YAML format goal - parse and update properly
            try:
                import yaml
                if content.strip():
                    data = yaml.safe_load(content)
                else:
                    data = {}

                # Update goal primary field
                if 'goal' not in data:
                    data['goal'] = {}
                data['goal']['primary'] = new_goal
                data['last_updated'] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

                # Write back as YAML
                updated_content = yaml.dump(
                    data, default_flow_style=False, allow_unicode=True
                )
                goal_file.write_text(updated_content)

            except ImportError:
                # Fallback to simple text update if PyYAML not available
                lines = content.split('\n')
                updated = False

                for i, line in enumerate(lines):
                    if line.strip().startswith('primary:'):
                        lines[i] = f'  primary: "{new_goal}"'
                        updated = True
                        break

                if not updated:
                    lines.insert(0, 'goal:')
                    lines.insert(1, f'  primary: "{new_goal}"')
                    lines.insert(2, '')

                timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                lines.append(f'last_updated: "{timestamp}"')
                goal_file.write_text('\n'.join(lines))

            self.goal = new_goal
            print(f"✅ Goal updated: {new_goal}")

            # Send activity about goal update
            self.messenger.send_activity('goal_updated', {
                'new_goal': new_goal,
                'updated_by': 'human_user',
                'timestamp': datetime.now().isoformat()
            })

        except Exception as e:
            self.logger.error(f"Failed to update goal: {e}")
            print(f"❌ Failed to update goal: {e}")

    def run(self):
        """Main interaction loop"""
        try:
            # Start protocol listener in background
            protocol_thread = threading.Thread(
                target=self.start_protocol_listener,
                daemon=True
            )
            protocol_thread.start()

            # Send startup activity
            self.messenger.send_activity('startup', {
                'repository': str(self.target_repo),
                'goal': self.goal,
                'protocols_loaded': len(self.protocols.get('rules', {}))
            })

            # Main interaction loop
            print("\n💬 Ready for your input...")

            while True:
                try:
                    user_input = input("\n👤 You: ").strip()

                    if not self.process_command(user_input):
                        break

                except KeyboardInterrupt:
                    print("\n\n🛑 Stopping V5 tool...")
                    break
                except EOFError:
                    break

        except Exception as e:
            self.logger.error(f"Error in main loop: {e}")

        finally:
            # Send shutdown activity
            self.messenger.send_activity('shutdown', {
                'reason': 'user_request',
                'timestamp': datetime.now().isoformat()
            })

            print("\n👋 V5 Window A stopped")

def main():
    """Main entry point for Window A"""
    if len(sys.argv) < 2:
        print("Usage: python3 window_a.py <target_repository_path>")
        sys.exit(1)

    target_repo = sys.argv[1]

    try:
        window_a = WindowA(target_repo)
        window_a.run()
    except KeyboardInterrupt:
        print("\n🛑 V5 Window A interrupted")
    except Exception as e:
        print(f"❌ Error in Window A: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
