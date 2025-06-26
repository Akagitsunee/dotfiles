return {
    -- Copilot
    {
        'zbirenbaum/copilot.lua',
        cmd = 'Copilot',
        event = 'InsertEnter',
        config = function()
            require('copilot').setup {
                suggestion = { enabled = false },
                panel = { enabled = false },
            }
        end,
    },

    -- Copilot Chat
    {
        'CopilotC-Nvim/CopilotChat.nvim',
        dependencies = {
            'zbirenbaum/copilot.lua',
            'nvim-lua/plenary.nvim',
        },
        opts = {
            debug = false,
            context = 'buffer',
            show_help = true,
            prompts = {
                RubberDuck = {
                    prompt = 'You are my rubber duck debugging partner. Help me think through this problem: $input',
                },
                SmartSolution = {
                    prompt = 'Given the code context, suggest a smart approach to: $input',
                },
            },
        },
        keys = {
            { '<leader>ac', ':CopilotChat ',           desc = 'CopilotChat - Ask a question' },
            { '<leader>ae', ':CopilotChatExplain<cr>', desc = 'CopilotChat - Explain code' },
            { '<leader>at', ':CopilotChatTests<cr>',   desc = 'CopilotChat - Generate tests' },
            { '<leader>ar', ':CopilotChatReview<cr>',  desc = 'CopilotChat - Review code' },
            { '<leader>af', ':CopilotChatFix<cr>',     desc = 'CopilotChat - Fix issue' },
        },
    },
}

-- vim: ts=2 sts=2 sw=2 et
