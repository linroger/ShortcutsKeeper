# .claude Folder System Editing Guide

## Overview
This document provides comprehensive best practices for editing ANY part of the .claude folder system. Based on extensive real-world usage, it ensures system integrity and proper evolution.

## Pre-Edit Validation Checklist

### 🔍 System Understanding Check
Before editing ANYTHING in .claude/, verify:
- [ ] You understand the complete folder structure using `LS .claude/`
- [ ] You've read all existing CLAUDE.md files to understand current state
- [ ] You understand the integration flow between all components
- [ ] You've identified which specific component needs modification

### 📋 Current State Assessment
- [ ] Read `.claude/CLAUDE.md` to understand system integration
- [ ] Check if `project_knowledge.md` exists (create from template if missing)
- [ ] Verify all file paths are explicit (`.claude/subfolder/file`)
- [ ] Confirm USER approval for any changes to sub-agent outputs

### 🎯 Change Scope Definition
- [ ] Clearly define what you're changing and why
- [ ] Identify which other components might be affected
- [ ] Plan updates to maintain cross-component consistency
- [ ] Determine if CLAUDE.md files need updates

## Editing Rules & Best Practices

### 🚫 Absolute Rules (NEVER Break These)
1. **Maintain Leanness**: Keep all CLAUDE.md files under 20-35 lines
2. **Use Explicit Paths**: Always use `.claude/subfolder/filename` - never ambiguous references
3. **Preserve Hierarchy**: Root (project) → .claude/ (integration) → subfolders (specialized)
4. **No Duplication**: Each CLAUDE.md has unique purpose, no content overlap
5. **Self-Reference**: This file must document its own editing procedures

### ✅ Quality Standards
- **CLAUDE.md Format**: Purpose → Files → Usage (each under 20 lines)
- **Knowledge Entries**: Include "When was this created" with collaboration context
- **File References**: Complete paths, never relative or ambiguous
- **Integration Updates**: Update `.claude/CLAUDE.md` when adding/removing components

### 🔄 Cross-Component Consistency
- **Terminology**: Use USER/AI consistently across all files
- **Reference Codes**: Use descriptive codes that reflect actual content
- **Use Case Tags**: Apply [RESEARCH], [IMPLEMENT], [REFACTOR], etc. consistently
- **Path Standards**: All file references use complete `.claude/subfolder/file` format

## Component-Specific Editing Guidelines

### ai_history/ Component
**When to Edit:**
- USER provides feedback requiring knowledge base updates
- New patterns or workflows discovered during collaboration
- Template needs customization for specific project

**Editing Steps:**
1. Check if `project_knowledge.md` exists (create from `core/project_knowledge_template.md`)
2. Add new knowledge with descriptive reference codes
3. Include "When was this created" context
4. Update conversation folders for significant exchanges
5. Log knowledge usage in usage log

### claude_code/ Component
**When to Edit:**
- Tool usage patterns change or improve
- New best practices discovered through actual usage
- Model capabilities or configuration updates needed

**Editing Steps:**
1. Update `settings.md` with new tool guidance
2. Modify `claude_md_principles.md` if hierarchy patterns change
3. Adjust `CLAUDE.md` for new usage patterns
4. Update `../settings.json` for configuration changes

### commands/ Component
**When to Edit:**
- New custom slash commands created
- Workflow documentation needs updates
- System maintenance procedures change

**Editing Steps:**
1. Add new `.md` files for custom commands
2. Update `CLAUDE.md` to reference new commands
3. Modify this file (`edit_claude_system.md`) for procedure changes
4. Document command usage patterns

### sub-agent-tasks/ Component
**When to Edit:**
- Files are auto-generated, generally READ-ONLY
- Only edit `CLAUDE.md` if usage patterns change
- Require USER approval before using outputs as foundation

## Validation Workflow

### 🔧 Pre-Edit Validation
```bash
# Verify structure
LS .claude/

# Check integration
Read .claude/CLAUDE.md

# Understand current state
Read [component]/CLAUDE.md
```

### ✏️ During Editing
1. **Maintain explicit paths**: Use `.claude/subfolder/file` format
2. **Preserve integration**: Update `.claude/CLAUDE.md` if adding/removing components
3. **Follow CLAUDE.md patterns**: Purpose → Files → Usage format
4. **Document changes**: Add knowledge entries for significant modifications

### ✅ Post-Edit Validation
- [ ] All CLAUDE.md files remain under length limits (20-35 lines)
- [ ] All file references use explicit paths
- [ ] Integration hub (`.claude/CLAUDE.md`) reflects current structure
- [ ] No content duplication between CLAUDE.md files
- [ ] Cross-component consistency maintained

## System Evolution Best Practices

### 📈 Continuous Improvement
- **Monitor usage patterns**: Track what works vs. what doesn't
- **Update based on feedback**: USER corrections become system improvements
- **Evolve with projects**: Adapt templates for specific project needs
- **Document lessons learned**: Capture insights for future use

### 🔄 Template Maintenance
- **Keep core templates clean**: Don't pollute with project-specific content
- **Update procedures**: Refine editing processes based on actual usage
- **Maintain universality**: Ensure patterns work for any project type
- **Version control changes**: Track significant system modifications

### 🤝 Collaboration Principles
- **USER approval required**: For any significant system changes
- **Transparent process**: Explain what you're changing and why
- **Reversible changes**: Maintain ability to undo modifications
- **Knowledge preservation**: Don't lose valuable accumulated knowledge

## Emergency Recovery Procedures

### 🚨 If System Becomes Inconsistent
1. **Stop all edits** until structure is repaired
2. **Use `LS .claude/` to assess damage**
3. **Restore from known good patterns** using this guide
4. **Rebuild integration hub** (`.claude/CLAUDE.md`) with correct @ imports
5. **Validate all CLAUDE.md files** follow proper format

### 🔧 Common Issues & Fixes
- **Ambiguous file references**: Replace with explicit `.claude/subfolder/file` paths
- **CLAUDE.md too long**: Split into Purpose → Files → Usage, remove duplication
- **Missing integration**: Add component to `.claude/CLAUDE.md` Active Components
- **Lost knowledge**: Recover from conversation history or knowledge usage logs

## Meta-Documentation
This file serves as the authoritative guide for editing the entire .claude folder system:
- **Scope**: ALL .claude folder components and their interactions
- **Authority**: Based on extensive real-world usage and refinement
- **Self-Reference**: Documents its own editing procedures and system role
- **Evolution**: Must be updated when system editing practices change