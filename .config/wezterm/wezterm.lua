-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}
-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices
-- colors
config.color_scheme = "nord"
config.window_background_opacity = 1.0
-- font
config.font = wezterm.font("Cica")
config.font_size = 18.0
-- 最大まで利用する
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- keybinds
-- デフォルトのkeybindを無効化
config.disable_default_key_bindings = true
-- `keybinds.lua`を読み込み
local keybinds = require("keybinds")
-- keybindの設定
config.keys = keybinds.keys
config.key_tables = keybinds.key_tables
-- Leaderキーの設定
config.leader = { key = "g", mods = "CTRL", timeout_milliseconds = 2000 }

-- and finally, return the configuration to wezterm
return config
