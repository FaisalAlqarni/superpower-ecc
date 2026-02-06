# ECC Integration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Integrate Everything Claude Code features into Superpowers v5.0.0, creating the most comprehensive Claude Code plugin by combining systematic workflows with battle-tested production tools.

**Architecture:** Three-layer architecture - Layer 1 (Superpowers systematic workflow), Layer 2 (ECC enhancements merged into skills), Layer 3 (ECC standalone commands/agents). Git operations restricted to read-only. All enhancements opt-out-able.

**Tech Stack:** Markdown skills, Node.js scripts for hooks, JSON configuration

---

## Phase 1: Foundation

### Task 1: Copy ECC Agents Directory

**Files:**
- Copy from: `D:\Projects\everything-claude-code-main\agents\*.md`
- Copy to: `D:\Projects\superpowers\agents\`
- Create: `D:\Projects\superpowers\agents\` (if doesn't exist)

**Step 1: Create agents directory**

Run: `mkdir agents` (if doesn't exist)
Expected: Directory created

**Step 2: Copy all agent files**

Run:
```bash
cp "D:\Projects\everything-claude-code-main\agents\planner.md" agents/
cp "D:\Projects\everything-claude-code-main\agents\architect.md" agents/
cp "D:\Projects\everything-claude-code-main\agents\code-reviewer.md" agents/
cp "D:\Projects\everything-claude-code-main\agents\security-reviewer.md" agents/
cp "D:\Projects\everything-claude-code-main\agents\tdd-guide.md" agents/
cp "D:\Projects\everything-claude-code-main\agents\e2e-runner.md" agents/
cp "D:\Projects\everything-claude-code-main\agents\build-error-resolver.md" agents/
cp "D:\Projects\everything-claude-code-main\agents\go-reviewer.md" agents/
cp "D:\Projects\everything-claude-code-main\agents\go-build-resolver.md" agents/
cp "D:\Projects\everything-claude-code-main\agents\python-reviewer.md" agents/
cp "D:\Projects\everything-claude-code-main\agents\database-reviewer.md" agents/
cp "D:\Projects\everything-claude-code-main\agents\doc-updater.md" agents/
cp "D:\Projects\everything-claude-code-main\agents\refactor-cleaner.md" agents/
```

Expected: 13 agent files copied

**Step 3: Verify copy**

Run: `ls agents/ | wc -l`
Expected: 13

---

### Task 2: Add Git Policy to All Agents

**Files:**
- Modify: All `agents/*.md` files

**Step 1: Add git policy to planner.md**

Modify: `agents/planner.md`

Add after the main description section:

```markdown
## Git Policy

You may read git state (status, diff, log) for context only.
NEVER execute or suggest git write operations. Work in current directory/branch.
When work is complete, report completion without git operations.
```

**Step 2: Add git policy to architect.md**

Modify: `agents/architect.md`

Add the same Git Policy section

**Step 3: Add git policy to code-reviewer.md**

Modify: `agents/code-reviewer.md`

Add the same Git Policy section

**Step 4: Add git policy to security-reviewer.md**

Modify: `agents/security-reviewer.md`

Add the same Git Policy section

**Step 5: Add git policy to tdd-guide.md**

Modify: `agents/tdd-guide.md`

Add the same Git Policy section

**Step 6: Add git policy to e2e-runner.md**

Modify: `agents/e2e-runner.md`

Add the same Git Policy section

**Step 7: Add git policy to build-error-resolver.md**

Modify: `agents/build-error-resolver.md`

Add the same Git Policy section

**Step 8: Add git policy to go-reviewer.md**

Modify: `agents/go-reviewer.md`

Add the same Git Policy section

**Step 9: Add git policy to go-build-resolver.md**

Modify: `agents/go-build-resolver.md`

Add the same Git Policy section

**Step 10: Add git policy to python-reviewer.md**

Modify: `agents/python-reviewer.md`

Add the same Git Policy section

**Step 11: Add git policy to database-reviewer.md**

Modify: `agents/database-reviewer.md`

Add the same Git Policy section

**Step 12: Add git policy to doc-updater.md**

Modify: `agents/doc-updater.md`

Add the same Git Policy section

**Step 13: Add git policy to refactor-cleaner.md**

Modify: `agents/refactor-cleaner.md`

Add the same Git Policy section

**Step 14: Verify git policy added**

Run: `grep -l "Git Policy" agents/*.md | wc -l`
Expected: 13

---

### Task 3: Modify build-error-resolver Agent for Escalation

**Files:**
- Modify: `agents/build-error-resolver.md`

**Step 1: Read current build-error-resolver**

Run: `cat agents/build-error-resolver.md`
Expected: Current agent content displayed

**Step 2: Add escalation logic section**

Modify: `agents/build-error-resolver.md`

Add after the main approach section:

```markdown
## Escalation Strategy

Use hybrid approach for build errors:

1. **Quick Pattern-Match (First Attempt)**
   - Check for common build errors (missing dependency, syntax error, import issue)
   - If pattern matches, apply known fix
   - Verify fix works

2. **Escalation Criteria**
   - Pattern-match fails (unknown error type)
   - 2+ fix attempts don't resolve the issue
   - Error is complex or involves multiple systems

3. **Escalation Action**
   When escalation criteria met:
   - Report: "Build error is complex. Escalating to systematic debugging."
   - Invoke: superpowers:systematic-debugging skill
   - Provide all context: error messages, attempted fixes, environment details

**Never:** Blindly apply fixes without understanding. When in doubt, escalate.
```

**Step 3: Verify escalation added**

Run: `grep -q "Escalation Strategy" agents/build-error-resolver.md && echo "Found"`
Expected: "Found"

---

### Task 4: Rename Commands with ECC Prefix

**Files:**
- Rename: All `commands/*.md` files (except brainstorm.md, execute-plan.md, write-plan.md)

**Step 1: Rename build-fix.md**

Run: `mv commands/build-fix.md commands/ecc-build-fix.md`
Expected: File renamed

**Step 2: Rename checkpoint.md**

Run: `mv commands/checkpoint.md commands/ecc-checkpoint.md`
Expected: File renamed

**Step 3: Rename e2e.md**

Run: `mv commands/e2e.md commands/ecc-e2e.md`
Expected: File renamed

**Step 4: Rename evolve.md**

Run: `mv commands/evolve.md commands/ecc-evolve.md`
Expected: File renamed

**Step 5: Rename go-build.md**

Run: `mv commands/go-build.md commands/ecc-go-build.md`
Expected: File renamed

**Step 6: Rename go-review.md**

Run: `mv commands/go-review.md commands/ecc-go-review.md`
Expected: File renamed

**Step 7: Rename go-test.md**

Run: `mv commands/go-test.md commands/ecc-go-test.md`
Expected: File renamed

**Step 8: Rename instinct-export.md**

Run: `mv commands/instinct-export.md commands/ecc-instinct-export.md`
Expected: File renamed

**Step 9: Rename instinct-import.md**

Run: `mv commands/instinct-import.md commands/ecc-instinct-import.md`
Expected: File renamed

**Step 10: Rename instinct-status.md**

Run: `mv commands/instinct-status.md commands/ecc-instinct-status.md`
Expected: File renamed

**Step 11: Rename learn.md**

Run: `mv commands/learn.md commands/ecc-learn.md`
Expected: File renamed

**Step 12: Rename multi-backend.md**

Run: `mv commands/multi-backend.md commands/ecc-multi-backend.md`
Expected: File renamed

**Step 13: Rename multi-execute.md**

Run: `mv commands/multi-execute.md commands/ecc-multi-execute.md`
Expected: File renamed

**Step 14: Rename multi-frontend.md**

Run: `mv commands/multi-frontend.md commands/ecc-multi-frontend.md`
Expected: File renamed

**Step 15: Rename multi-plan.md**

Run: `mv commands/multi-plan.md commands/ecc-multi-plan.md`
Expected: File renamed

**Step 16: Rename multi-workflow.md**

Run: `mv commands/multi-workflow.md commands/ecc-multi-workflow.md`
Expected: File renamed

**Step 17: Rename orchestrate.md**

Run: `mv commands/orchestrate.md commands/ecc-orchestrate.md`
Expected: File renamed

**Step 18: Rename python-review.md**

Run: `mv commands/python-review.md commands/ecc-python-review.md`
Expected: File renamed

**Step 19: Rename refactor-clean.md**

Run: `mv commands/refactor-clean.md commands/ecc-refactor-clean.md`
Expected: File renamed

**Step 20: Rename sessions.md**

Run: `mv commands/sessions.md commands/ecc-sessions.md`
Expected: File renamed

**Step 21: Rename setup-pm.md**

Run: `mv commands/setup-pm.md commands/ecc-setup-pm.md`
Expected: File renamed

**Step 22: Rename skill-create.md**

Run: `mv commands/skill-create.md commands/ecc-skill-create.md`
Expected: File renamed

**Step 23: Rename test-coverage.md**

Run: `mv commands/test-coverage.md commands/ecc-test-coverage.md`
Expected: File renamed

**Step 24: Rename update-codemaps.md**

Run: `mv commands/update-codemaps.md commands/ecc-update-codemaps.md`
Expected: File renamed

**Step 25: Rename update-docs.md**

Run: `mv commands/update-docs.md commands/ecc-update-docs.md`
Expected: File renamed

**Step 26: Rename verify.md**

Run: `mv commands/verify.md commands/ecc-verify.md`
Expected: File renamed

**Step 27: Verify renames**

Run: `ls commands/ecc-*.md | wc -l`
Expected: 26

---

### Task 5: Update Command Invocation Syntax

**Files:**
- Modify: All `commands/ecc-*.md` files

**Step 1: Update ecc-build-fix.md syntax**

Modify: `commands/ecc-build-fix.md`

Find and replace invocation examples:
- Change `/build-fix` to `/ecc:build-fix`
- Update any internal references

**Step 2: Update ecc-test-coverage.md syntax**

Modify: `commands/ecc-test-coverage.md`

Find and replace:
- Change `/test-coverage` to `/ecc:test-coverage`

**Step 3: Update ecc-e2e.md syntax**

Modify: `commands/ecc-e2e.md`

Find and replace:
- Change `/e2e` to `/ecc:e2e`

**Step 4: Update ecc-learn.md syntax**

Modify: `commands/ecc-learn.md`

Find and replace:
- Change `/learn` to `/ecc:learn`

**Step 5: Update ecc-instinct-status.md syntax**

Modify: `commands/ecc-instinct-status.md`

Find and replace:
- Change `/instinct-status` to `/ecc:instinct-status`

**Step 6: Update ecc-instinct-import.md syntax**

Modify: `commands/ecc-instinct-import.md`

Find and replace:
- Change `/instinct-import` to `/ecc:instinct-import`

**Step 7: Update ecc-instinct-export.md syntax**

Modify: `commands/ecc-instinct-export.md`

Find and replace:
- Change `/instinct-export` to `/ecc:instinct-export`

**Step 8: Update ecc-evolve.md syntax**

Modify: `commands/ecc-evolve.md`

Find and replace:
- Change `/evolve` to `/ecc:evolve`

**Step 9: Update remaining command files**

Modify: All remaining `commands/ecc-*.md` files

For each file, update invocation syntax to use `/ecc:` prefix

**Step 10: Verify syntax updates**

Run: `grep -l "/ecc:" commands/ecc-*.md | wc -l`
Expected: 26

---

### Task 6: Strip Git Write Operations from Commands

**Files:**
- Modify: All `commands/ecc-*.md` files

**Step 1: Scan for git write operations**

Run:
```bash
grep -n "git commit\|git push\|git merge\|git checkout\|git branch -\|git worktree\|git reset\|git rebase" commands/ecc-*.md
```

Expected: List of files with git write operations (if any)

**Step 2: Remove git write operations from flagged files**

For each file found in Step 1:
- Remove `git commit` commands
- Remove `git push` commands
- Remove `git merge` commands
- Remove `git checkout` commands
- Remove `git branch` creation/deletion
- Remove `git worktree` operations
- Remove `git reset` commands
- Remove `git rebase` commands

Keep read-only operations:
- `git status`
- `git diff`
- `git log`
- `git show`

**Step 3: Add git policy to command docs**

For each `commands/ecc-*.md` file that had git operations:

Add section:
```markdown
## Git Policy

This command uses git for context only (status, diff, log).
No git write operations are performed.
You remain in your current directory and branch.
```

**Step 4: Verify git write operations removed**

Run:
```bash
grep -n "git commit\|git push\|git merge\|git checkout -\|git reset\|git rebase" commands/ecc-*.md
```

Expected: No results (only read operations like "git checkout main" in documentation context is OK)

---

### Task 7: Read Existing Hooks Configuration

**Files:**
- Check: `hooks/hooks.json` (if exists)
- Reference: `D:\Projects\everything-claude-code-main\hooks\hooks.json`

**Step 1: Check if hooks.json exists**

Run: `test -f hooks/hooks.json && echo "Exists" || echo "Not found"`
Expected: Either "Exists" or "Not found"

**Step 2: Read existing hooks (if exists)**

If exists, run: `cat hooks/hooks.json`
Expected: Current hooks configuration

**Step 3: Read ECC hooks configuration**

Run: `cat "D:\Projects\everything-claude-code-main\hooks\hooks.json"`
Expected: ECC hooks configuration displayed

**Step 4: Document hooks to merge**

Create: `docs/plans/hooks-merge-analysis.md`

Content:
```markdown
# Hooks Merge Analysis

## Existing Superpowers Hooks
[Paste output from Step 2, or "None" if doesn't exist]

## ECC Hooks to Integrate
[Paste output from Step 3]

## Conflicts Identified
[List any overlapping hook types]

## Merge Strategy
[Document which hooks to keep, merge, or modify]
```

**Step 5: Verify analysis document created**

Run: `test -f docs/plans/hooks-merge-analysis.md && echo "Created"`
Expected: "Created"

---

### Task 8: Create Git Write Blocker Hook Script

**Files:**
- Create: `scripts/hooks/block-git-writes.js`

**Step 1: Create hooks directory if needed**

Run: `mkdir -p scripts/hooks`
Expected: Directory created (if didn't exist)

**Step 2: Write block-git-writes.js**

Create: `scripts/hooks/block-git-writes.js`

```javascript
#!/usr/bin/env node

/**
 * Pre-tool-use hook to block git write operations
 * Checks if Bash command contains git write operations
 * Returns error if detected, allows if read-only or non-git
 */

const fs = require('fs');
const path = require('path');

// Git write operations to block
const BLOCKED_OPERATIONS = [
  'git commit',
  'git push',
  'git pull',
  'git merge',
  'git checkout',
  'git switch',
  'git branch -',
  'git branch -D',
  'git worktree add',
  'git worktree remove',
  'git reset',
  'git rebase',
  'git stash',
  'git cherry-pick',
  'git tag ',
  'git remote add',
  'git remote remove',
  'git remote set-url'
];

// Read tool use from stdin
let input = '';
process.stdin.on('data', (chunk) => {
  input += chunk;
});

process.stdin.on('end', () => {
  try {
    const toolUse = JSON.parse(input);

    // Only check Bash tool
    if (toolUse.tool !== 'Bash') {
      process.exit(0); // Allow non-Bash tools
    }

    const command = toolUse.parameters?.command || '';

    // Check for blocked operations
    for (const blockedOp of BLOCKED_OPERATIONS) {
      if (command.includes(blockedOp)) {
        console.error(`\nGit write operation blocked: "${blockedOp}"`);
        console.error('Policy: Git write operations must be performed manually by user.');
        console.error('Read-only operations (status, diff, log) are allowed.\n');
        process.exit(1); // Block the operation
      }
    }

    // Allow the operation
    process.exit(0);

  } catch (error) {
    console.error('Error in block-git-writes hook:', error.message);
    process.exit(0); // Allow on error to not break workflow
  }
});
```

**Step 3: Make script executable**

Run: `chmod +x scripts/hooks/block-git-writes.js`
Expected: Script is executable

**Step 4: Verify script created**

Run: `test -f scripts/hooks/block-git-writes.js && echo "Created"`
Expected: "Created"

---

### Task 9: Merge Hooks Configuration

**Files:**
- Create/Modify: `hooks/hooks.json`
- Reference: `docs/plans/hooks-merge-analysis.md`

**Step 1: Create base hooks.json structure**

Create: `hooks/hooks.json`

```json
{
  "hooks": [
    {
      "type": "PreToolUse",
      "tool": "Bash",
      "command": "node scripts/hooks/block-git-writes.js",
      "description": "Block git write operations"
    }
  ]
}
```

**Step 2: Add SessionStart hook**

Modify: `hooks/hooks.json`

Add to hooks array:
```json
{
  "type": "SessionStart",
  "command": "node scripts/hooks/session-start.js",
  "description": "Load previous context and memory"
}
```

**Step 3: Add SessionEnd hook**

Modify: `hooks/hooks.json`

Add to hooks array:
```json
{
  "type": "SessionEnd",
  "command": "node scripts/hooks/session-end.js",
  "description": "Save session state for next time"
}
```

**Step 4: Add PreCompact hook**

Modify: `hooks/hooks.json`

Add to hooks array:
```json
{
  "type": "PreCompact",
  "command": "node scripts/hooks/pre-compact.js",
  "description": "Save state before compaction"
}
```

**Step 5: Add strategic compaction hook**

Modify: `hooks/hooks.json`

Add to hooks array:
```json
{
  "type": "PostToolUse",
  "command": "node scripts/hooks/suggest-compact.js",
  "description": "Suggest compaction when context is large"
}
```

**Step 6: Verify hooks.json structure**

Run: `cat hooks/hooks.json | jq '.hooks | length'`
Expected: 5

**Step 7: Validate JSON**

Run: `cat hooks/hooks.json | jq .`
Expected: Valid JSON output

---

## Phase 2: Enhancements

### Task 10: Create Mode Skills from ECC Contexts

**Files:**
- Create: `skills/contexts/superpowers-research-mode/SKILL.md`
- Reference: `D:\Projects\everything-claude-code-main\contexts\research.md`

**Step 1: Create contexts directory**

Run: `mkdir -p skills/contexts/superpowers-research-mode`
Expected: Directory created

**Step 2: Read ECC research context**

Run: `cat "D:\Projects\everything-claude-code-main\contexts\research.md"`
Expected: Research context content

**Step 3: Create superpowers-research-mode skill**

Create: `skills/contexts/superpowers-research-mode/SKILL.md`

```markdown
---
name: superpowers-research-mode
description: Deep codebase exploration mode - invoked BY workflow skills during research phases, not as workflow replacement
---

# Superpowers Research Mode

## Overview

Temporary behavior modifier for deep codebase exploration.

**Invoked by:** brainstorming skill during "understanding the idea" phase
**Not:** A replacement for systematic workflow
**Purpose:** Optimize for information gathering and context building

## When Active

This mode is active when invoked by workflow skills that need deep exploration.

**Characteristics:**
- Lighter prompts optimized for information gathering
- Focus on understanding existing code and patterns
- Efficient token usage for context building
- Multiple rapid queries for comprehensive understanding

## Behavior Adjustments

**Exploration:**
- Use Grep and Glob liberally for code discovery
- Read multiple files to understand patterns
- Build mental model of codebase structure
- Identify relevant files quickly

**Communication:**
- Concise explanations focused on facts
- Less verbose than normal mode
- Quick summaries of findings
- Direct answers to research questions

**Token Efficiency:**
- Skip unnecessary context in responses
- Focus on actionable information
- Use parallel tool calls when possible
- Minimize redundant explanations

## Integration with Workflow

**Invocation Pattern:**
```
During brainstorming:
1. User asks about existing codebase patterns
2. Workflow invokes: superpowers:research-mode
3. Research mode explores codebase efficiently
4. Findings inform design discussion
5. Exit research mode, continue brainstorming
```

**Not Used For:**
- Implementing code (use normal mode)
- Writing tests (use TDD mode)
- Code review (use review mode)

## Exit Condition

Research mode exits automatically when:
- Research questions answered
- Invoking workflow skill completes
- Next workflow step begins

---

**Remember:** This is a tool WITHIN the workflow, not an alternative TO the workflow.
```

**Step 4: Verify skill created**

Run: `test -f skills/contexts/superpowers-research-mode/SKILL.md && echo "Created"`
Expected: "Created"

---

### Task 11: Create Review Mode Skill

**Files:**
- Create: `skills/contexts/superpowers-review-mode/SKILL.md`
- Reference: `D:\Projects\everything-claude-code-main\contexts\review.md`

**Step 1: Create directory**

Run: `mkdir -p skills/contexts/superpowers-review-mode`
Expected: Directory created

**Step 2: Create superpowers-review-mode skill**

Create: `skills/contexts/superpowers-review-mode/SKILL.md`

```markdown
---
name: superpowers-review-mode
description: Focused code review mindset - invoked BY workflow skills during review phases
---

# Superpowers Review Mode

## Overview

Temporary behavior modifier for focused code review.

**Invoked by:** Code review workflows
**Purpose:** Optimize for finding issues and suggesting improvements

## When Active

This mode is active during code review workflows.

**Characteristics:**
- Critical eye for potential issues
- Focus on quality, security, and maintainability
- Structured feedback delivery
- Evidence-based critique

## Behavior Adjustments

**Analysis:**
- Check for security vulnerabilities
- Identify performance issues
- Spot code smells and anti-patterns
- Verify test coverage
- Check error handling

**Communication:**
- Structured feedback (issues, suggestions, praise)
- Specific line references
- Concrete examples of improvements
- Prioritized feedback (critical vs. nice-to-have)

**Focus Areas:**
- Correctness: Does it work as intended?
- Security: Any vulnerabilities?
- Performance: Any bottlenecks?
- Maintainability: Easy to understand and change?
- Testing: Adequate coverage?

## Integration with Workflow

**Invocation Pattern:**
```
During code review:
1. Review workflow begins
2. Invoke: superpowers:review-mode
3. Analyze code with critical mindset
4. Provide structured feedback
5. Exit review mode
```

## Exit Condition

Review mode exits when review workflow completes.

---

**Remember:** This enhances the review workflow, doesn't replace it.
```

**Step 3: Verify skill created**

Run: `test -f skills/contexts/superpowers-review-mode/SKILL.md && echo "Created"`
Expected: "Created"

---

### Task 12: Create Dev Mode Skill

**Files:**
- Create: `skills/contexts/superpowers-dev-mode/SKILL.md`
- Reference: `D:\Projects\everything-claude-code-main\contexts\dev.md`

**Step 1: Create directory**

Run: `mkdir -p skills/contexts/superpowers-dev-mode`
Expected: Directory created

**Step 2: Create superpowers-dev-mode skill**

Create: `skills/contexts/superpowers-dev-mode/SKILL.md`

```markdown
---
name: superpowers-dev-mode
description: Implementation-focused mindset - invoked BY workflow skills during active development
---

# Superpowers Dev Mode

## Overview

Temporary behavior modifier for focused implementation.

**Invoked by:** Development workflow during coding
**Purpose:** Optimize for efficient, quality code implementation

## When Active

This mode is active during implementation phases.

**Characteristics:**
- Focus on writing clean, tested code
- TDD discipline (RED-GREEN-REFACTOR)
- Frequent small commits
- YAGNI and DRY principles

## Behavior Adjustments

**Implementation:**
- Write tests first (TDD)
- Minimal code to pass tests
- Refactor after green
- Follow language-specific patterns

**Communication:**
- Clear about what's being implemented
- Explain trade-offs when relevant
- Show test results
- Concise commit messages

**Quality Focus:**
- Tests before implementation
- Clean, readable code
- Appropriate abstractions (not premature)
- Error handling where needed (not everywhere)

## Integration with Workflow

**Invocation Pattern:**
```
During implementation:
1. Task begins
2. Invoke: superpowers:dev-mode
3. Follow TDD cycle for each feature
4. Write clean, tested code
5. Exit dev mode when task complete
```

## Exit Condition

Dev mode exits when implementation task completes.

---

**Remember:** This enhances the TDD workflow, doesn't replace it.
```

**Step 3: Verify skill created**

Run: `test -f skills/contexts/superpowers-dev-mode/SKILL.md && echo "Created"`
Expected: "Created"

---

### Task 13: Create Extract Patterns Skill

**Files:**
- Create: `skills/superpowers/extract-patterns/SKILL.md`
- Reference: `D:\Projects\everything-claude-code-main\skills\continuous-learning-v2\SKILL.md`

**Step 1: Create directory**

Run: `mkdir -p skills/superpowers/extract-patterns`
Expected: Directory created

**Step 2: Create extract-patterns skill**

Create: `skills/superpowers/extract-patterns/SKILL.md`

```markdown
---
name: superpowers-extract-patterns
description: Extract learned patterns from session - invoked automatically by finishing-a-development-branch or manually anytime
---

# Extract Patterns

## Overview

Wraps ECC's continuous-learning-v2 system to extract and save useful patterns from development sessions.

**Auto-invoked by:** finishing-a-development-branch skill
**Can be invoked:** Manually anytime to save learning
**Purpose:** Build institutional knowledge over time

**Announce at start:** "I'm using the extract-patterns skill to learn from this session."

## The Process

### Step 1: Invoke Pattern Extraction

Use `/ecc:learn` command to extract patterns:

```
/ecc:learn
```

This analyzes the current session for:
- Successful problem-solving approaches
- Useful code patterns
- Effective debugging strategies
- Language/framework insights
- Common mistake avoidance

### Step 2: Review Extracted Patterns

The learning system will show patterns with confidence scores.

**Review criteria:**
- Is the pattern actually useful?
- Is the confidence score appropriate?
- Would this help in future sessions?

### Step 3: Save to Instinct System

Patterns are automatically saved to the instinct system.

**View saved patterns:**
```
/ecc:instinct-status
```

### Step 4: Optional - Evolve into Skills

For mature patterns (high confidence, multiple uses):

```
/ecc:evolve
```

This clusters related patterns into reusable skills.

## Integration with Workflow

**Auto-Invoked:**
```
finishing-a-development-branch:
1. Verify tests pass
2. Sync documentation
3. Extract patterns (THIS SKILL) ← Auto-invoked
4. Generate changelist
5. Present options
```

**Manual Invocation:**
```
Any time during development:
- "Can you extract patterns from what we just did?"
- Skill invoked
- Patterns saved for future
```

## Opt-Out

To disable auto-invocation in finishing workflow:

See: `docs/integration/OPT-OUT.md`

## Exporting/Importing Patterns

**Export patterns to file:**
```
/ecc:instinct-export
```

**Import patterns from file:**
```
/ecc:instinct-import
```

Useful for:
- Sharing patterns across teams
- Backing up learned knowledge
- Transferring patterns between projects

## Quick Reference

| Command | Purpose |
|---------|---------|
| `/ecc:learn` | Extract patterns from session |
| `/ecc:instinct-status` | View saved patterns |
| `/ecc:instinct-export` | Export to file |
| `/ecc:instinct-import` | Import from file |
| `/ecc:evolve` | Cluster patterns into skills |

## Remember

- Patterns accumulate over time
- Higher confidence = more proven
- Export periodically for backup
- Share successful patterns with team

---

**Remember:** This builds institutional knowledge. The more you use it, the smarter the system becomes.
```

**Step 3: Verify skill created**

Run: `test -f skills/superpowers/extract-patterns/SKILL.md && echo "Created"`
Expected: "Created"

---

### Task 14: Enhance test-driven-development Skill (Part 1)

**Files:**
- Modify: `skills/superpowers/test-driven-development/SKILL.md`

**Step 1: Read current TDD skill**

Run: `cat skills/superpowers/test-driven-development/SKILL.md`
Expected: Current TDD skill content

**Step 2: Add coverage tracking section**

Modify: `skills/superpowers/test-driven-development/SKILL.md`

Add new section after RED-GREEN-REFACTOR cycle:

```markdown
## Coverage Tracking (Enhanced)

After completing a feature with tests, check coverage:

**Check coverage:**
```
/ecc:test-coverage
```

**Interpret results:**
- **80%+ coverage:** Good baseline
- **90%+ coverage:** Excellent
- **<80% coverage:** Add more tests

**Focus on:**
- Critical paths (authentication, payment, data integrity)
- Error handling branches
- Edge cases
- Complex business logic

**Don't obsess over:**
- Trivial getters/setters
- Framework boilerplate
- Auto-generated code

**Coverage is a guide, not a goal.** High coverage + poor tests = false confidence.

## E2E Test Generation (Enhanced, Opt-Out Available)

For user-facing features (UI, API endpoints), consider E2E tests.

**When to suggest:**
- New user workflows
- Critical user journeys
- API endpoints with complex flows

**Suggestion pattern:**
```
"This is a user-facing feature. Would you like to generate E2E tests?"

If yes: /ecc:e2e
If no: Continue with unit tests only
```

**Never:** Force E2E generation. It's optional.

**Opt-out:** See `docs/integration/OPT-OUT.md` to disable E2E suggestions.
```

**Step 3: Verify sections added**

Run: `grep -q "Coverage Tracking" skills/superpowers/test-driven-development/SKILL.md && echo "Found"`
Expected: "Found"

---

(Continuing with remaining tasks... Due to length, I'll create the complete implementation plan)
