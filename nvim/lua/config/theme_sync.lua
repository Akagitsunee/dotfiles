local M = {}

local uv = vim.uv

local CONFIG_ROOT = vim.fs.dirname(vim.fn.stdpath 'config')
local STATE_DIR = vim.fn.stdpath 'state' .. '/theme-sync'
local STATE_PATH = STATE_DIR .. '/external-theme.json'

local GHOSTTY_CONFIG_PATH = CONFIG_ROOT .. '/ghostty/config'
local GHOSTTY_THEME_PATH = CONFIG_ROOT .. '/ghostty/themes/NvimSync'
local TMUX_POWERLINE_CONFIG_PATH = CONFIG_ROOT .. '/tmux-powerline/config.sh'
local TMUX_POWERLINE_COLORS_PATH = CONFIG_ROOT .. '/tmux/powerline_colors.sh'
local TMUX_CONFIG_PATH = CONFIG_ROOT .. '/tmux/tmux.conf'

local GHOSTTY_THEME_NAME = 'NvimSync'
local TMUX_POWERLINE_THEME_NAME = 'dynamic_bubble'

local augroup = nil
local sync_timer = nil

-- Only touch the terminal-side files for terminals that can actually use them.
local function in_ghostty()
  return vim.env.TERM_PROGRAM == 'ghostty' or vim.env.GHOSTTY_RESOURCES_DIR ~= nil
end

local function in_tmux()
  return vim.env.TMUX ~= nil and vim.fn.executable 'tmux' == 1
end

local function hex(value)
  if type(value) == 'number' then
    return string.format('#%06x', value)
  end

  if type(value) ~= 'string' or value == '' then
    return nil
  end

  if value == 'NONE' then
    return nil
  end

  if value:sub(1, 1) ~= '#' then
    return '#' .. value
  end

  return value
end

local function hl(name)
  local ok, value = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if not ok then
    return {}
  end

  return {
    fg = hex(value.fg),
    bg = hex(value.bg),
  }
end

local function read_file(path)
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end

  return table.concat(vim.fn.readfile(path), '\n')
end

local function write_file(path, content)
  -- Skip identical content so unchanged runs don't dirty files (or the git tree).
  if read_file(path) == content then
    return
  end
  vim.fn.mkdir(vim.fs.dirname(path), 'p')
  local lines = vim.split(content, '\n', { plain = true })
  vim.fn.writefile(lines, path)
end

local function delete_file(path)
  if vim.fn.filereadable(path) == 1 then
    vim.fn.delete(path)
  end
end

local function decode_state(raw)
  if not raw or raw == '' then
    return nil
  end

  local ok, decoded = pcall(vim.json.decode, raw)
  if not ok or type(decoded) ~= 'table' then
    return nil
  end

  decoded.pids = decoded.pids or {}
  decoded.original = decoded.original or {}
  return decoded
end

local function load_state()
  local state = decode_state(read_file(STATE_PATH))
  if state then
    return state
  end

  return {
    pids = {},
    original = {},
  }
end

local function save_state(state)
  vim.fn.mkdir(STATE_DIR, 'p')
  write_file(STATE_PATH, vim.json.encode(state))
end

local function clear_state()
  delete_file(STATE_PATH)
end

local function pid_is_alive(pid)
  local ok, result = pcall(uv.kill, tonumber(pid), 0)
  return ok and result
end

local function active_pid_count(state)
  local count = 0
  for pid, _ in pairs(state.pids or {}) do
    if pid_is_alive(pid) then
      count = count + 1
    else
      state.pids[pid] = nil
    end
  end

  return count
end

local function replace_first_matching_line(path, matcher, replacement)
  if vim.fn.filereadable(path) ~= 1 then
    return false
  end

  local lines = vim.fn.readfile(path)
  for i, line in ipairs(lines) do
    if matcher(line) then
      if line ~= replacement then
        lines[i] = replacement
        vim.fn.writefile(lines, path)
      end
      return true
    end
  end

  lines[#lines + 1] = replacement
  vim.fn.writefile(lines, path)
  return true
end

local function remove_first_matching_line(path, matcher)
  if vim.fn.filereadable(path) ~= 1 then
    return false
  end

  local lines = vim.fn.readfile(path)
  for i, line in ipairs(lines) do
    if matcher(line) then
      table.remove(lines, i)
      vim.fn.writefile(lines, path)
      return true
    end
  end

  return false
end

local function build_palette()
  local ui = (_G.get_ui_colors and _G.get_ui_colors()) or (_G.config and _G.config.colors) or {}
  local normal = hl 'Normal'
  local comment = hl 'Comment'
  local cursor = hl 'Cursor'
  local cursor_line_nr = hl 'CursorLineNr'
  local directory = hl 'Directory'
  local error = hl 'DiagnosticSignError'
  local info = hl 'DiagnosticSignInfo'
  local string_hl = hl 'String'
  local special = hl 'Special'
  local type_hl = hl 'Type'
  local visual = hl 'Visual'
  local warning = hl 'DiagnosticSignWarn'

  return {
    bg = normal.bg or ui.bg,
    fg = normal.fg or ui.fg,
    cursor = cursor.bg or normal.fg or ui.fg,
    cursor_text = cursor.fg or normal.bg or ui.bg,
    selection_bg = visual.bg or ui.surface or ui.primary,
    selection_fg = visual.fg or normal.fg or ui.bg,
    black = normal.bg or ui.bg,
    red = error.fg or ui.error,
    green = string_hl.fg or ui.success,
    yellow = warning.fg or ui.warning,
    blue = directory.fg or ui.primary,
    magenta = special.fg or ui.secondary,
    cyan = info.fg or type_hl.fg or ui.info,
    white = normal.fg or ui.fg,
    bright_black = comment.fg or ui.muted,
    bright_red = error.fg or ui.error,
    bright_green = string_hl.fg or ui.success,
    bright_yellow = cursor_line_nr.fg or warning.fg or ui.warning,
    bright_blue = directory.fg or ui.primary,
    bright_magenta = special.fg or ui.secondary,
    bright_cyan = info.fg or type_hl.fg or ui.info,
    bright_white = normal.fg or ui.fg,
    extended_orange = ui.warning,
    extended_red = ui.error,
    panel = ui.panel or normal.bg or ui.bg,
    surface = ui.surface or ui.panel or normal.bg or ui.bg,
    subtle = ui.subtle or comment.fg or ui.muted,
    muted = ui.muted or comment.fg or ui.subtle,
    primary = ui.primary or directory.fg or special.fg,
    info = ui.info or info.fg or type_hl.fg,
  }
end

local function ghostty_theme_content(colors)
  local lines = {
    '# Managed by Neovim external theme sync.',
    '# This file is rewritten while at least one Neovim instance is running.',
    ('background = %s'):format(colors.bg),
    ('foreground = %s'):format(colors.fg),
    '',
    '# Cursor colors',
    ('cursor-color = %s'):format(colors.cursor),
    ('cursor-text = %s'):format(colors.cursor_text),
    '',
    '# Selection colors',
    ('selection-background = %s'):format(colors.selection_bg),
    ('selection-foreground = %s'):format(colors.selection_fg),
    '',
    '# ANSI Colors (0-7)',
    ('palette = 0=%s'):format(colors.black),
    ('palette = 1=%s'):format(colors.red),
    ('palette = 2=%s'):format(colors.green),
    ('palette = 3=%s'):format(colors.yellow),
    ('palette = 4=%s'):format(colors.blue),
    ('palette = 5=%s'):format(colors.magenta),
    ('palette = 6=%s'):format(colors.cyan),
    ('palette = 7=%s'):format(colors.white),
    '',
    '# Bright colors (8-15)',
    ('palette = 8=%s'):format(colors.bright_black),
    ('palette = 9=%s'):format(colors.bright_red),
    ('palette = 10=%s'):format(colors.bright_green),
    ('palette = 11=%s'):format(colors.bright_yellow),
    ('palette = 12=%s'):format(colors.bright_blue),
    ('palette = 13=%s'):format(colors.bright_magenta),
    ('palette = 14=%s'):format(colors.bright_cyan),
    ('palette = 15=%s'):format(colors.bright_white),
    '',
    '# Extended colors',
    ('palette = 16=%s'):format(colors.extended_orange),
    ('palette = 17=%s'):format(colors.extended_red),
  }

  return table.concat(lines, '\n')
end

local function tmux_colors_content(colors)
  local lines = {
    '#!/usr/bin/env sh',
    '# Managed by Neovim external theme sync.',
    ('PL_BG=%q'):format(colors.panel),
    ('PL_FG=%q'):format(colors.fg),
    ('PL_ACCENT=%q'):format(colors.primary),
    ('PL_CYAN=%q'):format(colors.info),
    ('PL_DIM_BG=%q'):format(colors.surface),
    ('PL_GREY=%q'):format(colors.muted or colors.subtle),
  }

  return table.concat(lines, '\n')
end

local function refresh_tmux_clients()
  if not in_tmux() then
    return
  end

  vim.system({ 'tmux', 'list-clients', '-F', '#{client_tty}' }, { text = true }, function(result)
    if result.code ~= 0 then
      return
    end

    for _, tty in ipairs(vim.split(result.stdout or '', '\n', { trimempty = true })) do
      vim.system({ 'tmux', 'refresh-client', '-S', '-t', tty }, { detach = true })
    end
  end)
end

local function capture_original_theme_line(path, matcher)
  if vim.fn.filereadable(path) ~= 1 then
    return vim.NIL
  end

  for _, line in ipairs(vim.fn.readfile(path)) do
    if matcher(line) then
      return line
    end
  end

  return vim.NIL
end

local function capture_tmux_conf_option_line(option)
  if vim.fn.filereadable(TMUX_CONFIG_PATH) ~= 1 then
    return vim.NIL
  end

  local pattern = '^%s*set%-option%s+%-g%s+' .. vim.pesc(option) .. '%s+'
  local alt_pattern = '^%s*set%s+%-g%s+' .. vim.pesc(option) .. '%s+'

  for _, line in ipairs(vim.fn.readfile(TMUX_CONFIG_PATH)) do
    if line:match(pattern) or line:match(alt_pattern) then
      return line
    end
  end

  return vim.NIL
end

local function tmux_has_server()
  return in_tmux()
end

local function tmux_show_option(option)
  if not tmux_has_server() then
    return nil
  end

  local result = vim.system({ 'tmux', 'show-options', '-gqv', option }, { text = true }):wait(500)
  if result.code ~= 0 then
    return nil
  end

  return vim.trim(result.stdout or '')
end

local function tmux_set_option(option, value)
  if not tmux_has_server() then
    return
  end

  vim.system({ 'tmux', 'set-option', '-g', option, value }, { detach = true })
end

local function snapshot_originals(state)
  if next(state.original or {}) ~= nil then
    return
  end

  state.original = {
    ghostty_theme_line = capture_original_theme_line(GHOSTTY_CONFIG_PATH, function(line)
      return line:match '^%s*theme%s*=' ~= nil
    end),
    tmux_powerline_theme_line = capture_original_theme_line(TMUX_POWERLINE_CONFIG_PATH, function(line)
      return line:match '^%s*export%s+TMUX_POWERLINE_THEME=' ~= nil
    end),
    tmux_colors = read_file(TMUX_POWERLINE_COLORS_PATH) or vim.NIL,
    tmux_status_style = tmux_show_option 'status-style',
    tmux_status_style_line = capture_tmux_conf_option_line 'status-style',
  }
end

local function apply_external_theme(colors)
  if in_ghostty() then
    write_file(GHOSTTY_THEME_PATH, ghostty_theme_content(colors))

    replace_first_matching_line(GHOSTTY_CONFIG_PATH, function(line)
      return line:match '^%s*theme%s*=' ~= nil
    end, ('theme = %s'):format(GHOSTTY_THEME_NAME))
  end

  if in_tmux() then
    replace_first_matching_line(TMUX_POWERLINE_CONFIG_PATH, function(line)
      return line:match '^%s*export%s+TMUX_POWERLINE_THEME=' ~= nil
    end, ('export TMUX_POWERLINE_THEME="%s"'):format(TMUX_POWERLINE_THEME_NAME))

    write_file(TMUX_POWERLINE_COLORS_PATH, tmux_colors_content(colors))
    tmux_set_option('status-style', ('bg=%s,fg=%s'):format(colors.panel, colors.fg))
    refresh_tmux_clients()
  end
end

local function restore_originals(state)
  local original = state.original or {}

  if original.ghostty_theme_line == vim.NIL then
    remove_first_matching_line(GHOSTTY_CONFIG_PATH, function(line)
      return line:match '^%s*theme%s*=' ~= nil
    end)
  elseif original.ghostty_theme_line then
    replace_first_matching_line(GHOSTTY_CONFIG_PATH, function(line)
      return line:match '^%s*theme%s*=' ~= nil
    end, original.ghostty_theme_line)
  end

  if original.tmux_powerline_theme_line == vim.NIL then
    remove_first_matching_line(TMUX_POWERLINE_CONFIG_PATH, function(line)
      return line:match '^%s*export%s+TMUX_POWERLINE_THEME=' ~= nil
    end)
  elseif original.tmux_powerline_theme_line then
    replace_first_matching_line(TMUX_POWERLINE_CONFIG_PATH, function(line)
      return line:match '^%s*export%s+TMUX_POWERLINE_THEME=' ~= nil
    end, original.tmux_powerline_theme_line)
  end

  if original.tmux_colors == vim.NIL then
    delete_file(TMUX_POWERLINE_COLORS_PATH)
  elseif type(original.tmux_colors) == 'string' then
    write_file(TMUX_POWERLINE_COLORS_PATH, original.tmux_colors)
  end

  if type(original.tmux_status_style) == 'string' and original.tmux_status_style ~= '' then
    tmux_set_option('status-style', original.tmux_status_style)
  elseif original.tmux_status_style_line ~= vim.NIL and type(original.tmux_status_style_line) == 'string' then
    local value = original.tmux_status_style_line:gsub('^%s*set%-option%s+%-g%s+status%-style%s+', '', 1):gsub('^%s*set%s+%-g%s+status%-style%s+', '', 1)
    if value ~= '' then
      tmux_set_option('status-style', value)
    end
  end

  refresh_tmux_clients()
end

local function current_pid_key()
  return tostring(vim.fn.getpid())
end

function M.sync_current_theme()
  -- Headless runs (scripts, :checkhealth CI, ...) have nothing to theme and
  -- used to leave stale PIDs behind plus modified tracked files.
  if #vim.api.nvim_list_uis() == 0 or not (in_ghostty() or in_tmux()) then
    return
  end

  local state = load_state()
  active_pid_count(state)
  if next(state.pids) == nil and next(state.original or {}) ~= nil then
    restore_originals(state)
    state.original = {}
  end

  snapshot_originals(state)
  state.pids[current_pid_key()] = true
  apply_external_theme(build_palette())
  save_state(state)
end

-- Debounced entry point: theme changes fire several events in a row.
function M.request_sync()
  if sync_timer then
    sync_timer:stop()
  else
    sync_timer = assert(vim.uv.new_timer())
  end

  sync_timer:start(
    300,
    0,
    vim.schedule_wrap(function()
      pcall(M.sync_current_theme)
    end)
  )
end

function M.teardown()
  local state = load_state()
  active_pid_count(state)
  state.pids[current_pid_key()] = nil

  if next(state.pids) == nil then
    restore_originals(state)
    clear_state()
    return
  end

  save_state(state)
end

function M.setup()
  if augroup then
    return
  end

  augroup = vim.api.nvim_create_augroup('ExternalThemeSync', { clear = true })

  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = augroup,
    callback = function()
      pcall(M.teardown)
    end,
  })

  M.request_sync()
end

return M
