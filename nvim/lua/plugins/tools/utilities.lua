return {
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = true,
      keywords = {
        FIX = {
          icon = _G.config.icons.diagnostics.error,
          color = 'error',
          alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' },
        },
        TODO = {
          icon = _G.config.icons.diagnostics.info,
          color = 'info',
        },
        HACK = {
          icon = _G.config.icons.diagnostics.warn,
          color = 'warning',
        },
        WARN = {
          icon = _G.config.icons.diagnostics.warn,
          color = 'warning',
          alt = { 'WARNING', 'XXX' },
        },
        PERF = {
          icon = ' ',
          alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' },
        },
        NOTE = {
          icon = _G.config.icons.diagnostics.hint,
          color = 'hint',
          alt = { 'INFO' },
        },
        TEST = {
          icon = '⏲ ',
          color = 'test',
          alt = { 'TESTING', 'PASSED', 'FAILED' },
        },
      },
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    dependencies = {
      -- Full spec lives in plugins/core/treesitter.lua; lazy.nvim merges
      -- fragments by plugin name so only the name is needed here.
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      file_types = { 'markdown' },
      render_modes = { 'n', 'c', 't' },
      anti_conceal = {
        enabled = true,
        disabled_modes = false,
        above = 0,
        below = 0,
        ignore = {
          code_background = true,
          indent = true,
          sign = true,
          virtual_lines = true,
        },
      },
      win_options = {
        concealcursor = {
          rendered = 'nvic',
          raw = '',
        },
      },
    },
  },
  -- Training and utility plugins
  {
    'ThePrimeagen/vim-be-good',
    event = 'VeryLazy',
    cmd = 'VimBeGood', -- Only load when command is used
  },
  {
    'vuki656/package-info.nvim',
    event = { 'BufEnter package.json' },
    dependencies = { 'MunifTanjim/nui.nvim' },
    config = function()
      require('package-info').setup {
        colors = {
          up_to_date = _G.config.colors.success,
          outdated = _G.config.colors.warning,
          invalid = _G.config.colors.error,
        },
        icons = {
          enable = true,
          style = {
            up_to_date = '|  ',
            outdated = '|  ',
            invalid = '|  ',
          },
        },
        autostart = true,
        hide_up_to_date = false,
        hide_unstable_versions = false,
        package_manager = 'npm',
      }
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
