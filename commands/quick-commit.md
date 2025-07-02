---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
description: Quick commit with automatic message generation
---

# Quick Commit Command

## Context
- Current status: !`git status`
- Staged changes: !`git diff --cached --name-only`
- Unstaged changes: !`git diff --name-only`

## Your Task
1. Review the current git status above
2. Stage all relevant changes (avoiding temporary files)
3. Generate a descriptive commit message based on the changes
4. Create the commit with the generated message

## Commit Message Guidelines
- Use conventional commit format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, test, chore
- Keep first line under 50 characters
- Add detailed body if changes are complex

## Example Output
```bash
git add [relevant files]
git commit -m "feat(calculator): add bond pricing functionality

- Implement Black-Scholes pricing model
- Add comprehensive input validation
- Include unit tests for edge cases"
```