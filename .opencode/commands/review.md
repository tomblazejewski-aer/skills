---
description: Review implementation against the plan, acceptance criteria, and coding standards
---

Read the most recent plan file:

!ls -t .opencode/plans/*.md 2>/dev/null | head -1 | xargs cat 2>/dev/null || echo "No plan file found. Run /plan first."

Read the project's coding standards:

!cat STANDARDS.md 2>/dev/null || cat "$HOME/.config/opencode/STANDARDS.md" 2>/dev/null || echo "No STANDARDS.md found"

Now perform a thorough review:

1. Run every command listed under **Verification Commands** in the plan and report each result
2. Check each item in the **Acceptance Criteria** checklist against the current code — mark each as passing or failing with a specific reason and file + line reference
3. Check the changed files against the coding standards — flag every violation with file + line reference

When done, produce a concise review report:

- **PASS** or **FAIL** for each acceptance criterion
- **PASS** or **FAIL** for each verification command
- A list of any standards violations found (file + line for each)

If there are failures or violations, describe exactly what needs to be fixed. The user will tab to the build agent to make the fixes, then return to `/review` to re-check.
