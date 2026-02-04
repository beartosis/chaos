# Guided Mode

Interactive conversation to shape a spec from a high-level goal.

## Invocation

```
/create-spec [optional-feature-name]
```

## Phase 1: Assess Context

Check if there's relevant prior discussion in this conversation.

**If prior context exists** about a feature or implementation:
- Summarize what you understood from the discussion
- Ask: "Would you like me to create a spec based on what we've discussed?"
- Use that context as a starting point

**If no prior context** (or `$ARGUMENTS` is a feature name):
- Ask: "What feature would you like to spec out? Describe what you're trying to build."

## Phase 2: Scout the Codebase

Launch **scout** agent to explore the codebase:

```
Task(scout, run_in_background: true):
  Feature goal: [user's description]

  Find:
  - Similar existing implementations
  - Patterns to follow
  - Files likely to be modified
  - Test patterns used
  - Any potential conflicts
```

**WAIT** for scout to complete. Share relevant findings with the user.

## Phase 3: Clarifying Questions

Ask questions to fill gaps in your understanding. Focus on:

1. **Requirements** - What specifically needs to happen?
2. **Constraints** - What must NOT change? What limitations exist?
3. **Edge cases** - What happens when X fails? What about empty states?
4. **Success criteria** - How will we know it works?
5. **Scope boundaries** - What are we explicitly NOT doing?

**Guidelines:**
- Ask 2-4 questions at a time, not a huge list
- Build on previous answers
- Use `AskUserQuestion` for structured choices when helpful
- Keep asking until you have SOLID understanding

**Good questions:**
- "What should happen if the email fails to send?"
- "Should users be able to configure this, or is it automatic?"
- "You mentioned 'fast' - what's the target response time?"

**Bad questions:**
- "Can you clarify the requirements?" (too vague)
- "Is this correct?" (too broad)

## Phase 4: Confirm Understanding

Before generating the spec, summarize your understanding:

```markdown
**Goal**: [1-2 sentences]

**Key Requirements**:
- [requirement 1]
- [requirement 2]

**Constraints**:
- [constraint 1]

**Success Criteria**:
- [how we'll verify it works]

**Out of Scope**:
- [what we're NOT doing]

Does this capture everything accurately?
```

Wait for user confirmation before proceeding to spec generation.
