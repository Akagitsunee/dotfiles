-- Standalone Vue setup (no hybrid-mode wiring into vtsls): `<template>`/`<style>`
-- completion, hover and diagnostics work; full `<script>` type intelligence
-- would need the vtsls `@vue/typescript-plugin` handshake, skipped here since
-- Vue is occasional rather than a daily driver alongside Svelte/React/Angular.
return {
    {
        "neovim/nvim-lspconfig",
        ft = { "vue" },
        opts = {
            servers = {
                vue_ls = {
                    on_attach = function(client)
                        -- Prettier owns formatting, not vue_ls
                        client.server_capabilities.documentFormattingProvider = false
                        client.server_capabilities.documentRangeFormattingProvider = false
                    end,
                },
            },
        },
    },
}

-- vim: ts=2 sts=2 sw=2 et
