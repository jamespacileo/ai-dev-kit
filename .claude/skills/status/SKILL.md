---
name: status
description: |
  Display a beads task dashboard showing project progress, ready work, and blockers.
  Use when: (1) User says /status or asks about task status, (2) User asks "what's next" or
  "what needs to be done", (3) User wants to see the current state of the task graph.
---

# Beads Task Dashboard

## Workflow

1. **Gather all task data**:
   ```bash
   bd list --json
   bd ready --json
   bd blocked --json
   ```

2. **Present dashboard**:

   ```
   Project Status
   ══════════════
   Ready:       X tasks (can start now)
   In Progress: Y tasks (being worked on)
   Blocked:     Z tasks (waiting on dependencies)
   Closed:      W tasks (completed)
   ─────────────
   Total:       N tasks
   ```

3. **Show ready tasks** (sorted by priority):
   List each ready task with ID, title, and priority.

4. **Show blockers** (if any):
   For each blocked task, show what it's waiting on.

5. **Show in-progress tasks** (if any):
   Flag tasks that have been in-progress for an unusually long time.

6. **Quick actions**:
   Suggest what the user can do next:
   - "Run `/sprint` to start working through ready tasks"
   - "Run `/decompose` to break down more work"
   - "Run `bd show <id> --json` to see details of a specific task"
