# Windows dotfiles

Personal Windows configuration with reproducible WezTerm and AutoHotkey setup.
The repository is private because some helpers contain machine-specific hostnames.

The visual direction adapts
[kunchenguid's dotfiles](https://github.com/kunchenguid/dotfiles): Rose Pine
Moon, Hack Nerd Font, subtle transparency, and very little terminal chrome.
The Windows version uses Acrylic at slightly higher opacity to keep dense Herdr
layouts legible.

## Repository boundary

This repository owns local terminal configuration, its clipboard-image helper,
and small keyboard automations. It deliberately does not duplicate Tailscale,
the DevBox, Herdr, or the remote shell configuration. On Windows, it expects the
existing PowerShell function `tsh` to connect to the DevBox and start Herdr.

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

## AutoHotkey

`windows/autohotkey/switch-same-app.ahk` provides:

- `Left Alt` + backtick to cycle forward through windows of the active app.
- `Left Alt` + `Shift` + backtick to cycle backward.
- The ISO/OEM-102 to backtick remap previously handled by PowerToys.

The shortcuts intentionally use Left Alt so Polish AltGr (`Left Ctrl` +
`Right Alt`) cannot trigger them. Keep PowerToys Keyboard Manager disabled to
avoid installing a second keyboard hook for the same remap.

## Files

- `wezterm.lua`: terminal behavior and presentation.
- `windows/clip2path.ps1`: clipboard-image uploader used by `Ctrl+Alt+V`.
- `windows/autohotkey/switch-same-app.ahk`: app-window cycling and OEM-key remap.
- `install/windows.ps1`: idempotent Windows installation and migration.
- `legacy/windows-terminal/clip2path.ahk`: retired Windows Terminal wrapper.
