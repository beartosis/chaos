---
name: learn
description: Post-task reflection — capture observations and promote proven patterns to standards
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# /learn — Self-Reinforcing Learning Loop

Run this after completing a task (post-merge). It captures what you learned and promotes proven patterns into project standards.

## Step 1: Reflect on the Task

Think about what just happened:
- What worked well?
- What was surprising about the codebase?
- What patterns did you discover that future sessions should know?
- What mistakes did you make that could be avoided?
- Were there any gaps in the standards that would have helped?

## Step 2: Capture Observations

Append new observations to `.chaos/learnings.md` using this format:

```markdown
## [DATE] — [Task ID or Brief Description]

- **Observation**: [What you noticed]
- **Context**: [Why it matters]
- **Recommendation**: [What future sessions should do]
```

Keep observations specific and actionable. "The codebase uses X pattern" is better than "The code is interesting."

## Step 3: Scan for Promotable Patterns

Run the analysis script to find promotion candidates, then review manually:

```bash
bash .claude/scripts/analyze-learnings.sh
```

Also read through `.chaos/learnings.md` and look for patterns that appear **3 or more times** across different tasks. These are candidates for promotion to project standards.

Examples of promotable patterns:
- A specific error handling pattern that keeps coming up
- A naming convention that multiple observations reference
- A testing approach that has been rediscovered repeatedly
- A common pitfall that multiple sessions have hit

## Step 4: Promote to Standards

For each pattern ready for promotion:

1. Determine which standards file it belongs to:
   - `standards/global/` — applies everywhere
   - `standards/backend/` — backend-specific
   - `standards/frontend/` — frontend-specific
   - `standards/testing/` — test-related

2. Add the pattern to the appropriate file with:
   - A clear description of the pattern
   - When to use it
   - An example

3. Mark the promoted observations in `.chaos/learnings.md` by prepending `[PROMOTED]`:
   ```markdown
   - **[PROMOTED]** Observation: Always use X pattern for Y
   ```

4. Log the promotion to `standards/CHANGELOG.md`:
   ```markdown
   ### YYYY-MM-DD — [Pattern Name]
   - **Source**: [Task ID or session]
   - **Evidence**: [N] occurrences across [M] tasks
   - **Target**: standards/[domain]/[file].md
   - **Pattern**: [Brief description]
   ```

## Step 5: Archive if Needed

If `.chaos/learnings.md` grows beyond ~100 observations, archive older promoted entries:

```bash
# Move promoted entries to archive
# Keep only un-promoted and recent observations in learnings.md
```

Archive to `.chaos/learnings-archive/YYYY-MM.md` grouped by month.

## Key Principles

- **Be specific.** "Use `trpc.router()` not `express.Router()`" beats "Use the right router."
- **Include context.** Future sessions won't have your conversation history.
- **Promote conservatively.** Three occurrences means it's a real pattern, not a coincidence.
- **Standards are permanent.** Only promote things you're confident about.
