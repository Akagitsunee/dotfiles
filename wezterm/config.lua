local wezterm = require("wezterm")
local gpu_adapters = require("gpu-adapter")
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- FONT CONFIGURATION
local fonts = {
  "JetBrainsMono Nerd Font Mono",
  "FiraCode Nerd Font Mono",
  "CaskaydiaCove Nerd Font Mono",
}

config = {
  -- font = wezterm.font("FiraCode Nerd Font Mono", { weight = "Light" }),
  -- font = wezterm.font("JetBrains Mono", { weight = "Bold" })
  -- font = wezterm.font("JetBrainsMono Nerd Font")
  font = wezterm.font_with_fallback({
    { family = "FiraCode Nerd Font",           weight = "Light",   italic = false },
    { family = "CaskaydiaCove Nerd Font Mono", weight = "Regular", italic = false },
    { family = "JetBrains Mono",               weight = "Regular", italic = false },
    { family = "SauceCodePro Nerd Font Mono",  weight = "Regular", italic = false },
    { family = "CommitMono Nerd Font Mono",    weight = "Regular", italic = false },
    { family = "RobotoMono Nerd Font Mono",    weight = "Regular", italic = false },
  }),

  color_schemes = {
    ["dark"] = {
      foreground = "#ffffff",
      background = "#16181a",
      cursor_bg = "#ffffff",
      cursor_fg = "#ffffff",
      cursor_border = "#16181a",
      selection_fg = "#16181a",
      selection_bg = "#5eff6c",
      scrollbar_thumb = "#ffffff",
      split = "#5eff6c",
      ansi = {
        "#16181a",
        "#ff5ea0",
        "#5eff6c",
        "#ffbd5e",
        "#5ea1ff",
        "#bd5eff",
        "#5ef1ff",
        "#ffffff",
      },
      brights = {
        "#16181a",
        "#ff5ea0",
        "#5eff6c",
        "#ffbd5e",
        "#5ea1ff",
        "#bd5eff",
        "#5ef1ff",
        "#ffffff",
      },
      indexed = {
        [16] = "#d17c00",
        [17] = "#d11500",
      },
    },
  },

  font_size = 14,
  line_height = 1.35,
  cell_width = 1.0,
  adjust_window_size_when_changing_font_size = false,
  default_cursor_style = "SteadyBar",

  -- WINDOW AND UI
  initial_rows = 50,
  initial_cols = 190,
  window_close_confirmation = "NeverPrompt",
  window_decorations = "RESIZE",
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  -- window_background_image = '/Users/omerhamerman/Downloads/3840x1080-Wallpaper-041.jpg'
  -- window_background_image_hsb = {
  --   brightness = 0.01,
  --   hue = 1.0,
  --   saturation = 0.5,
  -- }
  -- window_background_opacity = 0.78
  -- window_background_opacity = 0.92

  -- BACKGROUND
  background = {
    -- {
    -- 	source = {
    -- 		File = "/Users/" .. os.getenv("USER") .. "/.config/wezterm/background.jpeg",
    -- 	},
    -- 	hsb = {
    -- 		hue = 1.0,
    -- 		saturation = 1.02,
    -- 		brightness = 0.25,
    -- 	},
    -- 	attachment = { Parallax = 0.3 },
    -- 	width = "100%",
    -- 	height = "100%",
    -- },
    {
      source = {
        Color = "#222836",
      },
      width = "100%",
      height = "100%",
      opacity = 0.96,
      -- opacity = 0.80,
    },
  },
  -- macos_window_background_blur = 40
  -- macos_window_background_blur = 20

  -- TABS AND UI
  enable_tab_bar = false,
  use_fancy_tab_bar = false,
  tab_bar_at_bottom = false,

  -- RENDERING
  front_end = "WebGpu",
  webgpu_power_preference = "HighPerformance",
  webgpu_preferred_adapter = gpu_adapters:pick_best(),
  max_fps = 240,
  freetype_load_target = "Light",
  freetype_render_target = "HorizontalLcd",
  freetype_load_flags = "NO_HINTING",

  -- BEHAVIOR
  automatically_reload_config = true,
  check_for_updates = false,

  -- KEYBINDINGS
  keys = {
    -- Increase font size
    { key = "=", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
    -- Decrease font size
    { key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
    -- Reset font size
    { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
    -- Toggle font custom action
    { key = "1", mods = "CTRL", action = wezterm.action.EmitEvent("toggle-font") },
  },

  -- HYPERLINK RULES
  hyperlink_rules = {
    {
      regex = "\\((\\w+://\\S+)\\)",
      format = "$1",
      highlight = 1,
    },
    {
      regex = "\\[(\\w+://\\S+)\\]",
      format = "$1",
      highlight = 1,
    },
    {
      regex = "\\{(\\w+://\\S+)\\}",
      format = "$1",
      highlight = 1,
    },
    {
      regex = "<(\\w+://\\S+)>",
      format = "$1",
      highlight = 1,
    },
    {
      regex = "[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)",
      format = "$1",
      highlight = 1,
    },
    {
      regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
      format = "mailto:$0",
    },
  },

  color_scheme = "dark",
}

-- THEME (commented)
-- color_scheme = "termnial.sexy"
-- color_scheme = "Catppuccin Mocha"

return config
