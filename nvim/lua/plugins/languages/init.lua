local function merge_language_specs(modules)
    local merged_ft = {}
    local seen_ft = {}
    local opts_mergers = {}

    for _, module_name in ipairs(modules) do
        local spec = require(module_name)[1]

        for _, ft in ipairs(spec.ft or {}) do
            if not seen_ft[ft] then
                seen_ft[ft] = true
                table.insert(merged_ft, ft)
            end
        end

        opts_mergers[#opts_mergers + 1] = spec.opts
    end

    return {
        "neovim/nvim-lspconfig",
        ft = merged_ft,
        opts = function(_, opts)
            opts.servers = opts.servers or {}

            for _, merger in ipairs(opts_mergers) do
                if type(merger) == "function" then
                    merger(nil, opts)
                elseif type(merger) == "table" then
                    opts.servers = vim.tbl_deep_extend("force", opts.servers, merger.servers or {})
                end
            end
        end,
    }
end

return {
    merge_language_specs({
        "plugins.languages.bashls",
        "plugins.languages.cssls",
        -- "plugins.languages.eslint",
        "plugins.languages.graphql",
        "plugins.languages.html",
        "plugins.languages.go",
        "plugins.languages.jsonls",
        "plugins.languages.lua_ls",
        "plugins.languages.tailwindcss",
        "plugins.languages.svelte",
        "plugins.languages.typescript",
        "plugins.languages.vuels",
        "plugins.languages.yamlls",
    }),
}

-- vim: ts=2 sts=2 sw=2 et
