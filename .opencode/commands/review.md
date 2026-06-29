---
description: Review implementation against the plan using 3 parallel specialist reviewers — correctness, standards, and architecture.
---

Find the most recent plan file:

```bash
ls -t .opencode/plans/*.md 2>/dev/null | head -1
```

If no plan file is found, stop and tell the user: "No plan file found. Run /plan first."

Store the path as `PLAN_FILE`. Read it in full.

Determine the cycle number by counting existing `## Review Cycle` sections in `PLAN_FILE` and adding 1. If none exist, use 1.

Determine the list of changed files:

```bash
git diff --name-only HEAD
```

If the result is empty (all changes are already committed), fall back to:

```bash
git diff --name-only HEAD~1 HEAD
```

In a **single message**, invoke all three reviewer subagents simultaneously via the Task tool:

1. `afk-reviewer-correctness` — pass `PLAN_FILE: <path>`, `FILES: <list>`, and the cycle number
2. `afk-reviewer-standards` — pass `PLAN_FILE: <path>`, `FILES: <list>`, and the cycle number
3. `afk-reviewer-architecture` — pass `PLAN_FILE: <path>`, `FILES: <list>`, and the cycle number

Wait for all 3 results, then append the following block to the end of `PLAN_FILE`:

```
---

## Review Cycle <CYCLE>

### Correctness Reviewer
VERDICT: <PASS | FAIL>
<findings>

### Standards Reviewer
VERDICT: <PASS | FAIL>
<findings>

### Architecture Reviewer
VERDICT: <PASS | FAIL>
<findings>

**Overall: <PASS — all 3 reviewers agreed | FAIL — N reviewer(s) blocked>**
```

Finally, report the overall result to the user. If any reviewer returned `VERDICT: FAIL`, list the specific findings and what must be fixed. If all three returned `VERDICT: PASS`, confirm the implementation is ready.
