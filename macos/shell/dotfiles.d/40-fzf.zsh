# fzf (installed by brew)
if command -v fzf >/dev/null 2>&1 && [[ -n "${DOTFILES_ZSH_BREW_PREFIX:-}" ]]; then
  [[ -f "$DOTFILES_ZSH_BREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]] && source "$DOTFILES_ZSH_BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
  [[ -f "$DOTFILES_ZSH_BREW_PREFIX/opt/fzf/shell/completion.zsh" ]] && source "$DOTFILES_ZSH_BREW_PREFIX/opt/fzf/shell/completion.zsh"
fi

