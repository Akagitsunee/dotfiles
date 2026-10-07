-- Load options and globalstatus
require 'config.globals'

local log_dir = vim.fn.stdpath 'config' .. '/.logs'
local log_file = log_dir .. '/nvim-errors.log'

local function level_name(level)
  local levels = vim.log.levels
  if level == levels.TRACE then
    return 'TRACE'
  elseif level == levels.DEBUG then
    return 'DEBUG'
  elseif level == levels.INFO then
    return 'INFO'
  elseif level == levels.WARN then
    return 'WARN'
  elseif level == levels.ERROR then
    return 'ERROR'
  end

  return tostring(level or 'INFO')
end

local function append_error_log(message, level, opts)
  local ok, err = pcall(function()
    vim.fn.mkdir(log_dir, 'p')

    local title = opts and opts.title and (' [' .. opts.title .. ']') or ''
    local header = string.format('%s [%s]%s', os.date '%Y-%m-%d %H:%M:%S', level_name(level), title)
    local lines = vim.split(tostring(message), '\n', { plain = true })
    table.insert(lines, 1, header)
    table.insert(lines, '')
    vim.fn.writefile(lines, log_file, 'a')
  end)

  if not ok then
    vim.schedule(function()
      vim.api.nvim_echo({ { 'Failed to write config error log: ' .. tostring(err), 'WarningMsg' } }, true, {})
    end)
  end
end

_G.config_log_file = log_file
_G.append_error_log = append_error_log
_G.install_notify_logger = function(notify_impl)
  if type(notify_impl) ~= 'function' then
    return
  end

  if rawget(_G, '_notify_logger_source') == notify_impl then
    return
  end

  vim.notify = function(message, level, opts)
    local notify_level = level or vim.log.levels.INFO
    if notify_level >= vim.log.levels.WARN then
      append_error_log(message, notify_level, opts)
    end
    return notify_impl(message, level, opts)
  end

  _G._notify_logger_source = notify_impl
end

_G.install_notify_logger(vim.notify)

vim.api.nvim_create_autocmd('VimLeavePre', {
  group = vim.api.nvim_create_augroup('ConfigErrorLogging', { clear = true }),
  callback = function()
    if vim.v.errmsg ~= '' then
      append_error_log(vim.v.errmsg, vim.log.levels.ERROR, { title = 'vim.v.errmsg' })
    end
  end,
})

vim.g.base46_cache = vim.fn.stdpath 'config' .. '/.base46_cache/'

-- Bootstrap lazy.nvim
require 'config.lazy'

if vim.fn.isdirectory(vim.g.base46_cache) == 1 then
  for _, file in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
    pcall(dofile, vim.g.base46_cache .. file)
  end
end

-- Load core configuration
require 'config.options'
require 'config.keymaps'
require 'config.autocmds'

-- vim: ts=2 sts=2 sw=2 et
