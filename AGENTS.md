# Git Workflow

- Never stage files or modify the Git index unless the user explicitly requests it.
- Never create, amend, squash, rebase, or otherwise modify commits or Git history.
- Never push changes or create tags unless the user explicitly requests the exact action.
- Never assume that a request to edit, fix, validate, or review files includes permission to stage or commit them.
- Leave all changes unstaged for the user to review unless explicitly instructed otherwise.
- Do not alter the user's existing staged changes. If a task requires editing a staged file, edit only the worktree and leave the index untouched.

# Engineering Approach

- Prefer the smallest correct change.
- Keep code simple, readable, and easy to maintain.
- Do not introduce unnecessary variables, arrays, helpers, branches, prompts, or compatibility logic.
- Reuse existing behavior and native tool semantics instead of duplicating them.
- Understand the complete execution path before changing behavior shared across commands or entry points.
- Diagnose and fix the root cause rather than layering workarounds over symptoms.
- Ask focused clarification questions when the requested behavior is ambiguous.

# Logging

- Add progress logging only around operations that may take noticeable time.
- Do not add progress logging around immediate checks such as testing a file, checking an executable, or running a simple text match.
- Check whether work is needed before logging that a conditional action has started.
- Do not report an action as completed when it was skipped or declined.

# Validation

- Validate changed scripts and rendered templates without running installers, updates, bootstrap processes, or other system-changing commands.
- Verify claimed behavior through the relevant rendered output or execution path before reporting it as fixed.

# Communication

- Be concise and direct.
- Do not overstate what was fixed or validated.
- Clearly distinguish confirmed behavior from assumptions or likely causes.
