#!/bin/bash
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/.local/bin ~/.codex/prompts

for script in "$DOTFILES_DIR"/bin/*; do
  ln -sf "$script" ~/.local/bin/
done

for prompt in "$DOTFILES_DIR"/codex-prompts/*; do
  ln -sf "$prompt" ~/.codex/prompts/
done

echo "Dotfiles installed"
