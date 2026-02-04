#!/usr/bin/env python3
"""
LLM-based grader for CHAOS agent evaluations.

Uses Claude Code CLI to evaluate agent outputs against rubrics.
No API key required - uses existing Claude Code subscription.

Usage:
    python judge.py --rubric plan-quality.yml --output agent_output.txt
    python judge.py --rubric spec-review-quality.yml --output review.txt --model sonnet
    python judge.py --rubric plan-quality.yml --output agent_output.txt --mock  # For testing
"""

import argparse
import json
import subprocess
import sys
import yaml
from pathlib import Path
from typing import Optional


def load_rubric(rubric_path: Path) -> dict:
    """Load a rubric YAML file."""
    with open(rubric_path) as f:
        return yaml.safe_load(f)


def load_output(output_path: Path) -> str:
    """Load agent output to be graded."""
    with open(output_path) as f:
        return f.read()


def build_judge_prompt(rubric: dict, output: str, spec: Optional[str] = None) -> str:
    """Build the prompt for the LLM judge."""
    criteria_text = "\n".join([
        f"- **{c['name']}** (weight: {c['weight']}): {c['description']}\n"
        f"  Scale: {json.dumps(c['scale'], indent=2)}"
        for c in rubric['criteria']
    ])

    spec_context = f"\n\nOriginal Spec:\n{spec}" if spec else ""

    return f"""{rubric['system_prompt']}

## Criteria to Evaluate

{criteria_text}

## Output Format

Return ONLY valid JSON matching this structure (no markdown, no explanation outside JSON):
{rubric['output_format']}

## Agent Output to Grade
{spec_context}

```
{output}
```

Evaluate this output against each criterion. Return ONLY the JSON object."""


def call_llm_judge_cli(prompt: str, model: str = "sonnet") -> dict:
    """
    Call Claude Code CLI to grade the output.

    Uses: claude -p "prompt" --model <model> --output-format json
    """
    # Map friendly names to Claude model flags
    model_map = {
        "haiku": "haiku",
        "sonnet": "sonnet",
        "opus": "opus"
    }
    model_flag = model_map.get(model, "sonnet")

    try:
        # Call Claude Code CLI in print mode
        result = subprocess.run(
            [
                "claude",
                "-p", prompt,
                "--model", model_flag,
                "--output-format", "text"  # We'll parse JSON from text
            ],
            capture_output=True,
            text=True,
            timeout=120  # 2 minute timeout for evaluation
        )

        if result.returncode != 0:
            print(f"CLI Error: {result.stderr}", file=sys.stderr)
            raise RuntimeError(f"Claude CLI failed: {result.stderr}")

        response_text = result.stdout.strip()

        # Extract JSON from response (handle potential markdown wrapping)
        json_text = response_text
        if "```json" in response_text:
            json_text = response_text.split("```json")[1].split("```")[0].strip()
        elif "```" in response_text:
            json_text = response_text.split("```")[1].split("```")[0].strip()

        return json.loads(json_text)

    except subprocess.TimeoutExpired:
        raise RuntimeError("Claude CLI timed out after 120 seconds")
    except json.JSONDecodeError as e:
        print(f"Failed to parse JSON from response: {response_text}", file=sys.stderr)
        raise RuntimeError(f"Invalid JSON in Claude response: {e}")


def call_llm_judge_mock(prompt: str, model: str = "sonnet") -> dict:
    """Return mock response for testing the harness without CLI calls."""
    return {
        "scores": {
            "specificity": 4,
            "ordering": 4,
            "scope": 5,
            "completeness": 4
        },
        "weighted_average": 4.25,
        "pass": True,
        "reasoning": "MOCK MODE: Skipped actual evaluation. Use --no-mock for real grading."
    }


def calculate_weighted_score(scores: dict, criteria: list) -> float:
    """Calculate weighted average from individual scores."""
    total_weight = sum(c['weight'] for c in criteria)
    weighted_sum = sum(
        scores.get(c['name'], 0) * c['weight']
        for c in criteria
    )
    return weighted_sum / total_weight


def grade_output(
    rubric_path: Path,
    output_path: Path,
    spec_path: Optional[Path] = None,
    model: str = "sonnet",
    mock: bool = False
) -> dict:
    """Grade an agent output against a rubric using Claude Code CLI."""
    rubric = load_rubric(rubric_path)
    output = load_output(output_path)
    spec = load_output(spec_path) if spec_path else None

    prompt = build_judge_prompt(rubric, output, spec)

    # Choose mock or real CLI based on flag
    if mock:
        result = call_llm_judge_mock(prompt, model)
    else:
        result = call_llm_judge_cli(prompt, model)

    # Verify/recalculate weighted average
    calculated_avg = calculate_weighted_score(result['scores'], rubric['criteria'])
    result['calculated_weighted_average'] = calculated_avg
    result['pass'] = calculated_avg >= rubric['passing_threshold']

    return result


def main():
    parser = argparse.ArgumentParser(
        description='LLM-based grader for CHAOS agent evals (uses Claude Code CLI)'
    )
    parser.add_argument('--rubric', required=True, help='Path to rubric YAML file')
    parser.add_argument('--output', required=True, help='Path to agent output file')
    parser.add_argument('--spec', help='Path to original spec (for context)')
    parser.add_argument('--model', default='sonnet', choices=['haiku', 'sonnet', 'opus'],
                        help='Claude model to use for judging (default: sonnet)')
    parser.add_argument('--mock', action='store_true',
                        help='Use mock responses instead of calling Claude CLI')
    parser.add_argument('--json', action='store_true', help='Output as JSON')

    args = parser.parse_args()

    try:
        result = grade_output(
            rubric_path=Path(args.rubric),
            output_path=Path(args.output),
            spec_path=Path(args.spec) if args.spec else None,
            model=args.model,
            mock=args.mock
        )

        if args.json:
            print(json.dumps(result, indent=2))
        else:
            print(f"Scores: {result['scores']}")
            print(f"Weighted Average: {result['calculated_weighted_average']:.2f}")
            print(f"Pass: {'YES' if result['pass'] else 'NO'}")
            print(f"Reasoning: {result['reasoning']}")

        sys.exit(0 if result['pass'] else 1)

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(2)


if __name__ == '__main__':
    main()
