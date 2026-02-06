---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for review, delivery, or cleanup
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling chosen workflow.

**Core principle:** Verify tests → Present options → Execute choice.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

**Note:** Git operations (branching, merging, worktrees, PRs) are disabled. This skill focuses on verification, presentation, and cleanup without touching git.

## The Process

### Step 1: Verify Tests

**Before presenting options, verify tests pass:**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**If tests fail:**
```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed until tests pass.
```

Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Step 2.

### Step 2: Summarize Work Done

Prepare a summary of what was implemented:

- **Files changed:** List all created, modified, and deleted files
- **Features added:** Bullet list of what's new
- **Tests added/updated:** Count and brief description
- **Verification status:** Test results, lint status, build status

### Step 3: Present Options

Present exactly these 4 options:

```
Implementation complete. All tests passing. What would you like to do?

1. Review the summary and mark complete
2. Generate a changelist/report I can use for a PR or handoff
3. Keep working (I want to make more changes)
4. Discard this work and revert my files

Which option?
```

**Don't add explanation** - keep options concise.

### Step 4: Execute Choice

#### Option 1: Review and Mark Complete

Present the full summary from Step 2 in a clean format:

```
## Completed Work

### Changes
- <file>: <what changed>
- <file>: <what changed>

### Test Results
<N> tests passing, 0 failing

### Ready for Integration
All implementation tasks complete and verified.
```

Then: Report done and ask if anything else is needed.

#### Option 2: Generate Changelist/Report

Generate a structured report suitable for a PR description, handoff doc, or commit message:

```markdown
## Summary
<2-3 bullets of what changed and why>

## Changes
- <file>: <description>
- <file>: <description>

## Test Plan
- [ ] <verification step>
- [ ] <verification step>

## Notes
<anything the reviewer should know>
```

Present this to the user for copy/paste. Do not run any git commands.

#### Option 3: Keep Working

Report: "Understood. Continuing development. Let me know what to work on next."

**Don't change anything.** Stay in current session context.

#### Option 4: Discard

**Confirm first:**
```
This will revert all changes made during this implementation:

Files modified:
- <list of files>

Type 'discard' to confirm.
```

Wait for exact confirmation.

If confirmed, explain which files to revert but **do not run git checkout, git reset, or any git commands**. Instead:

- For files that were modified: restore from last known good state if available, or tell the user which files to revert manually
- For files that were created: delete them
- For test files that were added: delete them

Report what was cleaned up.

## Quick Reference

| Option | Action | Stays in Session | Generates Report |
|--------|--------|-----------------|-----------------|
| 1. Review & complete | Summarize, mark done | No | Summary only |
| 2. Generate report | Create PR/handoff doc | No | Full changelist |
| 3. Keep working | Continue development | Yes | None |
| 4. Discard | Revert files | No | None |

## Common Mistakes

**Skipping test verification**
- **Problem:** Mark work complete when tests are broken
- **Fix:** Always verify tests before offering options

**Open-ended questions**
- **Problem:** "What should I do next?" → ambiguous
- **Fix:** Present exactly 4 structured options

**Running git commands**
- **Problem:** Git operations are disabled for this workflow
- **Fix:** Never run git commands. Summarize, report, or revert files directly

**No confirmation for discard**
- **Problem:** Accidentally delete work
- **Fix:** Require typed "discard" confirmation

## Red Flags

**Never:**
- Proceed with failing tests
- Run any git commands (commit, merge, push, checkout, branch, worktree, rebase, reset)
- Delete work without confirmation
- Assume which branch or remote to target

**Always:**
- Verify tests before offering options
- Present exactly 4 options
- Get typed confirmation for Option 4
- Generate clean, copy-pasteable reports for Option 2

## Integration

**Called by:**
- **subagent-driven-development** (Step 7) - After all tasks complete
- **executing-plans** (Step 5) - After all batches complete

**Works without:**
- **using-git-worktrees** - No worktree cleanup needed since git is disabled