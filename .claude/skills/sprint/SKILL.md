---
name: sprint
description: |
  Start an autonomous Ralph Wiggum loop to work through beads tasks.
  Use when: (1) User says /sprint or asks to start an autonomous coding loop, (2) User wants to run
  Ralph Wiggum against the current task graph, (3) User says "start working" or "run the agent loop".
---

# Start Ralph Sprint

## Workflow

1. **Check readiness**: Verify there are tasks to work on.
   ```bash
   bd ready --json
   ```
   If no tasks are ready, inform the user and suggest running `/decompose` first.

2. **Show task summary**: Display how many tasks are ready, blocked, and total.
   ```bash
   bd list --json
   ```

3. **Ask the user for configuration**:
   - Which agent: `claude-code` or `codex`
   - Maximum iterations (suggest 20 for a focused sprint, 30 for larger work)
   - Sandboxed execution? (recommended for unattended/long-running loops)

4. **Construct the command**:

   **Standard (supervised):**
   ```bash
   ralph -f .ralph/iterate.md \
     --agent <agent-choice> \
     --completion-promise "ALL_TASKS_COMPLETE" \
     --task-promise "READY_FOR_NEXT_TASK" \
     --tasks \
     --max-iterations <limit>
   ```

   **Sandboxed (unattended — recommended for long-running loops):**
   ```bash
   .sandbox/sandbox-ralph.sh . <limit> <agent-choice>
   ```
   This runs the agent inside a Docker Sandbox microVM with `--dangerously-skip-permissions`
   and deny-by-default networking. Requires Docker Desktop 4.50+.

5. **Display the command** for the user to run. Remind them:
   - Monitor with: `ralph --status` (standard) or `docker sandbox exec -it <name> bash` (sandboxed)
   - Inject hints with: `ralph --add-context "hint text"`
   - Stop with: `Ctrl+C`
   - Switch agents by stopping and restarting with `--agent codex` or `--agent claude-code`

## Agent Routing Suggestions

| Task Type | Recommended Agent |
|-----------|------------------|
| Architecture, system design | claude-code |
| Test generation, boilerplate | codex |
| Complex refactoring | claude-code |
| API endpoints | either |
| Documentation | claude-code |
| Bug fixes with clear repro | codex |
