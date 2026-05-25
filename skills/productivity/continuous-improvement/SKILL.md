---
name: continuous-improvement
description: File GitHub issues for bugs discovered mid-conversation, then resume the original task
compatibility: opencode
---

## What I do

Allow you to interrupt any conversation to file a GitHub issue for a bug you just discovered, then seamlessly resume the original topic.

## When to use me

- You notice a bug, defect, or unexpected behaviour while working on something else
- You want to quickly capture an issue without losing your current flow
- You say something like "log a bug", "file an issue", "track this bug", "create an issue for this"

## Workflow

### 1. Gather issue details

When the user wants to file an issue, collect the following (infer from conversation context where possible, ask for anything missing):

- **Title**: concise summary of the bug
- **Description**: what is wrong
- **Steps to reproduce**: how to trigger the bug
- **Context**: what was being worked on when the bug was found
- **Labels**: infer appropriate labels (e.g. `bug`, `enhancement`, `documentation`). Only use `bug` if it is truly a bug.
- **Priority**: infer from context if obvious, otherwise ask. Use one of:
  - `priority: high` — broken feature, significant user impact, blocks work, data loss, security
  - `priority: medium` — degraded experience, workaround exists, should be addressed
  - `priority: low` — cosmetic, minor inconvenience, edge case

### 2. Determine target repository

Look up the current workspace path in the config file `repos.json` (located alongside this skill file). The config maps workspace paths to GitHub `org/repo` identifiers.

If the current workspace matches a path in `repos.json`, use the corresponding `github` value directly — no need to run any git commands.

If no match is found, fall back to:

```
git remote get-url origin
```

Parse the `org/repo` from the remote URL. If still ambiguous, ask the user which repo to file against.

### 3. Create the issue

Use the GitHub CLI to create the issue:

1. Write the issue body to a temp file (to avoid shell-escaping issues with multiline Markdown)
2. Run:

```
gh issue create --repo <org/repo> --title "<title>" --body-file <temp-file> --label "priority: <level>" --label <additional-labels>
```

Build the `--label` flags dynamically from the collected labels. Always include the appropriate `priority: <level>` label, plus any other relevant labels.

The body should be formatted as:

```markdown
## Description

<description>

## Steps to Reproduce

<steps>

## Context

<what was being worked on when this was discovered>
```

### 4. Confirm and resume

- Report the created issue number and URL to the user
- Explicitly state: "Returning to the previous topic."
- Continue the conversation from where it was interrupted

## Important notes

- This skill is an interrupt — it should be fast and lightweight
- Do NOT lose track of what was being discussed before the bug report
- If the user provides enough context in their message to fill all fields, do not ask redundant questions — just file it
- Always confirm the issue was created successfully before resuming
