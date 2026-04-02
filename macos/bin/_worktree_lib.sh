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
