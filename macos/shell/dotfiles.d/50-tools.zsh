# Starship prompt
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# zoxide
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# direnv
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

