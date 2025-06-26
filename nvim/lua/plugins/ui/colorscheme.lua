return {
    -- Transparent background support
    {
        'xiyaowong/transparent.nvim',
        lazy = false,   -- Load immediately for transparency
        priority = 900, -- Load before colorschemes
        config = function()
            require('transparent').setup({
                groups = {
                    'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
                    'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String',
                    'Function', 'Conditional', 'Repeat', 'Operator', 'Structure',
                    'LineNr', 'NonText', 'SignColumn', 'CursorLine', 'CursorLineNr',
                    'StatusLine', 'StatusLineNC', 'EndOfBuffer',
                },
                extra_groups = { 'SagaWinbarFile', 'SagaWinbarSep',
                    'SagaWinbarFolder', 'SagaWinbarSymbol', 'BufferLineTabClose',
                    'BufferlineBufferSelected',
                    'BufferLineFill',
                    'BufferLineBackground',
                    'BufferLineSeparator',
                    'BufferLineIndicatorSelected',
                    'WinBar',
                    'WinBarNC',
                    'TreesitterContext',

                    'IndentBlanklineChar',

                    -- make floating windows transparent
                    'LspFloatWinNormal',
                    'Normal',
                    'NormalFloat',
                    'FloatBorder',
                    'TelescopeNormal',
                    'TelescopeBorder',
                    'TelescopePromptBorder',
                    'SagaBorder',
                    'SagaNormal', },
                exclude_groups = {},
            })

            -- Apply transparency if enabled in global config
            require('transparent').clear_prefix('BufferLine')
            require('transparent').clear_prefix('lualine')
            require('transparent').clear_prefix('lspsaga')
        end,
    },

    -- Primary colorscheme - Nightfox family
    {
        "EdenEast/nightfox.nvim",
        name = "nightfox",
        lazy = false,
        priority = 1000,
        config = function()
            require('nightfox').setup({
                options = {
                    compile_path = vim.fn.stdpath("cache") .. "/nightfox",
                    compile_file_suffix = "_compiled",
                    transparent = _G.config and _G.config.theme.transparent_background or false,
                    terminal_colors = true,
                    dim_inactive = false,
                    module_default = true,
                    colorblind = {
                        enable = false,
                        simulate_only = false,
                        severity = {
                            protan = 0,
                            deutan = 0,
                            tritan = 0,
                        },
                    },
                    styles = {
                        comments = _G.config and _G.config.theme.italic_comments and "italic" or "NONE",
                        conditionals = "NONE",
                        constants = "NONE",
                        functions = _G.config and _G.config.theme.bold_functions and "bold" or "NONE",
                        keywords = "bold",
                        numbers = "NONE",
                        operators = "NONE",
                        strings = "NONE",
                        types = "italic,bold",
                        variables = "NONE",
                    },
                    inverse = {
                        match_paren = false,
                        visual = false,
                        search = false,
                    },
                    modules = {
                        -- Plugin integrations
                        aerial = true,
                        barbar = true,
                        cmp = true,
                        diagnostic = {
                            enable = true,
                            background = true,
                        },
                        gitsigns = true,
                        hop = true,
                        indent_blankline = true,
                        lsp_trouble = true,
                        lsp_semantic_tokens = true,
                        native_lsp = {
                            enable = true,
                            background = true,
                        },
                        navic = false,
                        nvimtree = true,
                        symbol_outline = true,
                        telescope = true,
                        treesitter = true,
                        tsrainbow = true,
                        whichkey = true,
                    },
                },
                palettes = {
                    carbonfox = {
                        -- Custom palette adjustments if needed
                        -- These will be overridden by global config colors if set
                    },
                },
                specs = {
                    carbonfox = {
                        -- Custom specifications
                    },
                },
                groups = {
                    carbonfox = {
                        -- Use global config colors if available
                        -- Otherwise fall back to theme defaults
                    },
                },
            })

            -- Set the default colorscheme from global config
            local default_scheme = (_G.config and _G.config.theme.name) or "carbonfox"
            vim.cmd("colorscheme " .. default_scheme)

            -- Create utility functions for theme management
            _G.set_carbonfox = function()
                vim.cmd("colorscheme carbonfox")
                if _G.config then
                    _G.config.theme.name = "carbonfox"
                end
            end

            -- User command for easy access
            vim.api.nvim_create_user_command('Carbonfox', function()
                vim.cmd('colorscheme carbonfox')
            end, { desc = "Switch to Carbonfox theme" })
        end,
    },

    -- Alternative colorscheme - Catppuccin
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = true,
        priority = 900,
        opts = function()
            return {
                flavour = "macchiato", -- latte, frappe, macchiato, mocha
                background = {
                    light = "latte",
                    dark = "macchiato",
                },
                transparent_background = _G.config and _G.config.theme.transparent_background or false,
                show_end_of_buffer = false,
                term_colors = true,
                dim_inactive = {
                    enabled = false,
                    shade = "dark",
                    percentage = 0.15,
                },
                no_italic = not (_G.config and _G.config.theme.italic_comments),
                no_bold = false,
                no_underline = false,
                styles = {
                    comments = { "italic" },
                    conditionals = { "italic" },
                    loops = {},
                    functions = {},
                    keywords = {},
                    strings = {},
                    variables = {},
                    numbers = {},
                    booleans = {},
                    properties = {},
                    types = {},
                    operators = {},
                },
                color_overrides = {},
                custom_highlights = function(colors)
                    -- Use global config colors if available
                    if _G.config and _G.config.colors then
                        return {
                            -- Example of using global colors
                            CursorLine = { bg = colors.surface0 },
                            -- Add more custom highlights based on global config
                        }
                    end
                    return {}
                end,
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    nvimtree = true,
                    treesitter = true,
                    telescope = {
                        enabled = true,
                        style = "nvchad"
                    },
                    lsp_trouble = true,
                    which_key = true,
                    indent_blankline = {
                        enabled = true,
                        colored_indent_levels = false,
                    },
                    native_lsp = {
                        enabled = true,
                        virtual_text = {
                            errors = { "italic" },
                            hints = { "italic" },
                            warnings = { "italic" },
                            information = { "italic" },
                        },
                        underlines = {
                            errors = { "underline" },
                            hints = { "underline" },
                            warnings = { "underline" },
                            information = { "underline" },
                        },
                        inlay_hints = {
                            background = true,
                        },
                    },
                    noice = true,
                    notify = true,
                    mason = true,
                    -- Add more integrations as needed
                },
            }
        end,
        config = function(_, opts)
            require("catppuccin").setup(opts)

            -- Create utility function
            _G.set_catppuccin = function(flavour)
                flavour = flavour or "macchiato"
                vim.cmd("colorscheme catppuccin-" .. flavour)
                if _G.config then
                    _G.config.theme.name = "catppuccin-" .. flavour
                end
            end

            -- User commands
            vim.api.nvim_create_user_command('Catppuccin', function(opts)
                local flavour = opts.args ~= "" and opts.args or "macchiato"
                _G.set_catppuccin(flavour)
            end, {
                nargs = '?',
                complete = function()
                    return { "latte", "frappe", "macchiato", "mocha" }
                end,
                desc = "Switch to Catppuccin theme with optional flavour"
            })
        end,
    },

    -- VSCode theme for familiarity
    {
        'Mofiqul/vscode.nvim',
        name = "vscode",
        lazy = true,
        priority = 900,
        config = function()
            local c = require('vscode.colors').get_colors()
            require('vscode').setup({
                -- Alternatively set style in setup
                -- style = 'light'

                -- Enable transparent background
                transparent = false,

                -- Enable italic comment
                italic_comments = true,

                -- Underline `@markup.link.*` variants
                underline_links = true,

                -- Disable nvim-tree background color
                disable_nvimtree_bg = true,

                -- Apply theme colors to terminal
                terminal_colors = true,

                -- Override colors (see ./lua/vscode/colors.lua)
                color_overrides = {
                    vscLineNumber = '#FFFFFF',
                },

                -- Override highlight groups (see ./lua/vscode/theme.lua)
                group_overrides = {
                    -- this supports the same val table as vim.api.nvim_set_hl
                    -- use colors from this colorscheme by requiring vscode.colors!
                    Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
                }
            })
            require("vscode").load()
        end
    },

    -- Additional theme options (loaded on demand)
    {
        "folke/tokyonight.nvim",
        lazy = true,
        priority = 900,
        opts = function()
            return {
                style = "night", -- storm, moon, night, day
                transparent = _G.config and _G.config.theme.transparent_background or false,
                terminal_colors = true,
                styles = {
                    comments = { italic = _G.config and _G.config.theme.italic_comments or true },
                    keywords = { italic = true },
                    functions = {},
                    variables = {},
                },
                sidebars = { "qf", "help", "vista_kind", "terminal", "packer" },
                day_brightness = 0.3,
                hide_inactive_statusline = false,
                dim_inactive = false,
                lualine_bold = false,
            }
        end,
    },

    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = true,
        priority = 900,
        opts = function()
            return {
                variant = "auto", -- auto, main, moon, or dawn
                dark_variant = "main",
                bold_vert_split = false,
                dim_nc_background = false,
                disable_background = _G.config and _G.config.theme.transparent_background or false,
                disable_float_background = false,
                groups = {
                    -- Use global config colors if available
                    background = (_G.config and _G.config.colors.background) or "base",
                    panel = "surface",
                    border = "highlight_med",
                    comment = "muted",
                    link = "iris",
                    punctuation = "subtle",
                },
                highlight_groups = {
                    -- Custom highlights using global config
                }
            }
        end,
    },
    {
        "scottmckendry/cyberdream.nvim",
        lazy = false,
        priority = 1000,
    },
}

-- vim: ts=2 sts=2 sw=2 et
