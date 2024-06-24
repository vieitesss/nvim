return {
    "j-hui/fidget.nvim",
    event = "BufEnter",
    opts = {
        notification = {
            -- override_vim_notify = true,
            window = {
                winblend = 0,
            },
        },
        -- logger = {
        --     level = vim.log.levels.INFO,
        -- }
    }
}
