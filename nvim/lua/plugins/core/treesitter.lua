-- plugins/core/treesitter.lua
-- Treesitter configuration for syntax highlighting and code understanding
-- Part of the 'core' category as it's essential for modern text editing

return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufNewFile" }, -- Lazy load on file operations
        build = ":TSUpdate",
        dependencies = {
            {
                "nvim-treesitter/nvim-treesitter-textobjects",
                event = "VeryLazy", -- Defer to reduce startup impact (was 21.79ms)
            },
            {
                "nvim-treesitter/nvim-treesitter-context",
                event = "VeryLazy",                                                   -- Load after treesitter is ready
                opts = {
                    max_lines = 3,
                    trim_scope = 'outer',
                    patterns = {
                        -- Match against more specific patterns
                        default = {
                            'class',
                            'function',
                            'method',
                            'for',
                            'while',
                            'if',
                            'switch',
                            'case',
                        },
                    },
                },
            },
        },
        config = function()
                require("nvim-treesitter").setup({
                    -- Only install parsers for languages you actually use
                    ensure_installed = {
                        "lua",
                        "javascript",
                        "typescript",
                        "tsx",
                        "json",
                        "html",
                        "css",
                        "scss",
                        "markdown",
                        "markdown_inline",
                        "vim",
                        "vimdoc",
                        "query", -- Treesitter query language
                        "regex", -- Regex highlighting
                        "bash",
                        "dockerfile",
                        "gitignore",
                        "yaml",
                        "toml",
                        "dap_repl",
                        "go",
                        "gomod",
                        "gowork",
                        "gosum",
                        "svelte",
                        -- "java",
                        -- "python",
                    },

                    -- Performance optimizations
                    sync_install = false, -- Don't block on parser installation
                    auto_install = true,  -- Install parsers automatically when needed

                    -- Core highlighting configuration
                    highlight = {
                        enable = true,
                        -- Disable highlighting for large files to maintain performance
                        disable = function(lang, buf)
                            local max_filesize = 1024 * 1024
                            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
                            if ok and stats and stats.size > max_filesize then
                                return true
                            end
                        end,
                        -- Disable vim regex highlighting for better performance
                        additional_vim_regex_highlighting = false,
                    },

                    -- Text objects configuration (loaded VeryLazy to reduce startup time)
                    textobjects = {
                        select = {
                            enable = true,
                            lookahead = true, -- Automatically jump forward to textobj
                            keymaps = {
                                -- Function objects
                                ["af"] = "@function.outer",
                                ["if"] = "@function.inner",
                                -- Class objects
                                ["ac"] = "@class.outer",
                                ["ic"] = "@class.inner",
                                -- Parameter objects
                                ["aa"] = "@parameter.outer",
                                ["ia"] = "@parameter.inner",
                                -- Conditional objects
                                ["ai"] = "@conditional.outer",
                                ["ii"] = "@conditional.inner",
                                -- Loop objects
                                ["al"] = "@loop.outer",
                                ["il"] = "@loop.inner",
                            },
                            -- You can choose the selection modes
                            selection_modes = {
                                ['@parameter.outer'] = 'v', -- charwise
                                ['@function.outer'] = 'V',  -- linewise
                                ['@class.outer'] = '<c-v>', -- blockwise
                            },
                        },

                        -- Smart movement between code objects
                        move = {
                            enable = true,
                            set_jumps = true, -- Set jumps in the jumplist
                            goto_next_start = {
                                ["]f"] = "@function.outer",
                                ["]c"] = "@class.outer",
                                ["]a"] = "@parameter.inner",
                            },
                            goto_next_end = {
                                ["]F"] = "@function.outer",
                                ["]C"] = "@class.outer",
                                ["]A"] = "@parameter.inner",
                            },
                            goto_previous_start = {
                                ["[f"] = "@function.outer",
                                ["[c"] = "@class.outer",
                                ["[a"] = "@parameter.inner",
                            },
                            goto_previous_end = {
                                ["[F"] = "@function.outer",
                                ["[C"] = "@class.outer",
                                ["[A"] = "@parameter.inner",
                            },
                        },

                        -- Swap objects (useful for reordering parameters, etc.)
                        swap = {
                            enable = true,
                            swap_next = {
                                ["<leader>sa"] = "@parameter.inner",
                                ["<leader>sf"] = "@function.outer",
                            },
                            swap_previous = {
                                ["<leader>sA"] = "@parameter.inner",
                                ["<leader>sF"] = "@function.outer",
                            },
                        },
                    },

                    -- Incremental selection based on treesitter
                    incremental_selection = {
                        enable = true,
                        keymaps = {
                            init_selection = "<C-space>",
                            node_incremental = "<C-space>",
                            scope_incremental = false, -- Disabled to avoid confusion
                            node_decremental = "<bs>",
                        },
                    },

                    -- Treesitter-based indentation (experimental)
                    indent = {
                        enable = true,
                        -- Disable for languages where it's problematic
                        disable = { "python", "yaml", "markdown" },
                    },

                })

                -- Set up treesitter-based folding expression
                -- vim.opt.foldmethod = "expr"
                -- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
                -- vim.opt.foldenable = false -- Start with all folds open
        end,
    },
}
-- vim: ts=2 sts=2 sw=2 et
