---
name: create-adr
description: |
  Create an Architecture Decision Record documenting a significant technical decision.
  Use when: (1) User says /create-adr or asks to document an architecture decision, (2) A significant
  technical choice is being made (framework, library, pattern, infrastructure), (3) User asks to
  record why a decision was made for future reference.
---

# Create Architecture Decision Record

## Workflow

1. **Determine the next ADR number**:
   Look at existing files in `adr/` to find the highest number, then increment.

2. **Gather decision context** from the user:
   - What decision is being made?
   - What problem or need prompted it?
   - What alternatives were considered?
   - What are the consequences (both positive and negative)?

3. **Create the ADR file** using the template at `adr/template.md`:

   File name: `adr/NNNN-<kebab-case-title>.md`

   ```markdown
   # NNNN. <Title>

   Date: <today's date>
   Status: Proposed

   ## Context
   <What is the issue motivating this decision?>

   ## Decision
   <What is the change being made?>

   ## Consequences
   <What becomes easier or more difficult?>
   ```

4. **Confirm with user**: Show the draft and ask if they want to accept it or make changes.

5. **Update status**: If the user approves, change status to "Accepted".

## Guidelines

- Keep ADRs concise (one page)
- Focus on the "why" not just the "what"
- Include alternatives that were rejected and why
- Link to related ADRs if this supersedes a previous decision
- Every ADR should be understandable by someone joining the project later
