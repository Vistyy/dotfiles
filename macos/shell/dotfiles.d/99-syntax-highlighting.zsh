# zsh-syntax-highlighting should be sourced last.
if [[ -n "${DOTFILES_ZSH_BREW_PREFIX:-}" ]]; then
  [[ -f "$DOTFILES_ZSH_BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$DOTFILES_ZSH_BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

