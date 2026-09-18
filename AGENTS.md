# Git Workflow

- Never stage files or modify the Git index unless the user explicitly requests it.
- Never create, amend, squash, rebase, or otherwise modify commits or Git history.
- Never push changes or create tags unless the user explicitly requests the exact action.
- Never assume that a request to edit, fix, validate, or review files includes permission to stage or commit them.
- Leave all changes unstaged for the user to review unless explicitly instructed otherwise.
- Do not alter the user's existing staged changes. If a task requires editing a staged file, edit only the worktree and leave the index untouched.
