local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
local snacks_ok, Snacks = pcall(require, 'snacks')

-- Helper function to merge opts with desc
local function desc_opts(description, extra_opts)
  local merged = vim.tbl_extend('force', opts, { desc = description })
  if extra_opts then
    merged = vim.tbl_extend('force', merged, extra_opts)
  end
  return merged
end

local function safe_require(mod)
  local ok, module = pcall(require, mod)
  if ok then
    return module
  end

  vim.notify(('Module not available: %s'):format(mod), vim.log.levels.WARN)
  return nil
end

local function with_module(mod, cb)
  return function(...)
    local module = safe_require(mod)
    if module then
      return cb(module, ...)
    end
  end
end

-- ╭─────────────────────────────────────────────────────────╮
-- │                         LAZY                            │
-- ╰─────────────────────────────────────────────────────────╯

keymap('n', '<leader>ll', '<cmd>Lazy<cr>', desc_opts 'Lazy Plugin Manager')
keymap('n', '<leader>lc', '<cmd>Lazy check<cr>', desc_opts 'Lazy Check Updates')
keymap('n', '<leader>lu', '<cmd>Lazy update<cr>', desc_opts 'Lazy Update Plugins')
keymap('n', '<leader>ls', '<cmd>Lazy sync<cr>', desc_opts 'Lazy Sync Plugins')
keymap('n', '<leader>lp', '<cmd>Lazy profile<cr>', desc_opts 'Lazy Profile Startup')
keymap('n', '<leader>ld', '<cmd>Lazy debug<cr>', desc_opts 'Lazy Debug')

-- ╭─────────────────────────────────────────────────────────╮
-- │                      ESSENTIALS                         │
-- ╰─────────────────────────────────────────────────────────╯

-- Window navigation: <C-h/j/k/l> are provided by vim-tmux-navigator (plugins/editor/tmux.lua),
-- which moves between nvim splits and tmux panes alike.

-- Resize windows with arrows
keymap('n', '<C-Up>', ':resize -2<CR>', desc_opts 'Decrease window height')
keymap('n', '<C-Down>', ':resize +2<CR>', desc_opts 'Increase window height')
keymap('n', '<C-Left>', ':vertical resize -2<CR>', desc_opts 'Decrease window width')
keymap('n', '<C-Right>', ':vertical resize +2<CR>', desc_opts 'Increase window width')

-- Buffer navigation
keymap('n', '<S-l>', ':bnext<CR>', desc_opts 'Go to next buffer')
keymap('n', '<S-h>', ':bprevious<CR>', desc_opts 'Go to previous buffer')

-- =============================================================================
-- 💾 WRITE & QUIT
-- =============================================================================
keymap('n', '<leader>w', ':w<CR>', desc_opts 'Write (Save)')
keymap('n', '<leader>q', ':q<CR>', desc_opts 'Quit Window')
keymap('n', '<leader>W', ':x<CR>', desc_opts 'Write & Quit')
keymap('n', '<leader>Q', ':qa<CR>', desc_opts 'Quit All')

-- =============================================================================
-- ✍️ TEXT MANIPULATION
-- =============================================================================
keymap({ 'n', 'v' }, '<leader>ty', '"+y', desc_opts 'Yank to system clipboard')
keymap('n', '<leader>tY', '"+Y', desc_opts 'Yank line to system clipboard')
keymap({ 'n', 'v' }, '<leader>tdx', [["_d]], desc_opts 'Delete without yanking (to void)')
keymap('n', '<leader>tdu', '0Yo<Esc>P', desc_opts 'Duplicate line')
keymap('n', '<leader>ta', 'ggVG', desc_opts 'Select all')
keymap('n', '<leader>tp', 'ggVGp', desc_opts 'Paste over whole file')

-- =============================================================================
-- 🔍 SEARCH
-- =============================================================================
keymap('n', '<leader>sc', ':nohlsearch<CR>', desc_opts 'Clear search highlights')
keymap('n', 'n', 'nzzzv', desc_opts 'Next search result centered')
keymap('n', 'N', 'Nzzzv', desc_opts 'Previous search result centered')

-- ============================================================================
--   GIT KEYMAPS (Gitsigns)
-- ============================================================================

-- Helper function to safely call gitsigns functions
local function gitsigns_action(action)
  return function()
    local ok, gitsigns = pcall(require, 'gitsigns')
    if ok then
      return gitsigns[action]()
    else
      vim.notify('Gitsigns not loaded', vim.log.levels.WARN)
    end
  end
end

-- Navigation between hunks
keymap('n', ']c', function()
  if vim.wo.diff then
    return ']c'
  end
  vim.schedule(gitsigns_action 'next_hunk')
  return '<Ignore>'
end, desc_opts('Next git hunk', { expr = true }))

keymap('n', '[c', function()
  if vim.wo.diff then
    return '[c'
  end
  vim.schedule(gitsigns_action 'prev_hunk')
  return '<Ignore>'
end, desc_opts('Previous git hunk', { expr = true }))

-- Git actions with leader+g prefix
keymap('n', '<leader>gs', gitsigns_action 'stage_hunk', desc_opts 'Stage hunk')
keymap('n', '<leader>gr', gitsigns_action 'reset_hunk', desc_opts 'Reset hunk')

-- Visual mode staging/resetting
keymap('v', '<leader>gs', function()
  local ok, gitsigns = pcall(require, 'gitsigns')
  if ok then
    gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
  end
end, desc_opts 'Stage hunk (visual)')

keymap('v', '<leader>gr', function()
  local ok, gitsigns = pcall(require, 'gitsigns')
  if ok then
    gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
  end
end, desc_opts 'Reset hunk (visual)')

-- Buffer-level operations
keymap('n', '<leader>gS', gitsigns_action 'stage_buffer', desc_opts 'Stage entire buffer')
keymap('n', '<leader>gu', gitsigns_action 'undo_stage_hunk', desc_opts 'Undo stage hunk')
keymap('n', '<leader>gR', gitsigns_action 'reset_buffer', desc_opts 'Reset entire buffer')

-- Preview and blame
keymap('n', '<leader>gp', gitsigns_action 'preview_hunk', desc_opts 'Preview hunk')
keymap('n', '<leader>gb', function()
  local ok, gitsigns = pcall(require, 'gitsigns')
  if ok then
    gitsigns.blame_line { full = true }
  end
end, desc_opts 'Blame line (full)')
keymap('n', '<leader>gB', gitsigns_action 'toggle_current_line_blame', desc_opts 'Toggle line blame')

-- Diff operations
keymap('n', '<leader>gd', gitsigns_action 'diffthis', desc_opts 'Diff this')
keymap('n', '<leader>gD', function()
  local ok, gitsigns = pcall(require, 'gitsigns')
  if ok then
    gitsigns.diffthis '~'
  end
end, desc_opts 'Diff this (cached)')

-- Text object for git hunks
keymap({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', desc_opts 'Select git hunk')

-- ADHD-friendly: Quick toggle for visual helpers
keymap('n', '<leader>gt', gitsigns_action 'toggle_signs', desc_opts 'Toggle git signs')
keymap('n', '<leader>gw', gitsigns_action 'toggle_word_diff', desc_opts 'Toggle word diff')
keymap('n', '<leader>gl', gitsigns_action 'toggle_linehl', desc_opts 'Toggle line highlight')

-- =============================================================================
-- 🎯 LSP KEYMAPS (Using LSP Saga)
-- =============================================================================
-- 📋 Diagnostic Navigation
keymap('n', '[d', '<cmd>Lspsaga diagnostic_jump_prev<CR>', desc_opts 'Previous diagnostic')
keymap('n', ']d', '<cmd>Lspsaga diagnostic_jump_next<CR>', desc_opts 'Next diagnostic')

-- 🔍 Show Diagnostics
keymap('n', '<leader>cd', '<cmd>Lspsaga show_line_diagnostics<CR>', desc_opts 'Show line diagnostics')
keymap('n', '<leader>cD', '<cmd>Lspsaga show_cursor_diagnostics<CR>', desc_opts 'Show cursor diagnostics')

-- ⚡ Code Actions
keymap('n', '<leader>ca', '<cmd>Lspsaga code_action<CR>', desc_opts 'Code action')
keymap('v', '<leader>ca', '<cmd>Lspsaga code_action<CR>', desc_opts 'Code action (visual)')

-- 🏷️ Smart Rename
keymap('n', '<leader>cr', '<cmd>Lspsaga rename<CR>', desc_opts 'Rename symbol')
keymap('n', '<leader>cR', '<cmd>Lspsaga rename ++project<CR>', desc_opts 'Rename symbol in project')

-- 📖 Hover Documentation
keymap('n', 'K', '<cmd>Lspsaga hover_doc<CR>', desc_opts 'Hover documentation')
keymap('n', '<leader>K', '<cmd>Lspsaga hover_doc ++keep<CR>', desc_opts 'Persistent hover doc')

-- 🎯 Definition & Type Definition
keymap('n', 'gd', '<cmd>Lspsaga goto_definition<CR>', desc_opts 'Go to definition')
keymap('n', 'gD', '<cmd>Lspsaga peek_definition<CR>', desc_opts 'Peek definition')
keymap('n', 'gt', '<cmd>Lspsaga goto_type_definition<CR>', desc_opts 'Go to type definition')
keymap('n', 'gT', '<cmd>Lspsaga peek_type_definition<CR>', desc_opts 'Peek type definition')

-- 🔍 Find References & Implementations
keymap('n', 'gr', '<cmd>Lspsaga finder<CR>', desc_opts 'Find references and definitions')
keymap('n', 'gR', '<cmd>Lspsaga finder ref<CR>', desc_opts 'Find references only')
keymap('n', 'gi', '<cmd>Lspsaga finder imp<CR>', desc_opts 'Find implementations')

-- 📋 Outline & Structure
keymap('n', '<leader>co', '<cmd>Trouble symbols toggle focus=false<CR>', desc_opts 'Toggle symbols outline')

-- 📞 Call Hierarchy
keymap('n', '<leader>ch', '<cmd>Lspsaga incoming_calls<CR>', desc_opts 'Show incoming calls')
keymap('n', '<leader>cH', '<cmd>Lspsaga outgoing_calls<CR>', desc_opts 'Show outgoing calls')

-- =============================================================================
-- 🔧 FORMATTING & LINTING
-- =============================================================================

-- Toggle format on save
keymap('n', '<leader>cF', '<cmd>FormatToggle<cr>', desc_opts 'Toggle format on save')

keymap({ 'n', 'v' }, '<leader>cf', '<cmd>Format<cr>', desc_opts 'Format buffer/selection')

keymap('n', '<leader>cl', '<cmd>LintBuffer<cr>', desc_opts 'Lint current buffer')

-- Show linter info for current filetype
keymap('n', '<leader>cL', '<cmd>LintInfo<cr>', desc_opts 'Show linter info')

-- =============================================================================
-- 🗂️ FILE MANAGEMENT
-- =============================================================================
-- File explorer (Oil.nvim)
keymap('n', '<leader>e', ':Oil<CR>', desc_opts 'Open Oil file explorer')
keymap('n', '<leader>E', function()
  local api = safe_require 'nvim-tree.api'
  if not api then
    return
  end
  api.tree.toggle {
    find_file = true,
    focus = true,
    update_root = true,
  }
end, desc_opts 'Toggle Explorer Map')

-- =============================================================================
-- 🔭 Snacks Picker (Fuzzy Finding)
-- =============================================================================

-- File Operation
keymap('n', '<leader>ff', function()
  if snacks_ok then
    Snacks.picker.files()
  else
    vim.notify('snacks.nvim not loaded', vim.log.levels.WARN)
  end
end, desc_opts 'Find files')
keymap('n', '<leader>fg', function()
  if snacks_ok then
    Snacks.picker.grep()
  else
    vim.notify('snacks.nvim not loaded', vim.log.levels.WARN)
  end
end, desc_opts 'Find (Grep) in files')
keymap('n', '<leader>fb', function()
  if snacks_ok then
    Snacks.picker.buffers()
  else
    vim.notify('snacks.nvim not loaded', vim.log.levels.WARN)
  end
end, desc_opts 'Find buffers')
keymap('n', '<leader>fh', function()
  if snacks_ok then
    Snacks.picker.help()
  else
    vim.notify('snacks.nvim not loaded', vim.log.levels.WARN)
  end
end, desc_opts 'Find help')
keymap('n', '<leader>fk', function()
  if snacks_ok then
    Snacks.picker.keymaps()
  else
    vim.notify('snacks.nvim not loaded', vim.log.levels.WARN)
  end
end, desc_opts 'Find keymaps')
keymap('n', '<leader>fr', function()
  if snacks_ok then
    Snacks.picker.oldfiles()
  else
    vim.notify('snacks.nvim not loaded', vim.log.levels.WARN)
  end
end, desc_opts 'Recent files')
keymap('n', '<leader>fc', function()
  if snacks_ok then
    Snacks.picker.commands()
  else
    vim.notify('snacks.nvim not loaded', vim.log.levels.WARN)
  end
end, desc_opts 'Command palette')
keymap('n', '<leader>fw', function()
  if snacks_ok then
    Snacks.picker.grep_word()
  else
    vim.notify('snacks.nvim not loaded', vim.log.levels.WARN)
  end
end, desc_opts 'Live grep string')

-- ========================================
-- ⚡ FLASH NAVIGATION KEYMAPS
-- ========================================

-- Flash jump keymaps (lazy loaded)
keymap({ 'n', 'x', 'o' }, 's', function()
  local flash = safe_require 'flash'
  if flash then
    flash.jump()
  end
end, desc_opts 'Flash Jump')

keymap({ 'n', 'x', 'o' }, 'S', function()
  local flash = safe_require 'flash'
  if flash then
    flash.treesitter()
  end
end, desc_opts 'Flash Treesitter')

keymap('o', 'r', function()
  local flash = safe_require 'flash'
  if flash then
    flash.remote()
  end
end, desc_opts 'Remote Flash')

keymap({ 'o', 'x' }, 'R', function()
  local flash = safe_require 'flash'
  if flash then
    flash.treesitter_search()
  end
end, desc_opts 'Treesitter Search')

keymap('c', '<c-s>', function()
  local flash = safe_require 'flash'
  if flash then
    flash.toggle()
  end
end, desc_opts 'Toggle Flash Search')

-- =============================================================================
-- 🌈 THEME SWITCHING
-- =============================================================================

keymap('n', '<leader>uc', function()
  _G.pick_base46_theme()
end, desc_opts 'Pick base46 theme')

-- =============================================================================
-- 🌈 UI toggles
-- =============================================================================
keymap('n', '<leader>ut', '<cmd>ToggleTransparency<CR>', desc_opts 'Toggle Transparency')
keymap('n', '<leader>uz', ':ZenMode<CR>', desc_opts 'Toggle Zen Mode')
keymap('n', '<leader>ur', function()
  vim.wo.relativenumber = not vim.wo.relativenumber
end, desc_opts 'Toggle relative number')

keymap('n', '<leader>uo', function()
  vim.opt.scrolloff = 999 - vim.o.scrolloff
end, desc_opts 'Toggle center cursor')

keymap('n', '<leader>uh', function()
  local buf = vim.api.nvim_get_current_buf()
  local enabled = vim.lsp.inlay_hint.is_enabled { bufnr = buf }
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = buf })
end, desc_opts 'Toggle Inlay Hints')

local signs = {
  text = {
    [vim.diagnostic.severity.ERROR] = _G.config.icons.diagnostics.error,
    [vim.diagnostic.severity.WARN] = _G.config.icons.diagnostics.warn,
    [vim.diagnostic.severity.INFO] = _G.config.icons.diagnostics.info,
    [vim.diagnostic.severity.HINT] = _G.config.icons.diagnostics.hint,
  },
}

keymap('n', '<leader>ud', function()
  local current = vim.diagnostic.config()
  local enabled = current.virtual_text

  vim.diagnostic.config {
    virtual_text = not enabled,
    signs = signs,
    underline = current.underline,
    update_in_insert = current.update_in_insert,
    severity_sort = current.severity_sort,
  }
end, desc_opts 'Toggle inline diagnostics')

-- =============================================================================
-- 🤖 COPILOT CHAT
-- =============================================================================

-- keymap("n", "<leader>ac", ":CopilotChat<CR>", desc_opts("Chat with Copilot"))
-- keymap("n", "<leader>ae", ":CopilotChatExplain<CR>", desc_opts("Explain code with Copilot"))
-- keymap("n", "<leader>at", ":CopilotChatTests<CR>", desc_opts("Generate tests with Copilot"))
-- keymap("n", "<leader>ar", ":CopilotChatReview<CR>", desc_opts("Review code with Copilot"))
-- keymap("n", "<leader>af", ":CopilotChatFixDiagnostic<CR>", desc_opts("Fix diagnostics with Copilot"))
-- keymap("n", "<leader>am", ":CopilotChatCommit<CR>", desc_opts("Generate commit message"))

-- =============================================================================
-- 🐛 DEBUGGING (DAP)
-- =============================================================================
-- ▶️ Core debugging controls
keymap(
  'n',
  '<Leader>dc',
  with_module('dap', function(dap)
    dap.continue()
  end),
  desc_opts 'Debug: Continue'
)
keymap(
  'n',
  '<Leader>dt',
  with_module('dap', function(dap)
    dap.terminate()
  end),
  desc_opts 'Debug: Terminate'
)
keymap(
  'n',
  '<Leader>dl',
  with_module('dap', function(dap)
    dap.run_last()
  end),
  desc_opts 'Debug: Run Last'
)
keymap(
  'n',
  '<Leader>dj',
  with_module('dap', function(dap)
    dap.run_to_cursor()
  end),
  desc_opts 'Debug: Run to Cursor'
)

-- 🛑 Breakpoint management
keymap(
  'n',
  '<Leader>db',
  with_module('dap', function(dap)
    dap.toggle_breakpoint()
  end),
  desc_opts 'Debug: Toggle Breakpoint'
)
keymap(
  'n',
  '<Leader>dB',
  with_module('dap', function(dap)
    dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
  end),
  desc_opts 'Debug: Conditional Breakpoint'
)
keymap(
  'n',
  '<Leader>dp',
  with_module('dap', function(dap)
    dap.set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
  end),
  desc_opts 'Debug: Log Point'
)
keymap(
  'n',
  '<Leader>dx',
  with_module('dap', function(dap)
    dap.clear_breakpoints()
  end),
  desc_opts 'Debug: Clear Breakpoints'
)

-- 🪜 Step controls
keymap(
  'n',
  '<Leader>di',
  with_module('dap', function(dap)
    dap.step_into()
  end),
  desc_opts 'Debug: Step Into'
)
keymap(
  'n',
  '<Leader>do',
  with_module('dap', function(dap)
    dap.step_out()
  end),
  desc_opts 'Debug: Step Out'
)
keymap(
  'n',
  '<Leader>dO',
  with_module('dap', function(dap)
    dap.step_over()
  end),
  desc_opts 'Debug: Step Over'
)

-- 🧩 DAP UI management
keymap(
  'n',
  '<Leader>du',
  with_module('dapui', function(dapui)
    dapui.toggle()
  end),
  desc_opts 'Debug: Toggle UI'
)
keymap(
  'n',
  '<Leader>dq',
  with_module('dapui', function(dapui)
    dapui.close()
  end),
  desc_opts 'Debug: Close UI'
)
keymap(
  'n',
  '<Leader>de',
  with_module('dapui', function(dapui)
    dapui.eval()
  end),
  desc_opts 'Evaluate Expression'
)

-- 🧠 Evaluation and inspection
keymap(
  { 'n', 'v' },
  '<Leader>dh',
  with_module('dap.ui.widgets', function(widgets)
    widgets.hover()
  end),
  desc_opts 'Debug: Hover Value'
)
keymap(
  'n',
  '<Leader>dw',
  with_module('dapui', function(dapui)
    dapui.float_element('watches', { enter = true })
  end),
  desc_opts 'Debug: Show Watches'
)
keymap(
  'n',
  '<Leader>ds',
  with_module('dapui', function(dapui)
    dapui.float_element('scopes', { enter = true })
  end),
  desc_opts 'Debug: Show Scopes'
)
keymap(
  'n',
  '<Leader>dr',
  with_module('dapui', function(dapui)
    dapui.float_element('repl', { enter = true })
  end),
  desc_opts 'Debug: Open REPL'
)
keymap(
  'n',
  '<Leader>df',
  with_module('dap.ui.widgets', function(widgets)
    widgets.centered_float(widgets.frames)
  end),
  desc_opts 'Debug: Show Frames'
)
keymap(
  'n',
  '<Leader>dv',
  with_module('dap.ui.widgets', function(widgets)
    widgets.centered_float(widgets.scopes)
  end),
  desc_opts 'Debug: Show Variables'
)
keymap(
  'n',
  '<Leader>dgt',
  with_module('dap-go', function(dap_go)
    dap_go.debug_test()
  end),
  desc_opts 'Debug Go Test'
)
keymap(
  'n',
  '<Leader>dgl',
  with_module('dap-go', function(dap_go)
    dap_go.debug_last_test()
  end),
  desc_opts 'Debug Last Go Test'
)
keymap(
  'n',
  '<Leader>dgp',
  with_module('dap', function(dap)
    dap.run {
      type = 'go',
      name = 'Debug Package',
      request = 'launch',
      program = vim.fn.expand '%:p:h',
    }
  end),
  desc_opts 'Debug Go Package'
)

-- 🔲 Window Management
keymap('n', '<Leader>dm', '<Cmd>MaximizerToggle<CR>', desc_opts 'Toggle Maximize Current Split')

-- =============================================================================
-- 🎮 TRAINING & UTILITIES
-- =============================================================================
keymap('n', '<leader>vg', ':VimBeGood<CR>', desc_opts 'Open VimBeGood game')
keymap('n', '<leader>ul', '<cmd>OpenErrorLog<CR>', desc_opts 'Open error log')

-- =============================================================================
-- 🎨 VISUAL MODE ENHANCEMENTS
-- =============================================================================
-- Stay in indent mode
keymap('v', '<', '<gv', desc_opts 'Indent left and stay in visual mode')
keymap('v', '>', '>gv', desc_opts 'Indent right and stay in visual mode')

-- Move text up and down
keymap('v', 'J', ":m '>+1<CR>gv=gv", desc_opts 'Move selected lines down')
keymap('v', 'K', ":m '<-2<CR>gv=gv", desc_opts 'Move selected lines up')

-- =============================================================================
-- 🧹 ADHD-FRIENDLY QUALITY OF LIFE
-- =============================================================================
-- Disable arrow keys in normal mode (force hjkl)
keymap('n', '<Up>', '<Nop>', desc_opts 'Disable Up arrow (use k)')
keymap('n', '<Down>', '<Nop>', desc_opts 'Disable Down arrow (use j)')
keymap('n', '<Left>', '<Nop>', desc_opts 'Disable Left arrow (use h)')
keymap('n', '<Right>', '<Nop>', desc_opts 'Disable Right arrow (use l)')

-- Center cursor on page up/down
keymap('n', '<C-u>', '<C-u>zz', desc_opts 'Page up and center cursor')
keymap('n', '<C-d>', '<C-d>zz', desc_opts 'Page down and center cursor')

-- Keep cursor centered on search
keymap('n', '*', '*zzzv', desc_opts 'Search forward and center')
keymap('n', '#', '#zzzv', desc_opts 'Search backward and center')

-- Paste with padding
keymap('n', '<leader>P', 'o<Esc>O<Esc>p', desc_opts 'Paste with padding')

-- Terminal Escape
keymap('t', '<Esc><Esc>', '<C-\\><C-n>', desc_opts 'Exit terminal mode')
keymap('i', '<C-c>', '<Esc>', desc_opts 'Exit insert mode')

-- vim: ts=2 sts=2 sw=2 et
