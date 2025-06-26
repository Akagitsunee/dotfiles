---@diagnostic disable: different-requires
return {
    {
        'kevinhwang91/nvim-ufo',
        dependencies = 'kevinhwang91/promise-async',
        event = "VimEnter",
        config = function()
            local ufo_utils = require("utils.ufo")
            require('ufo').setup({
                fold_virt_text_handler = ufo_utils.handler,
                open_fold_hl_timeout = 0,
                provider_selector = function(bufnr, filetype, buftype)
                    -- Only apply folding to actual code files
                    local code_filetypes = {
                        'lua', 'python', 'javascript', 'typescript', 'javascriptreact',
                        'typescriptreact', 'go', 'rust', 'java', 'c', 'cpp', 'html', 'css'
                    }

                    -- Skip special buffers (dashboards, help, etc.)
                    if buftype ~= '' then
                        return ''
                    end

                    -- Skip startup screens and UI buffers
                    if filetype == '' or filetype == 'dashboard' or filetype == 'alpha' or filetype == 'snacks_dashboard' then
                        return ''
                    end

                    -- Only fold actual code files
                    for _, ft in ipairs(code_filetypes) do
                        if filetype == ft then
                            return { 'treesitter', 'indent' }
                        end
                    end

                    return ''
                end,
            })

            -- Utility: Open all folds + restore cursor position
            local function restore_view()
                local view = vim.fn.winsaveview()
                vim.defer_fn(function()
                    vim.fn.winrestview(view)
                    vim.cmd("normal! zR") -- Open all folds
                end, 20)
            end

            -- On LSP attach: prevent folding collapse
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function()
                    restore_view()
                end,
            })

            -- On save: prevent folding collapse
            vim.api.nvim_create_autocmd("BufWritePost", {
                callback = function()
                    restore_view()
                end,
            })

            -- On code action: prevent folding collapse
            vim.api.nvim_create_autocmd("User", {
                pattern = "LspCodeAction",
                callback = function()
                    restore_view()
                end,
            })
        end,
    },
    -- Colorizer
    {
        "brenoprata10/nvim-highlight-colors",
        opts = {
            enable_tailwind = false,
        }
    },
    { -- Add indentation guides even on blank lines
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            indent = {
                char = "┆",
                tab_char = "┆",
            },
            scope = {
                enabled = true,
                show_start = true,
                show_end = false,
                highlight = { "Function", "Label" },
            },
            exclude = {
                filetypes = {
                    "help",
                    "alpha",
                    "dashboard",
                    "neo-tree",
                    "Trouble",
                    "trouble",
                    "lazy",
                    "mason",
                    "notify",
                    "toggleterm",
                    "lazyterm",
                },
            },
        },
    },
    {
        'folke/zen-mode.nvim',
        event = 'CmdlineEnter',
        cmd = 'ZenMode',
        opts = {
            window = {
                width = 0.85,
                options = {
                    number = true,
                    relativenumber = true,
                },
            },
            plugins = {
                options = {
                    enabled = true,
                    ruler = false,
                    showcmd = false,
                    laststatus = 0,
                },
                twilight = { enabled = false },
                gitsigns = { enabled = false },
                tmux = { enabled = true },
            },
        },
    },
}

-- vim: ts=2 sts=2 sw=2 et
