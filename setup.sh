#!/usr/bin/env bash
set -euo pipefail

echo "Initializing ai-dev-kit..."
echo ""

# ── Check core prerequisites ──────────────────────────────────────────

check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    echo "  [ok] $1"
    return 0
  else
    echo "  [missing] $1 — $2"
    return 1
  fi
}

echo "Checking prerequisites..."
MISSING=0
check_command bd "Install: brew install beads (or npm install -g @beads/bd)" || MISSING=1
check_command git "Install git from https://git-scm.com" || MISSING=1
check_command ralph "Install: npm install -g @th0rgal/ralph-wiggum" || MISSING=1

# Optional tools (warn but don't block)
echo ""
echo "Checking optional tools..."
check_command gitleaks "Install: brew install gitleaks (secret scanning)" || true
check_command mise "Install: curl https://mise.run | sh (environment management)" || true
check_command docker "Install Docker Desktop 4.50+ for sandboxed execution" || true

if [ "$MISSING" -eq 1 ]; then
  echo ""
  echo "Error: Required tools are missing. Install them and re-run setup.sh"
  exit 1
fi

# ── Initialize beads ──────────────────────────────────────────────────

echo ""
if [ ! -d ".beads" ]; then
  bd init --quiet
  echo "Beads initialized (.beads/ created)"
else
  echo "Beads already initialized"
fi

# Install beads git hooks
bd hooks install 2>/dev/null && echo "Git hooks installed" || echo "Git hooks: skipped (may already exist)"

# ── Install MCP servers (if claude CLI available) ─────────────────────

echo ""
if command -v claude >/dev/null 2>&1; then
  echo "Configuring MCP servers..."
  echo "  MCP servers are configured in .claude/settings.json (project-level)"
  echo "  They will activate when you open Claude Code in this directory"
  echo "  Servers: sequential-thinking, context7, memory, playwright, repomix"
else
  echo "Claude Code CLI not found — skip MCP server setup"
  echo "  Install Claude Code, then MCP servers will auto-configure from .claude/settings.json"
fi

# ── Install mise tool versions ────────────────────────────────────────

echo ""
if command -v mise >/dev/null 2>&1 && [ -f ".mise.toml" ]; then
  echo "Installing tool versions via mise..."
  mise install 2>/dev/null && echo "Tool versions pinned" || echo "mise install: skipped (check .mise.toml)"
else
  echo "mise not available — skip tool version pinning"
fi

# ── Docker Sandbox template ──────────────────────────────────────────

echo ""
if command -v docker >/dev/null 2>&1 && docker sandbox version >/dev/null 2>&1; then
  echo "Building Docker Sandbox template..."
  if docker build -t ai-dev-kit-sandbox:latest .sandbox/ 2>/dev/null; then
    echo "Sandbox template built: ai-dev-kit-sandbox:latest"
  else
    echo "Sandbox template build: skipped (check .sandbox/Dockerfile)"
  fi
else
  echo "Docker Sandboxes not available — skip template build"
  echo "  Install Docker Desktop 4.50+ for sandboxed agent execution"
fi

# ── Summary ───────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════"
echo "  Setup complete!"
echo "════════════════════════════════════════"
echo ""
echo "Ready tasks: $(bd ready --json 2>/dev/null | grep -c '"id"' || echo 0)"
echo ""
echo "Next steps:"
echo "  1. Start planning:       /superpowers:brainstorm (in Claude Code)"
echo "  2. Decompose into tasks: /decompose (in Claude Code)"
echo "  3. Check task status:    /status (in Claude Code)"
echo "  4. Run agent loop:       /sprint (in Claude Code)"
echo "  5. Sandboxed execution:  .sandbox/sandbox-ralph.sh . (requires Docker Desktop)"
echo ""
echo "Available skills: /decompose /sprint /review-sprint /status /create-adr"
