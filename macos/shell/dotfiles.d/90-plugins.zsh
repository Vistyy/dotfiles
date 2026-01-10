# Plugins (installed via brew)
if [[ -n "${DOTFILES_ZSH_BREW_PREFIX:-}" ]]; then
  [[ -f "$DOTFILES_ZSH_BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$DOTFILES_ZSH_BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

