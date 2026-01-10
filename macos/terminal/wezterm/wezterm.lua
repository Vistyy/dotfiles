local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback({
  "JetBrains Mono",
  "Symbols Nerd Font Mono",
})
config.font_size = 14.5
config.colors = {
  foreground = "#f7efe3",
  background = "#14100d",
  cursor_bg = "#f7efe3",
  cursor_border = "#f7efe3",
  cursor_fg = "#14100d",
  selection_bg = "#4a3c30",
  selection_fg = "#f7efe3",
  ansi = {
    "#2a221b",
    "#d66b5c",
    "#a6c38b",
    "#e0b56b",
    "#8aa8c5",
    "#b792d3",
    "#8cb7a6",
    "#d9cbb7",
  },
  brights = {
    "#4a3f36",
    "#e79a90",
    "#c6dab0",
    "#f2d4a0",
    "#b1c9de",
    "#d1b2ee",
    "#b4d9cd",
    "#fbf5ea",
  },
}
config.window_decorations = "RESIZE"
config.window_background_opacity = 1.0
config.macos_window_background_blur = 20
config.scrollback_lines = 10000
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

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

config.keys = {
  { key = "d", mods = "CMD", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "d", mods = "CMD|SHIFT", action = act.SplitVertical { domain = "CurrentPaneDomain" } },

  -- Pane navigation
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection "Left" },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection "Down" },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection "Up" },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection "Right" },
  { key = "h", mods = "CMD|ALT", action = act.ActivatePaneDirection "Left" },
  { key = "j", mods = "CMD|ALT", action = act.ActivatePaneDirection "Down" },
  { key = "k", mods = "CMD|ALT", action = act.ActivatePaneDirection "Up" },
  { key = "l", mods = "CMD|ALT", action = act.ActivatePaneDirection "Right" },
  { key = "LeftArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection "Left" },
  { key = "DownArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection "Down" },
  { key = "UpArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection "Up" },
  { key = "RightArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection "Right" },

  -- Scrollback / copy / search
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },
  { key = "/", mods = "LEADER", action = act.Search("CurrentSelectionOrEmptyString") },

  -- Quick open: select a URL from the screen and open it in your default browser
  {
    key = "o",
    mods = "LEADER",
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

  -- New tab (prefers current pane cwd when possible)
  { key = "t", mods = "CMD|SHIFT", action = act.SpawnCommandInNewTab { domain = "CurrentPaneDomain" } },

  -- Workspaces / tabs / domains launcher
  { key = "w", mods = "LEADER", action = act.ShowLauncherArgs { flags = "FUZZY|WORKSPACES|TABS|DOMAINS" } },

  -- Rename tab
  { key = ",", mods = "LEADER", action = prompt_rename_tab() },

  -- Multiline input
  { key = "Enter", mods = "SHIFT", action = act.SendString "\x1b\r" },

  -- Reload
  { key = "r", mods = "LEADER", action = act.ReloadConfiguration },
  { key = "r", mods = "CMD|SHIFT", action = act.ReloadConfiguration },
  { key = "r", mods = "CMD|ALT", action = act.ReloadConfiguration },

  -- Debug
  { key = "D", mods = "CMD|ALT", action = act.ShowDebugOverlay },
  {
    key = "H",
    mods = "LEADER",
    action = act.SpawnCommandInNewTab {
      args = { "/bin/sh", "-lc", "/usr/bin/less -R ~/.config/wezterm/KEYBINDINGS.txt" },
    },
  },
  {
    key = "h",
    mods = "CMD|SHIFT",
    action = act.SpawnCommandInNewTab {
      args = { "/bin/sh", "-lc", "/usr/bin/less -R ~/.config/wezterm/KEYBINDINGS.txt" },
    },
  },
  {
    key = "?",
    mods = "LEADER",
    action = act.SpawnCommandInNewTab {
      args = { "/bin/sh", "-lc", "/usr/bin/less -R ~/.config/wezterm/KEYBINDINGS.txt" },
    },
  },
}

return config
