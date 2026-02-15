# ai-dev-kit

Batteries-included starter for AI-assisted development with autonomous agent loops.

**Superpowers** handles planning. **Beads** tracks tasks with dependency graphs. **Ralph Wiggum** drives autonomous iteration loops. Both Claude Code and Codex pull from the same task graph. Hooks auto-format, lint, and scan for secrets. CI/CD handles the rest.

---

## Prerequisites

Install these globally once. They are not project-specific.

### Required CLIs

```bash
# Beads — dependency-aware task tracker
brew install beads
# OR: npm install -g @beads/bd

# Open Ralph Wiggum — autonomous agent loop runner
npm install -g @th0rgal/ralph-wiggum

# Claude Code CLI
# https://docs.anthropic.com/en/docs/claude-code

# Codex CLI
npm install -g @openai/codex
```

### Optional CLIs

```bash
# Gitleaks — secret detection (pre-commit scanning)
brew install gitleaks

# mise — polyglot tool version manager (replaces nvm/pyenv/rbenv)
curl https://mise.run | sh

# Biome — JS/TS/CSS linter and formatter
npm install -g @biomejs/biome

# commitlint — Conventional Commits validation
npm install -g @commitlint/cli @commitlint/config-conventional

# Docker Desktop 4.50+ — sandboxed agent execution (microVM isolation)
# https://www.docker.com/products/docker-desktop/
```

Verify:
```bash
bd --version
ralph --help
claude --version
codex --version
```

### Superpowers Plugin

**For Claude Code** (run inside a Claude Code session):
```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

**For Codex:**
```bash
git clone https://github.com/obra/superpowers.git ~/.codex/superpowers
mkdir -p ~/.agents/skills
ln -s ~/.codex/superpowers/skills ~/.agents/skills/superpowers
```
Restart Codex after linking.

---

## Quick Start

### Create a new project from this template

```bash
gh repo create my-project --template jamespacileo/ai-dev-kit --clone
cd my-project
chmod +x setup.sh
./setup.sh
```

### Or clone and reinitialize manually

```bash
git clone https://github.com/jamespacileo/ai-dev-kit.git my-project
cd my-project
rm -rf .git && git init && git branch -m main
chmod +x setup.sh
./setup.sh
git add -A && git commit -m "feat: initial commit from ai-dev-kit template"
```

The `setup.sh` script initializes beads, installs git hooks, checks tool availability, and configures MCP servers.

---

## Workflow

The full development cycle follows five stages:

### 1. Brainstorm

Open Claude Code in your project and run:

```
/superpowers:brainstorm I want to build <your feature description>.
Help me clarify the exact constraints, requirements, and acceptance criteria.
```

Superpowers asks Socratic questions one at a time, then presents a design in digestible chunks. Iterate until the design is solid.

### 2. Plan

```
/superpowers:write-plan
```

Creates a detailed implementation plan in `docs/plans/` with architecture, tasks, and sequencing.

### 3. Decompose into Tasks

Use the built-in skill:

```
/decompose
```

Or manually ask Claude Code to decompose the plan into beads tasks with priorities, dependencies, and acceptance criteria.

Verify the graph:
```bash
bd list --json           # All tasks
bd ready --json          # Unblocked tasks ready to start
bd blocked --json        # Tasks waiting on dependencies
```

### 4. Execute with Ralph Loops

Use the built-in skill:

```
/sprint
```

Or run directly:

**Claude Code** (best for architecture, complex refactoring, multi-file coordination):
```bash
ralph -f .ralph/iterate.md \
  --agent claude-code \
  --completion-promise "ALL_TASKS_COMPLETE" \
  --task-promise "READY_FOR_NEXT_TASK" \
  --tasks \
  --max-iterations 30
```

**Codex** (best for test generation, boilerplate, focused bug fixes):
```bash
ralph -f .ralph/iterate.md \
  --agent codex \
  --completion-promise "ALL_TASKS_COMPLETE" \
  --task-promise "READY_FOR_NEXT_TASK" \
  --tasks \
  --max-iterations 20
```

Monitor from another terminal:
```bash
ralph --status              # Loop progress
ralph --status --tasks      # Including task list
ralph --add-context "hint"  # Inject a hint for the next iteration
```

Stop with `Ctrl+C` when you want to switch agents or review progress.

**Sandboxed execution** (recommended for unattended loops):

```bash
# Run Ralph in a Docker Sandbox — full permissions, isolated microVM
.sandbox/sandbox-ralph.sh .
```

See [Sandboxed Execution](#sandboxed-execution) for details.

### 5. Review and Ship

Use the built-in skill:

```
/review-sprint
```

Or manually:
```bash
bd list --json | jq '[.[] | select(.status != "closed")] | length'
npm test
git log --oneline --since="today"
git push
```

---

## Skills Reference

Custom skills available in both Claude Code and Codex:

| Skill | Purpose |
|-------|---------|
| `/decompose` | Break down a plan from `docs/plans/` into beads tasks with priorities, dependencies, and acceptance criteria |
| `/sprint` | Start a Ralph Wiggum autonomous loop — choose agent and iteration limit |
| `/review-sprint` | Review completed sprint: task progress, git commits, test status, lint status |
| `/status` | Beads task dashboard: ready / in-progress / blocked / closed counts |
| `/create-adr` | Create an Architecture Decision Record in `adr/` |

---

## MCP Servers

Pre-configured in `.claude/settings.json`. They activate automatically when you open Claude Code in this directory.

| Server | Purpose | Why |
|--------|---------|-----|
| Sequential Thinking | Structured step-by-step reasoning | #1 most used MCP server (5,500+ Smithery installs) |
| Context7 | Up-to-date library documentation | 44k GitHub stars. Eliminates hallucinated APIs |
| Memory | Persistent knowledge graph | Remembers decisions across sessions. Local storage |
| Playwright | Browser automation and testing | Microsoft-maintained. E2E testing via accessibility trees |
| Repomix | Codebase context compression | 22k stars. 70% token reduction via tree-sitter |

To disable a server you don't need, remove its entry from `.claude/settings.json`.

---

## Hooks

Configured in `.claude/settings.json`. Run automatically during Claude Code sessions.

| Hook | Trigger | What It Does |
|------|---------|--------------|
| Auto-format | After file write/edit | Runs Biome format on the changed file |
| Auto-lint | After file write/edit | Runs Biome lint check on the changed file |
| Secret scan | After git commit | Runs Gitleaks on staged changes |
| Notification | Claude needs attention | macOS desktop notification |

---

## Code Quality

**Biome** handles linting and formatting for JS/TS/CSS/JSON files.

```bash
# Check everything
npx @biomejs/biome check .

# Format files
npx @biomejs/biome format --write .

# Lint only
npx @biomejs/biome lint .
```

Config: `biome.json` — recommended rules, 2-space indent, 100-char line width.

Note: Biome is JS/TS/CSS only. For polyglot projects, consider adding [Trunk Check](https://trunk.io) or [MegaLinter](https://github.com/oxsecurity/megalinter).

---

## Security

### Gitleaks (local, pre-commit)

Detects hardcoded secrets (API keys, tokens, credentials) before they're committed.

```bash
# Scan current state
gitleaks detect --source . --no-git

# Scan staged changes only
gitleaks detect --staged
```

Config: `.gitleaks.toml` — default rules with allowlisted paths.

### Semgrep (CI)

Static analysis for code vulnerabilities. Runs in GitHub Actions on every PR and weekly.

Config: `.github/workflows/security.yml`

---

## CI/CD

Three GitHub Actions workflows in `.github/workflows/`:

| Workflow | Trigger | What It Does |
|----------|---------|--------------|
| `ci.yml` | Push to main, PRs | Install deps, Biome lint, Biome format check, run tests |
| `security.yml` | Push to main, PRs, weekly | Gitleaks secret scan + Semgrep SAST |
| `release.yml` | Push to main | Release Please: auto-creates release PRs with changelogs |

Release Please reads Conventional Commit messages and auto-bumps versions:
- `feat:` = minor version bump
- `fix:` = patch version bump
- `feat!:` or `BREAKING CHANGE:` = major version bump

---

## Environment

**mise** manages tool versions. Config: `.mise.toml`

```bash
# Install pinned tool versions
mise install

# List installed versions
mise ls

# Add a new tool
mise use python@3.12
```

Default pinned tools: Node.js (LTS), Bun (latest).

---

## Conventional Commits

All commit messages must follow the format:

```
<type>: <description>

[optional body]
```

| Type | When to Use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `chore` | Maintenance, deps, configs |
| `refactor` | Code change that neither fixes nor adds |
| `test` | Adding or updating tests |
| `ci` | CI/CD changes |
| `perf` | Performance improvement |

Validated by commitlint. Config: `commitlint.config.js`

---

## Architecture Decision Records

Document significant technical decisions in `adr/`.

```
/create-adr
```

Or manually create `adr/NNNN-kebab-case-title.md` using the template at `adr/template.md`.

ADRs answer: What decision was made? Why? What alternatives were rejected? What are the consequences?

---

## Dependency Management

**Renovate** automatically creates PRs for dependency updates. Config: `renovate.json`

- Schedule: weekly on Mondays
- Patch updates: auto-merged if CI passes
- Minor updates: grouped together
- Major updates: individual PRs for review

To enable: install the [Renovate GitHub App](https://github.com/apps/renovate) on your repo.

---

## Sandboxed Execution

Run autonomous agent loops inside isolated microVMs. The sandbox provides the security boundary — `--dangerously-skip-permissions` is enabled by default inside Docker Sandboxes.

Requires **Docker Desktop 4.50+** with Docker Sandboxes enabled.

### Quick Start

```bash
# Simplest: run Claude Code in a sandbox
docker sandbox run claude .

# With ai-dev-kit tools (Ralph + Beads pre-installed)
docker build -t ai-dev-kit-sandbox:latest .sandbox/
docker sandbox run --load-local-template -t ai-dev-kit-sandbox:latest claude .

# One-command sandboxed Ralph loop
.sandbox/sandbox-ralph.sh .
```

### Network Policy

For autonomous sessions, apply deny-by-default networking:

```bash
.sandbox/network-policy.sh <sandbox-name>
```

Whitelists only: Anthropic API, npm, GitHub. Add more domains as needed.

### Monitoring

```bash
docker sandbox exec -it <sandbox-name> bash    # Shell into sandbox
docker sandbox network log                      # View network activity
docker sandbox save <name> checkpoint:v1        # Save snapshot
docker sandbox ls                                # List all sandboxes
```

Full documentation: [`.sandbox/README.md`](.sandbox/README.md)

---

## Agent Routing Guide

| Task Type | Recommended Agent | Why |
|-----------|------------------|-----|
| Architecture, system design | Claude Code | Superior reasoning, multi-file coordination |
| Test generation, coverage | Codex | Fast, deterministic, good at boilerplate |
| Complex refactoring | Claude Code | Better at understanding intent across files |
| API endpoint implementation | Either | Both handle well |
| Documentation | Claude Code | Better prose, catches edge cases |
| Dependency upgrades | Claude Code + Ralph loop | Good at iterating through breaking changes |
| Bug fixes with clear repro | Codex | Fast, focused execution |

---

## Beads Commands Reference

```bash
# Find work
bd ready --json                    # Unblocked tasks ready to start
bd list --json                     # All tasks with status
bd blocked --json                  # Tasks waiting on dependencies
bd show <id> --json                # Full task details

# Work on tasks
bd update <id> --claim             # Atomically claim (sets assignee + in_progress)
bd close <id> --reason "Done"      # Complete a task

# Create tasks
bd create "Title" -t task -p 2 --json                    # Basic task
bd create "Title" -p 1 -d "Details" --acceptance "Criteria"  # With details
bd create "Title" --deps "blocks:<id>"                    # With dependency
bd create "Title" --deps "discovered-from:<id>"           # File discovered work
```

**Warning:** Never use `bd edit` — it opens an interactive editor that AI agents cannot use.

---

## Ralph Commands Reference

```bash
# Start loops
ralph "prompt" --agent claude-code --max-iterations 20
ralph -f .ralph/iterate.md --agent codex --max-iterations 10
ralph -f .ralph/iterate.md --agent claude-code --tasks --max-iterations 30

# Monitor
ralph --status                     # Loop progress
ralph --status --tasks             # With task list
ralph --list-tasks                 # Current task list

# Intervene
ralph --add-context "Focus on X"   # Hint for next iteration
ralph --clear-context              # Clear pending hints
ralph --add-task "New task desc"   # Add task to list
ralph --remove-task 3              # Remove task at index

# Options
--completion-promise "TEXT"        # Phrase that signals all done (default: COMPLETE)
--task-promise "TEXT"              # Phrase that signals one task done
--min-iterations N                 # Minimum iterations before completion allowed
--max-iterations N                 # Hard stop limit
--no-commit                        # Don't auto-commit after each iteration
--model MODEL                      # Override model (agent-specific)
```

---

## Template Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Claude Code agent instructions — beads workflow, skills, conventions |
| `AGENTS.md` | Codex agent instructions — beads workflow, skills, conventions |
| `.claude/settings.json` | Hooks (auto-format, lint, secret scan) + MCP server config |
| `.claude/skills/` | 5 Claude Code skills: decompose, sprint, review-sprint, status, create-adr |
| `.codex/skills/` | 5 Codex skills (same set) |
| `.ralph/iterate.md` | Shared iteration prompt for autonomous Ralph loops |
| `setup.sh` | Post-clone initialization (beads + hooks + tools) |
| `biome.json` | Biome linter/formatter config |
| `commitlint.config.js` | Conventional Commits rules |
| `.mise.toml` | Tool version pinning (Node, Bun) |
| `.gitleaks.toml` | Secret detection config |
| `renovate.json` | Dependency update bot config |
| `adr/template.md` | Architecture Decision Record template |
| `.sandbox/Dockerfile` | Custom Docker Sandbox template (Ralph + Beads) |
| `.sandbox/network-policy.sh` | Deny-by-default network policy for sandboxes |
| `.sandbox/sandbox-ralph.sh` | One-command sandboxed Ralph loop launcher |
| `.sandbox/README.md` | Sandbox usage documentation |
| `.github/workflows/` | CI, security, and release pipelines |
| `.gitignore` | Comprehensive ignore rules |

---

## Troubleshooting

**Agent ignores beads / doesn't run bd commands:**
Ensure `CLAUDE.md` (for Claude Code) and `AGENTS.md` (for Codex) are present in the project root.

**Ralph loop never completes:**
Check that `.ralph/iterate.md` contains the completion promise markers. The agent must output the exact string `ALL_TASKS_COMPLETE` or `READY_FOR_NEXT_TASK`.

**Beads sync conflicts after switching agents:**
Run `bd sync` before switching agents. If conflicts occur:
```bash
git checkout --theirs .beads/issues.jsonl
bd import -i .beads/issues.jsonl
```

**MCP servers not loading:**
Check `.claude/settings.json` has the `mcpServers` section. Verify with `claude mcp list` inside a Claude Code session.

**Hooks not running:**
Hooks require Claude Code to be running in the project directory. Check `.claude/settings.json` has the `hooks` section.

**Token cost management:**
Always set `--max-iterations`. A 30-iteration Claude Code loop costs approximately $30-75 depending on codebase size. Codex loops are generally cheaper. Monitor with `ralph --status`.

**Xcode license blocks brew:**
Use `npm install -g @beads/bd` as an alternative to `brew install beads`.

**Biome doesn't cover my language:**
Biome only supports JS/TS/CSS/JSON. For other languages, add [Trunk Check](https://trunk.io) (`brew install trunk-io`) or configure language-specific linters.

**Docker Sandbox not available:**
Requires Docker Desktop 4.50+. Enable in: Docker Desktop > Settings > Features in development > Docker Sandboxes.

**ANTHROPIC_API_KEY not found in sandbox:**
The sandbox daemon doesn't inherit shell env vars. Add `export ANTHROPIC_API_KEY=sk-...` to `~/.bashrc` or `~/.zshrc`, then restart Docker Desktop.
