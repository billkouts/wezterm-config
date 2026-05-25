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

config.font = wezterm.font_with_fallback({ "FiraCode Nerd Font", "Noto Color Emoji" })
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

local function find_git_repo_name(path)
  local check = path
  while check and check ~= "" and check ~= "/" do
    local f = io.open(check .. "/.git/HEAD", "r")
    if f then
      f:close()
      return check:match("([^/]+)$")
    end
    check = check:match("^(.+)/[^/]*$")
  end
  return nil
end

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

  -- Rename current tab
  {
    key = "r",
    mods = "LEADER",
    action = wezterm.action_callback(function(window, pane)
      local cwd = pane:get_current_working_dir()
      local ok_t, pane_title = pcall(function()
        return pane:get_title()
      end)
      local initial = (cwd and cwd.file_path and find_git_repo_name(cwd.file_path)) or (ok_t and pane_title) or ""
      window:perform_action(
        wezterm.action.PromptInputLine({
          description = "Rename tab (repo: " .. (initial or "") .. "):",
          action = wezterm.action_callback(function(win, p, line)
            if line then
              win:active_tab():set_title(line)
            end
          end),
        }),
        pane
      )
    end),
  },
  -- Send the leader key itself when pressed twice
  {
    key = "a",
    mods = "LEADER|CTRL",
    action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
  },

  -- Open link below cursor
  {
    key = "g",
    mods = "LEADER",
    action = wezterm.action_callback(function(win, pane)
      -- Get selected text in copy mode
      local selection = win:get_selection_text_for_pane(pane)

      if not selection or selection == "" then
        win:toast_notification("WezTerm", "No text selected", nil, 4000)
        return
      end

      -- Look for a URL in the selection
      local url = selection:match("(https?://[%w%p]+)")
      if url then
        wezterm.open_with(url)
      else
        win:toast_notification("WezTerm", "No URL found in selection", nil, 4000)
      end
    end),
  },
}

config.enable_tab_bar = false
config.show_tabs_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = true
config.show_tab_index_in_tab_bar = true
config.switch_to_last_active_tab_when_closing_tab = true

local function get_tab_title(tab)
  local title = tab.tab_title
  if title and #title > 0 then
    return title
  end

  local cwd
  local ok, val = pcall(function()
    return tab.active_pane:get_current_working_dir()
  end)
  if ok then
    cwd = val
  else
    ok, val = pcall(function()
      return tab.active_pane.current_working_dir
    end)
    if ok then
      cwd = val
    end
  end

  if cwd and cwd.file_path then
    local repo_name = find_git_repo_name(cwd.file_path)
    if repo_name then
      return repo_name
    end
  end

  local ok_t, pane_title = pcall(function()
    return tab.active_pane:get_title()
  end)
  if not ok_t then
    ok_t, pane_title = pcall(function()
      return tab.active_pane.title
    end)
  end
  return (ok_t and pane_title) or ""
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  return get_tab_title(tab)
end)

wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
  return get_tab_title(tab)
end)

return config
