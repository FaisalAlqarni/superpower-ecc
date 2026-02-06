#!/bin/bash
# Cross-platform Node.js wrapper for Claude Code hooks
# Finds and executes node in common installation locations

# Try to find node in PATH first (works on Mac/Linux and properly configured Windows)
if command -v node >/dev/null 2>&1; then
    exec node "$@"
fi

# Try common installation paths
NODE_PATHS=(
    "/usr/local/bin/node"           # Mac/Linux: Homebrew, manual install
    "/usr/bin/node"                 # Linux: apt/yum install
    "/opt/homebrew/bin/node"        # Mac: Apple Silicon Homebrew
    "$HOME/.nvm/versions/node/*/bin/node"  # nvm install (find latest)
    "/c/Program Files/nodejs/node.exe"     # Windows: Git Bash path
    "C:/Program Files/nodejs/node.exe"     # Windows: native path
    "/mnt/c/Program Files/nodejs/node.exe" # WSL path
)

# Try each path
for node_path in "${NODE_PATHS[@]}"; do
    # Expand glob pattern for nvm
    for expanded_path in $node_path; do
        if [ -x "$expanded_path" ]; then
            exec "$expanded_path" "$@"
        fi
    done
done

# Node.js not found - provide helpful error
echo "[Hook Error] Node.js not found in PATH or common locations" >&2
echo "[Hook Error] " >&2
echo "[Hook Error] Hooks require Node.js to run. Please install Node.js:" >&2
echo "[Hook Error]   - Download: https://nodejs.org/ (LTS recommended)" >&2
echo "[Hook Error]   - Or use nvm: https://github.com/nvm-sh/nvm" >&2
echo "[Hook Error] " >&2
echo "[Hook Error] After installation:" >&2
echo "[Hook Error]   1. Restart your terminal/IDE" >&2
echo "[Hook Error]   2. Verify: node --version" >&2
echo "[Hook Error] " >&2
echo "[Hook Error] Hooks are optional - the plugin works without them" >&2
echo "[Hook Error] but you won't have git write blocking and other features" >&2
exit 1
