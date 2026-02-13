---
name: review-sprint
description: |
  Review the results of a completed Ralph sprint. Summarizes task progress, reviews commits, checks test status.
  Use when: (1) User says /review-sprint or asks to review sprint results, (2) A Ralph loop has just finished
  and the user wants a summary, (3) User asks "how did the sprint go" or "what got done".
---

# Review Sprint Results

## Workflow

1. **Gather task status**:
   ```bash
   bd list --json
   ```
   Count and categorize: closed, in-progress, open, blocked.

2. **Review completed work**:
   For each closed task, show:
   - Task ID and title
   - Closing reason
   - Whether acceptance criteria were met

3. **Check for issues**:
   ```bash
   bd list --json  # Look for tasks with status "in_progress" (may be abandoned)
   ```
   Flag any tasks that are still in-progress (agent may have moved on without closing them).

4. **Review git history**:
   ```bash
   git log --oneline --since="12 hours ago"
   ```
   Show recent commits and correlate with closed tasks.

5. **Run test suite**:
   Run the project's test command (check package.json scripts or CLAUDE.md for the test command).
   Report pass/fail status.

6. **Run linter**:
   ```bash
   npx @biomejs/biome check .
   ```
   Report any linting issues introduced during the sprint.

7. **Present summary report**:
   ```
   Sprint Review
   ─────────────
   Completed: X tasks
   In Progress: Y tasks (may need attention)
   Blocked: Z tasks
   Open: W tasks remaining

   Tests: PASS/FAIL
   Lint: CLEAN/X issues

   Commits: N new commits
   ```

8. **Recommend next steps**:
   - If tasks remain: suggest another sprint
   - If tasks are blocked: identify what's blocking them
   - If all done: suggest running `/review-sprint` one final time after manual review
