return {
    -- 🔍 Snacks Finder - Fuzzy Finder
    {
        "folke/snacks.nvim",
        ---@type snacks.Config
        opts = {
            picker = {
                enabled = true,
                exclude = { -- add folder names here to exclude
                    -- 📦 Package managers & build tools
                    'node_modules/',
                    '%.lock',
                    'package%-lock%.json',
                    'yarn%.lock',
                    'pnpm%-lock%.yaml',
                    'npm%-shrinkwrap%.json',
                    'bun%-lock%.b',
                    '%.pnp%.c?js',
                    '%.toml', -- optional: cargo, poetry, etc.

                    -- 🧪 Test snapshots / coverage / build artifacts
                    '__snapshots__/',
                    'coverage/',
                    'dist/',
                    'build/',
                    'target/',
                    '%.class',
                    '%.jar',
                    '%.wasm',
                    '%.map', -- source maps

                    -- 🗃️ VCS and dotdirs
                    '%.git/',
                    '%.gitignore',
                    '%.gitattributes',
                    '%.svn/',
                    '%.hg/',
                    '%.env',
                    '%.editorconfig',
                    '%.prettier.*',
                    '%.eslint.*',

                    -- 📁 pnpm / monorepo extras
                    'pnpm/store',
                    'pnpm%-store/',
                    '%.turbo/',
                    '%.nx/',
                    '%.yalc/',
                    '.yalc/',

                    -- 💻 System / macOS / Linux clutter
                    '%.DS_Store',
                    '%.Trash',
                    'Icon%?',

                    -- 🪣 Caches / logs / temporary files
                    '%.cache/',
                    '%.npm/',
                    '%.yarn/',
                    'log/',
                    'logs/',
                    '%.log',
                    '%.tmp',
                    '%.bak',
                    '%.swp',
                    '%.swo',

                    -- 📚 Static site / frontend framework output
                    'public/',
                    'out/',
                    'storybook%-static/',
                    '.next/',
                    '.svelte%-kit/',
                    '.vite/',
                    '.astro/',
                },
            }
        }
    },

    -- ⚡ Flash - Enhanced Navigation
    {
        'folke/flash.nvim',
        event = 'VeryLazy',
        opts = {
            -- Use global design system
            modes = {
                search = {
                    enabled = true,
                },
                char = {
                    enabled = true,
                    -- Jump to unique chars automatically
                    autohide = false,
                    jump_labels = true,
                    multi_line = true,
                },
            },
            -- Consistent with global theme
            prompt = {
                enabled = true,
                prefix = { { '⚡', 'FlashPromptIcon' } },
            },
        },
        specs = {
            {
                "folke/snacks.nvim",
                opts = {
                    picker = {
                        win = {
                            input = {
                                keys = {
                                    ["<a-s>"] = { "flash", mode = { "n", "i" } },
                                    ["s"] = { "flash" },
                                },
                            },
                        },
                        actions = {
                            flash = function(picker)
                                require("flash").jump({
                                    pattern = "^",
                                    label = { after = { 0, 0 } },
                                    search = {
                                        mode = "search",
                                        exclude = {
                                            function(win)
                                                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~=
                                                    "snacks_picker_list"
                                            end,
                                        },
                                    },
                                    action = function(match)
                                        local idx = picker.list:row2idx(match.pos[1])
                                        picker.list:_move(idx, true, true)
                                    end,
                                })
                            end,
                        },
                    },
                },
            },
        },
        -- Keys defined in config/keymaps.lua
    },
}
