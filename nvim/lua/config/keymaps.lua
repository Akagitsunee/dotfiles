local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
local Snacks = require("snacks")

-- Helper function to merge opts with desc
local function desc_opts(description, extra_opts)
    local merged = vim.tbl_extend("force", opts, { desc = description })
    if extra_opts then
        merged = vim.tbl_extend("force", merged, extra_opts)
    end
    return merged
end

-- ╭─────────────────────────────────────────────────────────╮
-- │                         LAZY                            │
-- ╰─────────────────────────────────────────────────────────╯

keymap("n", "<leader>l", "<cmd>Lazy<cr>", desc_opts("Lazy Plugin Manager"))
keymap("n", "<leader>lc", "<cmd>Lazy check<cr>", desc_opts("Lazy Check Updates"))
keymap("n", "<leader>lu", "<cmd>Lazy update<cr>", desc_opts("Lazy Update Plugins"))
keymap("n", "<leader>ls", "<cmd>Lazy sync<cr>", desc_opts("Lazy Sync Plugins"))
keymap("n", "<leader>lp", "<cmd>Lazy profile<cr>", desc_opts("Lazy Profile Startup"))
keymap("n", "<leader>ld", "<cmd>Lazy debug<cr>", desc_opts("Lazy Debug"))

-- ╭─────────────────────────────────────────────────────────╮
-- │                      ESSENTIALS                         │
-- ╰─────────────────────────────────────────────────────────╯

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", desc_opts("Move focus to the left window"))
keymap("n", "<C-j>", "<C-w>j", desc_opts("Move focus to the lower window"))
keymap("n", "<C-k>", "<C-w>k", desc_opts("Move focus to the upper window"))
keymap("n", "<C-l>", "<C-w>l", desc_opts("Move focus to the right window"))

-- Resize windows with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", desc_opts("Decrease window height"))
keymap("n", "<C-Down>", ":resize +2<CR>", desc_opts("Increase window height"))
keymap("n", "<C-Left>", ":vertical resize -2<CR>", desc_opts("Decrease window width"))
keymap("n", "<C-Right>", ":vertical resize +2<CR>", desc_opts("Increase window width"))

-- Buffer navigation
keymap("n", "<S-l>", ":bnext<CR>", desc_opts("Go to next buffer"))
keymap("n", "<S-h>", ":bprevious<CR>", desc_opts("Go to previous buffer"))

-- =============================================================================
-- 💾 WRITE & QUIT
-- =============================================================================
keymap("n", "<leader>w", ":w<CR>", desc_opts("Write (Save)"))
keymap("n", "<leader>q", ":q<CR>", desc_opts("Quit Window"))
keymap("n", "<leader>wq", ":x<CR>", desc_opts("Write & Quit"))
keymap("n", "<leader>qq", ":qa<CR>", desc_opts("Quit All"))

-- =============================================================================
-- פּ TEXT MANIPULATION
-- =============================================================================
keymap({ "n", "v" }, "<leader>ty", "\"+y", desc_opts("Yank to system clipboard"))
keymap("n", "<leader>tY", "\"+Y", desc_opts("Yank line to system clipboard"))
keymap({ "n", "v" }, "<leader>tdx", [["_d]], desc_opts("Delete without yanking (to void)"))
keymap('n', '<leader>tdu', '0Yo<Esc>P', desc_opts("Duplicate line"))
keymap('n', '<leader>ta', 'ggVG', desc_opts("Select all"))
keymap('n', '<leader>tp', 'ggVGp', desc_opts("Paste over whole file"))

-- =============================================================================
-- 🔍 SEARCH
-- =============================================================================
keymap("n", "<leader>sc", ":nohlsearch<CR>", desc_opts("Clear search highlights"))
keymap("n", "n", "nzzzv", desc_opts("Next search result centered"))
keymap("n", "N", "Nzzzv", desc_opts("Previous search result centered"))

-- ============================================================================
--   GIT KEYMAPS (Gitsigns)
-- ============================================================================

-- Helper function to safely call gitsigns functions
local function gitsigns_action(action)
    return function()
        if _G.gitsigns then
            return _G.gitsigns[action]()
        else
            vim.notify("Gitsigns not loaded", vim.log.levels.WARN)
        end
    end
end

-- Navigation between hunks
keymap('n', ']c', function()
    if vim.wo.diff then
        return ']c'
    end
    vim.schedule(gitsigns_action('next_hunk'))
    return '<Ignore>'
end, desc_opts("Next git hunk", { expr = true }))

keymap('n', '[c', function()
    if vim.wo.diff then
        return '[c'
    end
    vim.schedule(gitsigns_action('prev_hunk'))
    return '<Ignore>'
end, desc_opts("Previous git hunk", { expr = true }))

-- Git actions with leader+g prefix
keymap('n', '<leader>gs', gitsigns_action('stage_hunk'), desc_opts("Stage hunk"))
keymap('n', '<leader>gr', gitsigns_action('reset_hunk'), desc_opts("Reset hunk"))

-- Visual mode staging/resetting
keymap('v', '<leader>gs', function()
    if _G.gitsigns then
        _G.gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end
end, desc_opts("Stage hunk (visual)"))

keymap('v', '<leader>gr', function()
    if _G.gitsigns then
        _G.gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end
end, desc_opts("Reset hunk (visual)"))

-- Buffer-level operations
keymap('n', '<leader>gS', gitsigns_action('stage_buffer'), desc_opts("Stage entire buffer"))
keymap('n', '<leader>gu', gitsigns_action('undo_stage_hunk'), desc_opts("Undo stage hunk"))
keymap('n', '<leader>gR', gitsigns_action('reset_buffer'), desc_opts("Reset entire buffer"))

-- Preview and blame
keymap('n', '<leader>gp', gitsigns_action('preview_hunk'), desc_opts("Preview hunk"))
keymap('n', '<leader>gb', function()
    if _G.gitsigns then
        _G.gitsigns.blame_line({ full = true })
    end
end, desc_opts("Blame line (full)"))
keymap('n', '<leader>gB', gitsigns_action('toggle_current_line_blame'), desc_opts("Toggle line blame"))

-- Diff operations
keymap('n', '<leader>gd', gitsigns_action('diffthis'), desc_opts("Diff this"))
keymap('n', '<leader>gD', function()
    if _G.gitsigns then
        _G.gitsigns.diffthis('~')
    end
end, desc_opts("Diff this (cached)"))

-- Text object for git hunks
keymap({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', desc_opts("Select git hunk"))

-- ADHD-friendly: Quick toggle for visual helpers
keymap('n', '<leader>gt', gitsigns_action('toggle_signs'), desc_opts("Toggle git signs"))
keymap('n', '<leader>gw', gitsigns_action('toggle_word_diff'), desc_opts("Toggle word diff"))
keymap('n', '<leader>gl', gitsigns_action('toggle_linehl'), desc_opts("Toggle line highlight"))

-- =============================================================================
-- 🎯 LSP KEYMAPS (Using LSP Saga)
-- =============================================================================
-- 📋 Diagnostic Navigation
keymap('n', '[d', '<cmd>Lspsaga diagnostic_jump_prev<CR>', desc_opts("Previous diagnostic"))
keymap('n', ']d', '<cmd>Lspsaga diagnostic_jump_next<CR>', desc_opts("Next diagnostic"))

-- 🔍 Show Diagnostics
keymap('n', '<leader>cd', '<cmd>Lspsaga show_line_diagnostics<CR>', desc_opts("Show line diagnostics"))
keymap('n', '<leader>cD', '<cmd>Lspsaga show_cursor_diagnostics<CR>', desc_opts("Show cursor diagnostics"))

-- ⚡ Code Actions
keymap('n', '<leader>ca', '<cmd>Lspsaga code_action<CR>', desc_opts("Code action"))
keymap('v', '<leader>ca', '<cmd>Lspsaga code_action<CR>', desc_opts("Code action (visual)"))

-- 🏷️ Smart Rename
keymap('n', '<leader>cr', '<cmd>Lspsaga rename<CR>', desc_opts("Rename symbol"))
keymap('n', '<leader>cR', '<cmd>Lspsaga rename ++project<CR>', desc_opts("Rename symbol in project"))

-- 📖 Hover Documentation
keymap('n', 'K', '<cmd>Lspsaga hover_doc<CR>', desc_opts("Hover documentation"))
keymap('n', '<leader>K', '<cmd>Lspsaga hover_doc ++keep<CR>', desc_opts("Persistent hover doc"))

-- 🎯 Definition & Type Definition
keymap('n', 'gd', '<cmd>Lspsaga goto_definition<CR>', desc_opts("Go to definition"))
keymap('n', 'gD', '<cmd>Lspsaga peek_definition<CR>', desc_opts("Peek definition"))
keymap('n', 'gt', '<cmd>Lspsaga goto_type_definition<CR>', desc_opts("Go to type definition"))
keymap('n', 'gT', '<cmd>Lspsaga peek_type_definition<CR>', desc_opts("Peek type definition"))

-- 🔍 Find References & Implementations
keymap('n', 'gr', '<cmd>Lspsaga finder<CR>', desc_opts("Find references and definitions"))
keymap('n', 'gR', '<cmd>Lspsaga finder ref<CR>', desc_opts("Find references only"))
keymap('n', 'gi', '<cmd>Lspsaga finder imp<CR>', desc_opts("Find implementations"))

-- 📋 Outline & Structure
keymap('n', '<leader>co', '<cmd>Lspsaga outline<CR>', desc_opts("Show document outline"))

-- 📞 Call Hierarchy
keymap('n', '<leader>ch', '<cmd>Lspsaga incoming_calls<CR>', desc_opts("Show incoming calls"))
keymap('n', '<leader>cH', '<cmd>Lspsaga outgoing_calls<CR>', desc_opts("Show outgoing calls"))

-- =============================================================================
-- 🔧 FORMATTING & LINTING
-- =============================================================================

-- Toggle format on save
keymap("n", "<leader>cF", "<cmd>FormatToggle<cr>", desc_opts("Toggle format on save"))

keymap({ "n", "v" }, "<leader>cf", function()
    -- This will be available after conform.nvim loads
    local conform_ok, conform = pcall(require, "conform")
    if conform_ok then
        conform.format({
            timeout_ms = 1000,
            lsp_fallback = true,
        })
    else
        -- Fallback to LSP formatting if conform isn't loaded yet
        vim.lsp.buf.format({ async = true })
    end
end, desc_opts("Format buffer/selection"))

keymap("n", "<leader>cl", function()
    local lint_ok, lint = pcall(require, "lint")
    if lint_ok then
        lint.try_lint()
    else
        require("notify")("nvim-lint not loaded", "warn")
    end
end, desc_opts("Lint current buffer"))

-- Show linter info for current filetype
keymap("n", "<leader>cL", "<cmd>LintInfo<cr>", desc_opts("Show linter info"))

-- =============================================================================
-- 🗂️ FILE MANAGEMENT
-- =============================================================================
-- File explorer (Oil.nvim)
keymap("n", "<leader>e", ":Oil<CR>", desc_opts("Open Oil file explorer"))

-- =============================================================================
-- 🔭 Snacks Picker (Fuzzy Finding)
-- =============================================================================

-- File Operation
keymap("n", "<leader>ff", function() Snacks.picker.files() end, desc_opts("Find files"))
keymap("n", "<leader>fg", function() Snacks.picker.grep() end, desc_opts("Find (Grep) in files"))
keymap("n", "<leader>fb", function() Snacks.picker.buffers() end, desc_opts("Find buffers"))
keymap("n", "<leader>fh", function() Snacks.picker.help() end, desc_opts("Find help"))
keymap("n", "<leader>fk", function() Snacks.picker.keymaps() end, desc_opts("Find keymaps"))
keymap("n", "<leader>fr", function() Snacks.picker.oldfiles() end, desc_opts("Recent files"))
keymap("n", "<leader>fc", function() Snacks.picker.commands() end, desc_opts("Command palette"))
keymap("n", "<leader>fw", function() Snacks.picker.grep_word() end, desc_opts("Live grep string"))

-- ========================================
-- ⚡ FLASH NAVIGATION KEYMAPS
-- ========================================

-- Flash jump keymaps (lazy loaded)
keymap({ "n", "x", "o" }, "s", function()
    require("flash").jump()
end, desc_opts("Flash Jump"))

keymap({ "n", "x", "o" }, "S", function()
    require("flash").treesitter()
end, desc_opts("Flash Treesitter"))

keymap("o", "r", function()
    require("flash").remote()
end, desc_opts("Remote Flash"))

keymap({ "o", "x" }, "R", function()
    require("flash").treesitter_search()
end, desc_opts("Treesitter Search"))

keymap("c", "<c-s>", function()
    require("flash").toggle()
end, desc_opts("Toggle Flash Search"))

-- =============================================================================
-- 🌈 THEME SWITCHING
-- =============================================================================

keymap("n", "<leader>uc", function() require("snacks").picker.colorschemes() end, desc_opts("Toggle color scheme"))

-- =============================================================================
-- 🌈 UI toggles
-- =============================================================================
keymap('n', '<leader>ut', ':TransparentToggle<CR>', desc_opts("Toggle Transparency"))
keymap('n', '<leader>uz', ':ZenMode<CR>', desc_opts("Toggle Zen Mode"))
keymap('n', '<leader>ur', function()
    vim.wo.relativenumber = not vim.wo.relativenumber
end, desc_opts("Toggle relative number"))

keymap('n', '<leader>uo', function()
    vim.opt.scrolloff = 999 - vim.o.scrolloff
end, desc_opts("Toggle center cursor"))

keymap('n', '<leader>uh', function()
    local buf = vim.api.nvim_get_current_buf()
    local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
    vim.lsp.inlay_hint.enable(not enabled, { bufnr = buf })
end, desc_opts("Toggle Inlay Hints"))

local signs = {
    text = {
        [vim.diagnostic.severity.ERROR] = _G.config.icons.diagnostics.error,
        [vim.diagnostic.severity.WARN] = _G.config.icons.diagnostics.warn,
        [vim.diagnostic.severity.INFO] = _G.config.icons.diagnostics.info,
        [vim.diagnostic.severity.HINT] = _G.config.icons.diagnostics.hint,
    },
}

keymap('n', '<leader>ue', function()
    local diagnostic_virtual_text_enabled = vim.diagnostic.config().virtual_text
    if not diagnostic_virtual_text_enabled then
        -- Enable only ESLint diagnostics
        vim.diagnostic.config({
            virtual_text = true,
            signs = signs,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
        })
    else
        -- Disable all diagnostics
        vim.diagnostic.config({
            virtual_text = false,
            signs = signs,
            underline = false,
            update_in_insert = false,
            severity_sort = false,
        })
    end
end, desc_opts("Toggle ESLint Diagnostics"))

-- =============================================================================
-- 🤖 COPILOT CHAT
-- =============================================================================

keymap("n", "<leader>ac", ":CopilotChat<CR>", desc_opts("Chat with Copilot"))
keymap("n", "<leader>ae", ":CopilotChatExplain<CR>", desc_opts("Explain code with Copilot"))
keymap("n", "<leader>at", ":CopilotChatTests<CR>", desc_opts("Generate tests with Copilot"))
keymap("n", "<leader>ar", ":CopilotChatReview<CR>", desc_opts("Review code with Copilot"))
keymap("n", "<leader>af", ":CopilotChatFixDiagnostic<CR>", desc_opts("Fix diagnostics with Copilot"))
keymap("n", "<leader>am", ":CopilotChatCommit<CR>", desc_opts("Generate commit message"))

-- =============================================================================
-- 🐛 DEBUGGING (DAP)
-- =============================================================================
-- ▶️ Core debugging controls
keymap("n", "<Leader>dc", "<Cmd>lua require('dap').continue()<CR>", desc_opts("Debug: Continue"))
keymap("n", "<Leader>dt", "<Cmd>lua require('dap').terminate()<CR>", desc_opts("Debug: Terminate"))

-- 🛑 Breakpoint management
keymap("n", "<Leader>db", "<Cmd>lua require('dap').toggle_breakpoint()<CR>", desc_opts("Debug: Toggle Breakpoint"))
keymap("n", "<Leader>dB", "<Cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
    desc_opts("Debug: Conditional Breakpoint"))

-- 🪜 Step controls
keymap("n", "<Leader>di", "<Cmd>lua require('dap').step_into()<CR>", desc_opts("Debug: Step Into"))
keymap("n", "<Leader>do", "<Cmd>lua require('dap').step_out()<CR>", desc_opts("Debug: Step Out"))
keymap("n", "<Leader>dO", "<Cmd>lua require('dap').step_over()<CR>", desc_opts("Debug: Step Over"))

-- 🧩 DAP UI management
keymap("n", "<Leader>du", "<Cmd>lua require('dapui').open()<CR>", desc_opts("Debug: Open UI"))
keymap("n", "<Leader>dq", "<Cmd>lua require('dapui').close()<CR>", desc_opts("Debug: Close UI"))
keymap("n", "<Leader>de", "<Cmd>lua require('dapui').eval()<CR>", desc_opts("Evaluate Expression"))

-- 🧠 Evaluation and inspection
keymap("n", "<Leader>dh", "<Cmd>lua require('dapui').eval()<CR>", desc_opts("Debug: Evaluate Expression"))
keymap("n", "<Leader>dw", "<Cmd>lua require('dapui').float_element('watches', { enter = true })<CR>",
    desc_opts("Debug: Show Watches"))
keymap("n", "<Leader>ds", "<Cmd>lua require('dapui').float_element('scopes', { enter = true })<CR>",
    desc_opts("Debug: Show Scopes"))
keymap("n", "<Leader>dr", "<Cmd>lua require('dapui').float_element('repl', { enter = true })<CR>",
    desc_opts("Debug: Open REPL"))

-- 🔲 Window Management
keymap("n", "<Leader>dm", "<Cmd>MaximizerToggle<CR>", desc_opts("Toggle Maximize Current Split"))

-- =============================================================================
-- 🎮 TRAINING & UTILITIES
-- =============================================================================
keymap("n", "<leader>vg", ":VimBeGood<CR>", desc_opts("Open VimBeGood game"))

-- =============================================================================
-- 🎨 VISUAL MODE ENHANCEMENTS
-- =============================================================================
-- Stay in indent mode
keymap("v", "<", "<gv", desc_opts("Indent left and stay in visual mode"))
keymap("v", ">", ">gv", desc_opts("Indent right and stay in visual mode"))

-- Move text up and down
keymap("v", "J", ":m '>+1<CR>gv=gv", desc_opts("Move selected lines down"))
keymap("v", "K", ":m '<-2<CR>gv=gv", desc_opts("Move selected lines up"))

-- =============================================================================
-- 🧹 ADHD-FRIENDLY QUALITY OF LIFE
-- =============================================================================
-- Disable arrow keys in normal mode (force hjkl)
keymap("n", "<Up>", "<Nop>", desc_opts("Disable Up arrow (use k)"))
keymap("n", "<Down>", "<Nop>", desc_opts("Disable Down arrow (use j)"))
keymap("n", "<Left>", "<Nop>", desc_opts("Disable Left arrow (use h)"))
keymap("n", "<Right>", "<Nop>", desc_opts("Disable Right arrow (use l)"))

-- Center cursor on page up/down
keymap("n", "<C-u>", "<C-u>zz", desc_opts("Page up and center cursor"))
keymap("n", "<C-d>", "<C-d>zz", desc_opts("Page down and center cursor"))

-- Keep cursor centered on search
keymap("n", "*", "*zzzv", desc_opts("Search forward and center"))
keymap("n", "#", "#zzzv", desc_opts("Search backward and center"))

-- Paste with padding
keymap('n', '<leader>P', 'o<Esc>O<Esc>p', desc_opts("Paste with padding"))

-- Terminal Escape
keymap('t', '<Esc><Esc>', '<C-\\><C-n>', desc_opts("Exit terminal mode"))
keymap('i', '<C-c>', '<Esc>', desc_opts("Exit insert mode"))

-- vim: ts=2 sts=2 sw=2 et
