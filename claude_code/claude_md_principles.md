# CLAUDE.md Design Principles for Any Repository

## Core Philosophy for Future Claude Code Agents
When you encounter ANY project with .claude/ folder, you must create CLAUDE.md files that are **lean, focused, and actionable** - not verbose documentation repositories. This approach works for any folder structure.

## Universal Hierarchy Design

### **Root CLAUDE.md** 
- **Purpose**: Project discovery and adaptation (for template repos) OR project-specific context (for active projects)
- **Content**: Minimal structure with @ imports to load .claude system
- **Pattern**: `@.claude/CLAUDE.md` to load integration hub
- **Length**: Under 30 lines

### **.claude/CLAUDE.md**
- **Purpose**: Integration hub that coordinates ALL subfolders in .claude/
- **Content**: Lists each subfolder with @ import, describes how they work together
- **Pattern**: `@.claude/subfolder_name/CLAUDE.md` for each subfolder discovered
- **Length**: Under 35 lines

### **Subfolder CLAUDE.md files**
- **Purpose**: Brief overview of that specific subfolder's purpose, files, and usage
- **Format**: Purpose → Files → Usage (each file gets name + one-sentence description)
- **Length**: Under 20 lines each

## Design Principles

### **Lean Structure**
- **Purpose**: 1-2 sentences maximum
- **Files**: List with name + single-sentence purpose
- **Usage**: Key behaviors and patterns only
- **No duplication**: Specific details belong in referenced files

### **Clear File References**
- **Always use explicit paths**: `.claude/ai_history/project_knowledge.md` not `project_knowledge.md`
- **Reference actual files**: Point to existing files with their exact names
- **Avoid ambiguity**: Leave nothing to interpretation

### **Actionable Content**
- **Bias toward behavior**: Tell AI agents what to DO, not just what exists
- **Integration focus**: Show how components work together
- **Active language**: "Create", "Check", "Suggest", "Update"

## Universal Patterns

### **Root CLAUDE.md Pattern**
```markdown
## 🎯 PRIMARY TASK FOR NEW AI AGENTS
1. Explore repository and ask user about project purpose
2. Update this file with project-specific context
3. Begin work using @ imported systems

## 🔧 System Integration & Active Features
@.claude/CLAUDE.md
```

### **Integration Hub Pattern (.claude/CLAUDE.md)**
```markdown
## Active Components
- **subfolder_a/**: @.claude/subfolder_a/CLAUDE.md
- **subfolder_b/**: @.claude/subfolder_b/CLAUDE.md

## Integration Protocol
How discovered subfolders work together...

## System Questions
Key decision prompts for AI agents...
```

### **Subfolder CLAUDE.md Pattern**
```markdown
## Purpose
Brief description of this subfolder's role

## Files
- **filename.ext**: One-sentence description
- **another_file.ext**: One-sentence description

## Usage
- Key behaviors for this subfolder
- How to use the files effectively
```

## Content Guidelines

### **What Belongs in CLAUDE.md**
- Folder purpose and scope
- File names with single-sentence descriptions
- Key usage patterns and behaviors
- Integration points between components

### **What Doesn't Belong**
- Detailed procedures (belongs in referenced files)
- Examples and templates (belongs in dedicated files)
- Lengthy explanations (keep concise and reference details elsewhere)
- Duplicate content from other CLAUDE.md files

## Instructions for Future Claude Code Agents

### **When You Encounter ANY .claude/ System**
You are Claude Code with powerful capabilities. When working in projects with .claude/ folders:
1. **Discover the structure**: Use LS to see what subfolders exist in .claude/
2. **Recognize the hierarchy**: Root (project-specific), .claude/ (integration), subfolders (specialized)  
3. **Follow the leanness principle**: Each CLAUDE.md under 20-35 lines, focused only on essentials
4. **Use explicit file paths**: Always use `.claude/subfolder/filename` - never leave ambiguous
5. **Maintain separation of concerns**: Don't duplicate content across CLAUDE.md files

### **Your Enhanced Capabilities**
- **64k output tokens**: Use for high-quality, comprehensive responses
- **32k thinking tokens**: Think thoroughly before acting on complex tasks
- **Advanced context evaluation**: Always ask "Is this knowledge relevant to current use case?"
- **Intelligent delegation**: Use Agent tool for parallel execution with structured outputs

### **Memory Integration Protocol**
- CLAUDE.md files are living memory that evolves during use
- Update using `/memory` command when USER provides feedback or patterns change
- Apply "When was this created" context - understand the collaboration circumstances behind each knowledge entry
- Capture what works vs. what doesn't for continuous improvement

## Discovery Protocol for Any Repository
When you encounter a .claude/ folder:
1. **Explore structure**: `LS .claude/` to see what subfolders exist
2. **Read existing CLAUDE.md files**: Start with `.claude/CLAUDE.md` if it exists
3. **Create missing CLAUDE.md files**: Follow the lean patterns for any subfolder
4. **Establish integration**: Update `.claude/CLAUDE.md` to coordinate all subfolders
5. **Maintain explicit paths**: Always reference files with full `.claude/subfolder/file` paths

## Expected Outcomes for Future Agents
When you properly implement this system in ANY repository:
- **Immediate comprehension**: You'll understand any project's purpose and structure instantly
- **Clear action items**: You'll know exactly what to do in each discovered subfolder
- **Efficient workflows**: You'll leverage all discovered capabilities without confusion
- **Intelligent evolution**: Any .claude/ system becomes more valuable through your usage
- **Seamless handoffs**: Other Claude Code agents can continue your work in any structure

## Implementation Mandate
This knowledge works for ANY .claude/ folder structure. Future Claude Code agents MUST:
- Discover and work with whatever subfolders exist
- Maintain the lean, focused approach to CLAUDE.md design regardless of folder names
- Use explicit `.claude/subfolder/file` paths always
- Apply context evaluation before using any stored knowledge
- Update the system based on discoveries and USER feedback