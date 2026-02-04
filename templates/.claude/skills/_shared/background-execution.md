# Background Execution Guide

Rules for launching and waiting for subagents in CHAOS workflows.

## Launch Pattern

ALL agent launches MUST use `run_in_background: true`:

```
Task(agent-name, run_in_background: true):
  [context and instructions]
```

## Wait for Completion

After launching an agent:
1. End your turn immediately
2. Wait for the system notification
3. Process the returned summary (< 500 tokens)

## Do NOT

- Poll agents with `TaskOutput`
- Read agent output files directly
- Process full agent outputs
- Launch multiple agents simultaneously

## Summary Token Limits

| Agent | Max Tokens |
|-------|------------|
| spec-reviewer | 400 |
| explore, plan, implement | 500 |
| verifier, code-reviewer | 500 |
| dispute-resolver | 500 |

## Where Details Go

Agents persist full details externally:
- **Beads issues**: Exploration notes, implementation plans
- **Git**: Code changes
- **Context files**: Patterns, references, decisions

The orchestrator only receives summaries to preserve context.
