---
description: Implement the feature from the most recent plan file using TDD (red-green-refactor)
agent: build
---

Load the TDD methodology:

!cat .opencode/skills/tdd/SKILL.md 2>/dev/null || cat "$HOME/.config/opencode/skills/tdd/SKILL.md" 2>/dev/null || echo "(tdd skill not found — apply red-green-refactor principles anyway)"

Read the most recent plan file:

!ls -t .opencode/plans/*.md 2>/dev/null | head -1 | xargs cat 2>/dev/null || echo "No plan file found. Run /plan first."

Implement using TDD — vertical slices, one acceptance criterion at a time:

1. Take the first unchecked acceptance criterion from the plan
2. Write a failing test for that behavior (RED)
3. Write the minimal code to make it pass (GREEN)
4. Refactor if needed — never while RED
5. Repeat for the next criterion

After all criteria are implemented, run every command listed under **Verification Commands** in the plan. Do not stop until all criteria pass and all commands succeed.
