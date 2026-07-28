# Cross-platform dotfiles

Personal Windows and macOS configuration with a reproducible WezTerm setup and
Windows AutoHotkey automation.
The repository is private because some helpers contain machine-specific hostnames.

The visual direction adapts
[kunchenguid's dotfiles](https://github.com/kunchenguid/dotfiles): Rose Pine
Moon, Hack Nerd Font, subtle transparency, and very little terminal chrome.
Windows uses Acrylic and macOS uses native background blur at the same opacity
to keep dense Herdr layouts legible.

## Repository boundary

This repository owns local terminal configuration, its clipboard-image helper,
and small keyboard automations. It deliberately does not duplicate Tailscale,
the DevBox, Herdr, or the remote shell configuration. On Windows, it expects the
existing PowerShell function `tsh`; on macOS, it expects the equivalent
interactive zsh alias.

## Windows installation

Clone the private repository and run this from PowerShell:

```powershell
.\install\windows.ps1
```

The installer:

1. Backs up an existing WezTerm config and clipboard helper under
   `$HOME\.wezterm-backup\<timestamp>`.
2. Installs Hack Nerd Font Mono for the current Windows user when needed.
3. Copies `wezterm.lua` to `$HOME\.config\wezterm\wezterm.lua`.
4. Copies the image uploader to `$env:APPDATA\wezterm\clip2path.ps1`.
5. Copies `switch-same-app.ahk` to `$HOME\scripts` and creates its Startup shortcut
   when AutoHotkey v2 is installed.
6. Removes the obsolete Windows Terminal AutoHotkey startup hook. Its source is
   retained under `legacy/windows-terminal` for recovery.

Use `-SkipFontInstall` only when Hack Nerd Font is already managed separately.

## macOS installation

Clone the repository and run this from a terminal:

```sh
./install/macos.sh
```

The installer:

1. Backs up an existing WezTerm config and clipboard helper under
   `$HOME/.wezterm-backup/<timestamp>`.
2. Installs Hack Nerd Font Mono for the current macOS user when needed.
3. Copies `wezterm.lua` and the native clipboard-image helper to
   `$HOME/.config/wezterm`.

The macOS launcher loads interactive zsh so the existing `tsh` alias is
available. The image helper uses the built-in macOS pasteboard API, `ssh`, and
`scp`; it does not require `pngpaste` or another Homebrew package. macOS does
not install the Windows-only AutoHotkey automation.

Use `--skip-font-install` only when Hack Nerd Font is already managed
separately.

## Key bindings

| Keys | Action |
| --- | --- |
| `Ctrl+T` | Open another DevBox/Herdr tab through `tsh` |
| `Ctrl+Shift+L` | Open a local PowerShell tab |
| `Ctrl+W` | Close the current tab |
| `Ctrl+Tab` | Next tab |
| `Ctrl+Shift+Tab` | Previous tab |
| `Shift+Enter` | Send a literal line feed for multiline agent input |
| `Ctrl+Alt+V` | Upload a clipboard image and paste its DevBox path |
| `Ctrl+Shift+F` | Search scrollback |
| `Ctrl+Shift+R` | Reload configuration |
| `Alt+Enter` | Toggle full screen |

`Ctrl+C` copies when text is selected; otherwise it sends an interrupt.
The same bindings work on both platforms. macOS additionally supports the
standard `Cmd+C`, `Cmd+V`, `Cmd+F`, `Cmd+T`, `Cmd+W`, and font-size shortcuts.

## AutoHotkey

`windows/autohotkey/switch-same-app.ahk` provides:

- `Left Alt` + backtick to cycle forward through windows of the active app.
- `Left Alt` + `Shift` + backtick to cycle backward.
- A modifier-transparent ISO/OEM-102 remap to the physical backtick key.

The shortcuts intentionally use Left Alt so Polish AltGr (`Left Ctrl` +
`Right Alt`) cannot trigger them. The native key remap preserves any held
modifiers.
Keep PowerToys Keyboard Manager disabled to avoid a second keyboard hook.

## Files

- `wezterm.lua`: terminal behavior and presentation.
- `windows/clip2path.ps1`: clipboard-image uploader used by `Ctrl+Alt+V`.
- `macos/clip2path.sh`: native macOS clipboard-image uploader.
- `windows/autohotkey/switch-same-app.ahk`: app-window cycling and modifier-safe
  OEM-key text input.
- `install/windows.ps1`: idempotent Windows installation and migration.
- `install/macos.sh`: idempotent macOS installation.
- `legacy/windows-terminal/clip2path.ahk`: retired Windows Terminal wrapper.
