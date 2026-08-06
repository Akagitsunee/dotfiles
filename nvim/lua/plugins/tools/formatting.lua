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
          go = { 'goimports', 'gofumpt' },
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
          if ok and stats and stats.size > max_filesize then
            return false
          end

          return {
            timeout_ms = 1000,
            lsp_fallback = true,
          }
        end,

        formatters = {
          stylua = {
            prepend_args = { '--indent-type', 'Spaces', '--indent-width', '2' },
          },
          prettierd = {
            prepend_args = { '--tab-width', '2', '--single-quote', 'true' },
          },
        },
      }

      -- 🎮 User Commands for Manual Control
      vim.api.nvim_create_user_command('Format', function()
        require('conform').format { timeout_ms = 1000, lsp_fallback = true }
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
        lua = { 'luacheck' },
      }

      -- 🔧 Custom Linter Settings
      lint.linters.luacheck.args = {
        '--globals',
        'vim',
        '_G',
        '--formatter',
        'plain',
        '--codes',
        '--ranges',
        '-',
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
