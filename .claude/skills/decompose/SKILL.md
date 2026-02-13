---
name: decompose
description: |
  Decompose an implementation plan into beads tasks with priorities, dependencies, and acceptance criteria.
  Use when: (1) User says /decompose or asks to break down a plan into tasks, (2) A plan exists in docs/plans/
  and needs to be converted into actionable work items, (3) User wants to create a beads task graph from requirements.
---

# Decompose Plan into Beads Tasks

## Workflow

1. **Find the plan**: Look for the most recent plan in `docs/plans/` or ask the user to specify which plan to decompose.

2. **Read and analyze**: Read the plan thoroughly. Identify:
   - Distinct implementation steps
   - Dependencies between steps (what must complete before what)
   - Natural priority ordering (foundational work first)
   - Testable acceptance criteria for each step

3. **Create an epic** (if the plan represents a feature):
   ```bash
   bd create "Epic: <feature name>" -t epic -p 1 -d "<one-line summary>" --json
   ```

4. **Create tasks** for each implementation step:
   ```bash
   bd create "<task title>" \
     -t task \
     -p <priority> \
     -d "<implementation details>" \
     --acceptance "<criterion 1>; <criterion 2>" \
     --json
   ```

   Priority scale:
   - P0: Critical / blocking everything
   - P1: High / foundational work
   - P2: Normal / feature implementation
   - P3: Low / polish and improvements
   - P4: Backlog / nice-to-have

5. **Add dependencies** between tasks:
   ```bash
   bd create "<task>" --deps "blocks:<parent-id>" --json
   ```

6. **Verify the graph**:
   ```bash
   bd list --json
   bd ready --json
   bd blocked --json
   ```

7. **Present summary**: Show the user a table of all created tasks with IDs, titles, priorities, and dependency status.

## Rules

- Every task MUST have testable acceptance criteria
- Tasks should be small enough to complete in one agent iteration (1-2 hours of work)
- If a task is too large, split it into subtasks
- Always use `--json` flag with bd commands
- Never use `bd edit` (interactive editor)
