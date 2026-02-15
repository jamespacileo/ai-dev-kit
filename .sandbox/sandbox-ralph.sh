#!/usr/bin/env bash
set -euo pipefail

# Start an autonomous Ralph Wiggum loop inside a Docker Sandbox.
# The sandbox provides microVM isolation so the agent runs with
# --dangerously-skip-permissions by default (the sandbox IS the security boundary).
#
# Usage:
#   .sandbox/sandbox-ralph.sh [project-dir] [max-iterations] [agent]
#
# Examples:
#   .sandbox/sandbox-ralph.sh .                     # Current dir, 30 iters, claude-code
#   .sandbox/sandbox-ralph.sh ~/myproject 50        # Custom dir, 50 iters
#   .sandbox/sandbox-ralph.sh . 20 codex            # Use Codex agent

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="${1:-.}"
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
MAX_ITERATIONS="${2:-30}"
AGENT="${3:-claude-code}"
SANDBOX_NAME="ralph-$(basename "$PROJECT_DIR")-$(date +%s)"

echo "══════════════════════════════════════════"
echo "  ai-dev-kit: Sandboxed Ralph Loop"
echo "══════════════════════════════════════════"
echo ""
echo "  Project:      $PROJECT_DIR"
echo "  Agent:        $AGENT"
echo "  Max iters:    $MAX_ITERATIONS"
echo "  Sandbox:      $SANDBOX_NAME"
echo ""

# ── Preflight checks ────────────────────────────────────────────────

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: Docker is not installed."
  echo "Install Docker Desktop 4.50+: https://www.docker.com/products/docker-desktop/"
  exit 1
fi

if ! docker sandbox version >/dev/null 2>&1; then
  echo "Error: Docker Sandboxes not available."
  echo "Requires Docker Desktop 4.50+ with Sandboxes enabled."
  echo "Enable in: Docker Desktop > Settings > Features in development > Docker Sandboxes"
  exit 1
fi

# ── Build custom template ───────────────────────────────────────────

if ! docker image inspect ai-dev-kit-sandbox:latest >/dev/null 2>&1; then
  echo "Building sandbox template (first time only)..."
  docker build -t ai-dev-kit-sandbox:latest "$SCRIPT_DIR"
  echo ""
fi

# ── Create sandbox ──────────────────────────────────────────────────

echo "Creating sandbox..."
docker sandbox create --name "$SANDBOX_NAME" \
  --load-local-template -t ai-dev-kit-sandbox:latest \
  claude "$PROJECT_DIR"

# ── Apply network policy ────────────────────────────────────────────

echo "Applying network policy (deny-by-default)..."
"$SCRIPT_DIR/network-policy.sh" "$SANDBOX_NAME" 2>/dev/null

# ── Start agent ─────────────────────────────────────────────────────

echo ""
echo "══════════════════════════════════════════"
echo "  Sandbox ready. Starting agent..."
echo "══════════════════════════════════════════"
echo ""
echo "  Monitor:   docker sandbox exec -it $SANDBOX_NAME bash"
echo "  Network:   docker sandbox network log"
echo "  Save:      docker sandbox save $SANDBOX_NAME checkpoint:v1"
echo "  Resume:    docker sandbox run $SANDBOX_NAME -- --continue"
echo "  Stop:      Ctrl+C"
echo "  Cleanup:   docker sandbox rm $SANDBOX_NAME"
echo ""

docker sandbox run "$SANDBOX_NAME"
