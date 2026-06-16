---
description: Implement the feature described in the most recent plan file
agent: build
---

Read the most recent plan file:

!ls -t .opencode/plans/*.md 2>/dev/null | head -1 | xargs cat 2>/dev/null || echo "No plan file found. Run /plan first."

Implement the feature as described in the plan above.

After implementing:

1. Run every command listed under **Verification Commands** in the plan
2. Confirm each item in the **Acceptance Criteria** checklist is met
3. If any command fails or any criterion is not met, fix the issue before stopping — do not stop until all criteria pass and all commands succeed
