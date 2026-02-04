# Minimal Changes Standards

## Core Principle

Make the smallest change that correctly solves the problem.

## Do

- Focus on the specific requirement
- Follow existing patterns in the codebase
- Reuse existing utilities and helpers
- Match the style of surrounding code

## Don't

- Refactor unrelated code
- Add "improvements" beyond scope
- Create abstractions for single-use cases
- Add features not requested
- Change formatting in files you didn't meaningfully modify

## Rationale

Over-engineering:
- Increases review burden
- Introduces potential bugs in unrelated areas
- Makes the actual change harder to identify
- Wastes time on hypothetical future needs

## Exception

If you notice a bug or security issue while working, note it but don't fix it unless:
1. It's directly blocking your task
2. You have explicit approval to expand scope
