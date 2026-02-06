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
