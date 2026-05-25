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

## Function Design

- Separate I/O from logic — loading data from external sources must be its own function, isolated so logic can be tested without mocking
- Each function has one concern
- Rely on return values, not side effects
- Avoid complex inline expressions — break them into named variables or steps
- Do not add artificial arguments just to make code testable; restructure instead
- Validate inputs before performing I/O — fail fast

## Domain

- Infrastructure types must depend on domain types, not vice versa
- Centralise type conversions — declare them explicitly (e.g. via a dedicated method or constructor); never convert inline

## Typing

- Use strict types; avoid relaxed types like `Any` or untyped dicts
- Prefer explicit nullable types over implicit optionality
- Never use a tuple as a return type when a named typed object can be used instead

## Naming

- Do not prefix names with underscores unless intentionally private
- Do not bury logic in private functions; keep logic visible and documented

## Documentation

- Comments and docstrings must document intent, not restate what the code does
- Function signatures must be accompanied by documentation of arguments and return values

## Imports

- Always import dependencies at the top of the file; no inline imports
- Remove unused imports
- If circular imports arise, rethink module structure rather than working around them with inline imports

## Testing

- Assert on full objects, not individual properties — this makes tests more concise and ensures all expected values are validated together
- Create the expected object first, then assert against it; do not construct complex expected values inline
- Pure unit tests are sufficient for decoupled logic — do not write integration tests just to work around I/O coupling
