return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local lualine = require 'lualine'

    local function wide(min_width)
      return function()
        return vim.o.columns > min_width
      end
    end

    local function shorten_path(path, target_width)
      if path == '' then
        return '[No Name]'
      end

      local parts = vim.split(path, '/', { plain = true })
      if #parts == 1 then
        return path
      end

      while vim.fn.strdisplaywidth(table.concat(parts, '/')) > target_width and #parts > 2 do
        for i = 1, #parts - 1 do
          if #parts[i] > 1 and parts[i] ~= '…' then
            parts[i] = parts[i]:sub(1, 1)
          end
          if vim.fn.strdisplaywidth(table.concat(parts, '/')) <= target_width then
            break
          end
        end

        if vim.fn.strdisplaywidth(table.concat(parts, '/')) > target_width then
          table.remove(parts, 1)
          table.insert(parts, 1, '…')
        end
      end

      return table.concat(parts, '/')
    end

    local function pretty_filename()
      local path = vim.fn.expand '%:~:.'
      local target_width = math.max(36, math.floor(vim.o.columns * 0.32))
      local modified = vim.bo.modified and (' ' .. _G.config.icons.ui.modified) or ''
      return shorten_path(path, target_width) .. modified
    end

    local function pretty_winbar()
      local path = vim.fn.expand '%:~:.'
      return shorten_path(path, math.max(48, math.floor(vim.o.columns * 0.5)))
    end

    local function setup_lualine()
      if vim.v.exiting ~= vim.NIL and vim.v.exiting ~= '' then
        return
      end

      local colors = (_G.get_ui_colors and _G.get_ui_colors()) or _G.config.colors
      local transparent = _G.config.theme.transparent_background
      local section_bg = transparent and 'NONE' or colors.surface
      local accent = function(color)
        if transparent then
          return { fg = color, bg = 'NONE', gui = 'bold' }
        end
        return { fg = colors.bg, bg = color, gui = 'bold' }
      end
      local theme = {
        normal = {
          a = accent(colors.primary),
          b = { fg = colors.fg, bg = section_bg },
          c = { fg = colors.muted, bg = 'NONE' },
        },
        insert = {
          a = accent(colors.success),
        },
        visual = {
          a = accent(colors.secondary),
        },
        replace = {
          a = accent(colors.error),
        },
        command = {
          a = accent(colors.warning),
        },
        inactive = {
          a = { fg = colors.line_number, bg = 'NONE' },
          b = { fg = colors.line_number, bg = 'NONE' },
          c = { fg = colors.line_number, bg = 'NONE' },
        },
      }

      lualine.setup {
        options = {
          theme = theme,
          globalstatus = true,
          component_separators = { left = '', right = '' },
          section_separators = transparent and { left = '', right = '' } or { left = '', right = '' },
          disabled_filetypes = {
            statusline = { 'snacks_dashboard', 'alpha', 'starter' },
            winbar = {
              'snacks_dashboard',
              'alpha',
              'starter',
              'NvimTree',
              'lazy',
              'mason',
              'help',
            },
          },
          always_divide_middle = true,
        },
        sections = {
          lualine_a = {
            {
              'mode',
              icon = _G.config.icons.ui.neovim,
              color = accent(colors.primary),
              separator = transparent and nil or { left = '', right = '' },
              padding = { left = 1, right = 1 },
            },
          },
          lualine_b = {
            { 'branch', icon = _G.config.icons.git.branch, cond = wide(90) },
            {
              'diff',
              cond = wide(120),
              symbols = {
                added = _G.config.icons.git.added,
                modified = _G.config.icons.git.modified,
                removed = _G.config.icons.git.removed,
              },
            },
          },
          lualine_c = {
            {
              'diagnostics',
              sources = { 'nvim_diagnostic' },
              symbols = {
                error = _G.config.icons.diagnostics.error,
                warn = _G.config.icons.diagnostics.warn,
                info = _G.config.icons.diagnostics.info,
                hint = _G.config.icons.diagnostics.hint,
              },
            },
            
          },
          lualine_x = {
            {
              pretty_filename,
              icon = _G.config.icons.ui.file,
              color = { fg = colors.fg },
            },
          },
          lualine_y = {
            {
              'filetype',
              fmt = string.upper,
              color = { fg = colors.muted },
            },
          },
          lualine_z = {
            {
              'location',
              color = accent(colors.primary),
              separator = transparent and nil or { left = '', right = '' },
              padding = { left = 1, right = 1 },
            },
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { pretty_filename, color = { fg = colors.line_number } } },
          lualine_x = { { 'location' } },
          lualine_y = {},
          lualine_z = {},
        },
        winbar = {
          lualine_c = {
            {
              pretty_winbar,
              icon = _G.config.icons.ui.directory,
              color = { fg = colors.muted },
            },
            { '%=', padding = 0 },  -- Center align components
            {
              'datetime',
              icon = _G.config.icons.ui.clock,
              style = '%H:%M ',
              padding = 0,
            },
          },
          lualine_z = {
            {
              function()
                return vim.bo.modified and _G.config.icons.ui.modified or ''
              end,
              color = { fg = colors.warning },
            },
          },
        },
        inactive_winbar = {
          lualine_c = {
            {
              pretty_winbar,
              icon = _G.config.icons.ui.directory,
              color = { fg = colors.line_number },
            },
          },
        },
        tabline = {},
        extensions = { 'nvim-tree', 'lazy', 'mason', 'quickfix' },
      }
    end

    setup_lualine()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('DynamicLualineTheme', { clear = true }),
      pattern = '*',
      callback = setup_lualine,
    })
    vim.api.nvim_create_autocmd('User', {
      group = 'DynamicLualineTheme',
      pattern = { 'NvThemeReload', 'TransparentClear' },
      callback = setup_lualine,
    })
  end,
}

-- vim: ts=2 sts=2 sw=2 et
