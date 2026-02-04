# From-Issue Mode

Parse a GitHub issue and expand it into a full specification.

## Invocation

```
/create-spec --from-issue <github-issue-url>
```

## Phase 1: Fetch and Parse Issue

1. Extract the URL from arguments
2. Fetch the issue using `WebFetch`:
   ```
   WebFetch(url, "Extract: title, description, reproduction steps, expected behavior, labels, comments summary")
   ```
3. Parse the issue content into:
   - **Problem**: What's broken or missing
   - **Context**: Reproduction steps, environment details
   - **Expected**: What should happen instead
   - **Labels**: Bug, feature, enhancement, etc.
4. Present parsed content to user for confirmation
5. Proceed to Phase 2 (Scout) with issue context

## Example Parsing

```markdown
## Parsed Issue: #142

**Title**: Login fails silently on timeout

**Problem**: When API times out, user sees blank screen

**Context**:
- Occurs after 30s of no response
- Reproduction: Throttle network, attempt login

**Expected**: Show error message with retry option

**Labels**: bug, UX, priority:high

Is this understanding correct?
```

## After Parsing

Continue with standard workflow:
1. Scout the codebase for relevant patterns
2. Ask clarifying questions if issue is ambiguous
3. Generate spec via spec-architect
4. Validate with spec-reviewer

## Tips

- GitHub issues often lack technical detail - ask about implementation approach
- Check if reproduction steps are complete
- Clarify acceptance criteria if not in the issue
- Labels can inform priority and scope
