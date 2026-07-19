local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-- The remote connection remains machine-local. This repository owns the
-- terminal experience, while `tsh` owns how the dev box and Herdr are started.
local remote_command = { 'powershell.exe', '-NoExit', '-Command', 'tsh' }
local local_command = { 'powershell.exe', '-NoExit' }

config.default_prog = remote_command

-- A Windows adaptation of kunchenguid's restrained Rose Pine setup.
config.color_scheme = 'rose-pine-moon'
config.font = wezterm.font_with_fallback {
  { family = 'Hack Nerd Font Mono', weight = 'Regular' },
  'Symbols Nerd Font Mono',
}
config.font_size = 13.5
config.line_height = 1.0
config.custom_block_glyphs = true
config.default_cursor_style = 'SteadyBar'
config.cursor_blink_rate = 0

-- Acrylic provides the Windows counterpart to the reference's macOS blur.
-- Slightly higher opacity keeps dense Herdr panes readable.
config.window_background_opacity = 0.88
config.win32_system_backdrop = 'Acrylic'
config.window_decorations = 'TITLE|RESIZE'
config.hide_tab_bar_if_only_one_tab = true

-- Quiet terminal behavior, with enough history for long-running agent output.
config.scrollback_lines = 20000
config.enable_scroll_bar = false
config.audible_bell = 'Disabled'
config.adjust_window_size_when_changing_font_size = false
config.switch_to_last_active_tab_when_closing_tab = true

-- Copy selected text with Ctrl+C; otherwise preserve the normal interrupt.
local copy_or_interrupt = wezterm.action_callback(function(window, pane)
  if window:get_selection_text_for_pane(pane) ~= '' then
    window:perform_action(act.CopyTo 'Clipboard', pane)
  else
    window:perform_action(act.SendKey { key = 'c', mods = 'CTRL' }, pane)
  end
end)

-- Upload a clipboard image with the persisted Windows helper, then paste the
-- resulting dev-box path into the active terminal pane.
local upload_clipboard_image = wezterm.action_callback(function(window, pane)
  local script = os.getenv('APPDATA') .. '\\wezterm\\clip2path.ps1'
  local success, _, stderr = wezterm.run_child_process {
    'powershell.exe',
    '-NoProfile',
    '-WindowStyle',
    'Hidden',
    '-File',
    script,
  }

  if success then
    window:perform_action(act.PasteFrom 'Clipboard', pane)
  else
    window:toast_notification(
      'Screenshot upload failed',
      stderr ~= '' and stderr or 'The clipboard does not contain an image.',
      nil,
      4000
    )
  end
end)

config.keys = {
  { key = 'c', mods = 'CTRL', action = copy_or_interrupt },
  { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
  { key = 'f', mods = 'CTRL|SHIFT', action = act.Search 'CurrentSelectionOrEmptyString' },
  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\x0a' },
  { key = 'v', mods = 'CTRL|ALT', action = upload_clipboard_image },

  { key = 't', mods = 'CTRL', action = act.SpawnCommandInNewTab { args = remote_command } },
  { key = 'w', mods = 'CTRL', action = act.CloseCurrentTab { confirm = true } },
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },

  { key = 'l', mods = 'CTRL|SHIFT', action = act.SpawnCommandInNewTab { args = local_command } },
  { key = 'r', mods = 'CTRL|SHIFT', action = act.ReloadConfiguration },
  { key = 'Enter', mods = 'ALT', action = act.ToggleFullScreen },
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },
  { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
}

config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.PasteFrom 'Clipboard',
  },
}

return config
