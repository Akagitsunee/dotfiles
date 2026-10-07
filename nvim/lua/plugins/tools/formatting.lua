return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre', 'BufNewFile' },
    cmd = { 'ConformInfo', 'Format', 'FormatToggle' },
    config = function()
      local conform = require 'conform'

      -- 🎯 Formatter Configuration
      conform.setup {
        formatters_by_ft = {
          lua = { 'stylua' },
          javascript = { 'prettierd' },
          typescript = { 'prettierd' },
          javascriptreact = { 'prettierd' },
          typescriptreact = { 'prettierd' },
          json = { 'prettierd' },
          yaml = { 'prettierd' },
          markdown = { 'prettierd' },
          html = { 'prettierd' },
          css = { 'prettierd' },
          scss = { 'prettierd' },
          svelte = { 'prettierd' },
          vue = { 'prettierd' },
          -- python = { "isort", "black" },
          -- java = { "google-java-format" },
          go = vim.fn.executable 'goimports' == 1 and { 'goimports', 'gofumpt' } or nil,
          sh = { 'shfmt' },
        },

        -- 🎨 Visual Formatting Options
        format_on_save = function(bufnr)
          -- Respect global setting from config
          if not _G.config.behavior.format_on_save then
            return false
          end

          -- Skip formatting for large files (performance)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
          if (ok and stats and stats.size > max_filesize) or vim.b[bufnr].large_file then
            return false
          end

          -- prettierd's first call has to start its daemon, so leave room for that.
          return {
            timeout_ms = 2000,
            lsp_format = 'fallback',
          }
        end,

        formatters = {
          -- stylua reads nvim/.stylua.toml by itself, no extra args needed.
          --
          -- prettierd accepts exactly ONE argument (the file path) and has no
          -- CLI options: extra flags make it fail with "Only a single file path
          -- is supported". Defaults therefore live in a config file that prettierd
          -- only uses when a project has no prettier config of its own.
          prettierd = {
            env = { PRETTIERD_DEFAULT_CONFIG = vim.fn.stdpath 'config' .. '/prettierrc.json' },
          },
        },
      }

      -- 🎮 User Commands for Manual Control
      vim.api.nvim_create_user_command('Format', function()
        require('conform').format { timeout_ms = 2000, lsp_format = 'fallback' }
      end, { desc = 'Format current buffer with smart detection' })

      vim.api.nvim_create_user_command('FormatToggle', function()
        _G.config.behavior.format_on_save = not _G.config.behavior.format_on_save

        local status = _G.config.behavior.format_on_save and 'enabled' or 'disabled'
        local icon = _G.config.behavior.format_on_save and (_G.config.icons and _G.config.icons.ui.check or '✓')
          or (_G.config.icons and _G.config.icons.ui.close or '✗')

        require 'notify'('Format on save ' .. status, _G.config.behavior.format_on_save and 'info' or 'warn', {
          title = 'Formatting',
          icon = icon,
        })
      end, {
        desc = 'Toggle format on save',
      })

      -- Note: Keymaps are defined in config/keymaps.lua
    end,
  },

  -- 🔍 Code Linting with nvim-lint
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = { 'LintBuffer', 'LintInfo' },
    config = function()
      local lint = require 'lint'

      -- 🎯 Linter Configuration
      lint.linters_by_ft = {
        javascript = { 'eslint_d' },
        typescript = { 'eslint_d' },
        javascriptreact = { 'eslint_d' },
        typescriptreact = { 'eslint_d' },
        -- python = { "pylint", "mypy" },
        svelte = { 'eslint_d' },
        markdown = { 'markdownlint' },
        yaml = { 'yamllint' },
        go = { 'golangcilint' },
        dockerfile = { 'hadolint' },
        sh = { 'shellcheck' },
        -- Lua has no linter here on purpose: Mason's luacheck is built against the system
        -- Lua 5.5 and crashes on load ("attempt to assign to const variable"), so it
        -- silently produced no diagnostics. lua_ls already reports them.
      }

      -- ⚡ Smart Linting Function
      local function smart_lint()
        local bufnr = vim.api.nvim_get_current_buf()
        local bufname = vim.api.nvim_buf_get_name(bufnr)

        -- 🛡️ Immediately exit if this is a temporary kubectl file
        if bufname:find 'kubectl%-edit' then
          return
        end
        -- Skip linting for large files (performance)
        local max_filesize = 200 * 1024 -- 200 KB
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
        if ok and stats and stats.size > max_filesize then
          return
        end

        -- Skip if file is not modifiable
        if not vim.bo[bufnr].modifiable then
          return
        end

        -- 🔍 Conditionally run eslint_d ONLY if config is present
        local names = lint._resolve_linter_by_ft(vim.bo[bufnr].filetype)
        local linters_to_run = {}

        for _, name in ipairs(names) do
          if name == 'eslint_d' then
            local eslint_root = vim.fs.find({
              '.eslintrc',
              '.eslintrc.js',
              '.eslintrc.cjs',
              '.eslintrc.yaml',
              '.eslintrc.yml',
              '.eslintrc.json',
              'eslint.config.js',
              'eslint.config.mjs',
              'eslint.config.cjs',
              'package.json',
            }, { path = vim.api.nvim_buf_get_name(bufnr), upward = true })[1]

            if eslint_root then
              table.insert(linters_to_run, name)
            end
          else
            table.insert(linters_to_run, name)
          end
        end

        if #linters_to_run > 0 then
          lint.try_lint(linters_to_run)
        end
      end

      -- 🔄 Auto-lint Events (Optimized for Performance)
      local lint_group = vim.api.nvim_create_augroup('SmartLinting', { clear = true })

      -- Lint after file operations
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost' }, {
        group = lint_group,
        callback = smart_lint,
        desc = 'Lint after file operations',
      })

      -- Lint after leaving insert mode (with debounce)
      local lint_timer = nil
      vim.api.nvim_create_autocmd('InsertLeave', {
        group = lint_group,
        callback = function()
          if lint_timer then
            vim.fn.timer_stop(lint_timer)
          end

          lint_timer = vim.fn.timer_start(_G.config.behavior.diagnostic_delay or 500, function()
            smart_lint()
            lint_timer = nil
          end)
        end,
        desc = 'Lint after leaving insert mode (debounced)',
      })

      -- 🎮 User Commands
      vim.api.nvim_create_user_command('LintBuffer', smart_lint, {
        desc = 'Lint current buffer',
      })

      vim.api.nvim_create_user_command('LintInfo', function()
        local ft = vim.bo.filetype
        local linters = lint.linters_by_ft[ft] or {}

        if #linters == 0 then
          require 'notify'('No linters configured for ' .. ft, 'info', {
            title = 'Linting',
          })
        else
          require 'notify'('Active linters: ' .. table.concat(linters, ', '), 'info', {
            title = 'Linting',
          })
        end
      end, {
        desc = 'Show active linters for current filetype',
      })

      -- Note: Keymaps are defined in config/keymaps.lua
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
