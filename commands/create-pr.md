---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(gh pr create:*)
description: Create a comprehensive pull request with proper documentation
---

# Create Pull Request - Complete Workflow

## Context
- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current` 
- Recent commits on this branch: !`git log --oneline -5`
- Base branch comparison: !`git diff main...HEAD --name-only`

## Your Task

**Phase 1: Summarize Changes**
1. Analyze all the changes shown above
2. Identify the main purpose and scope of the changes
3. Group related changes into logical categories
4. Note any breaking changes or significant modifications

**Phase 2: Create PR**
1. Generate a clear, descriptive PR title
2. Write a comprehensive PR description including:
   - Summary of changes and motivation
   - Detailed breakdown of modifications
   - Any architectural or design decisions
   - Dependencies or prerequisites

**Phase 3: Review and Refine**
1. Review the generated PR for completeness
2. Add any missing context or background information
3. Ensure the description clearly explains the "why" behind changes
4. Include any relevant issue numbers or references

**Phase 4: Add Testing Details**
1. Document how the changes were tested
2. Include any new test cases added
3. Note any manual testing performed
4. Highlight any areas that need additional testing

**Final Action**: Create the actual PR using `gh pr create` with the generated content.

## Success Criteria
- PR has clear, descriptive title
- Description explains both what changed and why
- Testing approach is documented
- PR is ready for team review