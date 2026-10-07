local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()
local is_windows = wezterm.target_triple:find('windows') ~= nil
local is_macos = wezterm.target_triple:find('apple%-darwin') ~= nil

-- Windows uses native SSH for the Herdr transport A/B test; macOS keeps `tsh`.
local remote_command
local local_command
local image_upload_command

if is_windows then
  local_command = { 'powershell.exe', '-NoExit' }
  config.ssh_domains = {
    {
      name = 'devbox',
      remote_address = 'devbox',
      username = 'syzom',
      multiplexing = 'None',
      default_prog = { 'bash', '-lc', 'herdr; exec fish -l' },
    },
  }
  config.default_domain = 'devbox'
  image_upload_command = {
    'powershell.exe',
    '-NoProfile',
    '-WindowStyle',
    'Hidden',
    '-File',
    os.getenv('APPDATA') .. '\\wezterm\\clip2path.ps1',
  }
elseif is_macos then
  -- `tsh` is defined by the interactive zsh setup on this machine. Keep a
  -- local login shell available after the remote session ends, matching
  -- PowerShell's -NoExit behavior on Windows.
  remote_command = { '/bin/zsh', '-lic', 'tsh; exec /bin/zsh -l' }
  local_command = { '/bin/zsh', '-l' }
  image_upload_command = { wezterm.config_dir .. '/clip2path.sh' }
else
  remote_command = { '/bin/sh', '-l' }
  local_command = remote_command
end

config.default_prog = is_windows and local_command or remote_command

local remote_tab = is_windows
  and { domain = { DomainName = 'devbox' } }
  or { args = remote_command }
local local_tab = is_windows
  and { domain = { DomainName = 'local' }, args = local_command }
  or { args = local_command }

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

-- Use each platform's native blur while keeping the same opacity.
config.window_background_opacity = 0.88
if is_windows then
  config.win32_system_backdrop = 'Acrylic'
elseif is_macos then
  config.macos_window_background_blur = 28
end
config.window_decorations = 'TITLE|RESIZE'
config.hide_tab_bar_if_only_one_tab = true

-- Quiet terminal behavior, with enough history for long-running agent output.
config.scrollback_lines = 20000
config.enable_scroll_bar = false
config.audible_bell = 'Disabled'
config.adjust_window_size_when_changing_font_size = false
config.switch_to_last_active_tab_when_closing_tab = true
-- Keep disconnected sessions open; Ctrl+T starts a fresh connection.
config.exit_behavior = 'Hold'
config.window_close_confirmation = 'NeverPrompt'

-- Copy selected text with Ctrl+C; otherwise preserve the normal interrupt.
local copy_or_interrupt = wezterm.action_callback(function(window, pane)
  if window:get_selection_text_for_pane(pane) ~= '' then
    window:perform_action(act.CopyTo 'Clipboard', pane)
  else
    window:perform_action(act.SendKey { key = 'c', mods = 'CTRL' }, pane)
  end
end)

-- Upload a clipboard image with the installed platform helper, then paste the
-- resulting dev-box path into the active terminal pane.
local upload_clipboard_image = wezterm.action_callback(function(window, pane)
  if not image_upload_command then
    window:toast_notification(
      'Screenshot upload unavailable',
      'Clipboard image upload is supported on Windows and macOS.',
      nil,
      4000
    )
    return
  end

  local success, _, stderr = wezterm.run_child_process(image_upload_command)

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

  { key = 't', mods = 'CTRL', action = act.SpawnCommandInNewTab(remote_tab) },
  { key = 'w', mods = 'CTRL', action = act.CloseCurrentTab { confirm = false } },
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentTab { confirm = false } },
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },

  { key = 'l', mods = 'CTRL|SHIFT', action = act.SpawnCommandInNewTab(local_tab) },
  { key = 'r', mods = 'CTRL|SHIFT', action = act.ReloadConfiguration },
  { key = 'Enter', mods = 'ALT', action = act.DisableDefaultAssignment },
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },
  { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
}

-- Retain the identical cross-platform bindings above while also honoring the
-- standard macOS Command-key equivalents.
if is_macos then
  local macos_keys = {
    { key = 'c', mods = 'CMD', action = act.CopyTo 'Clipboard' },
    { key = 'v', mods = 'CMD', action = act.PasteFrom 'Clipboard' },
    { key = 'f', mods = 'CMD', action = act.Search 'CurrentSelectionOrEmptyString' },
    { key = 't', mods = 'CMD', action = act.SpawnCommandInNewTab { args = remote_command } },
    { key = 'w', mods = 'CMD', action = act.CloseCurrentTab { confirm = false } },
    { key = '0', mods = 'CMD', action = act.ResetFontSize },
    { key = '=', mods = 'CMD', action = act.IncreaseFontSize },
    { key = '-', mods = 'CMD', action = act.DecreaseFontSize },
  }

  for _, binding in ipairs(macos_keys) do
    table.insert(config.keys, binding)
  end
end

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    mouse_reporting = true,
    action = act.OpenLinkAtMouseCursor,
  },
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    mouse_reporting = true,
    action = act.Nop,
  },
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.PasteFrom 'Clipboard',
  },
}

return config
