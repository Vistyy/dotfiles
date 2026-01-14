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
-- Include macOS window controls (traffic lights) so fullscreen works via the
-- standard macOS UI + shortcuts.
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
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

local function reload_config_with_toast()
  return wezterm.action_callback(function(window, pane)
    window:toast_notification("WezTerm", "Reloading configuration…", nil, 1500)
    window:perform_action(act.ReloadConfiguration, pane)
  end)
end

local function in_tmux(pane)
  local ok, name = pcall(function()
    return pane:get_foreground_process_name()
  end)
  if not ok or not name then
    return false
  end
  return name:find("tmux", 1, true) ~= nil
end

local function tmux_or_fallback(tmux_keys, fallback_action)
  return wezterm.action_callback(function(window, pane)
    if in_tmux(pane) then
      window:perform_action(act.SendString(tmux_keys), pane)
    else
      window:perform_action(fallback_action, pane)
    end
  end)
end

local function tmux_prefix_arrow(direction)
  local seq = nil
  if direction == "Left" then
    seq = "\x1b[D"
  elseif direction == "Down" then
    seq = "\x1b[B"
  elseif direction == "Up" then
    seq = "\x1b[A"
  elseif direction == "Right" then
    seq = "\x1b[C"
  else
    return act.Nop
  end
  return tmux_or_fallback("\x02" .. seq, act.Nop)
end

config.keys = {
  -- Window management (macOS)
  { key = "f", mods = "CMD|CTRL", action = act.ToggleFullScreen },
  -- If a window gets set to a non-standard window level (e.g. always-on-bottom),
  -- some window switchers may not list it. These bindings let you force it back.
  { key = "0", mods = "CMD|SHIFT", action = act.SetWindowLevel("Normal") },
  { key = "UpArrow", mods = "CMD|SHIFT", action = act.SetWindowLevel("AlwaysOnTop") },
  { key = "DownArrow", mods = "CMD|SHIFT", action = act.SetWindowLevel("AlwaysOnBottom") },

  -- tmux-first workflow:
  -- Cmd-based bindings drive tmux so panes/windows persist across reattaches.
  -- (tmux prefix is Ctrl-b; \x02 is Ctrl-b)
  { key = "d", mods = "CMD", action = act.SendString "\x02%" },
  { key = "d", mods = "CMD|SHIFT", action = act.SendString "\x02\"" },
  { key = "t", mods = "CMD", action = act.SendString "\x02c" },
  { key = "]", mods = "CMD", action = act.SendString "\x02n" },
  { key = "[", mods = "CMD", action = act.SendString "\x02p" },
  { key = "w", mods = "CMD", action = tmux_or_fallback("\x02x", act.CloseCurrentTab { confirm = true }) },
  { key = "w", mods = "CMD|SHIFT", action = tmux_or_fallback("\x02&", act.CloseCurrentTab { confirm = true }) },

  -- Pane navigation (tmux-first): send prefix+arrows (avoids Meta/Alt quirks)
  { key = "j", mods = "CMD|ALT", action = tmux_prefix_arrow("Left") },
  { key = "k", mods = "CMD|ALT", action = tmux_prefix_arrow("Down") },
  { key = "i", mods = "CMD|ALT", action = tmux_prefix_arrow("Up") },
  { key = "l", mods = "CMD|ALT", action = tmux_prefix_arrow("Right") },
  { key = "LeftArrow", mods = "CMD|ALT", action = tmux_prefix_arrow("Left") },
  { key = "DownArrow", mods = "CMD|ALT", action = tmux_prefix_arrow("Down") },
  { key = "UpArrow", mods = "CMD|ALT", action = tmux_prefix_arrow("Up") },
  { key = "RightArrow", mods = "CMD|ALT", action = tmux_prefix_arrow("Right") },

  -- Word navigation / deletion (Readline-style; works in zsh/bash/fish, locally and over SSH)
  { key = "LeftArrow", mods = "ALT", action = act.SendString "\x1bb" }, -- backward-word
  { key = "RightArrow", mods = "ALT", action = act.SendString "\x1bf" }, -- forward-word
  { key = "Backspace", mods = "ALT", action = act.SendString "\x1b\x7f" }, -- backward-kill-word
  { key = "d", mods = "ALT", action = act.SendString "\x1bd" }, -- kill-word (forward)

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
  { key = "r", mods = "CMD|SHIFT", action = reload_config_with_toast() },
  { key = "r", mods = "CMD|ALT", action = reload_config_with_toast() },

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
