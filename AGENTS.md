# Agent Instructions

## General

- When clarification is needed, always ask questions as an interactive prompt to the user — never embed questions in code comments, test stubs, or inline placeholders.
- NEVER ask questions in plain text responses. All questions must be asked using the interactive prompt tool. This is an absolute rule with no exceptions — it covers all forms of in-text questioning including but not limited to:
  - "Before I proceed..."
  - "Should I..."
  - "Would you like me to..."
  - "One thing I haven't resolved is..."
  - "I have a question about..."
  - Ending a response with an implicit or explicit question of any kind
- NEVER present a list of options or solutions in plain text and ask for a preference. If a choice needs to be made, use the interactive prompt tool.

## File System

- Never write files to paths outside the current working directory. All file operations must stay within the repo root.
- Delete any files created as part of a task (e.g. temp files, downloaded files) once you are done with them.

## Git

- NEVER use `git commit --amend` followed by a force push. Always create new commits to fix issues.
- NEVER merge pull requests or perform merges into the default branch. Merging is strictly forbidden — push branches and create PRs, but never merge them.

## GitHub

- When provided with GitHub issue or PR links, use `gh` to fetch their details rather than web fetching.
- When working on GitHub-hosted repos, pushing changes and creating a PR should be the default workflow. Do not wait to be asked — push the branch and create a PR unless told otherwise.

## Shell (PowerShell)

- When creating multi-line strings (e.g. PR bodies, issue bodies), use a PowerShell here-string passed directly to the command. Do NOT use bash heredocs (`<<EOF`) as they are not supported in PowerShell.
- NEVER write temporary files outside of the current repo directory. Do NOT use system temp folders (e.g. `$env:TEMP`, `C:\Users\...\AppData\Local\Temp`, `/tmp`).

## Coding Standards

See `STANDARDS.md` at the project root (or `~/.config/opencode/STANDARDS.md` globally) for coding rules covering Function Design, Domain, Typing, Naming, Documentation, Imports, and Testing.
