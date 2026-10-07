return {
  -- 🔍 Snacks Finder - Fuzzy Finder
  {
    'folke/snacks.nvim',
    ---@type snacks.Config
    opts = {
      picker = {
        enabled = true,
        exclude = { -- add folder names here to exclude
          -- 📦 Package managers & build tools
          'node_modules/',
          '%.lock',
          'package%-lock%.json',
          'yarn%.lock',
          'pnpm%-lock%.yaml',
          'npm%-shrinkwrap%.json',
          'bun%-lock%.b',
          '%.pnp%.c?js',
          '%.toml', -- optional: cargo, poetry, etc.

          -- 🧪 Test snapshots / coverage / build artifacts
          '__snapshots__/',
          'coverage/',
          'dist/',
          'build/',
          'target/',
          '%.class',
          '%.jar',
          '%.wasm',
          '%.map', -- source maps

          -- 🗃️ VCS and dotdirs
          '%.git/',
          '%.gitignore',
          '%.gitattributes',
          '%.svn/',
          '%.hg/',
          '%.env',
          '%.editorconfig',
          '%.prettier.*',
          '%.eslint.*',

          -- 📁 pnpm / monorepo extras
          'pnpm/store',
          'pnpm%-store/',
          '%.turbo/',
          '%.nx/',
          '%.yalc/',
          '.yalc/',

          -- 💻 System / macOS / Linux clutter
          '%.DS_Store',
          '%.Trash',
          'Icon%?',

          -- 🪣 Caches / logs / temporary files
          '%.cache/',
          '%.npm/',
          '%.yarn/',
          'log/',
          'logs/',
          '%.log',
          '%.tmp',
          '%.bak',
          '%.swp',
          '%.swo',

          -- 📚 Static site / frontend framework output
          'public/',
          'out/',
          'storybook%-static/',
          '.next/',
          '.svelte%-kit/',
          '.vite/',
          '.astro/',
        },
      },
    },
  },

  -- ⚡ Flash - Enhanced Navigation
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      -- Use global design system
      modes = {
        search = {
          enabled = true,
        },
        char = {
          enabled = true,
          -- Jump to unique chars automatically
          autohide = false,
          jump_labels = true,
          multi_line = true,
        },
      },
      -- Consistent with global theme
      prompt = {
        enabled = true,
        prefix = { { '⚡', 'FlashPromptIcon' } },
      },
    },
    specs = {
      {
        'folke/snacks.nvim',
        opts = {
          picker = {
            win = {
              input = {
                keys = {
                  ['<a-s>'] = { 'flash', mode = { 'n', 'i' } },
                  ['s'] = { 'flash' },
                },
              },
            },
            actions = {
              flash = function(picker)
                require('flash').jump {
                  pattern = '^',
                  label = { after = { 0, 0 } },
                  search = {
                    mode = 'search',
                    exclude = {
                      function(win)
                        return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'snacks_picker_list'
                      end,
                    },
                  },
                  action = function(match)
                    local idx = picker.list:row2idx(match.pos[1])
                    picker.list:_move(idx, true, true)
                  end,
                }
              end,
            },
          },
        },
      },
    },
    -- Keys defined in config/keymaps.lua
  },
  {
    'nvim-tree/nvim-tree.lua',
    cmd = { 'NvimTreeToggle', 'NvimTreeFindFile', 'NvimTreeFocus' },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local api = require 'nvim-tree.api'

      local function on_attach(bufnr)
        api.config.mappings.default_on_attach(bufnr)

        -- <C-k> (node info) would shadow vim-tmux-navigator's "focus up" inside the tree.
        pcall(vim.keymap.del, 'n', '<C-k>', { buffer = bufnr })

        local function map(lhs, rhs, desc)
          vim.keymap.set('n', lhs, rhs, { buffer = bufnr, noremap = true, silent = true, nowait = true, desc = desc })
        end

        map('l', api.node.open.edit, 'Open')
        map('h', api.node.navigate.parent_close, 'Close Directory')
        map('v', api.node.open.vertical, 'Open Vertical Split')
        map('H', api.tree.toggle_hidden_filter, 'Toggle Dotfiles')
        map('I', api.tree.toggle_gitignore_filter, 'Toggle Git Ignore')
      end

      require('nvim-tree').setup {
        on_attach = on_attach,
        disable_netrw = true,
        hijack_netrw = true,
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        view = {
          side = 'left',
          width = 30,
          preserve_window_proportions = true,
          signcolumn = 'no',
          number = false,
          relativenumber = false,
        },
        renderer = {
          root_folder_label = function(path)
            return '  ' .. vim.fn.fnamemodify(path, ':t')
          end,
          highlight_git = true,
          highlight_opened_files = 'name',
          indent_markers = {
            enable = true,
            inline_arrows = true,
            icons = {
              corner = '└',
              edge = '│',
              item = '│',
              bottom = '─',
              none = ' ',
            },
          },
          icons = {
            git_placement = 'after',
            modified_placement = 'after',
            padding = ' ',
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
              modified = true,
            },
            glyphs = {
              default = _G.config.icons.ui.file,
              symlink = ' ',
              bookmark = '󰆤 ',
              modified = _G.config.icons.ui.modified,
              folder = {
                arrow_closed = '',
                arrow_open = '',
                default = _G.config.icons.ui.folder_closed,
                open = _G.config.icons.ui.folder_open,
                empty = ' ',
                empty_open = ' ',
                symlink = ' ',
                symlink_open = ' ',
              },
              git = {
                unstaged = '',
                staged = '',
                unmerged = '',
                renamed = '󰁕',
                untracked = '',
                deleted = '󰍵',
                ignored = '',
              },
            },
          },
        },
        modified = {
          enable = true,
          show_on_dirs = true,
          show_on_open_dirs = true,
        },
        filters = {
          dotfiles = false,
          git_ignored = true,
          custom = { '.DS_Store' },
        },
        actions = {
          open_file = {
            quit_on_open = false,
            resize_window = true,
          },
        },
        diagnostics = {
          enable = true,
          show_on_dirs = true,
        },
        git = {
          enable = true,
          ignore = false,
        },
      }
    end,
  },
}
