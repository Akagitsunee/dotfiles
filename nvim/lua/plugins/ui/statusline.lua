return -- Status line
{
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local lualine = require 'lualine'

        -- Define custom conditions for lualine sections
        local section_b_cond = {
            function()
                return vim.o.columns >= 95
            end,
            function()
                return vim.o.columns >= 115
            end,
        }

        -- Lualine configuration
        lualine.setup {
            options = {
                globalstatus = vim.o.laststatus == 3, -- Enable global statusline
                component_separators = '',
                section_separators = { left = '', right = '' },
                disabled_filetypes = { statusline = {}, winbar = {} },
                always_divide_middle = true,
            },
            sections = {
                lualine_a = {
                    {
                        'mode',
                        icon = _G.config.icons.ui.neovim,
                        separator = { left = '', right = _G.config.icons.ui.separator.lualine.right },
                        padding = { left = 1, right = 0 },
                    },
                },
                lualine_b = {
                    { 'branch', icon = _G.config.icons.git.branch, cond = section_b_cond[1] },
                    {
                        'diff',
                        symbols = {
                            added = _G.config.icons.git.added,
                            modified = _G.config.icons.git.modified,
                            removed = _G.config.icons.git.removed,
                        },
                        padding = { left = 0, right = 1 },
                        cond = section_b_cond[2],
                    },
                },
                lualine_c = {
                    { '%=', padding = 0 }, -- Center align components
                    {
                        'datetime',
                        icon = _G.config.icons.ui.clock,
                        style = '%H:%M',
                        separator = { left = _G.config.icons.ui.separator.lualine.left, right = _G.config.icons.ui.separator.lualine.right },
                        padding = 0,
                    },
                },
                lualine_x = {}, -- Empty section for customization
                lualine_y = {
                    {
                        'filetype',
                        fmt = string.upper,
                        cond = section_b_cond[1],
                    },
                    -- {
                    --   function()
                    --     return vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
                    --   end,
                    --   icon = { icons.directory, color = 'Directory' },
                    --   cond = section_b_cond[2],
                    -- },
                    { 'filename' },
                },
                lualine_z = {
                    {
                        'location',
                        separator = { left = _G.config.icons.ui.separator.lualine.left, right = '' },
                        padding = { left = 0, right = 1 },
                    },
                },
            },
            inactive_sections = { -- Define inactive sections
                lualine_a = {},
                lualine_b = {},
                lualine_c = { { 'filename' } },
                lualine_x = { { 'location' } },
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {},
            winbar = {},
            inactive_winbar = {},
        }
    end,
}

-- vim: ts=2 sts=2 sw=2 et
