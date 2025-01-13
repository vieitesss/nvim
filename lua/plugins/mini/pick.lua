local grep_visual = function()
    local get_selected_text = function()
        local mode = vim.api.nvim_get_mode().mode
        local opts = {}
        if mode == "v" or mode == "V" or mode == "\22" then opts.type = mode end
        return vim.fn.getregion(vim.fn.getpos "v", vim.fn.getpos ".", opts)
    end

    local chars_to_escape = "'\\\"(){}[]<>+*-"
    require("mini.pick").builtin.grep({ pattern = vim.fn.escape(vim.fn.join(get_selected_text(), " "), chars_to_escape) })
end

return {
    {
        "echasnovski/mini.extra",
        version = false,
        lazy = false,
    },
    {
        "echasnovski/mini.pick",
        version = false,
        lazy = false,
        dependencies = "echasnovski/mini.extra",
        keys = {
            { "<Leader>ff", "<cmd>lua require('mini.pick').builtin.files()<CR>" },
            { "<Leader>fg", "<cmd>lua require('mini.pick').builtin.grep_live({tool = 'git'})<CR>" },
            { "<Leader>fh", "<cmd>lua require('mini.pick').builtin.help()<CR>" },
            { "<Leader>fg", grep_visual,                                            mode = "x" },
            { "<Leader>fb", "<cmd>lua require('mini.pick').builtin.buffers()<CR>" },
            { "<Leader>dot", function()
                require("mini.pick").builtin.files(
                    { tool = "git" },
                    { source = { cwd = require("vt").dotfiles_dir() } }
                )
            end, },
            { "<Leader>obs", "<cmd>lua require('mini.pick').builtin.files({}, { source = {cwd = '~/obsidian/'}})<CR>", },
            { "<Leader>nv",  "<cmd>lua require('mini.pick').builtin.files({}, { source = {cwd = '~/.config/nvim/'}})<CR>", },
            { "<Leader>fd",  "<cmd>lua require('mini.extra').pickers.diagnostic()<CR>" },
            { "<Leader>fk",  "<cmd>lua require('mini.extra').pickers.keymaps()<CR>" },
        },
        opts = {
            -- Keys for performing actions. See `:h MiniPick-actions`.
            mappings = {
                choose_marked  = '<C-q>',
                mark           = '<Tab>',
                move_down      = '<C-j>',
                move_up        = '<C-k>',
                refine_marked  = '<C-n>',
                stop           = '<Esc>',
                toggle_preview = '<C-p>',
            },
        },
    }
}
