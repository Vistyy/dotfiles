# Agent Instructions (dotfiles)

These instructions apply to the entire repository.

## System-specific scripts must stay aligned

This repo contains system-specific variants of similar scripts:
- `bin/` (often Linux/WSL-oriented)
- `macos/bin/` (macOS-oriented; `install.sh` prefers these on Darwin for some scripts)

When you change behavior, flags, output, or defaults in one system’s script, you MUST:
1. Identify the corresponding script(s) on the other system(s).
2. Either port the same behavior/UX to them, or explicitly document why the behavior is intentionally different.
3. Re-run a quick diff check to confirm only intentional differences remain.

### Required checks before finishing a script change

- Check recent history for related changes: `git log -n 10 --name-status -- bin macos/bin`
- Diff counterparts (where applicable):
  - `diff -u bin/dev-tabs macos/bin/dev-tabs || true`
  - `diff -u bin/new-worktree macos/bin/new-worktree || true`
  - `diff -u bin/rm-worktree macos/bin/rm-worktree || true`
- Sanity-check shell syntax for touched scripts:
  - `bash -n <script>`

### Notes

- It’s OK for terminal orchestration to differ (e.g., `wt.exe`/WSL vs `tmux`/WezTerm), but shared features like copy-manifests, safety checks, and flags should be kept consistent unless explicitly justified.
