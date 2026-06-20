---
description: Interview the user (grill-with-docs), design TDD-first, then write a plan with behavioral acceptance criteria
agent: plan
---

Load the grill-with-docs interview methodology:

!cat .opencode/skills/grill-with-docs/SKILL.md 2>/dev/null || cat "$HOME/.config/opencode/skills/grill-with-docs/SKILL.md" 2>/dev/null || echo "(grill-with-docs skill not found — use a thorough one-question-at-a-time interview approach anyway)"

Load the CONTEXT.md format:

!cat .opencode/skills/grill-with-docs/CONTEXT-FORMAT.md 2>/dev/null || cat "$HOME/.config/opencode/skills/grill-with-docs/CONTEXT-FORMAT.md" 2>/dev/null

Load the ADR format:

!cat .opencode/skills/grill-with-docs/ADR-FORMAT.md 2>/dev/null || cat "$HOME/.config/opencode/skills/grill-with-docs/ADR-FORMAT.md" 2>/dev/null

Load the TDD methodology:

!cat .opencode/skills/tdd/SKILL.md 2>/dev/null || cat "$HOME/.config/opencode/skills/tdd/SKILL.md" 2>/dev/null || echo "(tdd skill not found — apply red-green-refactor principles anyway)"

Load the coding standards:

!cat STANDARDS.md 2>/dev/null || cat "$HOME/.config/opencode/STANDARDS.md" 2>/dev/null || echo "(No STANDARDS.md found)"

---

You are in planning mode. This session has three phases — do not skip Phase 1 or Phase 2.

## Phase 1 — Interview

Follow the grill-with-docs methodology above. Interview the user relentlessly about this feature, one question at a time using the interactive prompt tool. Walk every branch of the decision tree until you reach a complete shared understanding of:

- Exactly what needs to be built
- All edge cases and constraints
- How it fits with the existing codebase and domain model
- What "done" looks like

If a question can be answered by exploring the codebase, explore it instead of asking.

Update `CONTEXT.md` inline whenever a term is resolved. Offer an ADR only if the decision is hard to reverse, surprising without context, and the result of a real trade-off.

Do not move to Phase 2 until the interview is complete.

## Phase 2 — TDD design

Using the TDD methodology above and what you learned in Phase 1:

- Confirm what interface changes are needed
- Identify which behaviors matter most to test (prioritize; you can't test everything)
- Design the public interface for testability — identify deep module opportunities
- List the behaviors to test as behavioral specifications (what the system does, not how)

Ask the user to confirm the interface design and testing priorities before proceeding.

## Phase 3 — Write the plan

Write the plan to `.opencode/plans/<timestamp>-<slug>.md` (Unix timestamp + kebab-case slug).

The file must contain exactly these three sections:

### Implementation Approach

A clear description of what changes will be made and why, including the public interface design and module structure.

### Acceptance Criteria

A checklist of behavioral test specifications derived from the interview and TDD design phase. Each item describes observable behavior through a public interface — not implementation details.

- [ ] <behavioral specification>

### Verification Commands

All commands needed to confirm correctness (tests, lint, build, type-check, etc.).

Tell the user the path to the plan file when done.
