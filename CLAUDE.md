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

## Conventions

- Follow TDD: failing test first, then implement, then refactor
- Keep commits focused — one task per commit when possible
- Include the beads task ID in commit messages
- Priority scale: P0 = critical, P1 = high, P2 = normal, P3 = low, P4 = backlog
