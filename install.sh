#!/bin/bash
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

mkdir -p ~/.local/bin

for script in "$DOTFILES_DIR"/bin/*; do
  base="$(basename "$script")"

  # On macOS, prefer native versions of these scripts under macos/bin/.
  if [[ "$OS" == "Darwin" ]]; then
    case "$base" in
      dev-tabs|new-worktree|rm-worktree) continue ;;
    esac
  fi

  target="$HOME/.local/bin/$(basename "$script")"
  if [ -e "$target" ] && [ "$script" -ef "$target" ]; then
    continue
  fi
  ln -sf "$script" "$target"
done

if [[ "$OS" == "Darwin" && -d "$DOTFILES_DIR/macos/bin" ]]; then
  for script in "$DOTFILES_DIR"/macos/bin/*; do
    base="$(basename "$script")"
    case "$base" in
      bootstrap-terminal|_*) continue ;;
    esac
    target="$HOME/.local/bin/$base"
    if [ -e "$target" ] && [ "$script" -ef "$target" ]; then
      continue
    fi
    ln -sf "$script" "$target"
  done
fi

notify_script="$DOTFILES_DIR/bin/notify-codex.sh"
if [ -f "$notify_script" ]; then
  mkdir -p "$HOME/.codex"
  notify_target="$HOME/.codex/notify-codex.sh"
  if ! { [ -e "$notify_target" ] && [ "$notify_script" -ef "$notify_target" ]; }; then
    ln -sf "$notify_script" "$notify_target"
  fi
fi

echo "Dotfiles installed"
