#!/usr/bin/env bash
set -euo pipefail

payload="${1:-}"
[ -n "$payload" ] || exit 0

if ! command -v jq >/dev/null 2>&1; then
  powershell.exe -NoProfile -Command "[console]::beep(880,160)" >/dev/null 2>&1 || true
  exit 0
fi

type=$(printf '%s' "$payload" | jq -r '.type // ""')
[ "$type" = "agent-turn-complete" ] || exit 0

clean_text() {
  local text="$1"
  text=${text//$'\r'/ }
  text=${text//$'\n'/ }
  text=$(printf '%s' "$text" | tr -s ' ')
  printf '%s' "$text"
}

escape_ps_single_quoted() {
  printf '%s' "$1" | sed "s/'/''/g"
}

turn_id=$(printf '%s' "$payload" | jq -r '."turn-id" // ""')
cwd=$(printf '%s' "$payload" | jq -r '.cwd // ""')
assistant_msg=$(printf '%s' "$payload" | jq -r '."last-assistant-message" // ""')
first_input_msg=$(printf '%s' "$payload" | jq -r '."input-messages"[0] // ""')

assistant_msg=$(clean_text "$assistant_msg")
first_input_msg=$(clean_text "$first_input_msg")

if [ -n "$assistant_msg" ]; then
  body="$assistant_msg"
elif [ -n "$first_input_msg" ]; then
  body="Prompt: $first_input_msg"
else
  body="Turn complete"
fi

repo_name=""
if [ -n "$cwd" ]; then
  repo_name=$(basename "$cwd")
fi

meta=""
if [ -n "$turn_id" ] && [ -n "$repo_name" ]; then
  meta="$repo_name - turn ${turn_id:0:8}"
elif [ -n "$repo_name" ]; then
  meta="$repo_name"
elif [ -n "$turn_id" ]; then
  meta="turn ${turn_id:0:8}"
fi

body=${body:0:240}
meta=${meta:0:80}

if powershell.exe -NoProfile -Command "if (Get-Module -ListAvailable -Name BurntToast) { exit 0 } else { exit 1 }" >/dev/null 2>&1; then
  title_ps=$(escape_ps_single_quoted "Codex")
  meta_ps=$(escape_ps_single_quoted "$meta")
  body_ps=$(escape_ps_single_quoted "$body")

  powershell.exe -NoProfile -Command "\
    Import-Module BurntToast;\
    \$children = @();\
    \$children += New-BTText -Text '$title_ps';\
    if ('$meta_ps') { \$children += New-BTText -Text '$meta_ps' };\
    if ('$body_ps') { \$children += New-BTText -Text '$body_ps' };\
    \$binding = New-BTBinding -Children \$children;\
    \$visual = New-BTVisual -BindingGeneric \$binding;\
    \$content = New-BTContent -Visual \$visual;\
    Submit-BTNotification -Content \$content;\
  " >/dev/null 2>&1 || true
  exit 0
fi

powershell.exe -NoProfile -Command "[console]::beep(880,160)" >/dev/null 2>&1 || true
exit 0
