#!/bin/sh

set -eu

skip_font_install=false
if [ "${1:-}" = '--skip-font-install' ]; then
  skip_font_install=true
  shift
fi
if [ "$#" -ne 0 ]; then
  echo "Usage: $0 [--skip-font-install]" >&2
  exit 2
fi

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
config_source=$repo_root/wezterm.lua
uploader_source=$repo_root/macos/clip2path.sh
config_directory=$HOME/.config/wezterm
config_destination=$config_directory/wezterm.lua
uploader_destination=$config_directory/clip2path.sh
timestamp=$(date '+%Y%m%d-%H%M%S')
backup_directory=$HOME/.wezterm-backup/$timestamp

backup_file() {
  source_path=$1
  backup_name=$2
  if [ ! -e "$source_path" ] && [ ! -L "$source_path" ]; then
    return
  fi

  mkdir -p "$backup_directory"
  cp -p "$source_path" "$backup_directory/$backup_name"
}

install_hack_nerd_font() {
  font_directory=$HOME/Library/Fonts
  if find "$font_directory" -maxdepth 1 -name 'HackNerdFontMono-*.ttf' -print -quit 2>/dev/null | grep -q .; then
    echo 'Hack Nerd Font Mono is already installed.'
    return
  fi

  temp_directory=$(mktemp -d "${TMPDIR:-/tmp}/wezterm-font.XXXXXX")
  archive=$temp_directory/Hack.zip
  expanded=$temp_directory/Hack

  mkdir -p "$font_directory" "$expanded"
  curl -fL 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip' -o "$archive"
  ditto -x -k "$archive" "$expanded"

  if ! find "$expanded" -name 'HackNerdFontMono-*.ttf' -print -quit | grep -q .; then
    rm -rf "$temp_directory"
    echo 'The Hack Nerd Font archive did not contain the expected mono font files.' >&2
    exit 1
  fi

  find "$expanded" -name 'HackNerdFontMono-*.ttf' -exec cp -f {} "$font_directory/" \;
  rm -rf "$temp_directory"
  echo 'Installed Hack Nerd Font Mono for the current macOS user.'
}

for source_path in "$config_source" "$uploader_source"; do
  if [ ! -f "$source_path" ]; then
    echo "Required repository file not found: $source_path" >&2
    exit 1
  fi
done

backup_file "$config_destination" wezterm.lua
backup_file "$uploader_destination" clip2path.sh

if [ "$skip_font_install" = false ]; then
  install_hack_nerd_font
fi

mkdir -p "$config_directory"
rm -f "$config_destination" "$uploader_destination"
cp "$config_source" "$config_destination"
cp "$uploader_source" "$uploader_destination"
chmod 755 "$uploader_destination"

echo "Installed WezTerm config: $config_destination"
echo "Installed clipboard uploader: $uploader_destination"
if [ -d "$backup_directory" ]; then
  echo "Backed up previous local files to: $backup_directory"
fi
echo 'Reload the WezTerm configuration or start a new window.'
