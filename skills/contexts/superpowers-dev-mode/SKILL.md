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
