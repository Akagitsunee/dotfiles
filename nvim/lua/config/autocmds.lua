-- ╭─────────────────────────────────────────────────────────╮
-- │             ADHD-FRIENDLY AUTOCOMMANDS                 │
-- │   Organized for clarity and cognitive load reduction    │
-- ╰─────────────────────────────────────────────────────────╯

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ============================================================================
-- 🎯 AUGROUP DEFINITIONS - Organized by functional area
-- ============================================================================

local groups = {
    ui_enhancements = augroup('UIEnhancements', { clear = true }),
    file_management = augroup('FileManagement', { clear = true }),
    formatting = augroup('Formatting', { clear = true }),
    focus_management = augroup('FocusManagement', { clear = true }),
    performance = augroup('Performance', { clear = true }),
    general = augroup('General', { clear = true }),
}

-- Helper function to restore view (prevents folding collapse)
local function restore_view()
    vim.schedule(function()
        if vim.fn.winsaveview then
            local view = vim.fn.winsaveview()
            vim.fn.winrestview(view)
        end
    end)
end

-- ============================================================================
-- 🎨 UI ENHANCEMENTS - Visual feedback and clarity for ADHD brains
-- ============================================================================

-- Highlight yanked text - immediate visual feedback for copy operations
autocmd('TextYankPost', {
    group = groups.ui_enhancements,
    desc = 'Highlight yanked text for visual feedback',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch', -- Use search highlight color
            timeout = 300,         -- Brief flash - not distracting
        })
    end,
})

-- Clear search highlights on cursor move - reduces visual clutter
autocmd('CursorMoved', {
    group = groups.ui_enhancements,
    desc = 'Clear search highlights when cursor moves (reduces visual noise)',
    callback = function()
        if vim.v.hlsearch == 1 and vim.fn.searchcount().current == 0 then
            vim.cmd.nohlsearch()
        end
    end,
})


-- Make the TSContext the same color as the background
local function set_treesitter_context_bg()
    local ok, normal = pcall(vim.api.nvim_get_hl, 0, { name = "Normal" })
    if ok and normal and normal.bg then
        vim.api.nvim_set_hl(0, "TreesitterContext", { bg = string.format("#%06x", normal.bg) })
    else
        vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "NONE" })
    end
end

-- 🔁 Run after each colorscheme change
autocmd("ColorScheme", {
    pattern = "*",
    callback = set_treesitter_context_bg,
})

-- ▶️ Also run immediately at startup (important!)
vim.schedule(set_treesitter_context_bg)

-- Auto-resize splits when window is resized - maintains visual proportions
autocmd('VimResized', {
    group = groups.ui_enhancements,
    desc = 'Auto-resize all splits to maintain proportions',
    callback = function()
        vim.schedule(function()
            vim.cmd('wincmd =') -- Equalize all windows
        end)
    end,
})

-- Auto-close helper windows with 'q' - reduces cognitive overhead
autocmd('FileType', {
    group = groups.ui_enhancements,
    pattern = {
        'help', 'qf', 'query', 'spectre_panel', 'startuptime',
        'tsplayground', 'PlenaryTestPopup', 'notify', 'lspinfo',
        'man', 'checkhealth', 'neotest-output', 'neotest-summary',
        'neotest-output-panel'
    },
    desc = 'Enable quick close with "q" for helper windows',
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set('n', 'q', '<cmd>close<cr>', {
            buffer = event.buf,
            silent = true,
            desc = 'Close this helper window'
        })
    end,
})

-- ============================================================================
-- 💾 FILE MANAGEMENT - Automatic saving and file handling
-- ============================================================================

-- Auto-save on focus loss - prevents work loss during ADHD context switching
autocmd({ 'FocusLost', 'BufLeave' }, {
    group = groups.file_management,
    desc = 'Auto-save modified files when losing focus (ADHD-friendly)',
    callback = function()
        -- Only save if auto_save is enabled and conditions are met
        if _G.config and _G.config.behavior and _G.config.behavior.auto_save then
            if vim.bo.modified and vim.fn.expand('%') ~= '' and not vim.bo.readonly then
                pcall(vim.cmd.write) -- Safe save - won't error on read-only files
            end
        end
    end,
})

-- Restore cursor position - return to where you were working
autocmd('BufReadPost', {
    group = groups.file_management,
    desc = 'Restore cursor to last known position when reopening files',
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local line_count = vim.api.nvim_buf_line_count(0)

        -- Only restore if mark is valid and within file bounds
        if mark[1] > 0 and mark[1] <= line_count then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
            vim.cmd('normal! zz') -- Center the restored position
        end
    end,
})

-- Create directories automatically when saving new files
autocmd('BufWritePre', {
    group = groups.file_management,
    desc = 'Create parent directories if they don\'t exist when saving',
    callback = function()
        local dir = vim.fn.expand('<afile>:p:h')
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, 'p')
        end
    end,
})

-- Auto-reload files changed outside of Neovim
autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
    group = groups.file_management,
    desc = 'Check for external file changes and reload if needed',
    callback = function()
        vim.cmd('checktime')
    end,
})

-- ============================================================================
-- ✨ FORMATTING - Code quality and consistency
-- ============================================================================

-- Format on save - uses global config setting
autocmd('BufWritePre', {
    group = groups.formatting,
    desc = 'Format code on save (respects global format_on_save setting)',
    callback = function()
        if _G.config and _G.config.behavior and _G.config.behavior.format_on_save then
            -- Try conform.nvim first, fallback to LSP formatting
            local conform_ok, conform = pcall(require, 'conform')
            if conform_ok then
                conform.format({
                    async = false,
                    timeout_ms = 1000,
                    lsp_fallback = true,
                })
            else
                -- Fallback to LSP formatting
                vim.lsp.buf.format({
                    async = false,
                    timeout_ms = 1000,
                })
            end
        end

        -- Restore view to prevent folding collapse
        restore_view()
    end,
})

-- Remove trailing whitespace for code files
autocmd('BufWritePre', {
    group = groups.formatting,
    pattern = { '*.lua', '*.js', '*.ts', '*.jsx', '*.tsx', '*.py', '*.java', '*.go', '*.rs' },
    desc = 'Remove trailing whitespace on save for code files',
    callback = function()
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[%s/\s\+$//e]])                          -- Remove trailing whitespace
        pcall(vim.api.nvim_win_set_cursor, 0, cursor_pos) -- Restore cursor
    end,
})

-- Auto-lint after changes (if nvim-lint is available)
autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
    group = groups.formatting,
    desc = 'Run linting after file changes',
    callback = function()
        local lint_ok, lint = pcall(require, 'lint')
        if lint_ok then
            lint.try_lint()
        end
    end,
})

-- ============================================================================
-- 🎯 FOCUS MANAGEMENT - ADHD-specific visual focus aids
-- ============================================================================

-- Show cursor line only in active window - reduces visual confusion
autocmd({ 'WinEnter', 'BufWinEnter' }, {
    group = groups.focus_management,
    desc = 'Show cursor line in active window only',
    callback = function()
        if vim.wo.number then -- Only if line numbers are enabled
            vim.wo.cursorline = true
        end
    end,
})

-- Hide cursor line in inactive windows
autocmd({ 'WinLeave', 'BufWinLeave' }, {
    group = groups.focus_management,
    desc = 'Hide cursor line in inactive windows',
    callback = function()
        vim.wo.cursorline = false
    end,
})

-- Auto-enter insert mode for commit messages - reduces mode switching
autocmd('BufWinEnter', {
    group = groups.focus_management,
    desc = 'Auto-enter insert mode for git commit messages',
    callback = function()
        local filetype = vim.bo.filetype
        local filename = vim.fn.expand('%:t')

        -- Auto-insert for git commit messages
        if filetype == 'gitcommit' or
            filename:match('^COMMIT_EDITMSG') or
            filename:match('^MERGE_MSG') then
            vim.cmd('startinsert')
        end
    end,
})

-- Show diagnostic float on cursor hold - contextual error information
autocmd('CursorHold', {
    group = groups.focus_management,
    desc = 'Show diagnostic information when cursor is idle',
    callback = function()
        vim.diagnostic.open_float(nil, {
            focusable = false,
            border = _G.config and _G.config.ui and _G.config.ui.border or 'rounded'
        })
    end,
})

-- ============================================================================
-- ⚡ PERFORMANCE OPTIMIZATIONS - Keep Neovim responsive
-- ============================================================================

-- Optimize for large files - disable expensive features
autocmd('BufReadPre', {
    group = groups.performance,
    desc = 'Optimize settings for large files (>1MB)',
    callback = function()
        local max_filesize = 1024 * 1024 -- 1MB threshold
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))

        if ok and stats and stats.size > max_filesize then
            -- Disable expensive features for large files
            vim.opt_local.eventignore:append({
                'FileType', 'Syntax', 'BufReadPost', 'BufReadPre'
            })
            vim.opt_local.undolevels = -1       -- Disable undo history
            vim.opt_local.swapfile = false      -- Disable swap file
            vim.opt_local.foldmethod = 'manual' -- Simple folding
            vim.opt_local.syntax = ''           -- Disable syntax highlighting

            vim.notify(
                'Large file detected. Some features disabled for performance.',
                vim.log.levels.WARN,
                { title = 'Performance Mode' }
            )
        end
    end,
})


-- local toggle_inlay_hints = function(enable)
--     vim.lsp.inlay_hint.enable(enable, { bufnr = 0 })
-- end

-- autocmd("InsertEnter", {
--     callback = function() toggle_inlay_hints(false) end,
-- })

-- autocmd("InsertLeave", {
--    callback = function() toggle_inlay_hints(true) end,
-- })


-- ============================================================================
-- 🔧 TERMINAL AND SPECIAL BUFFER SETTINGS
-- ============================================================================

-- Optimize terminal buffer settings
autocmd('TermOpen', {
    group = groups.general,
    desc = 'Configure terminal buffers for better UX',
    callback = function()
        vim.opt_local.number = false         -- No line numbers in terminal
        vim.opt_local.relativenumber = false -- No relative line numbers
        vim.opt_local.signcolumn = 'no'      -- No sign column
        vim.opt_local.spell = false          -- No spell checking
        vim.opt_local.wrap = false           -- No line wrapping

        vim.cmd('startinsert')               -- Start in insert mode

        -- Easy escape from terminal mode
        vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', {
            buffer = true,
            desc = 'Exit terminal mode'
        })
    end,
})

-- ============================================================================
-- 🚀 STARTUP AND CONFIGURATION MANAGEMENT
-- ============================================================================

-- Reload configuration on save
autocmd('BufWritePost', {
    group = groups.general,
    pattern = vim.fn.expand('$MYVIMRC'),
    desc = 'Reload Neovim configuration when init.lua is saved',
    callback = function()
        vim.cmd('source $MYVIMRC')
        vim.notify('Configuration reloaded!', vim.log.levels.INFO, {
            title = 'Neovim Config'
        })
    end,
})

local reload_group = vim.api.nvim_create_augroup("ConfigHotReload", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
    group = reload_group,
    pattern = { "*/config/globals.lua", "*/config/options.lua" },
    callback = function()
        for _, module in ipairs({ "config.globals", "config.options" }) do
            package.loaded[module] = nil
            local ok, err = pcall(require, module)
            if not ok then
                vim.notify("Hot reload failed: " .. module .. "\n" .. err, vim.log.levels.ERROR)
                return
            end
        end
        vim.notify("Hot reloaded globals and options!", vim.log.levels.INFO)
    end,
    desc = "Hot reload globals.lua/options.lua on save",
})
-- Post-startup optimizations
autocmd('VimEnter', {
    group = groups.general,
    desc = 'Post-startup optimizations and setup',
    callback = function()
        -- Re-enable syntax if it was disabled during startup
        if vim.g.syntax_on ~= 1 then
            vim.cmd('syntax enable')
        end

        -- Schedule additional ADHD-friendly features
        vim.schedule(function()
            -- Enable spell checking for text files
            local text_filetypes = { 'markdown', 'text', 'gitcommit' }
            if vim.tbl_contains(text_filetypes, vim.bo.filetype) then
                vim.opt_local.spell = true
                vim.opt_local.spelllang = 'en_us'
            end
        end)
    end,
})

-- Disable auto-comment continuation
autocmd('FileType', {
    group = groups.general,
    pattern = '*',
    desc = 'Disable automatic comment continuation',
    callback = function()
        vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' })
    end,
})

-- ============================================================================
-- 🔍 LSP AND CODE ACTION ENHANCEMENTS
-- ============================================================================

-- Prevent folding collapse after LSP actions
autocmd('LspAttach', {
    group = groups.general,
    desc = 'Maintain fold state after LSP attachment',
    callback = function()
        restore_view()
    end,
})

-- Prevent folding collapse after code actions
autocmd('User', {
    group = groups.general,
    pattern = 'LspCodeAction',
    desc = 'Maintain fold state after LSP code actions',
    callback = function()
        restore_view()
    end,
})

-- ============================================================================
-- 📝 HELPFUL NOTIFICATIONS AND FEEDBACK
-- ============================================================================

-- Notify about successful auto-saves (optional - can be disabled if too noisy)
autocmd('BufWritePost', {
    group = groups.file_management,
    desc = 'Show brief notification for auto-saves',
    callback = function()
        if _G.config and _G.config.behavior and _G.config.behavior.auto_save then
            local filename = vim.fn.expand('%:t')
            if filename ~= '' then
                vim.notify('💾 ' .. filename, vim.log.levels.INFO, {
                    title = 'Auto-saved',
                    timeout = 1000, -- Brief notification
                })
            end
        end
    end,
})

-- ============================================================================
-- 🛠️ DEVELOPMENT AND DEBUGGING HELPERS
-- ============================================================================

-- Enable auto-read for file changes (useful during development)
vim.opt.autoread = true

-- Set up global options that support the autocommands above
vim.schedule(function()
    -- Ensure diagnostic settings align with autocommands
    vim.diagnostic.config({
        float = {
            border = _G.config and _G.config.ui and _G.config.ui.border or 'rounded',
            source = 'always',
            header = '',
            prefix = '',
        },
        virtual_text = _G.config and _G.config.lsp and _G.config.lsp.virtual_text or false,
        signs = _G.config and _G.config.lsp and _G.config.lsp.signs or true,
        update_in_insert = _G.config and _G.config.lsp and _G.config.lsp.update_in_insert or false,
        severity_sort = _G.config and _G.config.lsp and _G.config.lsp.severity_sort or false,
    })
end)

-- vim: ts=2 sts=2 sw=2 et
