-- https://github.com/theopn/dotfiles/blob/main/wezterm/wezterm.lua
-- https://github.com/KevinSilvester/wezterm-config/

local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Solarized Dark Higher Contrast"
-- colors have been defined in cyberdream.lua file
-- config.colors = require 'cyberdream'
-- config.color_scheme = 'Catppuccin Frappe'
-- config.color_scheme = 'Catppuccin Macchiato'
-- config.color_scheme = 'Catppuccin Mocha'

config.font = wezterm.font("FiraCode Nerd Font")
-- != -> ==> |>
config.font_size = 9

config.window_background_opacity = 0.90
config.macos_window_background_blur = 10

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

config.inactive_pane_hsb = {
  saturation = 0.74,
  brightness = 0.4,
}

config.window_close_confirmation = "AlwaysPrompt"
config.skip_close_confirmation_for_processes_named = {}
config.exit_behavior = "Hold"
config.exit_behavior_messaging = "Verbose"

config.leader = {
  key = " ",
  mods = "CTRL",
  timeout_milliseconds = 1000,
}

config.keys = {
  {
    key = "t",
    mods = "LEADER",
    action = wezterm.action_callback(function(window)
      local overrides = window:get_config_overrides() or {}
      if overrides.enable_tab_bar == nil then
        overrides.enable_tab_bar = not config.enable_tab_bar
      else
        overrides.enable_tab_bar = not overrides.enable_tab_bar
      end
      window:set_config_overrides(overrides)
    end),
  },

  -- Tab and pane navigation

  -- Switch to previous tab
  {
    key = "h",
    mods = "LEADER",
    action = wezterm.action.ActivateTabRelative(-1),
  },
  -- Switch to next tab
  {
    key = "l",
    mods = "LEADER",
    action = wezterm.action.ActivateTabRelative(1),
  },
  -- Show tab navigator
  {
    key = "n",
    mods = "LEADER",
    action = wezterm.action.ShowTabNavigator,
  },
  -- Create new tab
  {
    key = "c",
    mods = "LEADER",
    action = wezterm.action.SpawnTab("CurrentPaneDomain"),
  },

  -- Activate pane selection mode
  {
    key = "p",
    mods = "LEADER",
    action = wezterm.action.PaneSelect({
      mode = "Activate",
    }),
  },
  -- Split horizontally
  {
    key = "o",
    mods = "LEADER",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  -- Split vertically
  {
    key = "v",
    mods = "LEADER",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  -- Close current pane
  {
    key = "x",
    mods = "LEADER",
    action = wezterm.action.CloseCurrentPane({ confirm = true }),
  },

  -- Send the leader key itself when pressed twice
  {
    key = "a",
    mods = "LEADER|CTRL",
    action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
  },
}

config.enable_tab_bar = false
config.show_tabs_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = true
config.show_tab_index_in_tab_bar = true
config.switch_to_last_active_tab_when_closing_tab = true

return config
