return {
    -- Window maximizer for debugging sessions
    {
        "szw/vim-maximizer",
        cmd = "MaximizerToggle",
    },

    -- Main DAP plugin with comprehensive debugging support
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "theHamsta/nvim-dap-virtual-text",
            "nvim-neotest/nvim-nio",
            "rcarriga/nvim-dap-ui",
            {
                "LiadOz/nvim-dap-repl-highlights",
                config = true,
                dependencies = {
                    "mfussenegger/nvim-dap",
                    "nvim-treesitter/nvim-treesitter",
                },
                build = function()
                    if not require("nvim-treesitter.parsers").has_parser("dap_repl") then
                        vim.cmd(":TSInstall dap_repl")
                    end
                end,
            },
        },
        config = function()
            local dapui = require("dapui")
            local dap = require("dap")
            local dap_vt = require("nvim-dap-virtual-text")
            local dap_utils = require("dap.utils")

            -- ╭──────────────────────────────────────────────────────────╮
            -- │ DAP Virtual Text Setup (ADHD-Friendly Visual Feedback)  │
            -- ╰──────────────────────────────────────────────────────────╯
            dap_vt.setup({
                enabled = true,
                enabled_commands = true,
                highlight_changed_variables = true,    -- Visual feedback for changed values
                highlight_new_as_changed = false,      -- Reduce visual noise
                show_stop_reason = true,               -- Clear context when debugging stops
                commented = false,                     -- Keep virtual text clean
                only_first_definition = true,          -- Reduce cognitive load
                all_references = false,                -- Focus on current context
                filter_references_pattern = "<module", -- Filter noise
                virt_text_pos = "eol",                 -- End of line placement
                all_frames = false,                    -- Focus on current frame
                virt_lines = false,                    -- Prevent flickering
                virt_text_win_col = nil,
            })

            -- ╭──────────────────────────────────────────────────────────╮
            -- │ DAP UI Setup (Using Global Design Variables)            │
            -- ╰──────────────────────────────────────────────────────────╯
            dapui.setup({
                icons = {
                    expanded = _G.config.icons.ui.folder_open or "▾",
                    collapsed = _G.config.icons.ui.folder_closed or "▸"
                },
                mappings = {
                    expand = { "<CR>", "<2-LeftMouse>" },
                    open = "o",
                    remove = "d",
                    edit = "e",
                    repl = "r",
                    toggle = "t",
                },
                expand_lines = vim.fn.has("nvim-0.7"),
                layouts = {
                    {
                        elements = {
                            { id = "scopes", size = 0.25 },
                            "breakpoints",
                            "watches",
                        },
                        size = _G.config.layout.sidebar_width or 40,
                        position = "left",
                    },
                    {
                        elements = {
                            "repl",
                            "console",
                        },
                        size = 0.25,
                        position = "bottom",
                    },
                },
                floating = {
                    max_height = _G.config.layout.popup_max_height or nil,
                    max_width = _G.config.layout.popup_max_width or nil,
                    border = _G.config.ui.border or "rounded",
                    mappings = {
                        close = { "q", "<Esc>" },
                    },
                },
                windows = { indent = 1 },
                render = {
                    max_type_length = nil,
                },
            })

            -- ╭──────────────────────────────────────────────────────────╮
            -- │ DAP Core Setup                                           │
            -- ╰──────────────────────────────────────────────────────────╯
            dap.set_log_level("TRACE")

            -- Auto-open/close UI for seamless debugging experience
            dap.listeners.before.attach["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.launch["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            -- Enable virtual text for inline debugging info
            vim.g.dap_virtual_text = true

            -- ╭──────────────────────────────────────────────────────────╮
            -- │ Debugging Icons (Using Global Icon System)              │
            -- ╰──────────────────────────────────────────────────────────╯
            local debug_icons = _G.config.icons.debug or {
                breakpoint = "🔵",
                breakpoint_rejected = "🔴",
                breakpoint_condition = "🟡",
                stopped = "🟢",
            }

            vim.fn.sign_define("DapBreakpoint", {
                text = debug_icons.breakpoint,
                texthl = "",
                linehl = "",
                numhl = ""
            })
            vim.fn.sign_define("DapBreakpointRejected", {
                text = debug_icons.breakpoint_rejected,
                texthl = "",
                linehl = "",
                numhl = ""
            })
            vim.fn.sign_define("DapConditionalBreakpoint", {
                text = debug_icons.breakpoint_condition,
                texthl = "",
                linehl = "",
                numhl = ""
            })
            vim.fn.sign_define("DapStopped", {
                text = debug_icons.stopped,
                texthl = "",
                linehl = "",
                numhl = ""
            })

            -- ╭──────────────────────────────────────────────────────────╮
            -- │ JavaScript/TypeScript Debug Adapters                    │
            -- ╰──────────────────────────────────────────────────────────╯
            local js_debug_path = vim.fn.stdpath("data") ..
                "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

            dap.adapters["pwa-node"] = {
                type = "server",
                host = "localhost",
                port = "${port}",
                executable = {
                    command = "node",
                    args = { js_debug_path, "${port}" },
                }
            }

            dap.adapters["pwa-chrome"] = {
                type = "server",
                host = "localhost",
                port = "${port}",
                executable = {
                    command = "node",
                    args = { js_debug_path, "${port}" },
                }
            }

            -- ╭──────────────────────────────────────────────────────────╮
            -- │ Debug Configurations for JS/TS Ecosystem                │
            -- ╰──────────────────────────────────────────────────────────╯
            local js_languages = {
                "javascript",
                "typescript",
                "javascriptreact",
                "typescriptreact",
                "vue",
                "svelte",
            }

            local debug_configurations = {
                -- Chrome debugging for frontend applications
                {
                    type = "pwa-chrome",
                    request = "launch",
                    name = "Launch Chrome with localhost",
                    url = function()
                        local co = coroutine.running()
                        return coroutine.create(function()
                            vim.ui.input({
                                prompt = 'Enter URL: ',
                                default = 'http://localhost:3000'
                            }, function(url)
                                if url == nil or url == '' then
                                    return
                                else
                                    coroutine.resume(co, url)
                                end
                            end)
                        end)
                    end,
                    webRoot = '${workspaceFolder}',
                    protocol = 'inspector',
                    sourceMaps = true,
                    userDataDir = false,
                    skipFiles = {
                        "<node_internals>/**",
                        "node_modules/**",
                        "${workspaceFolder}/node_modules/**"
                    },
                    resolveSourceMapLocations = {
                        "${webRoot}/*",
                        "${webRoot}/apps/**/**",
                        "${workspaceFolder}/apps/**/**",
                        "${webRoot}/packages/**/**",
                        "${workspaceFolder}/packages/**/**",
                        "${workspaceFolder}/*",
                        "!**/node_modules/**",
                    }
                },

                -- Next.js server-side debugging
                {
                    name = 'Next.js: debug server-side',
                    type = 'pwa-node',
                    request = 'attach',
                    port = 9231,
                    skipFiles = { '<node_internals>/**', 'node_modules/**' },
                    cwd = '${workspaceFolder}',
                },

                -- Launch current file with pnpm dev
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch with pnpm dev",
                    cwd = vim.fn.getcwd(),
                    args = { "${file}" },
                    sourceMaps = true,
                    protocol = "inspector",
                    runtimeExecutable = "pnpm",
                    runtimeArgs = { "run-script", "dev" },
                    resolveSourceMapLocations = {
                        "${workspaceFolder}/**",
                        "!**/node_modules/**",
                    }
                },

                -- TypeScript with ts-node
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch with ts-node",
                    cwd = vim.fn.getcwd(),
                    runtimeArgs = { "--loader", "ts-node/esm" },
                    runtimeExecutable = "node",
                    args = { "${file}" },
                    sourceMaps = true,
                    protocol = "inspector",
                    skipFiles = { "<node_internals>/**", "node_modules/**" },
                    resolveSourceMapLocations = {
                        "${workspaceFolder}/**",
                        "!**/node_modules/**",
                    },
                },

                -- Jest testing
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Debug Jest Tests",
                    cwd = vim.fn.getcwd(),
                    runtimeArgs = { "${workspaceFolder}/node_modules/.bin/jest" },
                    runtimeExecutable = "node",
                    args = { "${file}", "--coverage", "false" },
                    rootPath = "${workspaceFolder}",
                    sourceMaps = true,
                    console = "integratedTerminal",
                    internalConsoleOptions = "neverOpen",
                    skipFiles = { "<node_internals>/**", "node_modules/**" },
                },

                -- Vitest testing
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Debug Vitest Tests",
                    cwd = vim.fn.getcwd(),
                    program = "${workspaceFolder}/node_modules/vitest/vitest.mjs",
                    args = { "--inspect-brk", "--threads", "false", "run", "${file}" },
                    autoAttachChildProcesses = true,
                    smartStep = true,
                    console = "integratedTerminal",
                    skipFiles = { "<node_internals>/**", "node_modules/**" },
                },

                -- Deno debugging
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Debug Deno",
                    cwd = vim.fn.getcwd(),
                    runtimeArgs = { "test", "--inspect-brk", "--allow-all", "${file}" },
                    runtimeExecutable = "deno",
                    attachSimplePort = 9229,
                },

                -- Attach to Chrome (for debugging running applications)
                {
                    type = "pwa-chrome",
                    request = "attach",
                    name = "Attach to Chrome",
                    program = "${file}",
                    cwd = vim.fn.getcwd(),
                    sourceMaps = true,
                    protocol = 'inspector',
                    port = function()
                        return vim.fn.input("Select port: ", 9222)
                    end,
                    webRoot = "${workspaceFolder}",
                    skipFiles = {
                        "<node_internals>/**",
                        "node_modules/**",
                        "${workspaceFolder}/node_modules/**"
                    },
                    resolveSourceMapLocations = {
                        "${webRoot}/*",
                        "${webRoot}/apps/**/**",
                        "${workspaceFolder}/apps/**/**",
                        "${webRoot}/packages/**/**",
                        "${workspaceFolder}/packages/**/**",
                        "${workspaceFolder}/*",
                        "!**/node_modules/**",
                    }
                },

                -- Attach to Node process
                {
                    type = "pwa-node",
                    request = "attach",
                    name = "Attach to Node Process",
                    cwd = vim.fn.getcwd(),
                    processId = dap_utils.pick_process,
                    skipFiles = { "<node_internals>/**" },
                },
            }

            -- Apply configurations to all JavaScript/TypeScript languages
            for _, language in ipairs(js_languages) do
                dap.configurations[language] = debug_configurations
            end
        end,
    },
}

-- vim: ts=2 sts=2 sw=2 et
