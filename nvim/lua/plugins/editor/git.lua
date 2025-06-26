return {
    -- Git signs and blame integration
    {
        'lewis6991/gitsigns.nvim',
        event = { 'BufNewFile', 'BufReadPre' },
        config = function()
            require('gitsigns').setup({
                signs = {
                    add          = { text = _G.config.icons.git.added },
                    change       = { text = _G.config.icons.git.modified },
                    delete       = { text = _G.config.icons.git.removed },
                    topdelete    = { text = _G.config.icons.git.removed },
                    changedelete = { text = _G.config.icons.git.modified },
                    untracked    = { text = _G.config.icons.git.untracked },
                },

                signs_staged = {
                    add          = { text = _G.config.icons.git.staged },
                    change       = { text = _G.config.icons.git.staged },
                    delete       = { text = _G.config.icons.git.staged },
                    topdelete    = { text = _G.config.icons.git.staged },
                    changedelete = { text = _G.config.icons.git.staged },
                },

                -- ADHD-friendly: Reduce visual noise
                signcolumn = true,
                numhl = false,     -- Don't highlight line numbers
                linehl = false,    -- Don't highlight entire lines
                word_diff = false, -- Keep it simple

                -- Performance optimization
                watch_gitdir = {
                    follow_files = true
                },
                attach_to_untracked = true,
                current_line_blame = false, -- Toggle with keymap instead
                current_line_blame_opts = {
                    virt_text = true,
                    virt_text_pos = 'eol', -- end of line
                    delay = 300,           -- Faster for ADHD
                    ignore_whitespace = false,
                },
                current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',

                sign_priority = 6,
                update_debounce = 100,   -- Faster updates
                status_formatter = nil,  -- Use default
                max_file_length = 40000, -- Performance: Don't attach to huge files

                preview_config = {
                    -- Options passed to nvim_open_win
                    border = _G.config.ui.border,
                    style = 'minimal',
                    relative = 'cursor',
                    row = 0,
                    col = 1
                },

                -- Store gitsigns reference globally for keymaps
                on_attach = function(bufnr)
                    _G.gitsigns = package.loaded.gitsigns
                end
            })
        end,
    },
}

-- vim: ts=2 sts=2 sw=2 et
