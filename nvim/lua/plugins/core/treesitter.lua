-- plugins/core/treesitter.lua
-- Treesitter configuration for syntax highlighting and code understanding
-- Part of the 'core' category as it's essential for modern text editing
--
-- nvim-treesitter is pinned to the `main` branch (the 2024 rewrite, see
-- https://github.com/nvim-treesitter/nvim-treesitter). That branch's `setup()`
-- only accepts `install_dir` -- highlighting, indent, folds and textobjects
-- are no longer configured through it and must be wired up manually below.
-- The plugin also explicitly does not support lazy-loading.

-- Languages we want available; parsers outside this list can be added on
-- demand with `:TSInstall <lang>`.
local ensure_installed = {
  'lua',
  'javascript',
  'typescript',
  'tsx',
  'vue',
  'json',
  'html',
  'css',
  'scss',
  'markdown',
  'markdown_inline',
  'vim',
  'vimdoc',
  'query', -- Treesitter query language
  'regex', -- Regex highlighting
  'bash',
  'dockerfile',
  'gitignore',
  'yaml',
  'toml',
  'go',
  'gomod',
  'gowork',
  'gosum',
  'svelte',
}

-- Treesitter-based indentation is experimental upstream; skip it for
-- languages where it's known to misbehave and fall back to filetype indent.
local indent_disabled = { python = true, yaml = true, markdown = true }

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
      },
      {
        'nvim-treesitter/nvim-treesitter-context',
        event = 'VeryLazy', -- Load after treesitter is ready
        opts = {
          max_lines = 3,
          trim_scope = 'outer',
          patterns = {
            -- Match against more specific patterns
            default = {
              'class',
              'function',
              'method',
              'for',
              'while',
              'if',
              'switch',
              'case',
            },
          },
        },
      },
    },
    config = function()
      local ts = require 'nvim-treesitter'
      ts.install(ensure_installed)

      -- Highlighting, folds and indent are provided by Neovim core once a
      -- parser is attached; nvim-treesitter only ships the queries.
      local function attach(bufnr, ft, lang)
        -- Skip highlighting/indent for large files (performance)
        local max_filesize = 1024 * 1024
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
        if ok and stats and stats.size > max_filesize then
          return
        end

        if not pcall(vim.treesitter.start, bufnr, lang) then
          return
        end

        vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'

        if not indent_disabled[ft] then
          vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      local ts_group = vim.api.nvim_create_augroup('TreesitterAttach', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = ts_group,
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match) or args.match

          if vim.tbl_contains(ts.get_installed(), lang) then
            attach(args.buf, args.match, lang)
            return
          end

          if not vim.tbl_contains(ts.get_available(), lang) then
            return
          end

          -- Not installed yet: either the bulk `ensure_installed` job
          -- above is already fetching it, or this language was opened
          -- on demand. Either way, poll rather than nesting another
          -- `:wait()` inside that job (which can throw).
          if not vim.tbl_contains(ensure_installed, lang) then
            ts.install(lang)
          end

          local timer = vim.uv.new_timer()
          local done = false
          timer:start(
            200,
            200,
            vim.schedule_wrap(function()
              -- A repeating timer can queue more than one scheduled
              -- callback before the first gets to stop it; guard
              -- against double-closing the same handle.
              if done or not vim.tbl_contains(ts.get_installed(), lang) then
                return
              end
              done = true
              timer:stop()
              if not timer:is_closing() then
                timer:close()
              end
              if vim.api.nvim_buf_is_valid(args.buf) then
                attach(args.buf, args.match, lang)
              end
            end)
          )
        end,
      })

      -- Text objects (af/if/ac/ic/aa/ia/ai/ii/al/il, ]f ]c ]a, swaps).
      -- The `main` branch of nvim-treesitter-textobjects dropped the
      -- keymaps table from setup(); keymaps must be bound manually.
      require('nvim-treesitter-textobjects').setup {
        select = {
          lookahead = true,
          selection_modes = {
            ['@parameter.outer'] = 'v',
            ['@function.outer'] = 'V',
            ['@class.outer'] = '<c-v>',
          },
        },
        move = {
          set_jumps = true,
        },
      }

      local select_textobject = require('nvim-treesitter-textobjects.select').select_textobject
      local move = require 'nvim-treesitter-textobjects.move'
      local swap = require 'nvim-treesitter-textobjects.swap'

      local select_keymaps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['ai'] = '@conditional.outer',
        ['ii'] = '@conditional.inner',
        ['al'] = '@loop.outer',
        ['il'] = '@loop.inner',
      }
      for key, query in pairs(select_keymaps) do
        vim.keymap.set({ 'x', 'o' }, key, function()
          select_textobject(query, 'textobjects')
        end)
      end

      local move_keymaps = {
        goto_next_start = { [']f'] = '@function.outer', [']c'] = '@class.outer', [']a'] = '@parameter.inner' },
        goto_next_end = { [']F'] = '@function.outer', [']C'] = '@class.outer', [']A'] = '@parameter.inner' },
        goto_previous_start = { ['[f'] = '@function.outer', ['[c'] = '@class.outer', ['[a'] = '@parameter.inner' },
        goto_previous_end = { ['[F'] = '@function.outer', ['[C'] = '@class.outer', ['[A'] = '@parameter.inner' },
      }
      for method, keymaps in pairs(move_keymaps) do
        for key, query in pairs(keymaps) do
          vim.keymap.set({ 'n', 'x', 'o' }, key, function()
            move[method](query, 'textobjects')
          end)
        end
      end

      vim.keymap.set('n', '<leader>sa', function()
        swap.swap_next '@parameter.inner'
      end)
      vim.keymap.set('n', '<leader>sf', function()
        swap.swap_next '@function.outer'
      end)
      vim.keymap.set('n', '<leader>sA', function()
        swap.swap_previous '@parameter.inner'
      end)
      vim.keymap.set('n', '<leader>sF', function()
        swap.swap_previous '@function.outer'
      end)
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
