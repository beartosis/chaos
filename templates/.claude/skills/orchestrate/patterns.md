# Orchestration Patterns Reference

## How to Launch Agents

Throughout the orchestrate skill, you'll see **prompt templates** like:
```
Task(agent-name, run_in_background: true):
  Issue: [issue-id]
  Context: [details]
```

This is shorthand notation. To actually launch an agent, use the **Task tool** with these parameters:
- `description`: Short label (3-5 words)
- `prompt`: The indented content from the template
- `subagent_type`: The agent name (e.g., "explore", "plan", "implement")
- `run_in_background`: Set to `true` for all agent launches

**Example**: To launch the explore agent, call the Task tool with:
- `description`: "Explore auth system"
- `prompt`: "Issue: beads-123\nSpec context: User authentication...\nFocus: Find existing auth patterns..."
- `subagent_type`: "explore"
- `run_in_background`: true

---

## Background Agent Mechanics

When you launch an agent with `run_in_background: true`:
1. The Task tool returns immediately with an agent ID
2. The agent runs asynchronously in the background
3. When the agent completes, **you automatically receive a notification** in the conversation
4. The agent's summary appears in your context - no polling needed

**What "WAIT" means**: After launching a background agent, simply end your response. When the agent completes, you'll receive a notification and can continue. Do not:
- Call TaskOutput to poll for results
- Read the agent's output file directly
- Launch another agent before the current one completes

### Timeout Handling

Background agents should complete within reasonable timeframes:
- **explore** (Haiku): 1-3 minutes
- **plan** (Sonnet): 2-5 minutes
- **implement** (Opus): 5-15 minutes
- **verifier** (Haiku): 1-2 minutes
- **code-reviewer** (Sonnet): 2-5 minutes

**If an agent appears stuck** (no notification after expected time):

1. **Check status**: Run `/tasks` to see running background tasks
2. **Manual interrupt**: Press `Ctrl+C` to cancel the stuck agent
3. **Resume conversation**: The orchestrator can retry the failed step
4. **Report the issue**: Note which agent hung and what it was working on

**Proactive timeout strategy**:

When launching agents, include a time expectation in your prompt:
```
Task(implement, run_in_background: true):
  Issue: beads-123
  ...
  Expected completion: ~10 minutes for this scope
```

This helps the agent scope its work appropriately.

**Environment variable** (advanced):
Set `CLAUDE_CODE_MAX_TASK_DURATION_MS` to enforce a global timeout on all Task operations.

---

## Anti-Patterns (What NOT to Do)

```
- Launch agent -> poll with TaskOutput -> read output file
- Launch multiple agents simultaneously without waiting
- Skip straight to implement without explore/plan
- Retry indefinitely without escalation
- Batch multiple task completions together
```

---

## Correct Patterns (What TO Do)

```
- Launch agent in background -> wait for notification -> read summary -> proceed
- Sequential pipeline: explore -> plan -> implement -> verify -> review
- Three strikes -> dispute-resolver -> human if needed
- Close work units immediately after approval
- Mark tasks complete one at a time as they finish
```

---

## Retry Tracking Format

Track retries per work unit using this format:
```
Work Unit: [id]
  Attempt 1: [PASS|FAIL] - [brief reason]
  Attempt 2: [PASS|FAIL] - [brief reason]
  Attempt 3: [PASS|FAIL] - [brief reason] -> ESCALATE
```

**Retry decision tree**:
- **Attempt 1-2 failure**: Re-launch implement agent with:
  - Previous failure summary
  - Specific guidance on what went wrong
  - Updated context from verifier/reviewer feedback
- **Attempt 3 failure**: Launch dispute-resolver (do NOT retry again)

**When re-launching after failure**, include in the prompt:
```
Previous attempt failed.
Failure reason: [from verifier or code-reviewer]
Attempt: 2 of 3
Guidance: [specific fix instructions]
```

---

## Work Breakdown Examples

```bash
# Create issues with dependencies
bd create --title="Explore: [area]" --type=task --priority=2
bd create --title="Plan: [feature]" --type=task --priority=2
bd create --title="Implement: [component]" --type=task --priority=2
bd create --title="Verify: [acceptance criteria]" --type=task --priority=2

# Add dependencies (later issues depend on earlier ones)
bd dep add [implement-id] [plan-id]
bd dep add [plan-id] [explore-id]
bd dep add [verify-id] [implement-id]
```

**Output work breakdown table**:
```markdown
## Work Breakdown: [Spec Title]
| Phase | Issue ID | Title | Depends On | Agent |
|-------|----------|-------|------------|-------|
| 1 | beads-xxx | Explore: ... | - | explore |
| 2 | beads-yyy | Plan: ... | beads-xxx | plan |
| 3 | beads-zzz | Implement: ... | beads-yyy | implement |
| 4 | beads-aaa | Verify: ... | beads-zzz | verifier |
```

---

## Context Management

### Summary Tier System

Agents support tiered summaries to preserve context. Request specific tiers based on workflow stage:

| Stage | Recommended Tier | Rationale |
|-------|------------------|-----------|
| Early (agents 1-3) | STANDARD | Fresh context, need details |
| Mid (agents 4-6) | STANDARD | Balanced approach |
| Late (7+ agents) | CRITICAL-only | Preserve remaining context |

### Requesting Tiers

Include tier hint in agent prompts:
```
Task(explore, run_in_background: true):
  Issue: [id]
  ...
  Summary tier: STANDARD
```

Or for late-stage agents:
```
Task(verifier, run_in_background: true):
  Issue: [id]
  ...
  Summary tier: CRITICAL-only (context constrained)
```

### Context Overflow Handling

When context exceeds ~80% capacity (conversation becoming long):

1. **Archive completed summaries to Beads**:
   ```bash
   bd update [id] --notes="Full summary: [complete agent output]"
   ```

2. **Replace in-conversation with minimal reference**:
   ```markdown
   Work unit [X] complete. Details archived to Beads issue [id].
   Status: PASS | Files: 3 modified | Next: code-reviewer
   ```

3. **Continue with reduced footprint**

### Tracking Context Usage

Mentally track cumulative summary tokens:
- Early phases: ~150-200 tokens each (STANDARD tier)
- Late phases: ~50 tokens each (CRITICAL tier)
- Target: Keep total agent summaries under 2000 tokens

This leaves room for spec content, error messages, and conversation overhead.
