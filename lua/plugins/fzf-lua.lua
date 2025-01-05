return {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    keys = {
        { "<Leader>ff",  "<cmd>lua require('fzf-lua').files()<CR>" },
        { "<Leader>fg",  "<cmd>lua require('fzf-lua').live_grep()<CR>" },
        { "<Leader>fh",  "<cmd>lua require('fzf-lua').helptags()<CR>" },
        { "<Leader>fg",  "<cmd>lua require('fzf-lua').grep_visual()<CR>",                    mode = "x" },
        { "<Leader>fb",  "<cmd>lua require('fzf-lua').buffers()<CR>" },
        { "<Leader>dot", require("vt").dotfiles_dir, },
        { "<Leader>obs", "<cmd>lua require('fzf-lua').files({cwd = '~/obsidian/'})<CR>", },
        { "<Leader>nv",  "<cmd>lua require('fzf-lua').files({cwd = '~/.config/nvim/'})<CR>", },
        { "<Leader>fd", "<cmd>lua require('fzf-lua').diagnostics_workspace()<CR>" },
    },
    config = function()
        require('fzf-lua').setup({})

        local actions = require('fzf-lua.actions')
        local opts = {
            'default-title',
            winopts = {
                preview = {
                    vertical = "down:40%",
                    layout = "vertical",
                }
            },
            keymap = {
                builtin = {
                    true,
                    ["<C-d>"] = "preview-page-down",
                    ["<C-u>"] = "preview-page-up",
                },
                fzf = {
                    true,
                    ["ctrl-a"] = "toggle-all",
                }
            },
            actions = {
                files = {
                    true,
                    ["ctrl-q"] = actions.file_sel_to_qf
                }
            }
        }
        require('fzf-lua').setup(opts)
    end
}
