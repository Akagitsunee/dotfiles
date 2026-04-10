return {
    {
        'folke/todo-comments.nvim',
        event = 'VimEnter',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {
            signs = true,
            keywords = {
                FIX = {
                    icon = _G.config.icons.diagnostics.error,
                    color = 'error',
                    alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }
                },
                TODO = {
                    icon = _G.config.icons.diagnostics.info,
                    color = 'info'
                },
                HACK = {
                    icon = _G.config.icons.diagnostics.warn,
                    color = 'warning'
                },
                WARN = {
                    icon = _G.config.icons.diagnostics.warn,
                    color = 'warning',
                    alt = { 'WARNING', 'XXX' }
                },
                PERF = {
                    icon = ' ',
                    alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' }
                },
                NOTE = {
                    icon = _G.config.icons.diagnostics.hint,
                    color = 'hint',
                    alt = { 'INFO' }
                },
                TEST = {
                    icon = '⏲ ',
                    color = 'test',
                    alt = { 'TESTING', 'PASSED', 'FAILED' }
                },
            },
        },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        dependencies = {
            {
                "nvim-treesitter/nvim-treesitter",
                event = { "BufReadPost", "BufNewFile" },
                build = ":TSUpdate",
            },
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            file_types = { "markdown" },
            render_modes = { "n", "c", "t" },
            anti_conceal = {
                enabled = true,
                disabled_modes = false,
                above = 0,
                below = 0,
                ignore = {
                    code_background = true,
                    indent = true,
                    sign = true,
                    virtual_lines = true,
                },
            },
            win_options = {
                concealcursor = {
                    rendered = "nvic",
                    raw = "",
                },
            },
        },
    },
    -- Training and utility plugins
    {
        'ThePrimeagen/vim-be-good',
        event = 'VeryLazy',
        cmd = 'VimBeGood', -- Only load when command is used
    },
}

-- vim: ts=2 sts=2 sw=2 et
