# Claude Code Best Practices & Tools

## Purpose

Claude Code configuration, tool optimization, and workflow best practices for maximum efficiency.

## Files
- **`settings.md`**: Complete tools reference with usage guidance and core principles ("Context is King", delegation strategies, automation suggestions)
- **`claude_md_principles.md`**: CLAUDE.md design principles, hierarchy guidelines, and best practices learned from actual usage
- **`../settings.json`**: Project configuration (64k output tokens, 32k thinking tokens, permissions)

## Usage

- **Gather context first**: Use ls, glob, grep, ripgrep, read, websearch, webfetch before any task execution
- **Delegate strategically**: Use Agent tool with comprehensive prompts, save outputs to `.claude/sub-agent-tasks/task-{ID}-{description}.md`
- **Think hierarchically**: TodoWrite for parent/child task breakdown
- **Design lean CLAUDE.md files**: Follow `claude_md_principles.md` for hierarchy and content guidelines
- **Suggest automation**: Recommend custom slash commands for repetitive workflows
- **Batch operations**: Multiple tool calls in single responses for efficiency
