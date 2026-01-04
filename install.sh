#!/bin/bash
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/.local/bin ~/.codex/prompts ~/.codex/skills

for script in "$DOTFILES_DIR"/bin/*; do
  target="$HOME/.local/bin/$(basename "$script")"
  if [ -e "$target" ] && [ "$script" -ef "$target" ]; then
    continue
  fi
  ln -sf "$script" "$target"
done

for prompt in "$DOTFILES_DIR"/codex-prompts/*; do
  target="$HOME/.codex/prompts/$(basename "$prompt")"
  if [ -e "$target" ] && [ "$prompt" -ef "$target" ]; then
    continue
  fi
  ln -sf "$prompt" "$target"
done

for skill_dir in "$DOTFILES_DIR"/codex-skills/*; do
  if [ ! -d "$skill_dir" ]; then
    continue
  fi

  target="$HOME/.codex/skills/$(basename "$skill_dir")"

  # Codex skill discovery may treat a symlink-to-dir as "not a directory" when
  # enumerating skills. Install as a real directory instead of a directory
  # symlink.
  if [ -L "$target" ]; then
    rm -f "$target"
  fi

  mkdir -p "$target"

  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$skill_dir"/ "$target"/
  else
    rm -rf "$target"/*
    cp -a "$skill_dir"/. "$target"/
  fi
done

echo "Dotfiles installed"
