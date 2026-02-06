# Superpower-ECC

**An integration project combining [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent and [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) by Affaan Mustafa.**

This project merges the systematic workflows from Superpowers with the battle-tested production tools from Everything Claude Code, creating a comprehensive development toolkit for Claude Code with a three-layer architecture.

## Credits

- **Jesse Vincent** - Original [Superpowers v4.1.1](https://github.com/obra/superpowers) author (systematic workflows, TDD, debugging)
- **Affaan Mustafa** - Original [Everything Claude Code v1.4.1](https://github.com/affaan-m/everything-claude-code) author (agents, commands, hooks, patterns)
- **Faisal Alqarni** - Integration work and enhancements

**Source Versions:** Superpowers 4.1.1 + Everything Claude Code 1.4.1

## What This Project Provides

**Three-Layer Architecture:**
- **Layer 1** (from Superpowers): Systematic workflows (brainstorming → planning → execution → review)
- **Layer 2** (integrated): Mode skills and pattern extraction (auto-invoked by workflows)
- **Layer 3** (from ECC): Quick tools (26 commands, 13 specialist agents)

**Enhanced Language Support:**
- Ruby/Rails with **1,404 lines on Rails Engines** (added in this integration)
- Dart/Flutter with **state management decision matrices** (added in this integration)
- Python/Django, Go, Java/Spring Boot (from both projects)

**Git Safety** (from ECC): AI operations are read-only. You control commits, pushes, and history.

**Opt-Out-Able** (integrated): All auto-features can be disabled. See `docs/integration/OPT-OUT.md`.

## How It Works

**For Complex Features** (Layer 1 Workflows):

It starts from the moment you fire up your coding agent. As soon as it sees that you're building something, it *doesn't* just jump into trying to write code. Instead, it steps back and asks you what you're really trying to do.

Once it's teased a spec out of the conversation, it shows it to you in chunks short enough to actually read and digest.

After you've signed off on the design, your agent puts together an implementation plan that's clear enough for an enthusiastic junior engineer with poor taste, no judgement, no project context, and an aversion to testing to follow. It emphasizes true red/green TDD, YAGNI (You Aren't Gonna Need It), and DRY.

Next up, once you say "go", it launches a *subagent-driven-development* process, having agents work through each engineering task, inspecting and reviewing their work, and continuing forward. It's not uncommon for Claude to be able to work autonomously for a couple hours at a time without deviating from the plan you put together.

**For Quick Tasks** (Layer 3 Tools):

Need to fix a build error? `/ecc:build-fix`
Want test coverage? `/ecc:test-coverage`
Security audit needed? `@security-auditor`

Quick, focused, no ceremony. Use when you know exactly what you need.

**Best of Both Worlds:** Systematic workflows when you need structure. Quick tools when workflow is overkill.


## Support the Original Authors

This project builds on the excellent work of:

**Superpowers by Jesse Vincent:**
- Sponsor: [github.com/sponsors/obra](https://github.com/sponsors/obra)
- Project: [github.com/obra/superpowers](https://github.com/obra/superpowers)

**Everything Claude Code by Affaan Mustafa:**
- Project: [github.com/affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code)
- Twitter: [@affaanmustafa](https://x.com/affaanmustafa)


## Installation

**Note:** This is an independent integration project. For the original individual projects, see links above.

### Manual Installation for Claude Code

1. Clone this repository:
```bash
git clone https://github.com/FaisalAlqarni/superpower-ecc
```

2. Symlink to Claude Code plugins directory:
```bash
# On Windows
mklink /D "%USERPROFILE%\.claude\plugins\superpower-ecc" "path\to\superpower-ecc"

# On macOS/Linux
ln -s /path/to/superpower-ecc ~/.claude/plugins/superpower-ecc
```

3. Restart Claude Code

### Original Projects

To use the official versions instead:
- **Superpowers**: `/plugin install superpowers@superpowers-marketplace`
- **Everything Claude Code**: See [installation guide](https://github.com/affaan-m/everything-claude-code)

### Verify Installation

Start a new session and ask Claude to help with something that would trigger a skill (e.g., "help me plan this feature" or "let's debug this issue"). Claude should automatically invoke the relevant superpowers skill.


## Layer 1: The Systematic Workflow

1. **brainstorming** - Activates before writing code. Refines rough ideas through questions, explores alternatives, presents design in sections for validation. Saves design document.

2. **using-git-worktrees** - Activates after design approval. Creates isolated workspace (you create branch manually), runs project setup, verifies clean test baseline.

3. **writing-plans** - Activates with approved design. Breaks work into bite-sized tasks (2-5 minutes each). Every task has exact file paths, complete code, verification steps.

4. **subagent-driven-development** or **executing-plans** - Activates with plan. Dispatches fresh subagent per task with two-stage review (spec compliance, then code quality), or executes in batches with human checkpoints.

5. **test-driven-development** - Activates during implementation. Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass. **Enhanced with coverage tracking and E2E generation.**

6. **requesting-code-review** - Activates between tasks. Reviews against plan, reports issues by severity. Critical issues block progress.

7. **finishing-a-development-branch** - Activates when tasks complete. Verifies tests, **extracts learned patterns**, presents options (merge/PR/keep/discard - you execute), cleans up worktree.

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.

## Layer 2: Enhancements

**Mode Skills** (invoked BY workflows):
- **superpowers-research-mode** - Deep codebase exploration
- **superpowers-review-mode** - Critical code review focus
- **superpowers-dev-mode** - Implementation mindset

**Pattern Extraction:**
- **superpowers:extract-patterns** - Auto-invoked by finishing workflow, learns from your work

## Layer 3: Quick Tools

**Commands** (`/ecc:*`):
```
/ecc:build-fix          Fix build errors
/ecc:test-coverage      Check test coverage
/ecc:e2e                Generate E2E tests
/ecc:refactor-clean     Clean up code
/ecc:update-docs        Sync code and docs
/ecc:verify             Pre-commit verification
... 20 more commands
```

**Agents** (`agent-*` or `@agent-name`):
```
build-error-resolver        Fix build errors
test-failure-analyzer       Investigate test failures
security-auditor            Security review
performance-optimizer       Performance analysis
code-reviewer               Code review
... 8 more agents
```

**Decision Tree:** See `docs/integration/USAGE.md` for "which tool when" guide.

## What's Inside

### Layer 1: Systematic Workflows

**Testing**
- **test-driven-development** - RED-GREEN-REFACTOR cycle with coverage tracking and E2E generation

**Debugging**
- **systematic-debugging** - 4-phase root cause process with escalation to specialist agents
- **verification-before-completion** - Ensure it's actually fixed

**Collaboration**
- **brainstorming** - Socratic design refinement with research mode
- **writing-plans** - Detailed implementation plans
- **executing-plans** - Batch execution with checkpoints
- **subagent-driven-development** - Fast iteration with two-stage review (spec compliance, then code quality)
- **dispatching-parallel-agents** - Concurrent subagent workflows
- **requesting-code-review** - Pre-review checklist with review mode
- **receiving-code-review** - Responding to feedback
- **using-git-worktrees** - Parallel development branches (you create, AI guides)
- **finishing-a-development-branch** - Merge/PR decision workflow with pattern extraction

**Meta**
- **writing-skills** - Create new skills following best practices
- **using-superpowers** - Introduction to the skills system

### Layer 2: Enhancements

**Mode Skills** (auto-invoked):
- **superpowers-research-mode** - Deep exploration behavior
- **superpowers-review-mode** - Critical review behavior
- **superpowers-dev-mode** - Implementation behavior

**Pattern Learning:**
- **superpowers:extract-patterns** - Continuous learning from your work

### Layer 3: Quick Tools

**26 Commands** (`/ecc:*`): Build fixes, testing, code quality, development workflows

**13 Agents** (`agent-*`): Build errors, test failures, security, performance, code review, refactoring, documentation, API design, database, deployment

**Full List:** See `docs/integration/USAGE.md`

### Language & Framework Skills

**Ruby/Rails** (1,404 lines on Rails Engines):
- ruby-patterns, ruby-testing
- rails-patterns, rails-security, rails-tdd, rails-verification

**Dart/Flutter** (state management focus):
- dart-patterns, dart-testing
- flutter-patterns, flutter-verification (2,022 lines)

**Python/Django:**
- python-patterns, python-testing
- django-patterns, django-security, django-tdd, django-verification

**Go:**
- golang-patterns, golang-testing

**Java/Spring Boot:**
- java-coding-standards, jpa-patterns
- springboot-patterns, springboot-security, springboot-tdd, springboot-verification

**Databases:**
- postgres-patterns, clickhouse-io

### Hooks System

**6 Hook Types:** PreToolUse, PostToolUse, SessionStart, SessionEnd, PreCompact, Stop

**Key Hooks:**
- **Git write blocker** - Enforces read-only git operations (security)
- **Session evaluation** - Learn from completed sessions
- **TypeScript checking** - Type safety validation
- **Console.log warnings** - Code quality

**Configure:** `hooks/hooks.json`
**Opt-Out:** `docs/integration/OPT-OUT.md`

## Philosophy

- **Test-Driven Development** - Write tests first, always
- **Systematic over ad-hoc** - Process over guessing
- **Complexity reduction** - Simplicity as primary goal
- **Evidence over claims** - Verify before declaring success
- **User control** - AI guides, user executes (especially git operations)
- **Opt-out-able** - All auto-features can be disabled

Read more: [Superpowers for Claude Code](https://blog.fsck.com/2025/10/09/superpowers/)

## Documentation

**Getting Started:**
- **USAGE.md** - How to use three layers, decision trees for "which tool when"
- **MIGRATION.md** - Upgrading from v4.x or Everything Claude Code

**Deep Dives:**
- **ARCHITECTURE.md** - Three-layer architecture, git restrictions, hooks, security model

**Customization:**
- **OPT-OUT.md** - Disable E2E suggestions, pattern extraction, specific hooks

All docs: `docs/integration/`

## Contributing

Skills live directly in this repository. To contribute:

1. Create your feature branch
2. Create a branch for your skill
3. Follow the `writing-skills` skill for creating and testing new skills
4. Submit a PR

See `skills/writing-skills/SKILL.md` for the complete guide.

## Updating

Pull the latest changes from this repository:

```bash
cd path/to/superpower-ecc
git pull origin main
```

**Coming from Superpowers or ECC?** See `docs/integration/MIGRATION.md` for:
- What's changed in this integration
- How to use the three-layer architecture
- Migration paths from either project
- Common issues and solutions

## License

MIT License - see LICENSE file for details

## Support

**This Project:**
- Repository: https://github.com/FaisalAlqarni/superpower-ecc
- Issues: https://github.com/FaisalAlqarni/superpower-ecc/issues

**Original Projects:**
- Superpowers v4.1.1: https://github.com/obra/superpowers
- Everything Claude Code v1.4.1: https://github.com/affaan-m/everything-claude-code
