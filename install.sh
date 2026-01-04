#!/bin/bash
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/.local/bin ~/.codex/prompts ~/.codex/skills

for script in "$DOTFILES_DIR"/bin/*; do
  ln -sf "$script" ~/.local/bin/
done

for prompt in "$DOTFILES_DIR"/codex-prompts/*; do
  ln -sf "$prompt" ~/.codex/prompts/
done

for skill_dir in "$DOTFILES_DIR"/codex-skills/*; do
  if [ ! -d "$skill_dir" ]; then
    continue
  fi

  target="$HOME/.codex/skills/$(basename "$skill_dir")"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "Skipping skill (target exists and is not a symlink): $target"
    continue
  fi

  ln -snf "$skill_dir" "$target"
done

echo "Dotfiles installed"
