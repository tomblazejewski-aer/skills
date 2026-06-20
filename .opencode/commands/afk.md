---
description: Autonomously implement and review a feature — runs the full TDD build cycle followed by 3 parallel specialist reviewers until all agree the feature is done. Human starts once and walks away.
agent: afk-orchestrator
---

Start the AFK loop.

Find the most recent plan file in `.opencode/plans/` and run the autonomous build-review cycle until all 3 Reviewers agree the feature is implemented correctly.

If a specific plan file path is given as `$ARGUMENTS`, use that file instead of the most recent one.
