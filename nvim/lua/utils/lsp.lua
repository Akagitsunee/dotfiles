-- Shared LSP helpers.
local M = {}

-- Completion capabilities advertised to every language server.
--
-- This mirrors blink.cmp 1.x's `get_lsp_capabilities()` (sources/lib/init.lua) so the
-- first buffer doesn't have to load blink.cmp, LuaSnip and friends just to build a
-- table: blink.cmp is pinned to `1.*`, so the table is stable. nvim's own defaults are
-- merged in by vim.lsp.config() / the client, so they are not repeated here.
local completion_capabilities = {
  textDocument = {
    completion = {
      completionItem = {
        snippetSupport = true,
        commitCharactersSupport = false,
        documentationFormat = { 'markdown', 'plaintext' },
        deprecatedSupport = true,
        preselectSupport = false,
        tagSupport = { valueSet = { 1 } },
        insertReplaceSupport = true,
        resolveSupport = {
          properties = { 'documentation', 'detail', 'additionalTextEdits', 'command', 'data' },
        },
        insertTextModeSupport = { valueSet = { 1 } },
        labelDetailsSupport = true,
      },
      completionList = {
        itemDefaults = { 'commitCharacters', 'editRange', 'insertTextFormat', 'insertTextMode', 'data' },
      },
      contextSupport = true,
      insertTextMode = 1,
    },
    -- nvim-ufo folds through the language server when it can.
    foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
  },
}

--- A fresh copy of the shared capabilities, optionally extended with `override`.
---@param override? table
---@return table
function M.capabilities(override)
  return vim.tbl_deep_extend('force', vim.deepcopy(completion_capabilities), override or {})
end

-- mason.nvim prepends its bin dir to $PATH when it is set up, but it is loaded after
-- startup now; make the installed servers resolvable before the first buffer attaches.
function M.ensure_mason_on_path()
  local mason_bin = vim.fn.stdpath 'data' .. '/mason/bin'
  local sep = vim.fn.has 'win32' == 1 and ';' or ':'
  local path = vim.env.PATH or ''

  if not path:find(mason_bin, 1, true) then
    vim.env.PATH = mason_bin .. sep .. path
  end
end

return M
