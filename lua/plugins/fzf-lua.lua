local function dotfiles_dir()
    local out = vim.fn.system("uname -a")
    local pc = string.match(out, "^([%w]+)")

    local dir = ""
    if pc == "Darwin" then
        dir = "~/.mac_config/"
    elseif pc == "Linux" then
        dir = "~/.dot_linux/"
    end

    require('fzf-lua').files({ cwd = dir })
end

return {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    keys = {
        { "<Leader>ff",  "<cmd>lua require('fzf-lua').files()<CR>" },
        { "<Leader>fg",  "<cmd>lua require('fzf-lua').live_grep()<CR>" },
        { "<Leader>fg",  "<cmd>lua require('fzf-lua').grep_visual()<CR>",                    mode = "x" },
        { "<Leader>fb",  "<cmd>lua require('fzf-lua').buffers()<CR>" },
        { "<Leader>dot", dotfiles_dir, },
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
