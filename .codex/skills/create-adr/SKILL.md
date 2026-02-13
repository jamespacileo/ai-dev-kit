---
name: create-adr
description: "Create an Architecture Decision Record documenting a significant technical decision. Use when a technical choice is made (framework, library, pattern, infrastructure)."
---

# Create Architecture Decision Record

1. Find the next ADR number by checking existing files in `adr/`.

2. Gather from the user: what decision, what prompted it, alternatives considered, consequences.

3. Create `adr/NNNN-<kebab-case-title>.md` using the template:
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

4. Confirm with the user before finalizing.

Guidelines:
- Keep ADRs concise (one page)
- Focus on "why" not just "what"
- Include rejected alternatives
