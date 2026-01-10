# Dotfiles-managed zsh config (opt-in).
# Source this from your existing ~/.zshrc (recommended), e.g.:
#   [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/dotfiles.zsh" ]] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/dotfiles.zsh"
#
# Keep secrets and per-machine overrides in your own files (not this repo).

[[ -o interactive ]] || return 0

# Ensure user-level bin dir is on PATH (install.sh/bootstrap-terminal symlink here).
local_bin="$HOME/.local/bin"
if [[ -d "$local_bin" && ":$PATH:" != *":$local_bin:"* ]]; then
  export PATH="$local_bin:$PATH"
fi

# Shared variables for sub-files.
export DOTFILES_ZSH_BREW_PREFIX=""

# Homebrew (Intel + Apple Silicon)
# Prefer putting this in ~/.zprofile. As a fallback, only initialize it here if
# `brew` isn't already on PATH.
if command -v brew >/dev/null 2>&1; then
  DOTFILES_ZSH_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  DOTFILES_ZSH_BREW_PREFIX="$(/opt/homebrew/bin/brew --prefix 2>/dev/null || true)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
  DOTFILES_ZSH_BREW_PREFIX="$(/usr/local/bin/brew --prefix 2>/dev/null || true)"
fi

# Source modular config in a predictable order.
dotfiles_zsh_self="${${(%):-%x}:A}"
# If this file is sourced via a symlink (common when installed to ~/.config),
# resolve to the real path so we can find dotfiles.d next to the repo file.
dotfiles_zsh_self="${dotfiles_zsh_self:P}"
dotfiles_zsh_dir="${dotfiles_zsh_self:h}/dotfiles.d"
if [[ ! -d "$dotfiles_zsh_dir" ]]; then
  dotfiles_zsh_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/dotfiles.d"
fi
if [[ -d "$dotfiles_zsh_dir" ]]; then
  for f in "$dotfiles_zsh_dir"/*.zsh(N); do
    source "$f"
  done
fi
