local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback({
  "JetBrains Mono",
  "Symbols Nerd Font Mono",
})
config.font_size = 14.5
config.font_rules = {
  {
    italic = true,
    font = wezterm.font_with_fallback(
      {
        { family = "JetBrains Mono", style = "Normal" },
        "Symbols Nerd Font Mono",
      },
      { foreground = "#7f8a9d" }
    ),
  },
  {
    intensity = "Half",
    font = wezterm.font_with_fallback(
      {
        { family = "JetBrains Mono", style = "Normal" },
        "Symbols Nerd Font Mono",
      },
      { foreground = "#6f7887" }
    ),
  },
}
config.colors = {
  foreground = "#d7dee9",
  background = "#11161d",
  cursor_bg = "#d7dee9",
  cursor_border = "#7aa2f7",
  cursor_fg = "#11161d",
  selection_bg = "rgba(79, 102, 140, 0.45)",
  selection_fg = "#e5ebf5",
  scrollbar_thumb = "#2a3441",
  split = "#2c3644",
  compose_cursor = "#7aa2f7",
  ansi = {
    "#1a1f27",
    "#f7768e",
    "#9ece6a",
    "#e0af68",
    "#7aa2f7",
    "#bb9af7",
    "#7dcfff",
    "#c0caf5",
  },
  brights = {
    "#414868",
    "#ff899d",
    "#a9d67a",
    "#f0c27d",
    "#8db4ff",
    "#c6a8ff",
    "#97e4ff",
    "#e6edf7",
  },
  tab_bar = {
    background = "#0d1218",
    inactive_tab_edge = "#202833",
    active_tab = {
      bg_color = "#1a2330",
      fg_color = "#e6edf7",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#11161d",
      fg_color = "#7f8a9d",
    },
    inactive_tab_hover = {
      bg_color = "#18202b",
      fg_color = "#c7d0dd",
    },
    new_tab = {
      bg_color = "#0d1218",
      fg_color = "#7f8a9d",
    },
    new_tab_hover = {
      bg_color = "#18202b",
      fg_color = "#d7dee9",
    },
  },
}

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_background_opacity = 0.96
config.macos_window_background_blur = 28
config.scrollback_lines = 10000
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true
config.switch_to_last_active_tab_when_closing_tab = true
config.inactive_pane_hsb = {
  saturation = 0.92,
  brightness = 0.78,
}
config.window_padding = {
  left = 10,
  right = 10,
  top = 8,
  bottom = 6,
}
config.window_frame = {
  font = wezterm.font { family = "JetBrains Mono", weight = "DemiBold" },
  font_size = 12.5,
  active_titlebar_bg = "#0d1218",
  inactive_titlebar_bg = "#0b1015",
  active_titlebar_fg = "#d7dee9",
  inactive_titlebar_fg = "#7f8a9d",
  active_titlebar_border_bottom = "#202833",
  inactive_titlebar_border_bottom = "#161d26",
  button_fg = "#7f8a9d",
  button_bg = "#0d1218",
  button_hover_fg = "#e6edf7",
  button_hover_bg = "#1a2330",
}

wezterm.on('update-right-status', function(window, pane)
  window:set_right_status(window:active_workspace())
end)

local function prompt_rename_tab()
  return act.PromptInputLine {
    description = 'Rename tab',
    action = wezterm.action_callback(function(window, pane, line)
      if not line or line == '' then
        return
      end
      window:active_tab():set_title(line)
    end),
  }
end

local function reload_config_with_toast()
  return wezterm.action_callback(function(window, pane)
    window:toast_notification("WezTerm", "Reloading configuration...", nil, 1500)
    window:perform_action(act.ReloadConfiguration, pane)
  end)
end

config.keys = {
  { key = "f", mods = "CMD|CTRL", action = act.ToggleFullScreen },
  { key = "0", mods = "CMD|SHIFT", action = act.SetWindowLevel("Normal") },
  { key = "UpArrow", mods = "CMD|SHIFT", action = act.SetWindowLevel("AlwaysOnTop") },
  { key = "DownArrow", mods = "CMD|SHIFT", action = act.SetWindowLevel("AlwaysOnBottom") },

  -- Pane management
  { key = "d", mods = "CMD", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "d", mods = "CMD|SHIFT", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "w", mods = "CMD", action = act.CloseCurrentPane { confirm = true } },
  { key = "LeftArrow", mods = "ALT", action = act.ActivatePaneDirection "Left" },
  { key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection "Right" },
  { key = "UpArrow", mods = "ALT", action = act.ActivatePaneDirection "Up" },
  { key = "DownArrow", mods = "ALT", action = act.ActivatePaneDirection "Down" },
  { key = "LeftArrow", mods = "CMD|ALT", action = act.AdjustPaneSize { "Left", 5 } },
  { key = "RightArrow", mods = "CMD|ALT", action = act.AdjustPaneSize { "Right", 5 } },
  { key = "UpArrow", mods = "CMD|ALT", action = act.AdjustPaneSize { "Up", 3 } },
  { key = "DownArrow", mods = "CMD|ALT", action = act.AdjustPaneSize { "Down", 3 } },
  { key = "Enter", mods = "CMD", action = act.TogglePaneZoomState },

  -- Tabs
  { key = "t", mods = "CMD", action = act.SpawnTab "CurrentPaneDomain" },
  { key = "{", mods = "CMD|SHIFT", action = act.ActivateTabRelativeNoWrap(-1) },
  { key = "}", mods = "CMD|SHIFT", action = act.ActivateTabRelativeNoWrap(1) },
  { key = "w", mods = "CMD|SHIFT", action = act.CloseCurrentTab { confirm = true } },
  { key = ",", mods = "CMD|SHIFT", action = prompt_rename_tab() },

  -- Copy / paste / search
  { key = "c", mods = "CMD", action = act.CopyTo "Clipboard" },
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo "Clipboard" },
  { key = "v", mods = "CMD", action = act.PasteFrom "Clipboard" },
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom "Clipboard" },
  { key = "f", mods = "CMD", action = act.Search("CurrentSelectionOrEmptyString") },
  { key = "x", mods = "CMD|SHIFT", action = act.ActivateCopyMode },
  {
    key = "o",
    mods = "CMD|SHIFT",
    action = act.QuickSelectArgs {
      label = "open url",
      patterns = { "https?://\\S+" },
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        if not url or url == "" then
          return
        end
        wezterm.open_with(url)
      end),
    },
  },

  -- Shell editing helpers
  { key = "LeftArrow", mods = "CMD", action = act.SendString "\x01" },
  { key = "RightArrow", mods = "CMD", action = act.SendString "\x05" },
  { key = "b", mods = "ALT", action = act.SendString "\x1bb" },
  { key = "f", mods = "ALT", action = act.SendString "\x1bf" },
  { key = "Backspace", mods = "ALT", action = act.SendString "\x1b\x7f" },
  { key = "d", mods = "ALT", action = act.SendString "\x1bd" },
  { key = "Enter", mods = "SHIFT", action = act.SendString "\x1b\r" },

  -- Utilities
  { key = "r", mods = "CMD|SHIFT", action = reload_config_with_toast() },
  { key = "D", mods = "CMD|ALT", action = act.ShowDebugOverlay },
  {
    key = "h",
    mods = "CMD|SHIFT",
    action = act.SpawnCommandInNewTab {
      args = { "/bin/sh", "-lc", "/usr/bin/less -R ~/.config/wezterm/KEYBINDINGS.txt" },
    },
  },
}

return config
