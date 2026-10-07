-- ╭─────────────────────────────────────────────────────────╮
-- │                    GLOBAL OPTIONS                       │
-- ╰─────────────────────────────────────────────────────────╯
_G.config = {
  -- 🎨 VISUAL DESIGN
  ui = {
    border = 'rounded', -- Used by: LSP, Telescope, Which-key, Noice, etc.
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    transparency = 0.9, -- Global transparency level
    -- Keep floats fully opaque: with blend > 0 the blank cells of a float let the
    -- text underneath bleed through (pickers, Lazy, which-key, completion menu).
    blend = 0, -- Popup (pum) blend amount
    winblend = 0, -- Floating window blend
  },

  -- 🌈 COLOR SYSTEM
  colors = {
    bg = '#1e2127',
    panel = '#282c34',
    surface = '#2c323c',
    subtle = '#3e4452',
    fg = '#abb2bf',
    muted = '#5c6370',
    primary = '#61afef', -- Accent color for highlights
    secondary = '#c678dd', -- Secondary accent
    success = '#98c379', -- Success states
    warning = '#e5c07b', -- Warning states
    error = '#e06c75', -- Error states
    info = '#56b6c2', -- Info states
    line_number = '#4b5263',
  },

  -- 📐 SPACING & LAYOUT
  layout = {
    indent_size = 2, -- Global indentation
    line_spacing = 0, -- Additional line spacing
    sidebar_width = 50, -- File explorer width
    popup_max_height = 15, -- Max height for popups
    popup_max_width = 80, -- Max width for popups
    scroll_context = 10,
    -- For dynamic, responsive notifications
    notification_max_height_percent = 0.75,
    notification_max_width_percent = 0.75,
  },

  -- 🔤 TYPOGRAPHY
  fonts = {
    size = 15, -- Font size (if using GUI)
    family = 'JetBrainsMono Nerd Font', -- Font family preference
  },

  -- 🎯 ICONS & SYMBOLS (Consistent across all plugins)
  icons = {
    diagnostics = {
      error = ' ',
      warn = ' ',
      info = '󰋼 ',
      hint = '󰛩 ',
    },
    git = {
      added = '│',
      ignored = ' ',
      modified = '│',
      removed = ' ',
      renamed = ' ',
      untracked = '│',
      unstaged = '󰄱 ',
      staged = '│',
      conflict = '',
      logo = ' ',
      branch = ' ',
      commit = ' ',
      merge = ' ',
      compare = ' ',
    },
    ui = {
      folder_closed = ' ',
      folder_open = ' ',
      file = ' ',
      modified = '● ',
      readonly = '',
      symlink = '',
      separator = {
        lualine = { left = '', right = '' },
        standard = ' › ',
      },
      close = '󰅖 ',
      package = '󰏓 ',
      vim = ' ',
      neovim = ' ',
      clock = ' ',
      directory = ' ',
      dots = ' ',
      telescope = ' ',
      terminal = ' ',
      text = ' ',
      search = ' ',
      tag = ' ',
    },
    tab = {
      head = '󰓩 ',
      active = ' ',
      inactive = ' ',
    },
    kinds = { -- LSP completion item kinds
      Copilot = ' ',
      Text = '󰉿 ',
      Method = ' ',
      Function = '󰡱 ',
      Constructor = ' ',
      Field = ' ',
      Variable = ' ',
      Property = ' ',
      Class = ' ',
      Interface = ' ',
      Struct = ' ',
      Module = ' ',
      Unit = '󰪚 ',
      Value = ' ',
      Enum = ' ',
      EnumMember = ' ',
      Keyword = '󰻾 ',
      Constant = ' ',
      Snippet = '󱄽 ',
      Color = '󰏘 ',
      File = ' ',
      Reference = '󰬲 ',
      Folder = '󰉋 ',
      Event = ' ',
      Operator = ' ',
      TypeParameter = ' ',
    },
    groups_simple = {
      ai = '󰚩 ',
      code = '󰅱 ',
      debug = '󰃤 ',
      explorer = '󰙅 ',
      file = '',
      git = ' ',
      hunks = '󰊢 ',
      quit = '󰗼 ',
      search = '󰍉 ',
      ui = '󰙵 ',
      project = '󰏗 ',
      paste = '󰆒 ',
      diagnostics = '󱖫 ',
      buffer = '󰓩 ',
      windows = '󱂬 ',
      go_to = '󰌑 ',
      surround = '󰅪',
      fold = '󰙴 ',
      prev = '󰁅 ',
      next = '󰁄 ',
    },
    groups = {
      ai = '󰚩 ',
      code = '󰅱 ',
      debug = '󰃤 ',
      find = '󰍉 ',
      git = ' ',
      lazy = '󰒲 ',
      paste_project = '󰆏 ',
      quit = '󰗼 ',
      search = '󰍉 ',
      text = '󰭷 ',
      ui = '󰙵 ',
      trouble = '󱖫 ',
      buffer = '󰓩 ',
      windows = '󱂬 ',
      go_to = '󰌑 ',
      surround = '󰅪 ',
      fold = '󰙴 ',
      prev = '󰁍 ',
      next = '󰁔 ',
    },
  },

  -- ⚙️ BEHAVIOR SETTINGS
  behavior = {
    format_on_save = true, -- Auto-format files
    auto_save = true, -- Auto-save on focus lost
    scroll_context = 8, -- Lines to keep visible when scrolling
    completion_delay = 100, -- Completion trigger delay (ms)
    diagnostic_delay = 500, -- Diagnostic update delay (ms)
    timeout_len = 250, -- Which-key timeout
    update_time = 300,
  },

  -- 🔧 LSP CONFIGURATION
  lsp = {
    border = 'rounded', -- LSP hover/signature help border
    virtual_text = {
      enabled = false,
      spacing = 4,
      severity = { min = vim.diagnostic.severity.HINT },
    },
    signs = true,
    update_in_insert = false,
    severity_sort = false,
    float = {
      focusable = true,
      style = 'minimal',
      border = 'rounded',
      source = 'always',
      header = '',
      prefix = '',
    },
    codes = {
      -- Lua
      no_matching_function = {
        message = " Can't find a matching function",
        'redundant-parameter',
        'ovl_no_viable_function_in_call',
      },
      empty_block = {
        message = " That shouldn't be empty here",
        'empty-block',
      },
      missing_symbol = {
        message = ' Here should be a symbol',
        'miss-symbol',
      },
      expected_semi_colon = {
        message = ' Please put the `;` or `,`',
        'expected_semi_declaration',
        'miss-sep-in-table',
        'invalid_token_after_toplevel_declarator',
      },
      redefinition = {
        message = ' That variable was defined before',
        icon = ' ',
        'redefinition',
        'redefined-local',
        'no-duplicate-imports',
        '@typescript-eslint/no-redeclare',
        'import/no-duplicates',
      },
      no_matching_variable = {
        message = " Can't find that variable",
        'undefined-global',
        'reportUndefinedVariable',
      },
      trailing_whitespace = {
        message = '  Whitespaces are useless',
        'trailing-whitespace',
        'trailing-space',
      },
      unused_variable = {
        message = "󰂭  Don't define variables you don't use",
        icon = '󰂭  ',
        'unused-local',
        '@typescript-eslint/no-unused-vars',
        'no-unused-vars',
      },
      unused_function = {
        message = "  Don't define functions you don't use",
        'unused-function',
      },
      useless_symbols = {
        message = ' Remove that useless symbols',
        'unknown-symbol',
      },
      wrong_type = {
        message = ' Try to use the correct types',
        'init_conversion_failed',
      },
      undeclared_variable = {
        message = ' Have you delcared that variable somewhere?',
        'undeclared_var_use',
      },
      lowercase_global = {
        message = ' Should that be a global? (if so make it uppercase)',
        'lowercase-global',
      },
      -- Typescript
      no_console = {
        icon = '  ',
        'no-console',
      },
      -- Prettier
      prettier = {
        icon = '  ',
        'prettier/prettier',
      },
    },
  },

  -- 🎭 THEME SETTINGS
  theme = {
    name = 'onedark', -- Default colorscheme
    transparent_background = false,
    italic_comments = true,
    italic_keywords = false,
    bold_functions = true,
  },
}

-- ╭─────────────────────────────────────────────────────────╮
-- │                      LEADER KEY                         │
-- ╰─────────────────────────────────────────────────────────╯

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- vim: ts=2 sts=2 sw=2 et
