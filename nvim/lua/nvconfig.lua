local M = {}

M.base46 = {
  theme = 'onedark',
  transparency = _G.config and _G.config.theme and _G.config.theme.transparent_background or false,
  theme_toggle = { 'onedark', 'one_light' },
  integrations = {},
  changed_themes = {},
  excluded = { 'nvcheatsheet', 'statusline', 'tbline', 'telescope' },
  hl_add = {},
  hl_override = {
    Comment = {
      italic = true,
    },
    CursorLine = {
      bg = 'NONE',
    },
    CursorLineNr = {
      bold = true,
    },
  },
}

M.ui = {
  cmp = {
    style = 'default',
  },
  -- Compatibility shim for base46 internals; actual picker is snacks.nvim.
  telescope = {
    style = 'bordered',
  },
  statusline = {
    enabled = false,
    theme = 'default',
  },
}

return M

-- vim: ts=2 sts=2 sw=2 et
