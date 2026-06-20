# Coding Standards

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
