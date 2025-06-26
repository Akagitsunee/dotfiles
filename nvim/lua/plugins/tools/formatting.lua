return {
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre", "BufNewFile" },
        cmd = { "ConformInfo" },
        config = function()
            local conform = require("conform")

            -- 🎯 Formatter Configuration
            conform.setup({
                formatters_by_ft = {
                    lua = { "stylua" },
                    javascript = { "prettier", "eslint_d" },
                    typescript = { "prettier", "eslint_d" },
                    javascriptreact = { "prettier", "eslint_d" },
                    typescriptreact = { "prettier", "eslint_d" },
                    json = { "prettier" },
                    yaml = { "prettier" },
                    markdown = { "prettier" },
                    html = { "prettier" },
                    css = { "prettier" },
                    scss = { "prettier" },
                    python = { "isort", "black" },
                    java = { "google-java-format" },
                    go = { "goimports", "gofmt" },
                },

                -- 🎨 Visual Formatting Options
                format_on_save = function(bufnr)
                    -- Respect global setting from config
                    if not _G.config.behavior.format_on_save then
                        return false
                    end

                    -- Skip formatting for large files (performance)
                    local max_filesize = 100 * 1024 -- 100 KB
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
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
                        prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
                    },
                    prettier = {
                        prepend_args = { "--tab-width", "2", "--single-quote", "true" },
                    },
                },
            })

            -- 🎯 Smart Format Function (Your Original Logic Enhanced)
            local function smart_format()
                local bufnr = vim.api.nvim_get_current_buf()

                local ok, _ = pcall(require("conform").format, {
                    bufnr = bufnr,
                    timeout_ms = 1000,
                    lsp_fallback = true,
                })

                if not ok then
                    vim.lsp.buf.format({ async = true, bufnr = bufnr })
                end
            end

            -- 🔄 Auto-format Setup (Respects Global Config)
            if _G.config.behavior.format_on_save then
                local format_group = vim.api.nvim_create_augroup("SmartFormatOnSave", { clear = true })
                vim.api.nvim_create_autocmd("BufWritePre", {
                    group = format_group,
                    callback = smart_format,
                    desc = "Smart format on save",
                })
            end

            -- 🎮 User Commands for Manual Control
            vim.api.nvim_create_user_command("Format", smart_format, {
                desc = "Format current buffer with smart detection",
            })

            vim.api.nvim_create_user_command("FormatToggle", function()
                _G.config.behavior.format_on_save = not _G.config.behavior.format_on_save

                if _G.config.behavior.format_on_save then
                    -- Enable auto-format
                    local format_group = vim.api.nvim_create_augroup("SmartFormatOnSave", { clear = true })
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        group = format_group,
                        callback = smart_format,
                        desc = "Smart format on save",
                    })

                    require("notify")("Format on save enabled", "info", {
                        title = "Formatting",
                        icon = _G.config.icons and _G.config.icons.ui.check or "✓",
                    })
                else
                    -- Disable auto-format
                    pcall(vim.api.nvim_del_augroup_by_name, "SmartFormatOnSave")

                    require("notify")("Format on save disabled", "warn", {
                        title = "Formatting",
                        icon = _G.config.icons and _G.config.icons.ui.close or "✗",
                    })
                end
            end, {
                desc = "Toggle format on save",
            })

            -- Note: Keymaps are defined in config/keymaps.lua
        end,
    },

    -- 🔍 Code Linting with nvim-lint
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")

            -- 🎯 Linter Configuration
            lint.linters_by_ft = {
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescriptreact = { "eslint_d" },
                python = { "pylint", "mypy" },
                markdown = { "markdownlint" },
                yaml = { "yamllint" },
                dockerfile = { "hadolint" },
                sh = { "shellcheck" },
                lua = { "luacheck" },
            }

            -- 🔧 Custom Linter Settings
            lint.linters.luacheck.args = {
                "--globals", "vim", "_G",
                "--formatter", "plain",
                "--codes",
                "--ranges",
                "-",
            }

            -- ⚡ Smart Linting Function
            local function smart_lint()
                local bufnr = vim.api.nvim_get_current_buf()

                -- Skip linting for large files (performance)
                local max_filesize = 200 * 1024 -- 200 KB
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
                if ok and stats and stats.size > max_filesize then
                    return
                end

                -- Skip if file is not modifiable
                if not vim.bo[bufnr].modifiable then
                    return
                end

                lint.try_lint()
            end

            -- 🔄 Auto-lint Events (Optimized for Performance)
            local lint_group = vim.api.nvim_create_augroup("SmartLinting", { clear = true })

            -- Lint after file operations
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
                group = lint_group,
                callback = smart_lint,
                desc = "Lint after file operations",
            })

            -- Lint after leaving insert mode (with debounce)
            local lint_timer = nil
            vim.api.nvim_create_autocmd("InsertLeave", {
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
                desc = "Lint after leaving insert mode (debounced)",
            })

            -- 🎮 User Commands
            vim.api.nvim_create_user_command("LintBuffer", smart_lint, {
                desc = "Lint current buffer",
            })

            vim.api.nvim_create_user_command("LintInfo", function()
                local ft = vim.bo.filetype
                local linters = lint.linters_by_ft[ft] or {}

                if #linters == 0 then
                    require("notify")("No linters configured for " .. ft, "info", {
                        title = "Linting",
                    })
                else
                    require("notify")("Active linters: " .. table.concat(linters, ", "), "info", {
                        title = "Linting",
                    })
                end
            end, {
                desc = "Show active linters for current filetype",
            })

            -- Note: Keymaps are defined in config/keymaps.lua
        end,
    },
}

-- vim: ts=2 sts=2 sw=2 et
