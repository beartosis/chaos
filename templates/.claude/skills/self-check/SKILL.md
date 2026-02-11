---
name: self-check
description: Pre-push quality gate — verify your work before creating a PR
user-invocable: true
allowed-tools: Read, Bash, Grep, Glob
---

# /self-check — Pre-Push Quality Gate

Run this before pushing code. It catches issues that would be flagged in review.

## 1. Run Tests

```bash
# Run the project's test suite (auto-detects test runner)
bash .claude/scripts/run-tests.sh
```

Run the full test suite, not just your new tests.

**Verdict**: If tests fail, stop here. Fix them before continuing.

## 2. Review Your Diff

```bash
# Quick automated scan for secrets, debug code, TODOs
bash .claude/scripts/check-diff.sh

# Then review the full diff manually
git diff --stat
git diff
```

Check your diff against this checklist:

### Code Quality
- [ ] No hardcoded values that should be config/env
- [ ] No secrets, API keys, or credentials
- [ ] No dead code or commented-out blocks
- [ ] No TODO/FIXME/HACK comments left behind
- [ ] Error cases are handled (not swallowed or ignored)
- [ ] No console.log/print statements used for debugging

### Pattern Compliance
- [ ] Follows existing naming conventions
- [ ] Matches existing code style (indentation, formatting)
- [ ] Uses existing utilities/helpers rather than reinventing
- [ ] New files are in the right directories per project structure

### Scope Discipline
- [ ] Changes are limited to what the task requires
- [ ] No drive-by refactors of surrounding code
- [ ] No unnecessary dependency additions
- [ ] No changes to files unrelated to the task

### Testing
- [ ] New behavior has tests
- [ ] Tests cover the happy path and key edge cases
- [ ] Tests follow existing test patterns
- [ ] No tests were skipped or disabled

## 3. Verify Acceptance Criteria

Read the original task from your issue tracker (e.g., `bd show <current-task-id>`).

Check each acceptance criterion against your implementation. Every criterion must be demonstrably met.

## 4. Output Verdict

After completing all checks, output one of:

**READY TO PUSH** — All checks pass, code is production-grade.

**NEEDS FIXES** — List specific issues that must be addressed:
```
NEEDS FIXES:
- [ ] Issue 1: description
- [ ] Issue 2: description
```

If NEEDS FIXES, address each issue and run `/self-check` again.
