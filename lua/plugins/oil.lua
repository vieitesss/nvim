return {
    'stevearc/oil.nvim',
    name = 'oil',
    opts = {
        default_file_explorer = true,
        columns = {
            -- "permissions",
            -- "size",
            -- "icon",
        },
        float = {
            max_width = 60,
            max_height = 30
        },
        keymaps = {
            ["<C-v>"] = "actions.select_vsplit"
        },
        view_options = {
            show_hidden = true
        }
    },
    cmd = "Oil",
    keys = {
        { "<leader>pv", [[<cmd>Oil .<cr>]] },
        { "<leader>pf", [[<cmd>Oil %:p:h<cr>]] }
    }
}
