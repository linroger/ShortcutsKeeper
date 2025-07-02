# Claude Code Tools & Best Practices

## Core Principles

### **Context is King**
The quality of any task completed is directly proportional to the context provided for executing that task. Always gather comprehensive context using Read, Glob, Grep, LS, WebSearch, and WebFetch tools before beginning execution.

### **Think Before Acting**
Always analyze the task thoroughly before taking action. Create structured plans with clear parent tasks and child tasks to ensure comprehensive execution.

### **Delegate Strategically**
Use the Agent tool to delegate independent sub-tasks in parallel. Save sub-agent work in `.claude/sub-agent-tasks/` with ordered task IDs and descriptive filenames for proper tracking.

### **Plan Hierarchically**
Break down complex work into parent tasks with specific child tasks. Use TodoWrite to track this hierarchy and ensure nothing is missed.

### **Design Lean Memory**
Create CLAUDE.md files that are focused and actionable, not verbose. Follow hierarchy principles: Root (project discovery), .claude/ (integration hub), components (brief overviews). Keep each under 20-35 lines.

### **Leverage Model Capabilities**
As Claude Code with Sonnet 4, use 64k output tokens for high-quality responses and 32k thinking tokens for thorough analysis. Apply "When was this created" context evaluation for knowledge relevance.

### **Suggest Automation**
When you notice the user performing repetitive tasks, proactively suggest creating custom slash commands to automate these workflows.

## Available Tools

### **Agent**
Runs a sub-agent to handle complex, multi-step tasks. Provide detailed prompts with complete context, file references, and specific output instructions. Direct sub-agents to save work in `.claude/sub-agent-tasks/task-{ID}-{description}.md` for organized tracking.

### **Bash**
Executes shell commands in your environment. Use for running commands, managing files, system operations, and automation tasks.

### **Edit**
Makes targeted edits to specific files. Use when you need to modify existing documents, text files, or any file content.

### **Glob**
Finds files based on pattern matching. Essential for gathering context - use to locate relevant files before beginning any task execution.

### **Grep**
Searches for patterns in file contents. Critical for context gathering - use to find specific text, keywords, or patterns within files before task execution.

### **LS**
Lists files and directories. Fundamental for context building - use to explore folder structure and understand the environment before taking action.

### **MultiEdit**
Performs multiple edits on a single file atomically. Use when you need to make several changes to one document at once.

### **NotebookEdit**
Modifies Jupyter notebook cells. Use when working with data analysis notebooks or interactive documents.

### **NotebookRead**
Reads and displays Jupyter notebook contents. Use when you need to examine notebook structure and cell contents.

### **Read**
Reads the contents of files. Essential for context gathering - always read relevant files to understand the current state before making any modifications or decisions. Critical for CLAUDE.md design - read existing files to understand scope before creating lean, focused memory files.

### **TodoRead**
Reads the current session's task list. Use when you need to check what tasks are pending or completed.

### **TodoWrite**
Creates and manages structured task lists. Use when breaking down any complex work into manageable steps with clear parent-child task relationships. Essential for managing multi-component projects like CLAUDE.md hierarchy design.

### **WebFetch**
Fetches content from a specified URL. Use when you need to retrieve and analyze web content or online resources.

### **WebSearch**
Performs web searches with domain filtering. Use when you need current information or research from the internet.

### **Write**
Creates or overwrites files. Use when you need to generate new documents, save content, or create any type of file.

## Workflow Optimization

### **Custom Slash Commands**
Claude Code supports creating custom slash commands for repetitive workflows. When you notice patterns in user requests, suggest creating commands like:
- `/project:analyze` for repeated analysis tasks
- `/user:format` for document formatting workflows
- `/project:setup` for project initialization routines

### **Sub-Agent Task Management**
When delegating to Agent tools:
1. Create `.claude/sub-agent-tasks/` directory for organized output
2. Use naming pattern: `task-{ID}-{description}.md`
3. Provide comprehensive context in prompts including:
   - Relevant file paths and contents
   - Complete background information
   - Specific output format requirements
   - Clear success criteria
4. Read sub-agent outputs from saved files for integration

### **Parallel Execution**
When possible, delegate independent sub-tasks to Agent tools while continuing with main task execution. This ensures maximum efficiency and throughput.

### **Structured Planning**
Always begin complex tasks by:
1. **Context Gathering**: Use Read, Glob, Grep, LS, WebSearch, WebFetch to understand the environment
2. **Scope Analysis**: Analyze the full scope with complete context
3. **Task Hierarchy**: Create parent tasks for major phases using TodoWrite
4. **Child Task Breakdown**: Break each parent into specific child tasks
5. **Memory Design**: Create lean, focused CLAUDE.md files following hierarchy principles
6. **Systematic Execution**: Execute with progress tracking and context validation
7. **Knowledge Integration**: Update relevant knowledge bases with discoveries