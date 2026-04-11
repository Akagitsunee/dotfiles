return {
  -- Better UI components
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    opts = {
      cmdline = {
        view = 'cmdline_popup',
        format = {
          cmdline = { icon = '󰘳 ' },
          search_down = { icon = '󰍉  ' },
          search_up = { icon = '󰍉  ' },
          filter = { icon = '󰈲 ' },
          lua = { icon = ' ' },
          help = { icon = '󰋖 ' },
        },
      },
      views = {
        cmdline_popup = {
          position = {
            row = '40%',
            col = '50%',
          },
          size = {
            width = 60,
            height = 'auto',
          },
          border = {
            style = 'none',
            padding = { 1, 3 },
          },
        },
        popupmenu = {
          relative = 'editor',
          position = {
            row = '48%',
            col = '50%',
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = 'rounded',
            padding = { 0, 1 },
          },
        },
        mini = {
          position = {
            row = -2,
            col = '100%',
          },
        },
      },
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
    },
  },

  -- Notifications
  {
    'rcarriga/nvim-notify',
    event = 'VeryLazy',
    config = function(_, opts)
      local notify = require 'notify'
      notify.setup(opts)

      if _G.install_notify_logger then
        _G.install_notify_logger(notify)
      end
    end,
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * _G.config.layout.notification_max_height_percent)
      end,
      max_width = function()
        return math.floor(vim.o.columns * _G.config.layout.notification_max_width_percent)
      end,
      render = 'compact',
      stages = 'fade_in_slide_out',
      background_colour = '#1e2030',
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
