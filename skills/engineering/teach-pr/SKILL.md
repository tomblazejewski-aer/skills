---
name: teach-pr
description: Teach the user the concepts in a GitHub PR through an adaptive quiz — MCQ, open questions, and code writing — tracking progress in their Obsidian vault across sessions. Use when the user wants to learn from a PR, understand code changes, practice concepts from a pull request, or says "teach me this PR".
---

# Teach PR

Turn a GitHub pull request into an adaptive teaching session. The agent extracts concepts from the diff, tailors questions to the user's level and learning history, presents a full quiz, then reviews every answer and updates the user's Obsidian progress notes.

## Prerequisites

`docs/agents/learner-profile.md` must exist (written by `/setup-matt-pocock-skills`). If it is missing or the user opted out of PR teaching, say so and stop — do not improvise a profile.

## Process

### 1. Load context

Run in parallel:

- **PR content** — `gh pr view <pr> --json title,body,additions,deletions,changedFiles` and `gh pr diff <pr>` to get the full diff.
- **Learner profile** — read `docs/agents/learner-profile.md`. Extract: known stacks, target stack, analogy languages, current self-assessed level, and the vault path + progress subfolder.
- **Progress notes** — list all `.md` files under `<vault-path>/<progress-subfolder>/`. Read any whose filename matches concepts likely present in this PR. This tells you what the user already knows and what still needs work.

### 2. Extract concepts

From the diff and PR description, identify the distinct concepts being introduced or exercised. A concept is a discrete idea a learner could be tested on — not a file or function name, but the underlying pattern, technique, or design decision (e.g. "discriminated unions", "optimistic locking", "React Server Components", "dependency inversion").

For each concept, assign:

- **Familiarity** — `new` / `seen` / `practised` based on progress notes (default `new` if no note exists)
- **Complexity** — `foundational` / `intermediate` / `advanced` relative to the user's target stack level

### 3. Plan the quiz

Build a question plan before writing any questions. For each concept:

| Familiarity | Complexity | Question type |
|---|---|---|
| new | any | MCQ (recall) → open (understanding) |
| seen | foundational/intermediate | open (understanding) → short code |
| seen | advanced | open (understanding) → full code |
| practised | any | full code → open (edge cases) |

Use the learner's known stack for analogies in explanations. Do not use analogies in questions — only in feedback.

Aim for 2–3 questions per concept. Fewer for foundational concepts the user has already practised; more for new advanced ones.

### 4. Present the quiz

Show all questions at once in a single message. Format:

```
## PR Teaching Session: <PR title>

**Concepts covered:** <comma-separated list>
**Questions:** <total count>

---

### Concept: <concept name>

**Q1.** [MCQ or open question or code prompt]

A) ...
B) ...
C) ...
D) ...

---

### Concept: <next concept>

**Q2.** [question]

...
```

For code questions, include:

- The relevant snippet from the diff (trimmed to the essentials)
- A clear task: "Write a function that..." or "Refactor this to..."

Do not give hints. Do not reveal which answer is correct. Wait for the user to answer all questions before proceeding.

### 5. Review answers

After the user submits all answers, go through each question in order:

- **Correct / good answer** — confirm, then add one sentence of deeper context or a connection to a related concept.
- **Partially correct** — acknowledge what was right, explain what was missing.
- **Incorrect** — explain the correct answer clearly. Use an analogy from the user's known stack if it helps.
- **Code answers** — reason about correctness, edge cases, and style. Point to the actual diff to show how the real implementation chose to handle the same problem.

#### Scoring rules

**Per question:**

| Outcome | Points awarded |
|---|---|
| Correct | 1.0 |
| Partial | 0.5 |
| Incorrect | 0 |

**Weighting:** code questions count as 2 points maximum (still 0 / 1 / 2). MCQ and open questions count as 1 point maximum.

**Per concept score:** sum of points earned ÷ sum of points possible for that concept's questions. Express as a percentage.

**Correct session threshold:** ≥80% weighted score on a concept's questions = concept passed this session.

Show a score summary at the end:

```
## Results

| Concept | Score | Streak | Status |
|---|---|---|---|
| discriminated unions | 85% | 🔥 2 | seen → practised |
| optimistic locking | 40% | 💔 reset | seen (was 3, now 0) |
```

### 6. Update progress notes

For each concept, update (or create) `<vault-path>/<progress-subfolder>/<concept-slug>.md`.

#### Status state machine

States: `new` → `seen` → `practised` → `mastered`

**Advancing:**
- `new` → `seen`: any attempt (regardless of score)
- `seen` → `practised`: streak reaches 4 (4 consecutive sessions with ≥80% on this concept)
- `practised` → `mastered`: streak reaches 7

**Streak reset:** any session scoring <80% on the concept resets its streak to 0. Status does not immediately regress on a single failure.

**Regression:** 2 consecutive sessions scoring <80% demotes status by one level (mastered → practised → seen). Streak resets to 0. `seen` cannot regress further.

Track `consecutive_failures` in the note. Increment on each <80% session; reset to 0 on a ≥80% session.

#### Note format

```markdown
# <Concept Name>

**Status:** new | seen | practised | mastered
**Streak:** <n> consecutive passing sessions
**Consecutive failures:** <n>
**Last tested:** <YYYY-MM-DD>
**Sessions:** <total count>

## Notes

<One paragraph summary of what the user got right, what they struggled with,
and what to focus on next time. Written in second person.>

## History

| Date | PR | Score | Passed | Streak after |
|---|---|---|---|---|
| <date> | <PR title or URL> | <n>% | ✓/✗ | <n> |
```

### 7. Done

Tell the user:
- Which concepts they've mastered / are improving / still need work
- A suggested next PR to look at (if you can infer one from the repo's open PRs — `gh pr list`)
- That their notes have been updated in the vault
