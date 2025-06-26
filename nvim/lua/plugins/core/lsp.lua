-- lua/plugins/core/lsp.lua
return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'nvimdev/lspsaga.nvim',
    },
    config = function()
      vim.diagnostic.config {
        float = {
          source = false,
          format = function(diagnostic)
            local code = diagnostic.user_data and diagnostic.user_data.lsp and diagnostic.user_data.lsp.code
            if not diagnostic.source or not code then
              return diagnostic.message
            end

            local lsp_codes = _G.config.lsp.codes -- Use the global config
            for _, tbl in pairs(lsp_codes) do
              if vim.tbl_contains(tbl, code) then
                if diagnostic.source == 'eslint_d' and tbl.icon then
                  return string.format('%s [%s]', tbl.icon .. diagnostic.message, code)
                end
                return tbl.message
              end
            end
            return string.format('%s [%s]', diagnostic.message, diagnostic.source)
          end,
        },
        severity_sort = true,
        virtual_text = false,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = _G.config.icons.diagnostics.error,
            [vim.diagnostic.severity.WARN] = _G.config.icons.diagnostics.warn,
            [vim.diagnostic.severity.INFO] = _G.config.icons.diagnostics.info,
            [vim.diagnostic.severity.HINT] = _G.config.icons.diagnostics.hint,
          },
        },
        underline = true,
        update_in_insert = false,
      }

      local lspconfig = require 'lspconfig'
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Global override for floating preview border
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or _G.config.ui.border -- Use global border
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
  },
  {
    'williamboman/mason.nvim',
    build = ':MasonUpdate',
    config = function()
      require('mason').setup { ui = { border = _G.config.ui.border } }
      require('mason-lspconfig').setup {
        ensure_installed = {
          'bashls',
          'cssls',
          'graphql',
          'html',
          'jsonls',
          'lua_ls',
          -- 'prismals',
        },
        automatic_installation = true,
      }
    end,
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-tool-installer').setup {
        ensure_installed = {
          -- Formatters & Linters
          'eslint_d',
          'prettierd',
          'stylua',
          'luacheck',
          'shellcheck',
          'shfmt',
        },
        run_on_start = true,
        start_delay = 3000,
        debounce_hours = 8,
      }
    end,
  },
  -- LSP Saga for Enhanced LSP UI
  {
    'nvimdev/lspsaga.nvim',
    event = 'LspAttach',
    config = function()
      require('lspsaga').setup {
        -- 🎨 UI Configuration using global design system
        ui = {
          -- Use global border setting
          border = _G.config.ui.border,

          -- Use global color system
          colors = {
            normal_bg = vim.o.background == 'dark' and '#1a1b26' or '#ffffff',
            title_bg = _G.config.colors.primary,
            red = _G.config.colors.error,
            magenta = _G.config.colors.secondary,
            orange = _G.config.colors.warning,
            yellow = _G.config.colors.warning,
            green = _G.config.colors.success,
            cyan = _G.config.colors.info,
            blue = _G.config.colors.primary,
            purple = _G.config.colors.secondary,
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
          enable = true,
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
            quit = 'q',
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
          auto_preview = true,
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
      auto_preview = true,
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
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xb",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>xs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>xl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
    specs = {
      "folke/snacks.nvim",
      opts = function(_, opts)
        return vim.tbl_deep_extend("force", opts or {}, {
          picker = {
            actions = require("trouble.sources.snacks").actions,
            win = {
              input = {
                keys = {
                  ["<c-t>"] = {
                    "trouble_open",
                    mode = { "n", "i" },
                  },
                },
              },
            },
          },
        })
      end,
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
