return {
  {
    'neovim/nvim-lspconfig',
    ft = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
    opts = {
      servers = {
        yamlls = {
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              format = { enable = true },
              schemas = {
                ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
                ['https://json.schemastore.org/github-action.json'] = '/action.{yml,yaml}',
                ['https://json.schemastore.org/docker-compose.json'] = 'docker-compose*.{yml,yaml}',
                ['https://json.schemastore.org/pre-commit-config.json'] = '.pre-commit-config.{yml,yaml}',
              },
            },
          },
        },
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
