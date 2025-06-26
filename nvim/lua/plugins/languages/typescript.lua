return {
    {
        "pmizio/typescript-tools.nvim",
        ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "neovim/nvim-lspconfig",
            -- Make sure this loads after the main LSP config
            "blink.cmp",
        },
        config = function()
            local utils = require("utils.filter")
            local capabilities = require('blink.cmp').get_lsp_capabilities()

            -- Custom handlers using global config
            local handlers = {
                ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
                    border = _G.config.ui.border
                }),
                ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
                    border = _G.config.ui.border
                }),
                ["textDocument/definition"] = function(err, result, method, ...)
                    if vim.tbl_islist(result) and #result > 1 then
                        local filtered_result = utils.filter(result, utils.filterReactDTS)
                        return vim.lsp.handlers["textDocument/definition"](err, filtered_result, method, ...)
                    end
                    vim.lsp.handlers["textDocument/definition"](err, result, method, ...)
                end,
            }

            local on_attach = function(client, bufnr)
                -- Enable inlay hints
                -- local debounce = vim.schedule_wrap(function()
                --    vim.lsp.inlay_hint.enable(true, { bufnr = 0 })
                -- end)

                -- vim.api.nvim_create_autocmd("CursorHold", {
                --    pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
                --    callback = debounce,
                -- })

                -- Optional: Disable tsserver's formatting in favor of prettier/eslint
                --
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
            end

            require("typescript-tools").setup({
                capabilities = capabilities,
                handlers = handlers,
                on_attach = on_attach,

                settings = {
                    -- Performance settings
                    separate_diagnostic_server = true,
                    publish_diagnostic_on = "insert_leave",
                    tsserver_max_memory = "auto",

                    -- Formatting preferences
                    tsserver_format_options = {
                        insertSpaceAfterCommaDelimiter = true,
                        insertSpaceAfterConstructor = false,
                        insertSpaceAfterSemicolonInForStatements = true,
                        insertSpaceBeforeAndAfterBinaryOperators = true,
                        insertSpaceAfterKeywordsInControlFlowStatements = true,
                        insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
                        insertSpaceBeforeFunctionParenthesis = false,
                        insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = false,
                        insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
                        insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true,
                        insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = true,
                        insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,
                        insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = false,
                        insertSpaceAfterTypeAssertion = false,
                        placeOpenBraceOnNewLineForFunctions = false,
                        placeOpenBraceOnNewLineForControlBlocks = false,
                        semicolons = "ignore",
                        indentSwitchCase = true,
                    },

                    -- File preferences with inlay hints
                    tsserver_file_preferences = {
                        -- Inlay hint settings
                        includeInlayParameterNameHints = "literals",
                        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                        includeInlayFunctionParameterTypeHints = true,
                        includeInlayVariableTypeHints = false,
                        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                        includeInlayPropertyDeclarationTypeHints = false,
                        includeInlayFunctionLikeReturnTypeHints = false,
                        includeInlayEnumMemberValueHints = true,

                        -- General preferences
                        quotePreference = "auto",
                        importModuleSpecifierEnding = "auto",
                        jsxAttributeCompletionStyle = "auto",
                        allowTextChangesInNewFiles = true,
                        providePrefixAndSuffixTextForRename = true,
                        allowRenameOfImportPath = true,
                        includeAutomaticOptionalChainCompletions = true,
                        provideRefactorNotApplicableReason = true,
                        generateReturnInDocTemplate = true,
                        includeCompletionsForImportStatements = true,
                        includeCompletionsWithSnippetText = true,
                        includeCompletionsWithClassMemberSnippets = true,
                        includeCompletionsWithObjectLiteralMethodSnippets = true,
                        useLabelDetailsInCompletionEntries = true,
                        allowIncompleteCompletions = true,
                        displayPartsForJSDoc = true,
                        disableLineTextInReferences = true,
                    },

                    -- Feature settings
                    expose_as_code_action = "all",
                    complete_function_calls = false,
                    include_completions_with_insert_text = true,
                    code_lens = "implementations_only",
                },
            })
        end,
    },
    {
        "vuki656/package-info.nvim",
        event = { "BufEnter package.json" },
        dependencies = { "MunifTanjim/nui.nvim" },
        config = function()
            require("package-info").setup({
                colors = {
                    up_to_date = _G.config.colors.success,
                    outdated = _G.config.colors.warning,
                    invalid = _G.config.colors.error,
                },
                icons = {
                    enable = true,
                    style = {
                        up_to_date = "|  ",
                        outdated = "|  ",
                        invalid = "|  ",
                    },
                },
                autostart = true,
                hide_up_to_date = false,
                hide_unstable_versions = false,
                package_manager = "npm",
            })
        end,
    },
}

-- vim: ts=2 sts=2 sw=2 et
