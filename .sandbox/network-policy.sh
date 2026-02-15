#!/usr/bin/env bash
set -euo pipefail

# Configure Docker Sandbox network policy for autonomous agent sessions.
# Sets deny-by-default and whitelists only essential services.
#
# Usage: .sandbox/network-policy.sh <sandbox-name>

SANDBOX="${1:?Usage: $0 <sandbox-name>}"

echo "Applying network policy to sandbox: $SANDBOX"

# Default deny — block all outbound traffic
docker sandbox network proxy "$SANDBOX" --policy deny

# ── Claude API (required) ───────────────────────────────────────────
docker sandbox network proxy "$SANDBOX" --allow-host api.anthropic.com
docker sandbox network proxy "$SANDBOX" --allow-host statsig.anthropic.com
docker sandbox network proxy "$SANDBOX" --allow-host statsig.com
docker sandbox network proxy "$SANDBOX" --allow-host sentry.io

# ── Package registries ──────────────────────────────────────────────
docker sandbox network proxy "$SANDBOX" --allow-host "*.npmjs.org"
docker sandbox network proxy "$SANDBOX" --allow-host "*.yarnpkg.com"
docker sandbox network proxy "$SANDBOX" --allow-host registry.npmmirror.com

# ── GitHub ───────────────────────────────────────────────────────────
docker sandbox network proxy "$SANDBOX" --allow-host github.com
docker sandbox network proxy "$SANDBOX" --allow-host "*.github.com"
docker sandbox network proxy "$SANDBOX" --allow-host "*.githubusercontent.com"

# ── OpenAI (uncomment if using Codex) ───────────────────────────────
# docker sandbox network proxy "$SANDBOX" --allow-host api.openai.com

# ── Python (uncomment if needed) ────────────────────────────────────
# docker sandbox network proxy "$SANDBOX" --allow-host pypi.org
# docker sandbox network proxy "$SANDBOX" --allow-host files.pythonhosted.org

# ── Bun (uncomment if needed) ───────────────────────────────────────
# docker sandbox network proxy "$SANDBOX" --allow-host registry.npmjs.org

echo ""
echo "Network policy applied: deny-by-default"
echo "Allowed: Anthropic API, npm, GitHub"
echo ""
echo "View network logs:  docker sandbox network log"
echo "Add a domain:       docker sandbox network proxy $SANDBOX --allow-host example.com"
