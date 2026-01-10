# Plugins (managed by Antidote)
plugins_file="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/antidote/plugins.txt"

antidote_script=""
if [[ -n "${DOTFILES_ZSH_BREW_PREFIX:-}" && -f "$DOTFILES_ZSH_BREW_PREFIX/opt/antidote/share/antidote/antidote.zsh" ]]; then
  antidote_script="$DOTFILES_ZSH_BREW_PREFIX/opt/antidote/share/antidote/antidote.zsh"
elif [[ -f /opt/homebrew/opt/antidote/share/antidote/antidote.zsh ]]; then
  antidote_script="/opt/homebrew/opt/antidote/share/antidote/antidote.zsh"
elif [[ -f /usr/local/opt/antidote/share/antidote/antidote.zsh ]]; then
  antidote_script="/usr/local/opt/antidote/share/antidote/antidote.zsh"
fi

if [[ -n "$antidote_script" && -f "$plugins_file" ]]; then
  source "$antidote_script"
  antidote load "$plugins_file"
fi
