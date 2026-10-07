---@diagnostic disable: different-requires
return {
  {
    'kevinhwang91/nvim-ufo',
    dependencies = 'kevinhwang91/promise-async',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local ufo_utils = require 'utils.ufo'
      require('ufo').setup {
        fold_virt_text_handler = ufo_utils.handler,
        open_fold_hl_timeout = 0,
        close_fold_kinds_for_ft = {
          default = {},
          lua = {},
          python = { 'imports' },
          javascript = { 'imports' },
          typescript = { 'imports' },
          javascriptreact = { 'imports' },
          typescriptreact = { 'imports' },
          go = { 'imports' },
          rust = { 'imports' },
        },
        provider_selector = function(bufnr, filetype, buftype)
          -- Only apply folding to actual code files with solid treesitter support.
          local code_filetypes = {
            'lua',
            'python',
            'javascript',
            'typescript',
            'javascriptreact',
            'typescriptreact',
            'go',
            'rust',
            'java',
            'c',
            'cpp',
          }

          -- Skip special buffers (dashboards, help, etc.)
          if buftype ~= '' then
            return ''
          end

          -- Skip startup screens and UI buffers
          if filetype == '' or filetype == 'dashboard' or filetype == 'alpha' or filetype == 'snacks_dashboard' then
            return ''
          end

          -- Only fold actual code files
          for _, ft in ipairs(code_filetypes) do
            if filetype == ft then
              return { 'treesitter' }
            end
          end

          return ''
        end,
      }
    end,
  },
  -- Colorizer
  {
    'brenoprata10/nvim-highlight-colors',
    event = 'BufReadPost',
    opts = {
      enable_tailwind = false,
    },
  },
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      indent = {
        char = '│',
        tab_char = '│',
        highlight = 'IblChar',
      },
      scope = {
        enabled = false,
        show_start = false,
        show_end = false,
        highlight = 'IblScopeChar',
      },
      whitespace = {
        remove_blankline_trail = true,
      },
      exclude = {
        filetypes = {
          'help',
          'alpha',
          'dashboard',
          'NvimTree',
          'Trouble',
          'trouble',
          'lazy',
          'mason',
          'notify',
          'toggleterm',
          'lazyterm',
        },
      },
    },
  },
  {
    'folke/zen-mode.nvim',
    event = 'CmdlineEnter',
    cmd = 'ZenMode',
    opts = {
      window = {
        width = 0.85,
        options = {
          number = true,
          relativenumber = true,
        },
      },
      plugins = {
        options = {
          enabled = true,
          ruler = false,
          showcmd = false,
          laststatus = 0,
        },
        twilight = { enabled = false },
        gitsigns = { enabled = false },
        tmux = { enabled = true },
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
