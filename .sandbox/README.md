# Sandboxed Execution

Run AI coding agents with full permissions inside isolated microVMs. The sandbox is the security boundary — agents run with `--dangerously-skip-permissions` by default.

Requires **Docker Desktop 4.50+** with Docker Sandboxes enabled.

---

## Quick Start

```bash
# Run Claude Code in a sandbox (simplest)
docker sandbox run claude .

# Run with the ai-dev-kit custom template (includes Ralph + Beads)
docker build -t ai-dev-kit-sandbox:latest .sandbox/
docker sandbox run --load-local-template -t ai-dev-kit-sandbox:latest claude .

# Run an autonomous Ralph loop in a sandbox (one command)
.sandbox/sandbox-ralph.sh .
```

---

## How It Works

Docker Sandboxes create a **lightweight microVM** (not a container) for each agent session:

- **Own kernel**: Complete hypervisor-level isolation from your host
- **Private Docker daemon**: Agent can build/run containers without touching your host Docker
- **Network filtering**: Configurable domain allow/deny lists with HTTPS inspection
- **File sync**: Your project directory is synced bidirectionally between host and sandbox
- **Full permissions**: `--dangerously-skip-permissions` is enabled by default — the sandbox provides safety

### What's Included in the Custom Template

The `ai-dev-kit-sandbox:latest` template extends Docker's base Claude Code sandbox with:

| Tool | Purpose |
|------|---------|
| Ralph Wiggum (`ralph`) | Autonomous agent loop runner |
| Beads (`bd`) | Dependency-aware task tracking |
| build-essential | C/C++ compilation |
| python3-pip | Python package management |
| jq | JSON processing |

Plus everything in the base template: Docker CLI, GitHub CLI, Node.js, Go, Python 3, Git, ripgrep.

---

## Custom Template

### Modify the Template

Edit `.sandbox/Dockerfile` to add your project's dependencies:

```dockerfile
FROM docker/sandbox-templates:claude-code

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    your-package-here \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN npm install -g your-tool-here

# IMPORTANT: Switch back to agent user
USER agent
```

Rebuild after changes:

```bash
docker build -t ai-dev-kit-sandbox:latest .sandbox/
```

### Share Templates

```bash
# Push to a registry
docker tag ai-dev-kit-sandbox:latest myorg/ai-dev-kit-sandbox:latest
docker push myorg/ai-dev-kit-sandbox:latest

# Team members use it directly
docker sandbox run -t myorg/ai-dev-kit-sandbox:latest claude .
```

---

## Network Policy

By default, Docker Sandboxes allow all outbound traffic. For autonomous agent sessions, use deny-by-default:

```bash
# Apply the included policy (denies all, allows Anthropic API + npm + GitHub)
.sandbox/network-policy.sh <sandbox-name>

# Or configure manually
docker sandbox network proxy <sandbox-name> --policy deny
docker sandbox network proxy <sandbox-name> --allow-host api.anthropic.com
docker sandbox network proxy <sandbox-name> --allow-host github.com

# Add more domains as needed
docker sandbox network proxy <sandbox-name> --allow-host "*.your-registry.com"

# View network logs
docker sandbox network log
```

### Whitelisted Domains (Default Policy)

| Domain | Purpose |
|--------|---------|
| api.anthropic.com | Claude API |
| statsig.anthropic.com, statsig.com | Feature flags |
| sentry.io | Error reporting |
| *.npmjs.org, *.yarnpkg.com | npm/yarn packages |
| github.com, *.github.com | Git operations |
| *.githubusercontent.com | GitHub raw content |

---

## Ralph Loop Integration

### One-Command Sandboxed Sprint

```bash
# Default: current dir, 30 iterations, Claude Code
.sandbox/sandbox-ralph.sh .

# Custom configuration
.sandbox/sandbox-ralph.sh ~/myproject 50 claude-code
.sandbox/sandbox-ralph.sh . 20 codex
```

The script:
1. Builds the custom template (first time only)
2. Creates an isolated sandbox
3. Applies deny-by-default network policy
4. Starts Claude Code with full permissions
5. Prints monitoring commands

### Monitor a Running Sandbox

```bash
# Shell into the sandbox
docker sandbox exec -it <sandbox-name> bash

# Check Ralph status (inside sandbox)
ralph --status
ralph --status --tasks

# Inject a hint for the next iteration
ralph --add-context "Focus on the auth module"

# View network activity
docker sandbox network log
```

---

## Checkpointing and Restoring

### Save a Snapshot

```bash
# Save current sandbox state as a reusable template
docker sandbox save <sandbox-name> my-checkpoint:v1

# Export as a tar file
docker sandbox save -o checkpoint.tar <sandbox-name> my-checkpoint:v1
```

### Restore from Snapshot

```bash
# Create a new sandbox from a saved checkpoint
docker sandbox run --load-local-template -t my-checkpoint:v1 claude .
```

### Persistence

- **Same directory = same sandbox**: Running `docker sandbox run claude .` in the same directory reconnects to the existing sandbox. Installed packages persist.
- **Removing a sandbox deletes everything**: `docker sandbox rm <name>` destroys the VM.
- **Docker Desktop restart**: VMs stop but state is preserved. Reconnect with `docker sandbox run`.

---

## Environment Variables and Credentials

### Pass Environment Variables

```bash
docker sandbox run -e NODE_ENV=development -e DEBUG=true claude .
docker sandbox run -e DATABASE_URL=postgresql://localhost/myapp claude .
```

**Important**: Docker Sandbox daemon does NOT inherit your shell environment. Set `ANTHROPIC_API_KEY` in `~/.bashrc` or `~/.zshrc`, then restart Docker Desktop.

### Git Authentication

```bash
# Option 1: GitHub CLI (recommended)
# Authenticate inside the sandbox after creation
docker sandbox exec -it <sandbox-name> gh auth login

# Option 2: Pass GitHub token
docker sandbox run -e GITHUB_TOKEN=ghp_xxx claude .

# Option 3: Mount SSH keys (less secure)
docker sandbox run -v ~/.ssh:/home/agent/.ssh:ro claude .
```

### Volume Mounts

```bash
# Mount additional directories
docker sandbox run -v ~/datasets:/data:ro claude .
docker sandbox run -v ~/.cache/pip:/root/.cache/pip claude .
```

---

## MCP Servers

MCP servers configured in `.claude/settings.json` work inside Docker Sandboxes because they run as child processes of Claude Code (stdio transport).

**Note**: MCP servers that need to connect to host `localhost` services will NOT work — sandboxes cannot reach the host network by default.

---

## Sandbox Management

```bash
# List all sandboxes
docker sandbox ls

# Inspect a sandbox (JSON details)
docker sandbox inspect <sandbox-name>

# Stop without removing (preserves state)
docker sandbox stop <sandbox-name>

# Resume a stopped sandbox
docker sandbox run <sandbox-name>

# Resume a conversation
docker sandbox run <sandbox-name> -- --continue

# Remove a sandbox (deletes VM)
docker sandbox rm <sandbox-name>

# Reset all sandboxes
docker sandbox reset
```

---

## Troubleshooting

**Docker Sandboxes not available:**
Requires Docker Desktop 4.50+. Enable in: Docker Desktop > Settings > Features in development > Docker Sandboxes.

**ANTHROPIC_API_KEY not found:**
The sandbox daemon doesn't inherit shell environment. Add `export ANTHROPIC_API_KEY=sk-...` to `~/.bashrc` or `~/.zshrc`, run `source ~/.bashrc`, then restart Docker Desktop.

**Git push fails inside sandbox:**
Authenticate with `gh auth login` inside the sandbox, or pass `GITHUB_TOKEN` as an env var.

**Env var changes don't take effect:**
Configuration changes require deleting and recreating the sandbox:
```bash
docker sandbox rm <sandbox-name>
docker sandbox run -e NEW_VAR=value claude .
```

**Network request blocked:**
Add the domain to the network policy:
```bash
docker sandbox network proxy <sandbox-name> --allow-host example.com
```

**Linux users:**
Docker Sandboxes on Linux use legacy container-based isolation (not microVMs). For stronger isolation on Linux, consider using a DevContainer with gVisor runtime or the native Claude Code `/sandbox` command.

---

## Platform Support

| Platform | Isolation | Status |
|----------|-----------|--------|
| macOS | MicroVM (Apple Virtualization) | Full support |
| Windows | MicroVM (Hyper-V) | Experimental |
| Linux | Container (legacy) | Weaker isolation |

---

## Alternatives

If Docker Sandboxes don't fit your setup:

| Alternative | When to Use |
|-------------|-------------|
| Claude Code `/sandbox` | Quick local sandboxing without Docker. Uses OS-level primitives (Seatbelt on macOS, bubblewrap on Linux). |
| DevContainers | Need Linux support, gVisor runtime, or maximum configurability. See [Anthropic's reference](https://github.com/anthropics/claude-code/tree/main/.devcontainer). |
| Sprites.dev | Cloud execution with persistent filesystems and 300ms checkpoint/restore. |
| Daytona | Self-hostable cloud sandboxes. Open-source, cheapest managed option. |
