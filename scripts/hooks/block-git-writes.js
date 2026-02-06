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
