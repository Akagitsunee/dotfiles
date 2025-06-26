return {
  'saghen/blink.cmp',
  event = 'InsertEnter',
  build = 'cargo build --release',

  dependencies = {
    -- Snippet Engine
    {
      'L3MON4D3/LuaSnip',
      version = '2.*',
      build = "make install_jsregexp",

      dependencies = { 'rafamadriz/friendly-snippets' },

      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    {
      'fang2hou/blink-copilot',
      event = 'InsertEnter'
    },
    {
      'folke/lazydev.nvim',
      event = 'InsertEnter'
    },
    -- Add blink.pairs for autopair functionality
    {
      'saghen/blink.pairs',
      event = 'InsertEnter',
      build = 'cargo build --release'
    },
  },

  config = function(_, opts)
    require('blink.cmp').setup(opts)

    -- Safely pull icons AFTER _G.config is defined
    local icons = (_G.config and _G.config.icons and _G.config.icons.kinds) or {}
    opts.appearance.kind_icons = icons

    -- ADHD-friendly: Clear completion on Escape
    vim.keymap.set('i', '<Esc>', function()
      if require('blink.cmp').is_visible() then
        require('blink.cmp').cancel()
      end
      return '<Esc>'
    end, { expr = true })

    -- Setup blink.pairs
    require('blink.pairs').setup({
      mappings = {
        enabled = true,
        -- ADHD-friendly settings
        disabled_filetypes = { 'spectre_panel' },

        -- Default pairs
        pairs = {
          ["("] = ")",
          ["["] = "]",
          ["{"] = "}",
          ['"'] = '"',
          ["'"] = "'",
          ["`"] = "`",
        },
      },
      highlights = {
        enabled = true,
        groups = {
          'BlinkPairsOrange',
          'BlinkPairsPurple',
          'BlinkPairsBlue',
        },
        matchparen = {
          enabled = true,
          group = 'MatchParen',
        },
      },
      debug = false,
    })
  end,

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = 'super-tab',
      -- Better ADHD-friendly navigation
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-u>"] = { "scroll_documentation_up", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      ["<C-e>"] = { "cancel", "fallback" },
      -- Quick accept with Ctrl+Space
      ["<C-Space>"] = { "accept", "fallback" },
    },

    appearance = {
      nerd_font_variant = 'mono',
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev', 'copilot' },
      providers = {
        lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },

        copilot = {
          name = "copilot",
          module = "blink-copilot",
          opts = {
            max_completions = 3,
            max_attempts = 4,
          },
          score_offset = 100,
          async = true,
          transform_items = function(_, items)
            local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
            local kind_idx = #CompletionItemKind + 1
            CompletionItemKind[kind_idx] = "Copilot"
            for _, item in ipairs(items) do
              item.kind = kind_idx
            end
            return items
          end,
        },

        buffer = {
          name = "buffer",
          max_items = 5, -- Limit buffer suggestions
          opts = {
            get_bufnrs = function()
              -- Only current buffer to reduce noise
              return { vim.api.nvim_get_current_buf() }
            end,
          },
        },
      },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" },

    completion = {
      trigger = {
        show_on_trigger_character = true,
        show_on_insert_on_trigger_character = true,
        -- Reduce trigger noise
        show_on_x_blocked_trigger_characters = { "'", '"', '(', '{', '[', '=', ',' },
      },

      menu = {
        max_height = 10, -- Prevent overwhelming menu
        border = _G.config.ui.border,
        draw = {
          columns = {
            { "label",     "label_description", gap = 1 },
            { "kind_icon", "kind",              gap = 1 }
          },
          treesitter = { "lsp" }, -- Better syntax highlighting
        },
      },

      accept = {
        auto_brackets = {
          enabled = true,
          force_allow_filetypes = { "typescript", "javascript", "lua" },
        },
      },

      documentation = {
        auto_show = true,
        auto_show_delay_ms = 300, -- Faster for ADHD
        treesitter_highlighting = true,
        window = {
          border = 'rounded',
          max_width = 60,
          max_height = 20,
        },
      },

      ghost_text = {
        enabled = true,
      },

      -- ADHD-friendly: reduce visual noise
      list = {
        max_items = 15, -- Limit to prevent overwhelm
      },
    },

    signature = {
      enabled = true,
      window = {
        border = _G.config.ui.border,
      },
    },
  },
  opts_extend = { "sources.default" },
}


-- vim: ts=2 sts=2 sw=2 et
