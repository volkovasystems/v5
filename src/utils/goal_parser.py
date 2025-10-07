#!/usr/bin/env python3
"""
V5 Goal Parser
Parses the structured goal.yaml format for optimal AI understanding
"""

import re
import logging

try:
    import yaml
    YAML_AVAILABLE = True
except ImportError:
    YAML_AVAILABLE = False
    print("Warning: PyYAML not available. Install with: pip install PyYAML")
from pathlib import Path
from typing import Dict, Any, List, Optional
from dataclasses import dataclass

@dataclass
class RepositoryGoal:
    """Structured representation of repository goal"""
    primary: str
    description: str
    success_criteria: List[str]
    constraints: Dict[str, str]
    stakeholders: Dict[str, str]
    scope: Dict[str, str]
    metadata: Dict[str, str]

class GoalParser:
    """Parser for V5 goal.yaml format"""

    def __init__(self, goal_file: Path):
        self.goal_file = goal_file
        self.raw_content = ""
        self.parsed_goal = None
        self.logger = logging.getLogger(f'GoalParser')

    def parse(self) -> Optional[RepositoryGoal]:
        """Parse goal.yaml into structured format"""
        if not self.goal_file.exists():
            return None

        try:
            self.raw_content = self.goal_file.read_text()

            # Clean the content (remove comments and examples)
            clean_content = self._clean_content()

            # Parse YAML-like structure
            parsed_data = self._parse_yaml_like(clean_content)

            if parsed_data:
                self.parsed_goal = RepositoryGoal(
                    primary=parsed_data.get('goal', {}).get('primary', ''),
                    description=(
                        parsed_data.get('goal', {}).get('description', '')
                    ),
                    success_criteria=parsed_data.get('success_criteria', []),
                    constraints=parsed_data.get('constraints', {}),
                    stakeholders=parsed_data.get('stakeholders', {}),
                    scope=parsed_data.get('scope', {}),
                    metadata={
                        'created': parsed_data.get('created', ''),
                        'last_updated': parsed_data.get('last_updated', ''),
                        'version': parsed_data.get('version', '1.0')
                    }
                )

                return self.parsed_goal

        except Exception as e:
            self.logger.error(f"Failed to parse goal.yaml: {e}")
            return None

        return None

    def _clean_content(self) -> str:
        """Remove comments and example sections"""
        lines = self.raw_content.split('\n')
        clean_lines = []
        in_example = False

        for line in lines:
            # Skip example section
            if line.strip().startswith('# Example Configuration:'):
                in_example = True
                continue

            if in_example and line.strip().startswith('# Metadata'):
                in_example = False
                clean_lines.append(line)
                continue

            if in_example:
                continue

            # Skip pure comment lines (but keep YAML comments)
            if line.strip().startswith('#') and ':' not in line:
                continue

            clean_lines.append(line)

        return '\n'.join(clean_lines)

    def _parse_yaml_like(self, content: str) -> Optional[Dict]:
        """Parse YAML-like content"""
        if YAML_AVAILABLE:
            try:
                # Try standard YAML parsing first
                return yaml.safe_load(content)
            except Exception as e:
                self.logger.warning(
                    f"YAML parsing failed: {e}, falling back to manual parsing"
                )
                # Fallback to manual parsing
                return self._manual_yaml_parse(content)
        else:
            # Use manual parsing if PyYAML not available
            return self._manual_yaml_parse(content)

    def _manual_yaml_parse(self, content: str) -> Dict:
        """Manual YAML-like parsing for simple structures"""
        result = {}
        lines = content.split('\n')
        current_key = None
        current_dict = result
        indent_stack = [result]

        for line in lines:
            if not line.strip() or line.strip().startswith('#'):
                continue

            # Calculate indentation
            indent = len(line) - len(line.lstrip())

            # Handle different indent levels
            if ':' in line:
                key, value = line.split(':', 1)
                key = key.strip()
                value = value.strip()

                if indent == 0:
                    current_dict = result
                    indent_stack = [result]
                elif indent == 2:
                    # Sub-key
                    pass

                if value:
                    # Direct value
                    if value.startswith('"') and value.endswith('"'):
                        value = value[1:-1]  # Remove quotes
                    current_dict[key] = value
                else:
                    # Nested structure
                    current_dict[key] = {}
                    current_dict = current_dict[key]
                    current_key = key

            elif line.strip().startswith('- '):
                # List item
                item = line.strip()[2:]  # Remove '- '
                if item.startswith('"') and item.endswith('"'):
                    item = item[1:-1]  # Remove quotes

                if current_key not in result:
                    result[current_key] = []
                result[current_key].append(item)

            elif line.strip().startswith('|'):
                # Multi-line string (simplified)
                if current_key:
                    current_dict[current_key] = line.strip()[1:].strip()

        return result

    def get_summary_for_ai(self) -> str:
        """Get a concise summary optimized for AI consumption"""
        if not self.parsed_goal:
            return "No repository goal defined"

        summary_parts = []

        # Primary goal
        if self.parsed_goal.primary:
            summary_parts.append(f"PRIMARY GOAL: {self.parsed_goal.primary}")

        # Description
        if self.parsed_goal.description:
            summary_parts.append(
                f"DESCRIPTION: {self.parsed_goal.description.strip()}"
            )

        # Success criteria
        if self.parsed_goal.success_criteria:
            criteria = " | ".join(self.parsed_goal.success_criteria)
            summary_parts.append(f"SUCCESS CRITERIA: {criteria}")

        # Key constraints
        if self.parsed_goal.constraints:
            constraints = []
            for key, value in self.parsed_goal.constraints.items():
                constraints.append(f"{key.upper()}: {value}")
            summary_parts.append(f"CONSTRAINTS: {' | '.join(constraints)}")

        # Scope exclusions (important for preventing scope creep)
        if self.parsed_goal.scope.get('excluded'):
            summary_parts.append(
                f"EXCLUDED: {self.parsed_goal.scope['excluded']}"
            )

        return " || ".join(summary_parts)

    def get_focus_keywords(self) -> List[str]:
        """Extract key focus words for pattern matching"""
        keywords = []

        if not self.parsed_goal:
            return keywords

        # Extract from primary goal
        if self.parsed_goal.primary:
            keywords.extend(self._extract_keywords(self.parsed_goal.primary))

        # Extract from constraints
        for constraint in self.parsed_goal.constraints.values():
            keywords.extend(self._extract_keywords(constraint))

        # Remove duplicates and common words
        stop_words = {
            'the', 'a', 'an', 'and', 'or', 'but', 'in',
            'on', 'at', 'to', 'for', 'of', 'with', 'by'
        }
        keywords = [
            k.lower() for k in keywords
            if k.lower() not in stop_words and len(k) > 2
        ]

        return list(set(keywords))

    def _extract_keywords(self, text: str) -> List[str]:
        """Extract meaningful keywords from text"""
        # Simple keyword extraction
        words = re.findall(r'\b[a-zA-Z]+\b', text)
        # Words longer than 3 characters
        return [w for w in words if len(w) > 3]

    def validate_goal_alignment(
        self, user_request: str
    ) -> Dict[str, Any]:
        """Check if a user request aligns with the repository goal"""
        if not self.parsed_goal:
            return {'aligned': True, 'confidence': 0.0, 'reason': 'No goal defined'}

        focus_keywords = self.get_focus_keywords()
        request_words = self._extract_keywords(user_request.lower())

        # Simple keyword matching
        matches = len(set(focus_keywords) & set(request_words))
        total_keywords = len(focus_keywords)

        if total_keywords == 0:
            confidence = 0.5  # Neutral when no keywords
        else:
            confidence = matches / total_keywords

        # Check against excluded scope
        excluded_text = self.parsed_goal.scope.get('excluded', '').lower()
        if excluded_text and any(word in excluded_text for word in request_words):
            return {
                'aligned': False,
                'confidence': 0.9,
                'reason': f'Request may fall under excluded scope: {excluded_text}'
            }

        # Alignment decision
        aligned = confidence > 0.3  # Threshold for alignment
        reason = f"Keyword match: {matches}/{total_keywords} ({confidence:.1%})"

        return {
            'aligned': aligned,
            'confidence': confidence,
            'reason': reason,
            'matching_keywords': list(set(focus_keywords) & set(request_words))
        }

# Convenience functions
def parse_goal_file(goal_file_path: Path) -> Optional[RepositoryGoal]:
    """Parse a goal file and return structured goal"""
    parser = GoalParser(goal_file_path)
    return parser.parse()

def get_goal_summary_for_ai(goal_file_path: Path) -> str:
    """Get AI-optimized goal summary"""
    parser = GoalParser(goal_file_path)
    goal = parser.parse()
    if goal:
        return parser.get_summary_for_ai()
    return "Repository goal not defined or could not be parsed"

def check_request_alignment(goal_file_path: Path, user_request: str) -> Dict[str, Any]:
    """Check if user request aligns with repository goal"""
    parser = GoalParser(goal_file_path)
    goal = parser.parse()
    if goal:
        return parser.validate_goal_alignment(user_request)
    return {'aligned': True, 'confidence': 0.0, 'reason': 'No goal to check against'}
