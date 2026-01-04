# dotfiles

Personal dotfiles and scripts.

## Contents

- **bin/** - Utility scripts
  - `dev-tabs` - Open development environment in terminal tabs
  - `new-worktree` - Create git worktree with tmux session
  - `rm-worktree` - Remove git worktree and cleanup

- **codex-prompts/** - AI assistant prompts for code review and quality
- **codex-skills/** - Codex personal skills (symlinked into `~/.codex/skills`)

## Install

```bash
./install.sh
```

Creates symlinks in `~/.local/bin` and `~/.codex/prompts`.

Also creates symlinks in `~/.codex/skills`.
