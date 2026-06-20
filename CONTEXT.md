# Matt Pocock Skills

A collection of agent skills (slash commands and behaviors) loaded by Claude Code. Skills are organized into buckets and consumed by per-repo configuration emitted by `/setup-matt-pocock-skills`.

## Language

**Issue tracker**:
The tool that hosts a repo's issues — GitHub Issues, Linear, a local `.scratch/` markdown convention, or similar. Skills like `to-issues`, `to-prd`, `triage`, and `qa` read from and write to it.
_Avoid_: backlog manager, backlog backend, issue host

**Issue**:
A single tracked unit of work inside an **Issue tracker** — a bug, task, PRD, or slice produced by `to-issues`.
_Avoid_: ticket (use only when quoting external systems that call them tickets)

**Triage role**:
A canonical state-machine label applied to an **Issue** during triage (e.g. `needs-triage`, `ready-for-afk`). Each role maps to a real label string in the **Issue tracker** via `docs/agents/triage-labels.md`.

## Relationships

- An **Issue tracker** holds many **Issues**
- An **Issue** carries one **Triage role** at a time

**AFK Loop**:
The autonomous build-review cycle driven by `/afk`. A single invocation runs until all Reviewers agree the feature is correctly implemented.
_Avoid_: autonomous workflow, dispatch loop

**Review Cycle**:
One iteration of the AFK Loop — one build pass followed by 3 parallel Reviewer verdicts. Findings are appended to the plan file as `## Review Cycle N`.
_Avoid_: review round, iteration

**Reviewer**:
A read-only subagent with a fixed focus area (Correctness, Standards, or Architecture) that emits a `PASS | FAIL` verdict with specific findings against the current implementation.
_Avoid_: verifier, reviewer agent

## Flagged ambiguities

- "backlog" was previously used to mean both the *tool* hosting issues and the *body of work* inside it — resolved: the tool is the **Issue tracker**; "backlog" is no longer used as a domain term.
- "backlog backend" / "backlog manager" — resolved: collapsed into **Issue tracker**.
