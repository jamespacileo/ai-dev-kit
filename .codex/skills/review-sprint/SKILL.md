---
name: review-sprint
description: "Review results of a completed Ralph sprint. Summarizes task progress, reviews commits, checks tests. Use after a Ralph loop finishes."
---

# Review Sprint Results

1. Gather task status:
   ```bash
   bd list --json
   ```

2. Count: closed, in-progress, open, blocked tasks.

3. Review git history:
   ```bash
   git log --oneline --since="12 hours ago"
   ```

4. Run test suite and linter.

5. Present summary:
   ```
   Completed: X tasks
   In Progress: Y tasks
   Blocked: Z tasks
   Tests: PASS/FAIL
   ```

6. Recommend next steps (another sprint, fix blockers, or ship).
