# ai-dev-kit

Starter scaffolding for AI-assisted development with autonomous agent loops.

**Superpowers** handles planning. **Beads** tracks tasks with dependency graphs. **Ralph Wiggum** drives autonomous iteration loops. Both Claude Code and Codex can pull from the same task graph.

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
gh repo create my-project --template <your-username>/ai-dev-kit --clone
cd my-project
chmod +x setup.sh
./setup.sh
```

### Or clone and reinitialize manually

```bash
git clone <this-repo-url> my-project
cd my-project
rm -rf .git && git init && git branch -m main
chmod +x setup.sh
./setup.sh
git add -A && git commit -m "Initial commit from ai-dev-kit template"
```

The `setup.sh` script initializes beads and installs git hooks. After running it you are ready to start.

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

Ask Claude Code to convert the plan into beads tasks:

```
Read the plan at docs/plans/<your-plan>.md and decompose it into beads tasks.

For each task:
- bd create "Title" -t task -p <priority> --acceptance "Criterion 1; Criterion 2"
- Set dependencies where tasks depend on earlier work: --deps "blocks:<id>"
- Include a description with implementation details: -d "Details here"

Priority scale: P0 = critical, P1 = high, P2 = normal, P3 = low, P4 = backlog
```

Verify the graph:
```bash
bd list --json           # All tasks
bd ready --json          # Unblocked tasks ready to start
bd blocked --json        # Tasks waiting on dependencies
```

### 4. Execute with Ralph Loops

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

### 5. Review and Ship

```bash
# Check all tasks are done
bd list --json | jq '[.[] | select(.status != "closed")] | length'

# Run full test suite
npm test   # or your test command

# Review agent commits
git log --oneline --since="today"

# Ship
git push
```

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
bd update <id> --status in_progress  # Or claim manually
bd close <id> --reason "Done"      # Complete a task

# Create tasks
bd create "Title" -t task -p 2 --json                    # Basic task
bd create "Title" -p 1 -d "Details" --acceptance "Criteria"  # With details
bd create "Title" --deps "blocks:<id>"                    # With dependency

# Dependencies
bd create "Title" --deps "discovered-from:<id>"  # File discovered work

# Always use --json flag when scripting or in agent context
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
--task-promise "TEXT"              # Phrase that signals one task done (default: READY_FOR_NEXT_TASK)
--min-iterations N                 # Minimum iterations before completion allowed
--max-iterations N                 # Hard stop limit
--no-commit                        # Don't auto-commit after each iteration
--model MODEL                      # Override model (agent-specific)
```

---

## Template Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Claude Code agent instructions — beads workflow, conventions |
| `AGENTS.md` | Codex agent instructions — beads workflow, conventions |
| `.ralph/iterate.md` | Shared iteration prompt for autonomous Ralph loops |
| `setup.sh` | Post-clone initialization (beads init + git hooks) |
| `.gitignore` | Ignores beads DB, ralph state, OS files |

---

## Troubleshooting

**Agent ignores beads / doesn't run bd commands:**
Ensure `CLAUDE.md` (for Claude Code) and `AGENTS.md` (for Codex) are present in the project root. These files contain agent instructions that tell them to use beads.

**Ralph loop never completes:**
Check that `.ralph/iterate.md` contains the completion promise markers. The agent must output the exact string `ALL_TASKS_COMPLETE` or `READY_FOR_NEXT_TASK`.

**Beads sync conflicts after switching agents:**
Run `bd sync` before switching agents. If conflicts occur in `.beads/issues.jsonl`:
```bash
git checkout --theirs .beads/issues.jsonl
bd import -i .beads/issues.jsonl
```

**Token cost management:**
Always set `--max-iterations`. A 30-iteration Claude Code loop costs approximately $30-75 depending on codebase size. Codex loops are generally cheaper. Monitor with `ralph --status`.

**Xcode license blocks brew:**
Use `npm install -g @beads/bd` as an alternative to `brew install beads`.
