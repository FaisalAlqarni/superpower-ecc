# Hooks Merge Analysis

## Existing Superpowers Hooks

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh",
            "async": true
          }
        ]
      }
    ]
  }
}
```

**Summary:** Superpowers has a minimal hooks configuration with only a SessionStart hook that runs a shell script asynchronously.

## ECC Hooks to Integrate

ECC has a comprehensive hooks configuration with 6 hook types:

1. **PreToolUse** (5 matchers):
   - Block dev servers outside tmux
   - Remind to use tmux for long-running commands
   - Reminder before git push
   - Block creation of random .md files
   - Suggest manual compaction (uses script: `scripts/hooks/suggest-compact.js`)

2. **PreCompact** (1 matcher):
   - Save state before context compaction (uses script: `scripts/hooks/pre-compact.js`)

3. **SessionStart** (1 matcher):
   - Load previous context and detect package manager (uses script: `scripts/hooks/session-start.js`)

4. **PostToolUse** (5 matchers):
   - Log PR URL after creation
   - Build analysis (async)
   - Auto-format JS/TS with Prettier
   - TypeScript check after edits
   - Warn about console.log statements

5. **Stop** (1 matcher):
   - Check for console.log in modified files (uses script: `scripts/hooks/check-console-log.js`)

6. **SessionEnd** (2 matchers):
   - Persist session state (uses script: `scripts/hooks/session-end.js`)
   - Evaluate session for extractable patterns (uses script: `scripts/hooks/evaluate-session.js`)

## Conflicts Identified

### SessionStart Hook Conflict

**Superpowers SessionStart:**
- Uses shell script: `${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh`
- Async execution
- Matcher: "startup|resume|clear|compact"

**ECC SessionStart:**
- Uses Node.js script: `${CLAUDE_PLUGIN_ROOT}/scripts/hooks/session-start.js`
- No async specified (defaults to sync)
- Matcher: "*" (universal)
- Description: "Load previous context and detect package manager on new session"

**Key Difference:** Superpowers uses a shell script while ECC uses a Node.js script. Both serve session initialization purposes but with different implementations.

## Merge Strategy

### 1. SessionStart Hook
**Decision:** Keep BOTH hooks initially, then evaluate which to standardize on.

**Reasoning:**
- Superpowers' shell-based approach may have specific initialization logic
- ECC's Node.js approach provides cross-platform compatibility and package manager detection
- Running both shouldn't cause conflicts since they're async and likely handle different concerns

**Recommendation:**
- Keep Superpowers hook first (preserves existing behavior)
- Add ECC hook second
- After testing, consolidate into a single unified script

### 2. PreToolUse Hooks
**Decision:** Adopt ALL ECC PreToolUse hooks.

**Reasoning:**
- Superpowers has no PreToolUse hooks currently
- ECC hooks provide valuable guardrails:
  - Tmux enforcement for dev servers (prevents lost logs)
  - Documentation file prevention (enforces consolidation)
  - Git push reminders (prevents accidental pushes)
  - Compaction suggestions (improves context management)

**Action:** Copy all 5 PreToolUse matchers from ECC.

### 3. PreCompact Hook
**Decision:** Adopt ECC PreCompact hook.

**Reasoning:**
- Superpowers has no PreCompact hooks
- State preservation before compaction is critical
- Requires script: `scripts/hooks/pre-compact.js`

**Action:** Add PreCompact section from ECC.

### 4. PostToolUse Hooks
**Decision:** Adopt ALL ECC PostToolUse hooks.

**Reasoning:**
- Superpowers has no PostToolUse hooks
- ECC hooks provide excellent DX improvements:
  - PR creation feedback
  - Auto-formatting with Prettier
  - TypeScript validation
  - console.log detection

**Action:** Copy all 5 PostToolUse matchers from ECC.

### 5. Stop Hook
**Decision:** Adopt ECC Stop hook.

**Reasoning:**
- Superpowers has no Stop hooks
- console.log checking after each response prevents code quality issues
- Requires script: `scripts/hooks/check-console-log.js`

**Action:** Add Stop section from ECC.

### 6. SessionEnd Hooks
**Decision:** Adopt BOTH ECC SessionEnd hooks.

**Reasoning:**
- Superpowers has no SessionEnd hooks
- State persistence is critical for continuity
- Session evaluation enables pattern extraction
- Requires scripts: `scripts/hooks/session-end.js`, `scripts/hooks/evaluate-session.js`

**Action:** Add SessionEnd section from ECC.

## Script Dependencies

The merged hooks configuration requires these scripts from ECC:
- `scripts/hooks/suggest-compact.js` (PreToolUse)
- `scripts/hooks/pre-compact.js` (PreCompact)
- `scripts/hooks/session-start.js` (SessionStart)
- `scripts/hooks/check-console-log.js` (Stop)
- `scripts/hooks/session-end.js` (SessionEnd)
- `scripts/hooks/evaluate-session.js` (SessionEnd)

Plus Superpowers' existing script:
- `hooks/session-start.sh` (SessionStart)

**Note:** All ECC scripts are under `scripts/hooks/` while Superpowers uses `hooks/` directly. The merged configuration preserves these paths.

## Recommended Final Structure

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "tool == \"Bash\" && tool_input.command matches \"(npm run dev|pnpm( run)? dev|yarn dev|bun run dev)\"",
        "hooks": [
          {
            "type": "command",
            "command": "node -e \"console.error('[Hook] BLOCKED: Dev server must run in tmux for log access');console.error('[Hook] Use: tmux new-session -d -s dev \\\"npm run dev\\\"');console.error('[Hook] Then: tmux attach -t dev');process.exit(1)\""
          }
        ],
        "description": "Block dev servers outside tmux - ensures you can access logs"
      },
      {
        "matcher": "tool == \"Bash\" && tool_input.command matches \"(npm (install|test)|pnpm (install|test)|yarn (install|test)?|bun (install|test)|cargo build|make|docker|pytest|vitest|playwright)\"",
        "hooks": [
          {
            "type": "command",
            "command": "node -e \"if(!process.env.TMUX){console.error('[Hook] Consider running in tmux for session persistence');console.error('[Hook] tmux new -s dev  |  tmux attach -t dev')}\""
          }
        ],
        "description": "Reminder to use tmux for long-running commands"
      },
      {
        "matcher": "tool == \"Bash\" && tool_input.command matches \"git push\"",
        "hooks": [
          {
            "type": "command",
            "command": "node -e \"console.error('[Hook] Review changes before push...');console.error('[Hook] Continuing with push (remove this hook to add interactive review)')\""
          }
        ],
        "description": "Reminder before git push to review changes"
      },
      {
        "matcher": "tool == \"Write\" && tool_input.file_path matches \"\\\\.(md|txt)$\" && !(tool_input.file_path matches \"README\\\\.md|CLAUDE\\\\.md|AGENTS\\\\.md|CONTRIBUTING\\\\.md\")",
        "hooks": [
          {
            "type": "command",
            "command": "node -e \"const fs=require('fs');let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{const i=JSON.parse(d);const p=i.tool_input?.file_path||'';if(/\\.(md|txt)$/.test(p)&&!/(README|CLAUDE|AGENTS|CONTRIBUTING)\\.md$/.test(p)){console.error('[Hook] BLOCKED: Unnecessary documentation file creation');console.error('[Hook] File: '+p);console.error('[Hook] Use README.md for documentation instead');process.exit(1)}console.log(d)})\""
          }
        ],
        "description": "Block creation of random .md files - keeps docs consolidated"
      },
      {
        "matcher": "tool == \"Edit\" || tool == \"Write\"",
        "hooks": [
          {
            "type": "command",
            "command": "node \"${CLAUDE_PLUGIN_ROOT}/scripts/hooks/suggest-compact.js\""
          }
        ],
        "description": "Suggest manual compaction at logical intervals"
      }
    ],
    "PreCompact": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "node \"${CLAUDE_PLUGIN_ROOT}/scripts/hooks/pre-compact.js\""
          }
        ],
        "description": "Save state before context compaction"
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh",
            "async": true
          }
        ],
        "description": "Superpowers session initialization (shell-based)"
      },
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "node \"${CLAUDE_PLUGIN_ROOT}/scripts/hooks/session-start.js\""
          }
        ],
        "description": "Load previous context and detect package manager on new session"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "tool == \"Bash\"",
        "hooks": [
          {
            "type": "command",
            "command": "node -e \"let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{const i=JSON.parse(d);const cmd=i.tool_input?.command||'';if(/gh pr create/.test(cmd)){const out=i.tool_output?.output||'';const m=out.match(/https:\\/\\/github.com\\/[^/]+\\/[^/]+\\/pull\\/\\d+/);if(m){console.error('[Hook] PR created: '+m[0]);const repo=m[0].replace(/https:\\/\\/github.com\\/([^/]+\\/[^/]+)\\/pull\\/\\d+/,'$1');const pr=m[0].replace(/.*\\/pull\\/(\\d+)/,'$1');console.error('[Hook] To review: gh pr review '+pr+' --repo '+repo)}}console.log(d)})\""
          }
        ],
        "description": "Log PR URL and provide review command after PR creation"
      },
      {
        "matcher": "tool == \"Bash\" && tool_input.command matches \"(npm run build|pnpm build|yarn build)\"",
        "hooks": [
          {
            "type": "command",
            "command": "node -e \"let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{console.error('[Hook] Build completed - async analysis running in background');console.log(d)})\"",
            "async": true,
            "timeout": 30
          }
        ],
        "description": "Example: async hook for build analysis (runs in background without blocking)"
      },
      {
        "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\\\.(ts|tsx|js|jsx)$\"",
        "hooks": [
          {
            "type": "command",
            "command": "node -e \"const{execFileSync}=require('child_process');const fs=require('fs');let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{const i=JSON.parse(d);const p=i.tool_input?.file_path;if(p&&fs.existsSync(p)){try{execFileSync('npx',['prettier','--write',p],{stdio:['pipe','pipe','pipe']})}catch(e){}}console.log(d)})\""
          }
        ],
        "description": "Auto-format JS/TS files with Prettier after edits"
      },
      {
        "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\\\.(ts|tsx)$\"",
        "hooks": [
          {
            "type": "command",
            "command": "node -e \"const{execSync}=require('child_process');const fs=require('fs');const path=require('path');let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{const i=JSON.parse(d);const p=i.tool_input?.file_path;if(p&&fs.existsSync(p)){let dir=path.dirname(p);while(dir!==path.dirname(dir)&&!fs.existsSync(path.join(dir,'tsconfig.json'))){dir=path.dirname(dir)}if(fs.existsSync(path.join(dir,'tsconfig.json'))){try{const r=execSync('npx tsc --noEmit --pretty false 2>&1',{cwd:dir,encoding:'utf8',stdio:['pipe','pipe','pipe']});const lines=r.split('\\n').filter(l=>l.includes(p)).slice(0,10);if(lines.length)console.error(lines.join('\\n'))}catch(e){const lines=(e.stdout||'').split('\\n').filter(l=>l.includes(p)).slice(0,10);if(lines.length)console.error(lines.join('\\n'))}}}console.log(d)})\""
          }
        ],
        "description": "TypeScript check after editing .ts/.tsx files"
      },
      {
        "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\\\.(ts|tsx|js|jsx)$\"",
        "hooks": [
          {
            "type": "command",
            "command": "node -e \"const fs=require('fs');let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{const i=JSON.parse(d);const p=i.tool_input?.file_path;if(p&&fs.existsSync(p)){const c=fs.readFileSync(p,'utf8');const lines=c.split('\\n');const matches=[];lines.forEach((l,idx)=>{if(/console\\.log/.test(l))matches.push((idx+1)+': '+l.trim())});if(matches.length){console.error('[Hook] WARNING: console.log found in '+p);matches.slice(0,5).forEach(m=>console.error(m));console.error('[Hook] Remove console.log before committing')}}console.log(d)})\""
          }
        ],
        "description": "Warn about console.log statements after edits"
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "node \"${CLAUDE_PLUGIN_ROOT}/scripts/hooks/check-console-log.js\""
          }
        ],
        "description": "Check for console.log in modified files after each response"
      }
    ],
    "SessionEnd": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "node \"${CLAUDE_PLUGIN_ROOT}/scripts/hooks/session-end.js\""
          }
        ],
        "description": "Persist session state on end"
      },
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "node \"${CLAUDE_PLUGIN_ROOT}/scripts/hooks/evaluate-session.js\""
          }
        ],
        "description": "Evaluate session for extractable patterns"
      }
    ]
  }
}
```

## Implementation Notes

1. **JSON Schema:** ECC includes the `$schema` property for validation support. This should be retained.

2. **Script Location:** The merged configuration references scripts in two locations:
   - `${CLAUDE_PLUGIN_ROOT}/scripts/hooks/` (ECC scripts)
   - `${CLAUDE_PLUGIN_ROOT}/hooks/` (Superpowers script)

3. **Async Execution:** Only the Superpowers SessionStart hook and one ECC PostToolUse hook (build analysis) use async execution.

4. **Platform Compatibility:** Most inline Node.js hooks will work cross-platform. The Superpowers shell script may need Windows evaluation.

5. **Hook Order:** Superpowers SessionStart hook is listed first to preserve existing initialization order, with ECC's following.

## Next Steps

1. Copy required ECC hook scripts to `scripts/hooks/` directory
2. Test Superpowers' `hooks/session-start.sh` compatibility
3. Verify no conflicts between the two SessionStart hooks
4. Consider consolidating SessionStart hooks after testing
5. Update hooks.json with the merged configuration
6. Test all hook types individually
7. Document any issues or adjustments needed

## Potential Issues

1. **Dual SessionStart Hooks:** Running both may cause duplicated initialization. Monitor for conflicts.

2. **Script Dependencies:** The 6 ECC script files must exist or hooks will fail:
   - `suggest-compact.js`
   - `pre-compact.js`
   - `session-start.js`
   - `check-console-log.js`
   - `session-end.js`
   - `evaluate-session.js`

3. **Path Resolution:** Windows path handling in `${CLAUDE_PLUGIN_ROOT}` variable must work correctly.

4. **Performance:** Multiple hooks (especially PostToolUse) may add latency. Monitor performance impact.

5. **Prettier/TypeScript Dependencies:** PostToolUse hooks assume `prettier` and `tsc` are available. May need conditional checks.
