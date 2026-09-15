# Agent Guidelines

- Prefer the smallest correct change.
- Keep responses and code concise, readable, and direct.
- Do not add abstractions, helpers, logging, comments, or compatibility logic without a clear need.
- Prefer one-line shell conditions when each `if`/`else` branch contains only one command, with the condition and each branch on separate lines.
- Use `if` blocks when a branch contains multiple commands or is clearer that way.
- Keep platform-specific installation snippets in `.chezmoitemplates/` and orchestration in `.chezmoiscripts/`.
- Preserve dependency chains: Darwin chezmoi requires Homebrew, and Homebrew requires Xcode Command Line Tools.
- Keep per-host settings in separate files under `.chezmoidata/`.
- Do not modify the system while developing or validating. Never run bootstrap, apply, update, package-manager, or installer commands unless explicitly requested.
- Validate changes with static shell syntax checks and chezmoi template rendering.
- Do not alter unrelated existing behavior or files.
