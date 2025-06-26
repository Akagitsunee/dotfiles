-- ~/.config/nvim/lua/config/lazy.lua
-- Bootstrap lazy.nvim plugin manager

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Auto-install lazy.nvim if not present
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

-- Add lazy.nvim to runtime path
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim with ADHD-friendly configuration
require("lazy").setup({
    -- Plugin specifications directory
    spec = {
        -- Import all plugin configurations from plugins/ directory
        { import = "plugins.core" },      -- Essential functionality
        { import = "plugins.editor" },    -- Text manipulation
        { import = "plugins.tools" },     -- Specialized utilities
        { import = "plugins.languages" }, -- Language-specific tools
        { import = "plugins.ui" },        -- Visual interface
    },

    -- ADHD-Friendly Configuration Options
    defaults = {
        lazy = false,    -- Don't lazy-load by default (we'll be explicit)
        version = false, -- Don't use version pinning by default
    },

    -- Installation settings
    install = {
        missing = true,                          -- Install missing plugins on startup
        colorscheme = { "nightfox", "habamax" }, -- Try these colorschemes during install
    },

    -- UI Configuration - matches your global design system
    ui = {
        -- Use global border setting if available, fallback to rounded
        border = _G.config and _G.config.ui.border or "rounded",
        size = { width = 0.8, height = 0.8 },
        wrap = true,
        -- Custom icons (will be overridden by global config when available)
        icons = {
            cmd = '⌘',
            config = '🛠',
            event = '📅',
            ft = '📂',
            init = '⚙',
            keys = '🗝',
            plugin = '🔌',
            runtime = '💻',
            require = '🌙',
            source = '📄',
            start = '🚀',
            task = '📌',
            lazy = '💤 ',
            import = " ",
            loaded = "●",
            not_loaded = "○",
            list = {
                "●",
                "➜",
                "★",
                "‒",
            },
        },
    },

    -- Performance optimization
    performance = {
        cache = {
            enabled = true,
        },
        reset_packpath = true,
        rtp = {
            reset = true,
            paths = {},
            disabled_plugins = {
                -- Disable built-in plugins we don't need
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },

    -- Development settings
    dev = {
        path = "~/projects", -- Path where you keep your plugin development
        patterns = {},       -- Patterns for local plugin development
        fallback = false,    -- Fallback to git when local plugin doesn't exist
    },

    -- Profiling and debugging
    profiling = {
        loader = false,
        require = false,
    },

    -- Change detection
    change_detection = {
        enabled = true,
        notify = false, -- Don't notify about config changes (reduces noise)
    },

    -- Checker settings
    checker = {
        enabled = false, -- Don't automatically check for plugin updates
        concurrency = nil,
        notify = true,
        frequency = 3600, -- Check every hour when enabled
    },
})

-- Set up global lazy loading helpers for plugins
_G.lazy_load = function(plugin, timer)
    if timer then
        vim.defer_fn(function()
            require("lazy").load({ plugins = { plugin } })
        end, timer)
    else
        require("lazy").load({ plugins = { plugin } })
    end
end
