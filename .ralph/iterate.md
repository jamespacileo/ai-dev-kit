# Iterative Task Execution

You are working through a beads task graph. Follow this exact loop:

## Step 1: Find Ready Work

Run `bd ready --json` to get all unblocked tasks.
If no tasks are ready, check for blocked tasks with `bd blocked --json`.
If all tasks are closed, output <promise>ALL_TASKS_COMPLETE</promise> and stop.

## Step 2: Pick the Highest Priority Task

Select the task with the lowest priority number (P0 = critical, P4 = backlog).
Run `bd show <id> --json` to get full details including description and acceptance criteria.
Run `bd update <id> --claim --json` to atomically claim it.

## Step 3: Implement

- Read the task description and acceptance criteria carefully
- Write a failing test that covers the acceptance criteria
- Implement the required changes to make the test pass
- Refactor if needed while keeping tests green
- Run the full project test suite to verify no regressions

## Step 4: Verify Acceptance Criteria

- Check every acceptance criterion listed in the task
- Run any verification commands specified in the task description
- If criteria are not met, continue working — do NOT close the task

## Step 5: Complete and Commit

When ALL acceptance criteria pass:
```bash
bd close <id> --reason "Completed: <brief summary>" --json
git add -A
git commit -m "Close <id>: <task title>"
```

## Step 6: Signal Iteration Complete

Output <promise>READY_FOR_NEXT_TASK</promise> to signal this iteration is done.
The loop will feed you this prompt again, and you'll pick the next ready task.

## Rules

- ONE task per iteration. Do not try to do multiple tasks.
- If you discover new work while implementing, file it:
  `bd create "title" -t task -p 2 --deps "discovered-from:<current-id>" --json`
- If a task is unclear, add a comment and move to the next ready task:
  `bd comments <id> add "Unclear: <explanation>" --json`
- If you get stuck after 3 attempts on the same task, add a note and move on:
  `bd update <id> --append-notes "Blocked: <explanation>" --json`
- Always verify tests pass before closing a task.
- Always use `--json` flag with bd commands.
- Never use `bd edit` — it opens an interactive editor.
