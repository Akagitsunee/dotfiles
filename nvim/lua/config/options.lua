-- ============================================================================
-- ⚙️ NEOVIM CORE SETTINGS
-- ============================================================================

local opt = vim.opt
local api = vim.api
local g = vim.g
local cmd = vim.cmd
local diagnostic = vim.diagnostic

-- ============================================================================
-- 🎨 APPEARANCE & UI
-- ============================================================================
opt.termguicolors = true -- Enable 24-bit RGB colors
opt.background = 'dark'  -- Dark background
opt.signcolumn = 'yes:1' -- Always show sign column (was "yes")
opt.numberwidth = 5
--opt.colorcolumn = "80,120" -- Show ruler at 80 and 120 characters
opt.cursorline = true -- Highlight current line
opt.number = true -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.wrap = false -- Don't wrap lines
opt.linebreak = true -- Break lines at word boundaries (explicit)
opt.showbreak = '↪ ' -- Character for wrapped lines
opt.scrolloff = _G.config.layout.scroll_context -- Keep lines visible when scrolling
opt.sidescrolloff = 8 -- Keep columns visible when side-scrolling
opt.cmdheight = 1 -- Command line height
opt.showmode = false -- Don't show mode (statusline shows it)
opt.showtabline = 0 -- Never show tabline
opt.laststatus = 3 -- Global statusline
opt.list = true -- Show invisible characters
opt.listchars = { -- Invisible characters representation
    tab = '→ ',
    trail = '·',
    nbsp = '␣',
    extends = '▶',
    precedes = '◀',
}
opt.fillchars = vim.tbl_extend('force', opt.fillchars:get(), { -- Fill chars for UI
    stl = '━',
    stlnc = '━',
    eob = ' ', -- End of buffer
    fold = ' ',
    foldopen = ' ',
    foldsep = ' ',
    foldclose = ' ',
})

-- Make line numbers styled
api.nvim_set_hl(0, 'LineNr', { fg = _G.config.colors.line_number })                    --
api.nvim_set_hl(0, 'CursorLineNr', { fg = _G.config.colors.line_number, bold = true }) --

-- ============================================================================
-- 🔍 SEARCH & NAVIGATION
-- ============================================================================
opt.hlsearch = true            -- Highlight search results
opt.incsearch = true           -- Show search matches as you type
opt.ignorecase = true          -- Ignore case in search
opt.smartcase = true           -- Case-sensitive if uppercase present
opt.grepprg = 'rg --vimgrep'   -- Use ripgrep for :grep
opt.grepformat = '%f:%l:%c:%m' -- Grep output format

-- ============================================================================
-- ✏️ EDITING & INDENTATION
-- ============================================================================
opt.expandtab = true                           -- Use spaces instead of tabs
opt.tabstop = _G.config.layout.indent_size     -- Tab width
opt.shiftwidth = _G.config.layout.indent_size  -- Indent width
opt.softtabstop = _G.config.layout.indent_size -- Soft tab width
opt.smartindent = true                         -- Smart auto-indenting
opt.autoindent = true                          -- Copy indent from current line
opt.breakindent = true                         -- Preserve indentation in wrapped text
opt.shiftround = true                          -- Round to nearest shiftwidth

-- ============================================================================
-- 💾 FILES & BACKUP
-- ============================================================================
opt.backup = false                              -- Don't create backup files
opt.writebackup = false                         -- Don't create backup before overwriting
opt.swapfile = false                            -- Don't create swap files
opt.undofile = true                             -- Enable persistent undo
opt.undodir = vim.fn.stdpath 'cache' .. '/undo' -- Undo directory
opt.autowrite = true                            -- Always auto-save (was _G.config.behavior.auto_save)
opt.autoread = true                             -- Auto-reload files changed outside vim
opt.confirm = true                              -- Confirm before closing unsaved files

-- ============================================================================
-- 🔄 SESSION & STATE
-- ============================================================================
-- Tells Neovim what to save and restore using session management.
opt.sessionoptions = {
    'buffers',
    'curdir',
    'folds',
    'help',
    'tabpages',
    'winsize',
    'winpos',
    'terminal',
}

-- ============================================================================
-- 🔧 BEHAVIOR & PERFORMANCE
-- ============================================================================
opt.updatetime = _G.config.behavior.update_time     -- Faster completion and diagnostics
opt.timeoutlen = _G.config.behavior.timeout_len     -- Time to wait for mapped sequence
opt.ttimeoutlen = 10                                -- Time to wait for key code sequence (was 0)
opt.completeopt = { 'menu', 'menuone', 'noselect' } -- Completion options
opt.pumheight = 15                                  -- Popup menu height (was 10)
opt.pumblend = _G.config.ui.blend                   -- Popup transparency
opt.winblend = _G.config.ui.winblend                -- Window transparency
opt.conceallevel = 0                                -- Don't hide markup in markdown files
opt.fileencoding = 'utf-8'                          -- File encoding
opt.mouse = 'a'                                     -- Enable mouse support
opt.mousemodel = 'popup'                            -- Right-click menu
opt.clipboard = 'unnamedplus'                       -- Use system clipboard
opt.splitbelow = true                               -- Horizontal splits below
opt.splitright = true                               -- Vertical splits to right
opt.splitkeep = 'screen'                            -- Keep text on screen when splitting
opt.equalalways = false                             -- Don’t auto-resize splits
opt.ttyfast = true                                  -- Fast terminal connection

-- ============================================================================
-- 🧠 MEMORY & PERFORMANCE (ADHD-Friendly)
-- ============================================================================
opt.history = 1000     -- Command history size
opt.hidden = true      -- Allow hidden buffers
opt.lazyredraw = false -- Don't redraw during macros (for smooth UI)
opt.synmaxcol = 300    -- Max column for syntax highlighting
opt.regexpengine = 0   -- Auto-select regexp engine

-- ============================================================================
-- 🔔 NOTIFICATIONS & MESSAGES
-- ============================================================================
opt.errorbells = false   -- Disable sound alerts
opt.visualbell = true    -- Use screen flash
opt.shortmess:append 'c' -- Don't pass messages to ins-completion-menu
opt.shortmess:append 'I' -- Don't show intro message
opt.shortmess:append 'W' -- Don't show "written" when writing
opt.shortmess:append 'F' -- Don't show file info when editing

-- ============================================================================
-- 🎯 FOLDING (Enhanced with nvim-ufo)
-- ============================================================================
opt.foldcolumn = '0'    -- Show fold column
opt.foldlevel = 99      -- High fold level (nvim-ufo handles this)
opt.foldlevelstart = 99 -- Start with all folds open
opt.foldenable = true   -- Enable folding

-- ============================================================================
-- 🌍 GLOBAL VARIABLES
-- ============================================================================
g.mapleader = ' '      -- Set leader key to space
g.maplocalleader = ' ' -- Set local leader to space

-- Disable some built-in plugins we don't need
g.loaded_gzip = 1
g.loaded_tar = 1
g.loaded_tarPlugin = 1
g.loaded_zip = 1
g.loaded_zipPlugin = 1
g.loaded_getscript = 1
g.loaded_getscriptPlugin = 1
g.loaded_vimball = 1
g.loaded_vimballPlugin = 1
g.loaded_matchit = 1
g.loaded_matchparen = 1
g.loaded_2html_plugin = 1
g.loaded_logiPat = 1
g.loaded_rrhelper = 1
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.loaded_netrwSettings = 1
g.loaded_netrwFileHandlers = 1

-- ============================================================================
-- 🚨 DIAGNOSTIC CONFIGURATION
-- ============================================================================
diagnostic.config {
    virtual_text = _G.config.lsp.virtual_text or false,
    signs = _G.config.lsp.signs,
    update_in_insert = _G.config.lsp.update_in_insert or false,
    underline = false,
    severity_sort = _G.config.lsp.severity_sort or false,
    float = _G.config.lsp.float,
}

-- ============================================================================
-- 🎨 THEME INTEGRATION & COMMANDS
-- ============================================================================
vim.o.background = "dark"
cmd.colorscheme(_G.config.theme.name) -- Set colorscheme before plugins

api.nvim_create_user_command('ToggleTransparency', function()
    local transparent = require 'transparent'
    transparent.toggle()
    _G.config.theme.transparent_background = not _G.config.theme.transparent_background
end, { desc = 'Toggle transparent background' })

api.nvim_create_user_command('ThemeInfo', function()
    print('Current theme: ' .. _G.config.theme.name)
    print('Transparent: ' .. tostring(_G.config.theme.transparent_background))
    print('Italic comments: ' .. tostring(_G.config.theme.italic_comments))
    print('Bold functions: ' .. tostring(_G.config.theme.bold_functions))
end, { desc = 'Show current theme information' })

-- ============================================================================
-- 📂 FILE EXPLORER SETTINGS
-- ============================================================================
g.netrw_browse_split = 0 -- Open files in same window
g.netrw_banner = 0       -- Hide banner
g.netrw_winsize = 25     -- Set window size

-- vim: ts=2 sts=2 sw=2 et
