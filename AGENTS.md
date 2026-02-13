# Agent Instructions

## Beads Task Tracking

This project uses beads (`bd`) for dependency-aware task tracking. When you see a `.beads/` directory, use these commands to manage work.

### Finding Work

```bash
bd ready --json           # Unblocked tasks you can start now
bd show <id> --json       # Full details and acceptance criteria
bd blocked --json         # Tasks waiting on dependencies
```

### Working on Tasks

```bash
bd update <id> --claim --json              # Claim a task (sets assignee + in_progress)
bd close <id> --reason "Done" --json       # Complete when acceptance criteria pass
bd create "title" -t task -p 2 --json      # File discovered work
bd create "title" --deps "discovered-from:<id>" --json  # Link to originating task
```

### Rules

- Always use `--json` for programmatic access
- Never use `bd edit` (opens interactive editor — agents cannot use it)
- Commit `.beads/` changes after completing tasks
- One task at a time: claim, implement, test, close, commit
- Write a failing test first, then implement (TDD)
- If blocked after 3 attempts, add notes to the task and move to the next ready task

## Available Skills

| Skill | Purpose |
|-------|---------|
| decompose | Break down a plan into beads tasks |
| sprint | Start a Ralph Wiggum autonomous loop |
| review-sprint | Review results of a completed sprint |
| status | Show beads task dashboard |
| create-adr | Create an Architecture Decision Record |

## Conventions

### Conventional Commits

All commit messages MUST follow the Conventional Commits format:
```
<type>: <description>
```
Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `ci`, `perf`, `build`, `revert`

### Code Quality

Run `npx @biomejs/biome check .` before committing. Biome handles JS/TS/CSS/JSON linting and formatting.

### Architecture Decision Records

When making significant technical decisions, create an ADR in `adr/` using the template at `adr/template.md`.

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
