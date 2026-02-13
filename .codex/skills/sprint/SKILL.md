---
name: sprint
description: "Start an autonomous Ralph Wiggum loop to work through beads tasks. Use when the user wants to begin automated task execution with Ralph."
---

# Start Ralph Sprint

1. Check readiness:
   ```bash
   bd ready --json
   ```

2. Show task summary (ready / blocked / total).

3. Construct the ralph command:
   ```bash
   ralph -f .ralph/iterate.md \
     --agent codex \
     --completion-promise "ALL_TASKS_COMPLETE" \
     --task-promise "READY_FOR_NEXT_TASK" \
     --tasks \
     --max-iterations 20
   ```

4. Display the command for the user to run.

Monitoring commands:
- `ralph --status` — check progress
- `ralph --add-context "hint"` — inject guidance
- `Ctrl+C` — stop the loop
