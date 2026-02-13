---
name: decompose
description: "Decompose an implementation plan into beads tasks with priorities, dependencies, and acceptance criteria. Use when breaking down plans from docs/plans/ into actionable work items."
---

# Decompose Plan into Beads Tasks

1. Find the most recent plan in `docs/plans/` or ask the user which plan to decompose.

2. For each implementation step, create a task:
   ```bash
   bd create "<task title>" -t task -p <priority> -d "<details>" --acceptance "<criteria>" --json
   ```

3. Add dependencies between tasks:
   ```bash
   bd create "<task>" --deps "blocks:<parent-id>" --json
   ```

4. Priority scale: P0 = critical, P1 = high, P2 = normal, P3 = low, P4 = backlog

5. Verify the graph:
   ```bash
   bd list --json
   bd ready --json
   ```

6. Present a summary table of all created tasks.

Rules:
- Every task MUST have testable acceptance criteria
- Tasks should be completable in one agent iteration
- Always use `--json` flag
- Never use `bd edit`
