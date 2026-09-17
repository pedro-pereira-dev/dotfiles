# Agent Guidelines

- Prefer the smallest correct change.
- Keep responses and code concise, readable, and direct.
- Write comments in lowercase.
- Do not end comments with punctuation.
- Comment complex template conditionals with when each branch is applied.
- Do not comment simple template conditionals when the condition is self-explanatory.
- Keep simple Bash functions on one line.
- Do not add abstractions, helpers, logging, comments, or compatibility logic without a clear need.
- Prefer one-line shell conditions when each `if`/`else` branch contains only one command, with the condition and each branch on separate lines.
- Use `if` blocks when a branch contains multiple commands or is clearer that way.
- Keep orchestration in `.chezmoiscripts/` and group supporting templates in `.chezmoitemplates/<step>/<platform>/`.
- Name each platform entry template after its action, such as `.chezmoitemplates/install-tools/darwin/install`, without repeating the parent step name.
- Start supporting template names with a verb that describes their action, such as `install-homebrew`, `install-chezmoi`, or `setup-bash`.
- Preserve dependency chains: Darwin chezmoi requires Homebrew, and Homebrew requires Xcode Command Line Tools.
- Keep per-host settings in separate files under `.chezmoidata/`.
- Never modify the system without the user's explicit consent. Never run bootstrap, apply, update, package-manager, installer, or system-configuration commands while developing or validating unless explicitly requested.
- Never commit, amend, reset, rebase, or otherwise change Git history without the user's explicit consent.
- Do not alter unrelated existing behavior or files.
