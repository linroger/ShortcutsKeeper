# AI History Tracking Instructions

## Terminology
- **USER**: The human providing instructions and feedback
- **AI**: The AI agent executing tasks and maintaining documentation

## System Overview
Context-aware knowledge management with intelligent conversation tracking and multi-context support.

## Folder Structure
```
.claude/ai_history/
├── core/
│   ├── tracking_instructions.md (this file)
│   └── project_knowledge_template.md
├── project_knowledge.md (created from template)
└── conversations/
    ├── conversation_001/
    │   ├── prompt_001_description.md
    │   └── prompt_002_description.md
    └── conversation_002/
        └── prompt_001_description.md
```

## Implementation Protocol

### 1. Project Knowledge Setup
1. **Check for `project_knowledge.md`** - if missing, copy from `core/project_knowledge_template.md`
2. **Always check existing knowledge** before starting significant work
3. **Evaluate relevance** - ask "Is [KNOWLEDGE_CODE] relevant to my current [USE_CASE]?"

### 2. Knowledge Management
**Creating Knowledge Entries:**
- Use descriptive reference codes (not generic categories)
- Include "When was this created" field explaining the collaboration context
- Tag with use case: [RESEARCH], [IMPLEMENT], [REFACTOR], [DOCUMENT], [TEXT_GEN], [IMAGE_GEN], [DEBUG], [WORKFLOW]

**Knowledge Usage:**
- Log all knowledge access in usage log
- Reference specific codes when applying knowledge
- Update knowledge base with new discoveries immediately

### 3. Conversation Tracking
**When to create conversations:**
- Start new `conversation_XXX` folder for significant sessions
- Number incrementally from existing folders
- Document key exchanges that contain reusable insights

**File Format:**
```markdown
# [Brief Description]

## New Knowledge Created (Optional)
*Only include if new knowledge was discovered during this exchange*

### [DESCRIPTIVE_CODE]: [Knowledge Title]
- **When was this created**: [What AI and USER were collaborating on when this knowledge emerged]
- **Use case**: [USE_CASE_TAG]
- **Content**: [Knowledge details]
- **Context**: When to apply this knowledge

## Summary
[One-line summary]

## USER Prompt
[USER's message]

## AI Response
[AI's response summary]
```

### 4. Context-Aware Operation
**Before using any knowledge:**
- Evaluate relevance to current use case context
- Log what knowledge was accessed and why
- Skip irrelevant knowledge to avoid contamination

**Multi-context support:**
- Different chat purposes don't interfere with each other
- Filter knowledge by use case tags
- Maintain separate context evaluation for each session type

### 5. Living Memory Updates
**Update triggers:**
- USER provides feedback or corrections
- New patterns or workflows discovered
- Significant decisions made
- System improvements identified

**Update targets:**
- Add insights to `project_knowledge.md`
- Create conversation records for significant exchanges
- **Duplicate new knowledge**: Any knowledge in conversation history must also be added to `project_knowledge.md`
- Update relevant CLAUDE.md files using `/memory` command

## Activation
This system activates automatically when working in projects with `.claude/ai_history/` folder.
