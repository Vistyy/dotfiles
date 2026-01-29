# dotfiles

Personal dotfiles and scripts.

## Contents

- **bin/** - Utility scripts
  - `dev-tabs` - Open development environment in terminal tabs
  - `new-worktree` - Create git worktree with tmux session
  - `rm-worktree` - Remove git worktree and cleanup

## Install

```bash
./install.sh
```

Creates symlinks in `~/.local/bin`.

## macOS terminal setup

```bash
./macos/bin/bootstrap-terminal
```

This installs terminal tools (Homebrew, WezTerm, tmux, Starship, etc) and links configs.

It links a zsh fragment into `~/.config/zsh/`, but does not touch your `~/.zshrc` unless you opt in:

```bash
./macos/bin/bootstrap-terminal --install-shell
```

Tip: keep machine/user-specific zsh tweaks private by putting them in `~/.zshrc.local`
and sourcing it from your `~/.zshrc` (see `macos/shell/zshrc.example`).

Optional flags:
- `--no-brew-update`
- `--no-fonts`
- `--fzf-shell`
- `--tmux-plugins`
