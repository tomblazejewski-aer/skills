---
description: Plan a feature with acceptance criteria and verification commands
agent: plan
---

Read the project's coding standards:

!cat STANDARDS.md 2>/dev/null || cat "$HOME/.config/opencode/STANDARDS.md" 2>/dev/null || echo "No STANDARDS.md found"

You are now in planning mode. Your task is to write a detailed implementation plan for the feature described above.

Before writing the plan:
1. Understand the feature request and any constraints
2. Identify which coding standards apply to this task

Then write the plan to `.opencode/plans/<timestamp>-<slug>.md` using the current Unix timestamp and a kebab-case slug based on the feature name.

The plan file must contain exactly these three sections:

## Implementation Approach

A clear description of what changes will be made and why — modules, functions, types, and their interactions.

## Acceptance Criteria

A checklist of concrete, testable statements. Each item must be independently verifiable.

- [ ] <testable statement>
- [ ] <testable statement>

## Verification Commands

All commands needed to confirm correctness after implementation (tests, lint, build, type-check, etc.). Pull these from the project's `package.json`, `Makefile`, `pyproject.toml`, or equivalent.

Once written, tell the user the path to the plan file.
