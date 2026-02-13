---
name: status
description: "Display a beads task dashboard showing project progress, ready work, and blockers. Use when asking about task status or what needs to be done."
---

# Beads Task Dashboard

1. Gather data:
   ```bash
   bd list --json
   bd ready --json
   bd blocked --json
   ```

2. Present dashboard with counts: ready, in-progress, blocked, closed, total.

3. List ready tasks sorted by priority.

4. Show blockers and what they're waiting on.

5. Suggest next actions:
   - Run sprint to start working
   - Run decompose to create more tasks
   - `bd show <id> --json` for task details
