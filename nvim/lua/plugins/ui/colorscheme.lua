local function hex(value)
  if type(value) ~= 'number' then
    return value
  end
  return string.format('#%06x', value)
end

local function hl(name)
  local ok, value = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if not ok then
    return {}
  end

  return {
    fg = hex(value.fg),
    bg = hex(value.bg),
    bold = value.bold,
    italic = value.italic,
  }
end

-- base46's palette for the active theme. Used for the colours that must stay opaque:
-- base46 itself blanks NormalFloat/NvimTreeNormal/... when its transparency flag is on,
-- so reading them back from the highlight groups would return nothing.
local function theme_palette()
  local ok, base46 = pcall(require, 'base46')
  if not ok then
    return {}
  end

  local ok_tb, palette = pcall(base46.get_theme_tb, 'base_30')
  return ok_tb and palette or {}
end

local function resolve_ui_colors()
  local fallback = (_G.config and _G.config.colors) or {}
  local palette = theme_palette()
  local normal = hl 'Normal'
  local normal_float = hl 'NormalFloat'
  local line_nr = hl 'LineNr'
  local comment = hl 'Comment'
  local directory = hl 'Directory'
  local cursor_line_nr = hl 'CursorLineNr'
  local special = hl 'Special'
  local separator = hl 'WinSeparator'
  local error = hl 'DiagnosticSignError'
  local warn = hl 'DiagnosticSignWarn'
  local info = hl 'DiagnosticSignInfo'
  local hint = hl 'DiagnosticSignHint'

  return {
    bg = normal.bg or palette.black or fallback.bg,
    panel = palette.darker_black or normal_float.bg or fallback.panel or normal.bg,
    surface = palette.black2 or hl('CursorLine').bg or fallback.surface or normal_float.bg or normal.bg,
    subtle = separator.fg or fallback.subtle or comment.fg,
    fg = normal.fg or fallback.fg,
    muted = comment.fg or fallback.muted or line_nr.fg,
    primary = cursor_line_nr.fg or directory.fg or fallback.primary,
    secondary = special.fg or hint.fg or fallback.secondary,
    success = hl('String').fg or fallback.success,
    warning = warn.fg or fallback.warning,
    error = error.fg or fallback.error,
    info = info.fg or fallback.info,
    line_number = line_nr.fg or fallback.line_number,
  }
end

_G.get_ui_colors = resolve_ui_colors

local function set_hl(name, value)
  pcall(vim.api.nvim_set_hl, 0, name, value)
end

local function base46_theme_names()
  local theme_dir = vim.fn.stdpath 'data' .. '/lazy/base46/lua/base46/themes'
  local names = {}

  for _, file in ipairs(vim.fn.readdir(theme_dir)) do
    if file:sub(-4) == '.lua' then
      names[#names + 1] = file:gsub('%.lua$', '')
    end
  end

  table.sort(names)
  return names
end

local function persist_base46_theme(theme)
  local path = vim.fn.stdpath 'config' .. '/lua/nvconfig.lua'
  local lines = vim.fn.readfile(path)

  for i, line in ipairs(lines) do
    if line:match '^%s*theme%s*=%s*[\'"].-[\'"],?%s*$' then
      lines[i] = line:gsub('([\'"]).-%1', string.format("'%s'", theme), 1)
      break
    end
  end

  vim.fn.writefile(lines, path)
end

local function apply_base46_theme(theme, opts)
  if not theme or theme == '' then
    return
  end

  opts = opts or {}

  local ok, nvconfig = pcall(require, 'nvconfig')
  if not ok then
    return
  end

  nvconfig.base46.theme = theme
  _G.config.theme.name = theme
  pcall(function()
    require('chadrc').base46.theme = theme
  end)
  if opts.persist then
    persist_base46_theme(theme)
  end
  _G.refresh_theme_ui()
  pcall(function()
    require('config.theme_sync').request_sync()
  end)
  if opts.notify then
    vim.notify('Theme switched to ' .. theme, vim.log.levels.INFO, { title = 'base46' })
  end
end

local function apply_ui_highlights()
  local colors = resolve_ui_colors()
  local transparent = _G.config and _G.config.theme and _G.config.theme.transparent_background
  -- Floating windows (pickers, which-key, noice, notify, ...) must stay opaque even
  -- when the editor background is transparent, otherwise the text behind them shows
  -- through. Only splits (nvim-tree, statusline, winbar, signs) follow the transparency.
  local panel_bg = colors.panel
  local float_bg = colors.panel
  local surface_bg = colors.surface
  local split_bg = transparent and 'NONE' or colors.panel
  local split_surface_bg = transparent and 'NONE' or colors.surface

  local highlights = {
    NormalFloat = { bg = float_bg, fg = colors.fg },
    FloatBorder = { bg = float_bg, fg = colors.subtle },
    FloatTitle = { bg = float_bg, fg = colors.primary, bold = true },
    WinBar = { bg = 'NONE', fg = colors.muted },
    WinBarNC = { bg = 'NONE', fg = colors.line_number },
    WinSeparator = { fg = colors.subtle, bg = 'NONE' },
    LspInlayHint = { fg = colors.muted, bg = transparent and 'NONE' or colors.bg, italic = true },
    IblChar = { fg = colors.subtle, nocombine = true },
    IblScopeChar = { fg = colors.line_number, nocombine = true },

    WhichKey = { fg = colors.primary, bg = float_bg },
    WhichKeyNormal = { fg = colors.fg, bg = float_bg },
    WhichKeyFloat = { bg = float_bg },
    WhichKeyBorder = { fg = colors.subtle, bg = float_bg },
    WhichKeyTitle = { fg = colors.primary, bg = float_bg, bold = true },
    WhichKeyGroup = { fg = colors.secondary, bold = true },
    WhichKeyDesc = { fg = colors.fg },
    WhichKeySeparator = { fg = colors.subtle },
    WhichKeyValue = { fg = colors.muted },
    WhichKeyIcon = { fg = colors.primary },

    NoiceCmdlinePopup = { fg = colors.fg, bg = float_bg },
    NoiceCmdlinePopupBorder = { fg = colors.subtle, bg = float_bg },
    NoiceCmdlineIcon = { fg = colors.primary, bg = float_bg },
    NoiceCmdlineIconSearch = { fg = colors.warning, bg = float_bg },
    NoiceConfirm = { fg = colors.fg, bg = float_bg },
    NoiceConfirmBorder = { fg = colors.primary, bg = float_bg },
    NoiceMini = { fg = colors.fg, bg = float_bg },
    NotifyBackground = { bg = float_bg },

    SnacksPicker = { fg = colors.fg, bg = float_bg },
    SnacksPickerBox = { bg = panel_bg },
    SnacksPickerList = { fg = colors.fg, bg = panel_bg },
    SnacksPickerListCursorLine = { bg = surface_bg },
    SnacksPickerPreview = { fg = colors.fg, bg = panel_bg },
    SnacksPickerPreviewCursorLine = { bg = surface_bg },
    SnacksPickerInput = { fg = colors.fg, bg = panel_bg },
    SnacksPickerInputSearch = { fg = colors.warning, bg = panel_bg, bold = true },
    SnacksPickerPrompt = { fg = colors.primary, bg = panel_bg },
    SnacksPickerSpinner = { fg = colors.secondary, bg = panel_bg },
    SnacksPickerTotals = { fg = colors.muted, bg = panel_bg },
    SnacksPickerToggle = { fg = colors.secondary, bg = panel_bg },
    SnacksPickerMatch = { fg = colors.warning, bold = true },
    SnacksPickerSearch = { fg = colors.warning, bold = true },
    SnacksPickerDir = { fg = colors.muted },
    SnacksPickerDirectory = { fg = colors.primary },
    SnacksPickerFile = { fg = colors.fg },
    SnacksPickerDimmed = { fg = colors.muted },
    SnacksPickerDelim = { fg = colors.subtle },
    SnacksPickerComment = { fg = colors.muted, italic = true },
    SnacksPickerGitStatusAdded = { fg = colors.success },
    SnacksPickerGitStatusModified = { fg = colors.warning },
    SnacksPickerGitStatusDeleted = { fg = colors.error },
    SnacksPickerGitStatusRenamed = { fg = colors.secondary },
    SnacksPickerGitStatusStaged = { fg = colors.info },
    SnacksPickerGitStatusUntracked = { fg = colors.success },
    SnacksPickerGitStatusIgnored = { fg = colors.muted },
    SnacksPickerGitStatusUnmerged = { fg = colors.error },

    NvimTreeNormal = { fg = colors.fg, bg = split_bg },
    NvimTreeNormalNC = { fg = colors.fg, bg = split_bg },
    NvimTreeEndOfBuffer = { fg = colors.panel, bg = split_bg },
    NvimTreeWinSeparator = { fg = colors.subtle, bg = split_bg },
    NvimTreeCursorLine = { bg = split_surface_bg },
    NvimTreeRootFolder = { fg = colors.primary, bg = split_bg, bold = true },
    NvimTreeFolderName = { fg = colors.fg, bg = split_bg },
    NvimTreeOpenedFolderName = { fg = colors.primary, bg = split_bg, bold = true },
    NvimTreeEmptyFolderName = { fg = colors.muted, bg = split_bg },
    NvimTreeFolderIcon = { fg = colors.primary, bg = split_bg },
    NvimTreeFolderArrowClosed = { fg = colors.subtle, bg = split_bg },
    NvimTreeFolderArrowOpen = { fg = colors.subtle, bg = split_bg },
    NvimTreeSpecialFile = { fg = colors.info, bg = split_bg, underline = true },
    NvimTreeGitDirty = { fg = colors.warning, bg = split_bg },
    NvimTreeGitNew = { fg = colors.success, bg = split_bg },
    NvimTreeGitDeleted = { fg = colors.error, bg = split_bg },
    NvimTreeIndentMarker = { fg = colors.subtle, bg = split_bg },

    DiagnosticSignError = { fg = colors.error, bg = transparent and 'NONE' or colors.bg },
    DiagnosticSignWarn = { fg = colors.warning, bg = transparent and 'NONE' or colors.bg },
    DiagnosticSignInfo = { fg = colors.info, bg = transparent and 'NONE' or colors.bg },
    DiagnosticSignHint = { fg = colors.secondary, bg = transparent and 'NONE' or colors.bg },
  }

  for group, value in pairs(highlights) do
    set_hl(group, value)
  end
end

-- Stamp of what the compiled base46 cache was built for. Kept outside the cache
-- directory because every file in there is sourced at startup.
local function theme_stamp()
  return table.concat({ require('nvconfig').base46.theme, tostring(_G.config.theme.transparent_background) }, '|')
end

local function stamp_path()
  return vim.fn.stdpath 'state' .. '/base46.stamp'
end

local function cache_is_fresh()
  if not vim.uv.fs_stat(vim.g.base46_cache .. 'defaults') then
    return false
  end

  local ok, lines = pcall(vim.fn.readfile, stamp_path())
  return ok and lines[1] == theme_stamp()
end

-- Cheap, idempotent: restyles the UI on top of whatever base46 highlights are loaded.
-- The transparent.nvim plugin is only loaded when transparency is actually wanted.
local function apply_theme_overrides()
  if _G.config.theme.transparent_background or vim.g.transparent_enabled then
    local ok, transparent = pcall(require, 'transparent')
    if ok then
      vim.g.transparent_enabled = _G.config.theme.transparent_background
      if _G.config.theme.transparent_background then
        transparent.clear()
        return
      end
    end
  end

  apply_ui_highlights()
end

-- Expensive: recompiles every base46 highlight file and reloads them. Only needed
-- when the theme/transparency changes or the cache is missing -- not on every start.
local function refresh_theme_ui()
  require('nvconfig').base46.transparency = _G.config.theme.transparent_background
  require('base46').load_all_highlights()
  pcall(vim.fn.writefile, { theme_stamp() }, stamp_path())
  apply_theme_overrides()
end

_G.apply_ui_highlights = apply_ui_highlights
_G.apply_theme_overrides = apply_theme_overrides
_G.refresh_theme_ui = refresh_theme_ui
_G.set_base46_theme = function(theme)
  apply_base46_theme(theme, { persist = true, notify = true })
end
_G.pick_base46_theme = function()
  local themes = base46_theme_names()
  local original = require('nvconfig').base46.theme
  local previewed = original
  local preview_timer = assert(vim.uv.new_timer())

  local function stop_preview_timer()
    if not preview_timer:is_closing() then
      preview_timer:stop()
    end
  end

  local function schedule_preview(theme)
    if not theme or theme == previewed then
      return
    end

    stop_preview_timer()
    preview_timer:start(
      120,
      0,
      vim.schedule_wrap(function()
        if theme ~= previewed then
          apply_base46_theme(theme, { persist = false, notify = false })
          previewed = theme
        end
      end)
    )
  end

  require('snacks').picker.select(themes, {
    prompt = 'Base46 Theme',
    format_item = function(item)
      return item
    end,
    snacks = {
      on_change = function(_, item)
        schedule_preview(item and item.item)
      end,
    },
  }, function(choice)
    stop_preview_timer()
    if not preview_timer:is_closing() then
      preview_timer:close()
    end

    if choice then
      apply_base46_theme(choice, { persist = true, notify = true })
    elseif previewed ~= original then
      apply_base46_theme(original, { persist = false, notify = false })
    end
  end)
end

return {
  {
    'xiyaowong/transparent.nvim',
    -- Only needed while transparency is on; apply_theme_overrides() requires it on demand.
    lazy = not _G.config.theme.transparent_background,
    priority = 900,
    config = function()
      require('transparent').setup {
        -- Floating windows are deliberately NOT listed: they must stay opaque.
        extra_groups = {
          'WinBar',
          'WinBarNC',
          'StatusLine',
          'StatusLineNC',
          'NvimTreeNormal',
          'NvimTreeNormalNC',
          'NvimTreeEndOfBuffer',
          'NvimTreeCursorLine',
          'NvimTreeWinSeparator',
        },
        on_clear = function()
          local transparent = require 'transparent'
          transparent.clear_prefix 'lualine'
          transparent.clear_prefix 'NvimTree'
          if _G.apply_ui_highlights then
            vim.schedule(_G.apply_ui_highlights)
          end
        end,
      }
      vim.g.transparent_enabled = _G.config.theme.transparent_background
    end,
  },
  {
    'NvChad/base46',
    lazy = false,
    priority = 1000,
    build = function()
      refresh_theme_ui()
    end,
    config = function()
      vim.api.nvim_create_autocmd('User', {
        group = vim.api.nvim_create_augroup('DynamicBase46Ui', { clear = true }),
        pattern = 'NvThemeReload',
        callback = function()
          if not _G.config.theme.transparent_background then
            apply_ui_highlights()
          end
          pcall(function()
            require('config.theme_sync').request_sync()
          end)
        end,
      })

      -- config/init.lua sources the compiled cache and then calls
      -- apply_theme_overrides(); a full recompile is only needed when it is stale.
      if not cache_is_fresh() then
        refresh_theme_ui()
      end
      require('config.theme_sync').setup()
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
