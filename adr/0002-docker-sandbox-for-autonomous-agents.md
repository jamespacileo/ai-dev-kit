# 2. Docker Sandboxes for Autonomous Agent Execution

Date: 2026-02-12
Status: Accepted

## Context

When running autonomous agent loops (Ralph Wiggum) or other long-running unattended tasks, AI coding agents need full command execution permissions. Without this, every shell command triggers a permission prompt that breaks autonomy.

Using `--dangerously-skip-permissions` on the bare host is unsafe — the agent has unrestricted access to the filesystem, network, and system services. We need a sandboxed execution environment where full permissions are safe because the sandbox itself provides the security boundary.

## Decision

Adopt **Docker Sandboxes** (Docker Desktop 4.50+) as the primary sandboxing solution for autonomous agent sessions.

Docker Sandboxes run agents inside lightweight microVMs with:
- Hypervisor-level isolation (own kernel, separate from host)
- Private Docker daemon (agents can build/run containers without accessing host Docker)
- Network filtering proxy with domain allow/deny lists
- Bidirectional file sync for the project directory
- `--dangerously-skip-permissions` enabled by default

The template includes a custom Dockerfile (`.sandbox/Dockerfile`), network policy script, and a one-command Ralph loop launcher.

## Alternatives Considered

**DevContainers (Anthropic/Trail of Bits reference)**: Free, cross-platform, well-documented. However, Docker containers share the host kernel — weaker isolation than microVMs. Requires manual hardening (iptables, gVisor, capability restrictions). Docker-in-Docker needs privileged mode. Better as a fallback for Linux users.

**Native `/sandbox` command**: Built into Claude Code. Zero setup. Uses OS-level primitives (Seatbelt on macOS, bubblewrap on Linux). Good for supervised local development but does not support Docker-in-Docker or network policy configuration.

**E2B (cloud)**: Firecracker microVM isolation, purpose-built for AI agents. However, $150/month Pro subscription, 24-hour hard session limit, and a reported pause/resume persistence bug make it expensive and restrictive for daily long-running sessions.

**Daytona (cloud)**: Open-source, self-hostable, cheapest managed option (~$24/month). Docker-based isolation is weaker than Firecracker unless Kata Containers are configured. Memory-state forking not yet available.

**Sprites.dev (cloud, Fly.io)**: Firecracker microVMs with persistent 100GB filesystem and 300ms checkpoint/restore. Excellent for cloud execution but Fly.io lock-in and no Docker image support.

## Consequences

**Benefits:**
- Zero cost (Docker Desktop license covers it)
- Strongest local isolation available (microVM with own kernel)
- Purpose-built for AI coding agents — Claude Code, Codex, Copilot, Gemini, and Kiro all supported
- One-command setup: `docker sandbox run claude .`
- Custom templates allow pre-installing project-specific tools
- Network deny-by-default prevents data exfiltration

**Trade-offs:**
- Requires Docker Desktop 4.50+ (not everyone has it)
- macOS and Windows only for microVM isolation; Linux gets weaker container-based sandboxes
- Environment variable changes require sandbox rebuild
- Cannot access host localhost services from inside the sandbox
- Each sandbox has independent storage (images not shared between sandboxes)
