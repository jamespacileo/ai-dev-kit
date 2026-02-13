#!/usr/bin/env bash
set -euo pipefail

echo "Initializing ai-dev-kit..."

# Check prerequisites
command -v bd >/dev/null 2>&1 || { echo "Error: beads (bd) is not installed. Run: brew install beads (or npm install -g @beads/bd)"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "Error: git is not installed."; exit 1; }

# Initialize beads if not already done
if [ ! -d ".beads" ]; then
  bd init --quiet
  echo "Beads initialized (.beads/ created)"
else
  echo "Beads already initialized"
fi

# Install beads git hooks
bd hooks install 2>/dev/null && echo "Git hooks installed" || echo "Git hooks: skipped (may already exist)"

# Verify
echo ""
echo "Setup complete."
echo "Ready tasks: $(bd ready --json 2>/dev/null | grep -c '"id"' || echo 0)"
echo ""
echo "Next steps:"
echo "  1. Start planning:  /superpowers:brainstorm (in Claude Code)"
echo "  2. Create tasks:    bd create \"Task title\" -t task -p 2"
echo "  3. Run agent loop:  ralph -f .ralph/iterate.md --agent claude-code --max-iterations 20"
