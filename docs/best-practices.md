# CHAOS Best Practices

Guidance for getting the best results from CHAOS v2.

## Skill Usage

### /work — Task Execution

**Read before you write.** The most common mistake is jumping into code changes without understanding existing patterns. `/work` explicitly guides you to explore first.

**Plan with TodoWrite.** Break the task into small steps. This keeps you focused and gives visibility into progress.

**Keep diffs minimal.** Only change what the task requires. Don't refactor surrounding code, add unrelated improvements, or "clean up" things that aren't broken.

### /self-check — Quality Gate

**Run it before every push.** Not just when you think there might be issues. The checklist catches things you don't think to look for.

**Fix issues immediately.** If `/self-check` says NEEDS FIXES, address them before pushing. Don't push and plan to fix later.

### /review-feedback — PR Reviews

**Take feedback seriously.** Reviewers (ORDER + GHA) catch things you miss. If they flag something, fix it.

**Fix root causes.** If a reviewer found one instance of an issue, check if the same issue exists elsewhere in your PR.

**Respond to everything.** Even if you disagree, explain your reasoning.

### /learn — Reflection

**Be specific.** "Use `trpc.router()` not `express.Router()`" is better than "Use the right router."

**Include context.** Future sessions won't have your conversation history.

**Promote conservatively.** Three occurrences means it's a real pattern. One occurrence is an anecdote.

## Learnings System

### Writing Good Observations

```markdown
## 2026-02-05 — task-123

- **Observation**: The auth middleware uses Passport.js strategies, not custom middleware
- **Context**: Found in src/middleware/auth.ts, used by all API routes
- **Recommendation**: Always create new auth flows as Passport strategies
```

### When to Run /learn

- After every merged PR
- After discovering something non-obvious about the codebase
- After making a mistake that future sessions should avoid

### Pruning Learnings

If `learnings.md` grows large, `/learn` will archive promoted entries. You can also manually clean up by:
1. Removing outdated observations (codebase has changed)
2. Consolidating duplicate observations
3. Moving promoted entries to the archive

## Standards System

Standards in `standards/` are the project's long-term memory. They evolve through the learning loop:

1. Multiple sessions observe the same pattern
2. `/learn` detects the pattern (3+ occurrences)
3. Pattern is promoted to the appropriate standards file
4. Future sessions read standards before writing code

**Don't edit standards manually** unless you're correcting an error. Let the learning loop handle promotion.

## Beads Workflow

### Keep Beads Updated

As you work, update the Beads issue with progress:

```bash
bd update <task-id> --note "Explored codebase, found existing auth patterns"
bd update <task-id> --note "Implementation complete, running self-check"
bd update <task-id> --note "Draft PR created: #42"
```

This creates an audit trail and helps ORDER track progress.

### Beads + Context Compaction

Beads state is re-primed on context compaction (via the `PreCompact` hook). This means your task context survives even when the conversation is summarized.

## Hook Configuration

### CHAOS Hooks

CHAOS installs two hooks:

| Event | Action |
|-------|--------|
| `PreCompact` | `bd prime` — re-load Beads context |
| `SessionStart` | `bd prime` + load learnings |

### Adding Custom Hooks

To add hooks without conflicting with CHAOS:

```json
{
  "hooks": {
    "PreCompact": [
      {
        "hooks": [
          { "type": "command", "command": "bd prime" }
        ],
        "matcher": ""
      },
      {
        "hooks": [
          { "type": "command", "command": "./your-custom-hook.sh" }
        ],
        "matcher": ""
      }
    ]
  }
}
```

## SDK Compatibility

### Tool Restrictions

The `allowed-tools` frontmatter in SKILL.md only works with Claude Code CLI. When using the SDK:

```python
options = ClaudeAgentOptions(
    cwd="/path/to/project",
    setting_sources=["user", "project"],
    allowed_tools=["Skill", "Read", "Write", "Edit", "Bash", "Grep", "Glob"]
)
```

### Loading Skills

The SDK requires explicit `setting_sources` to load filesystem-based skills:

```python
setting_sources=["user", "project"]  # Required!
```

## Troubleshooting

### Skills Not Found

**Symptom**: `/work` not recognized
**Fix**: Verify `.claude/skills/work/SKILL.md` exists and `setting_sources` includes `"project"`

### Beads Commands Fail

**Symptom**: `bd: command not found`
**Fix**: `go install github.com/steveyegge/beads/cmd/bd@latest`

### GitHub CLI Not Working

**Symptom**: `gh: command not found` or auth errors
**Fix**: Install from https://cli.github.com/ and run `gh auth login`

### Learnings Not Loading

**Symptom**: Session doesn't reference past learnings
**Fix**: Check `.chaos/learnings.md` exists. Run preflight: `.claude/scripts/preflight.sh`

### Hooks Not Running

**Symptom**: `bd prime` not executing at session start
**Fix**: Check `.claude/settings.local.json` exists and is valid JSON
