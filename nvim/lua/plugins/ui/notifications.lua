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
            lsp = {
                override = {
                    ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                    ['vim.lsp.util.stylize_markdown'] = true,
                    ['cmp.entry.get_documentation'] = true,
                },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
                inc_rename = false,
                lsp_doc_border = false,
            },
        },
    },

    -- Notifications
    {
        'rcarriga/nvim-notify',
        opts = {
            timeout = 3000,
            max_height = function()
                return math.floor(vim.o.lines * _G.config.layout.notification_max_height_percent)
            end,
            max_width = function()
                return math.floor(vim.o.columns * _G.config.layout.notification_max_width_percent)
            end,
            render = 'default',
        },
    },
}

-- vim: ts=2 sts=2 sw=2 et
