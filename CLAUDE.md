# Project Agent Instructions

## Beads Task Tracking

This project uses beads (`bd`) for dependency-aware task tracking. Always check for ready work before starting.

### Key Commands

```bash
bd ready --json                          # Find unblocked tasks
bd show <id> --json                      # Get task details + acceptance criteria
bd update <id> --claim --json            # Atomically claim a task (sets assignee + in_progress)
bd close <id> --reason "Done" --json     # Complete a task
bd create "title" -t task -p 2 --json    # File new work
bd create "title" --deps "discovered-from:<id>" --json  # Link discovered work
```

### Rules

- Always use `--json` flag for programmatic access
- Never use `bd edit` — it opens an interactive editor which cannot be used by agents
- After completing work, always commit `.beads/` changes:
  ```bash
  git add .beads/
  git commit -m "Close <id>: <brief summary>"
  ```
- One task at a time. Claim it before starting, close it when acceptance criteria pass.
- If you discover new work during implementation, file it with `bd create` and link it with `--deps "discovered-from:<current-id>"`

## Development Workflow

1. Check `bd ready --json` for the next unblocked task
2. Read the task details with `bd show <id> --json`
3. Claim it with `bd update <id> --claim --json`
4. Write a failing test for the acceptance criteria
5. Implement until the test passes
6. Run the full test suite to check for regressions
7. Close the task with `bd close <id> --reason "summary" --json`
8. Commit all changes including `.beads/`

## Available Skills

| Skill | Purpose |
|-------|---------|
| `/decompose` | Break down a plan into beads tasks with priorities and dependencies |
| `/sprint` | Start a Ralph Wiggum autonomous loop |
| `/review-sprint` | Review results of a completed sprint |
| `/status` | Show beads task dashboard |
| `/create-adr` | Create an Architecture Decision Record |

## Conventions

- Follow TDD: failing test first, then implement, then refactor
- Keep commits focused — one task per commit when possible
- Include the beads task ID in commit messages
- Priority scale: P0 = critical, P1 = high, P2 = normal, P3 = low, P4 = backlog

### Conventional Commits

All commit messages MUST follow the Conventional Commits format:

```
<type>: <description>

[optional body]
```

Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `ci`, `perf`, `build`, `revert`

### Code Quality

- Run `npx @biomejs/biome check .` before committing
- Biome auto-formats on file write (via hooks)
- Biome lints JS/TS/CSS/JSON files

### Architecture Decision Records

When making a significant technical decision (new framework, library, pattern, infrastructure change), create an ADR:
- Use `/create-adr` or manually create a file in `adr/`
- Follow the template at `adr/template.md`

## Sandbox Awareness

If running inside a Docker Sandbox (`docker sandbox run`), this agent has `--dangerously-skip-permissions` enabled by default. The sandbox provides microVM isolation — the security boundary is the sandbox itself, not per-command approval. Docker commands use the sandbox's private daemon, not the host.

If running on bare host, use Claude Code's `/sandbox` command for OS-level sandboxing, or run inside a Docker Sandbox for autonomous sessions.

## MCP Servers Available

| Server | What It Provides |
|--------|-----------------|
| Sequential Thinking | Structured reasoning for complex problems |
| Context7 | Up-to-date library documentation |
| Memory | Persistent knowledge graph across sessions |
| Playwright | Browser automation and testing |
| Repomix | Codebase context compression |
