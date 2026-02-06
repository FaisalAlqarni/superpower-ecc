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
