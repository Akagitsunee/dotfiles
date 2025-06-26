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
        "lukas-reineke/headlines.nvim",
        ft = { "markdown", "rmd", "norg", "org" },
        dependencies = {
            {
                "nvim-treesitter/nvim-treesitter",
                event = { "BufReadPost", "BufNewFile" },
                build = ":TSUpdate",
            }
        },
        config = function()
            -- Use vim.schedule to defer the setup for better performance
            vim.schedule(function()
                require("headlines").setup({
                    markdown = {
                        headline_highlights = {
                            "Headline1", "Headline2", "Headline3",
                            "Headline4", "Headline5", "Headline6"
                        },
                        codeblock_highlight = "CodeBlock",
                        dash_highlight = "Dash",
                        dash_string = "-",
                        quote_highlight = "Quote",
                        quote_string = "┃",
                        fat_headlines = true,
                        fat_headline_upper_string = "▃",
                        fat_headline_lower_string = "🬂",
                    },
                    rmd = {
                        headline_highlights = {
                            "Headline1", "Headline2", "Headline3",
                            "Headline4", "Headline5", "Headline6"
                        },
                        codeblock_highlight = "CodeBlock",
                    },
                    norg = {
                        headline_highlights = {
                            "Headline1", "Headline2", "Headline3",
                            "Headline4", "Headline5", "Headline6"
                        },
                        codeblock_highlight = "CodeBlock",
                    },
                    org = {
                        headline_highlights = {
                            "Headline1", "Headline2", "Headline3",
                            "Headline4", "Headline5", "Headline6"
                        },
                        codeblock_highlight = "CodeBlock",
                    },
                })
            end)
        end,
    },
    -- Training and utility plugins
    {
        'ThePrimeagen/vim-be-good',
        event = 'VeryLazy',
        cmd = 'VimBeGood', -- Only load when command is used
    },
}

-- vim: ts=2 sts=2 sw=2 et
