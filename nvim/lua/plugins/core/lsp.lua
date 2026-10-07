-- lua/plugins/core/lsp.lua

-- Servers/tools that need a language SDK on $PATH to be useful at all
-- (e.g. gopls needs `go` to install and to do anything meaningful).
-- Everything else (JS/TS, shell, yaml, lua, the npm-based web stack, ...)
-- only needs Node (guaranteed by install.sh via nvm) or nothing, so it's
-- always installed. This lets nvim work on a fresh machine without the
-- SDK, instead of Mason repeatedly failing to install servers it can't use.
local SDK_GATED_TOOLS = {
  {
    executable = 'go',
    servers = { 'gopls' },
    tools = { 'goimports', 'gofumpt', 'golangci-lint', 'delve' },
  },
}

local function with_gated(base_list, field)
  local list = vim.deepcopy(base_list)
  for _, gated in ipairs(SDK_GATED_TOOLS) do
    if vim.fn.executable(gated.executable) == 1 then
      vim.list_extend(list, gated[field])
    end
  end
  return list
end

return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    -- mason.nvim and lspsaga are intentionally not dependencies: they load on their own
    -- triggers (VeryLazy via mason-tool-installer, LspAttach) instead of delaying the
    -- first buffer. Only the PATH entry mason would add is needed up front.
    config = function(_, opts)
      -- Diagnostic display is configured once, in config/autocmds.lua -- don't
      -- duplicate vim.diagnostic.config() here, it'll race against that call.

      local lsp_utils = require 'utils.lsp'
      lsp_utils.ensure_mason_on_path()
      local capabilities = lsp_utils.capabilities()

      -- Global override for floating preview border
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or _G.config.ui.border -- Use global border
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      local servers = opts.servers or {}
      for server_name, server_opts in pairs(servers) do
        server_opts.capabilities = vim.tbl_deep_extend('force', capabilities, server_opts.capabilities or {})
        vim.lsp.config(server_name, server_opts)
        vim.lsp.enable(server_name)
      end
    end,
  },
  {
    'mason-org/mason-lspconfig.nvim',
    lazy = true,
  },
  {
    'mason-org/mason.nvim',
    build = ':MasonUpdate',
    cmd = 'Mason',
    config = function()
      require('mason').setup { ui = { border = _G.config.ui.border } }
      require('mason-lspconfig').setup {
        ensure_installed = with_gated({
          'bashls',
          'cssls',
          'graphql',
          'html',
          'svelte',
          'jsonls',
          'lua_ls',
          'vtsls',
          'tailwindcss',
          'yamlls',
          'vue_ls',
          -- 'prismals',
        }, 'servers'),
        automatic_enable = true,
      }
    end,
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'mason-org/mason.nvim' },
    lazy = true,
    -- Loading mason + mason-lspconfig + the tool installer costs ~100 ms of main-thread
    -- time. Do it shortly after startup finished instead of competing with it; the
    -- servers already resolve through $PATH (see utils/lsp.lua).
    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        once = true,
        callback = function()
          vim.defer_fn(function()
            require('lazy').load { plugins = { 'mason-tool-installer.nvim' } }
          end, 1500)
        end,
      })
    end,
    config = function()
      require('mason-tool-installer').setup {
        ensure_installed = with_gated({
          -- Formatters & Linters
          'eslint_d',
          'prettierd',
          'stylua',
          'shellcheck',
          'shfmt',
          'markdownlint',
          'yamllint',
          'hadolint',
        }, 'tools'),
        run_on_start = true,
        start_delay = 3000,
        debounce_hours = 8,
      }
      -- The plugin normally triggers itself off a VimEnter autocmd registered in its
      -- plugin/ script, but since we lazy-load on VeryLazy (which fires after VimEnter
      -- has already passed), that autocmd never runs. Trigger it ourselves instead.
      require('mason-tool-installer').run_on_start()
    end,
  },
  -- LSP Saga for Enhanced LSP UI
  {
    'nvimdev/lspsaga.nvim',
    event = 'LspAttach',
    config = function()
      local colors = (_G.get_ui_colors and _G.get_ui_colors()) or _G.config.colors
      require('lspsaga').setup {
        -- 🎨 UI Configuration using global design system
        ui = {
          -- Use global border setting
          border = _G.config.ui.border,

          -- Use global color system
          colors = {
            normal_bg = colors.panel,
            title_bg = colors.primary,
            red = colors.error,
            magenta = colors.secondary,
            orange = colors.warning,
            yellow = colors.warning,
            green = colors.success,
            cyan = colors.info,
            blue = colors.primary,
            purple = colors.secondary,
          },

          -- Use global transparency settings
          winblend = _G.config.ui.winblend,
        },

        -- 🔍 Diagnostic Configuration
        diagnostic = {
          -- ADHD-friendly: Clear visual indicators
          show_code_action = true,
          show_source = true,
          jump_num_shortcut = true,

          -- Use global layout settings
          max_width = _G.config.layout.popup_max_width,
          max_height = _G.config.layout.popup_max_height,

          -- Visual consistency
          text_hl_follow = true,
          border_follow = true,
          extend_relatedInformation = true,
          show_layout = 'float',

          -- ADHD-friendly: Quick, intuitive keybindings
          keys = {
            exec_action = 'o',
            quit = 'q',
            toggle_or_jump = '<CR>',
            quit_in_show = { 'q', '<ESC>' },
          },
        },

        -- 🏷️ Symbol Outline (Great for ADHD - structural overview)
        symbol_in_winbar = {
          enable = false,
          separator = _G.config.icons.ui.separator.standard,
          hide_keyword = true,
          show_file = true,
          folder_level = 1,
          respect_root = false,
          color_mode = true,
        },

        -- 🔍 Code Action Configuration
        code_action = {
          num_shortcut = true,
          show_server_name = false,
          extend_gitsigns = true,
          keys = {
            quit = { 'q', '<Esc>' },
            exec = '<CR>',
          },
        },

        -- 💡 Lightbulb (Visual cue for available actions)
        lightbulb = {
          enable = true,
          sign = true,
          virtual_text = false, -- Reduce visual clutter
        },

        -- 📖 Hover Documentation
        hover = {
          max_width = _G.config.layout.popup_max_width,
          max_height = _G.config.layout.popup_max_height,
          open_link = 'gx',
        },

        -- 🔄 Rename Configuration
        rename = {
          in_select = true,
          auto_save = _G.config.behavior.auto_save,
          project_max_width = _G.config.layout.popup_max_width,
          project_max_height = _G.config.layout.popup_max_height,
          keys = {
            quit = '<C-k>',
            exec = '<CR>',
            select = 'x',
          },
        },

        -- 🔍 Definition Preview
        definition = {
          width = _G.config.layout.popup_max_width,
          height = _G.config.layout.popup_max_height,
          keys = {
            edit = '<C-c>o',
            vsplit = '<C-c>v',
            split = '<C-c>i',
            tabe = '<C-c>t',
            quit = 'q',
            close = '<C-c>k',
          },
        },

        -- 🔍 References and Implementation
        finder = {
          max_height = _G.config.layout.popup_max_height,
          left_width = 0.3,
          right_width = 0.3,
          methods = {},
          default = 'ref+imp',
          layout = 'float',
          silent = false,
          filter = {},
          fname_sub = nil,
          sp_inexist = false,
          sp_global = false,
          ly_botright = false,
          keys = {
            shuttle = '[w',
            toggle_or_open = 'o',
            vsplit = 's',
            split = 'i',
            tabe = 't',
            tabnew = 'r',
            quit = 'q',
            close = '<C-c>k',
          },
        },

        -- 📋 Call Hierarchy
        callhierarchy = {
          layout = 'float',
          left_width = 0.2,
          right_width = 0.8,
          keys = {
            edit = 'e',
            vsplit = 's',
            split = 'i',
            tabe = 't',
            close = '<C-c>k',
            quit = 'q',
            shuttle = '[w',
            toggle_or_req = 'u',
          },
        },

        -- 🎯 Outline (Document structure - ADHD-friendly overview)
        outline = {
          win_position = 'right', -- Consistent with your sidebar_width setting
          win_width = _G.config.layout.sidebar_width,
          auto_preview = false,
          auto_close = true,
          close_after_jump = false,
          layout = 'normal',
          max_height = 0.5,
          left_width = 0.3,
          keys = {
            toggle_or_jump = 'o',
            quit = 'q',
            jump = 'e',
          },
        },

        -- 🎨 Beacon (Visual feedback for jumps - ADHD helpful)
        beacon = {
          enable = true,
          frequency = 7,
        },

        -- 📝 Scroll Preview
        scroll_preview = {
          scroll_down = '<C-f>',
          scroll_up = '<C-b>',
        },

        -- 🎯 Request Timeout
        request_timeout = 2000,
      }
    end,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'nvim-treesitter/nvim-treesitter',
    },
  },
  -- Diagnostic viewer - integrates with LSP diagnostics
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'LspAttach', -- Load when LSP attaches to buffer
    opts = {
      position = 'bottom',
      height = 10,
      width = 50,
      mode = 'workspace_diagnostics',
      padding = true,
      auto_preview = false,
      use_diagnostic_signs = true,
      -- Use global design system
      signs = {
        error = _G.config.icons.diagnostics.error,
        warning = _G.config.icons.diagnostics.warn,
        hint = _G.config.icons.diagnostics.hint,
        information = _G.config.icons.diagnostics.info,
      },
    },
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xb',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
    specs = {
      {
        'folke/snacks.nvim',
        opts = function(_, opts)
          return vim.tbl_deep_extend('force', opts or {}, {
            picker = {
              actions = {
                trouble_open = function(...)
                  return require('trouble.sources.snacks').actions.trouble_open(...)
                end,
              },
              win = {
                input = {
                  keys = {
                    ['<c-t>'] = {
                      'trouble_open',
                      mode = { 'n', 'i' },
                    },
                  },
                },
              },
            },
          })
        end,
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
