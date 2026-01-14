#!/usr/bin/env bash
set -euo pipefail

REPO_NAME="budgeat"
REPO_ROOT="${HOME}/projects/budgeat"
WORKTREES_DIR="${HOME}/projects/budgeat.worktrees"
DEFAULT_BASE_BRANCH="main"

say() {
  printf "%s\n" "$*"
}

err() {
  printf "%s\n" "$*" >&2
}

die() {
  err "Error: $*"
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

is_unsafe_relpath() {
  local p="$1"
  [[ -z "$p" ]] && return 0
  [[ "$p" == /* ]] && return 0
  [[ "$p" == ".." || "$p" == ../* || "$p" == */../* || "$p" == */.. ]] && return 0
  return 1
}

branch_from_task_file() {
  local task_file="$1"
  [[ -n "$task_file" ]] || die "task_file is required"
  local filename
  filename="$(basename "$task_file" .md)"
  local branch_suffix="${filename#TODO-}"
  printf "feat/%s" "$branch_suffix"
}

branch_to_dir_name() {
  local branch="$1"
  printf "%s" "${branch//\//-}"
}

branch_to_session_name() {
  local branch="$1"
  local dir_name
  dir_name="$(branch_to_dir_name "$branch")"
  printf "%s__%s" "$REPO_NAME" "$dir_name"
}

copy_relpath() {
  local worktree_path="$1"
  local relpath="$2"
  local src="$REPO_ROOT/$relpath"
  local dest="$worktree_path/$relpath"

  if command -v rsync >/dev/null 2>&1; then
    (cd "$REPO_ROOT" && rsync -aR "$relpath" "$worktree_path/")
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  if [[ -d "$src" ]]; then
    mkdir -p "$dest"
    cp -a "$src/." "$dest/"
  else
    cp -a "$src" "$dest"
  fi
}

copy_gitignored_extras() {
  local worktree_path="$1"
  local script_copy_manifest="${2:-}"
  local copy_manifest_override="${3:-}"

  local repo_copy_manifest="$REPO_ROOT/.worktree.copylist"
  local copy_manifest=""

  if [[ -n "$copy_manifest_override" ]]; then
    copy_manifest="$copy_manifest_override"
  elif [[ -f "$repo_copy_manifest" ]]; then
    copy_manifest="$repo_copy_manifest"
  else
    copy_manifest="$script_copy_manifest"
  fi

  if [[ -f "${copy_manifest:-}" ]]; then
    say "    Manifest: $copy_manifest"
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line%$'\r'}"
      local relpath
      relpath="$(trim "$line")"
      [[ -z "$relpath" ]] && continue
      [[ "$relpath" == \#* ]] && continue

      relpath="${relpath%/}"

      if is_unsafe_relpath "$relpath"; then
        err "    Skipping unsafe path in manifest: $relpath"
        continue
      fi

      if [[ -e "$REPO_ROOT/$relpath" ]]; then
        copy_relpath "$worktree_path" "$relpath"
        say "    Copied $relpath"
      fi
    done <"$copy_manifest"
    return 0
  fi

  if [[ -n "${copy_manifest:-}" ]]; then
    say "    No manifest found at: $copy_manifest"
  else
    say "    No manifest configured"
  fi
  say "    Falling back to built-in defaults (.env, models/)"

  if [[ -f "$REPO_ROOT/.env" ]]; then
    cp "$REPO_ROOT/.env" "$worktree_path/.env"
    say "    Copied .env"
  fi

  if [[ -d "$REPO_ROOT/models" ]]; then
    mkdir -p "$worktree_path/models"
    cp -r "$REPO_ROOT/models/"* "$worktree_path/models/" 2>/dev/null || true
    say "    Copied models/"
  fi
}

ensure_tmux_layout() {
  local session="$1"
  local cwd="$2"
  local create_setup_window="${3:-true}"

  require_cmd tmux

  if ! tmux has-session -t "$session" 2>/dev/null; then
    local shell="${SHELL:-/bin/zsh}"
    tmux new-session -d -s "$session" -c "$cwd" -n codex

    local pane1 pane2
    pane1="$(tmux display-message -p -t "${session}:codex" '#{pane_id}')"
    pane2="$(tmux split-window -h -P -F '#{pane_id}' -t "${session}:codex" -c "$cwd")"
    tmux select-layout -t "${session}:codex" even-horizontal >/dev/null 2>&1 || true

    tmux send-keys -t "$pane1" "cd \"$cwd\" && (codex -p codex || true) && exec \"$shell\" -l" C-m
    tmux send-keys -t "$pane2" "cd \"$cwd\" && (codex -p standard || true) && exec \"$shell\" -l" C-m

    if [[ "$create_setup_window" == "true" ]]; then
      tmux new-window -t "$session" -n setup -c "$cwd"
      tmux send-keys -t "${session}:setup" "cd \"$cwd\" && (uv sync && just q || true) && exec \"$shell\" -l" C-m
    fi
  fi
}

open_wezterm_to_tmux_session() {
  local session="$1"
  local cwd="$2"

  require_cmd wezterm
  require_cmd tmux

  (nohup wezterm start --cwd "$cwd" -- tmux new -A -s "$session" >/dev/null 2>&1 &)
}
