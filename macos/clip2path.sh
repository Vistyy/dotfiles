#!/bin/sh

set -eu

host=${WEZTERM_CLIP_HOST:-devbox.tailf9563c.ts.net}
user=${WEZTERM_CLIP_USER:-syzom}
remote_dir=${WEZTERM_CLIP_REMOTE_DIR:-/tmp/wezterm-clip}
timestamp=$(date '+%Y%m%d_%H%M%S')_$$
local_file=${TMPDIR:-/tmp}/clip_$timestamp.png
clipboard_file=${TMPDIR:-/tmp}/clip_$timestamp.clipboard
remote_file=$remote_dir/clip_$timestamp.png

cleanup() {
  rm -f "$local_file" "$clipboard_file"
}
trap cleanup EXIT HUP INT TERM

# Read the image with built-in AppleScript and normalize it to PNG with sips;
# this handles apps that expose either PNG or TIFF clipboard data.
/usr/bin/osascript -l AppleScript - "$clipboard_file" <<'APPLESCRIPT'
on run argv
  set outputPath to item 1 of argv
  try
    set imageData to the clipboard as «class PNGf»
  on error
    try
      set imageData to the clipboard as TIFF picture
    on error
      error "The clipboard does not contain an image."
    end try
  end try

  set fileHandle to open for access POSIX file outputPath with write permission
  try
    set eof fileHandle to 0
    write imageData to fileHandle
    close access fileHandle
  on error errorMessage number errorNumber
    try
      close access fileHandle
    end try
    error errorMessage number errorNumber
  end try
end run
APPLESCRIPT

/usr/bin/sips -s format png "$clipboard_file" --out "$local_file" >/dev/null

/usr/bin/ssh -o StrictHostKeyChecking=accept-new "$user@$host" "mkdir -p '$remote_dir'"
/usr/bin/scp -o StrictHostKeyChecking=accept-new "$local_file" "$user@$host:$remote_file"
printf '%s' "$remote_file" | /usr/bin/pbcopy
