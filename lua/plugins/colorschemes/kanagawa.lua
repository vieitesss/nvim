return {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require('kanagawa').setup({
            transparent = true,
            -- colors = {
            --     palette = {
            --         kanagawa wave fg
            --         fujiWhite = "#e8e8d8",
            --     },
            -- }
        })

        vim.cmd("colorscheme kanagawa-dragon")
    end,
}
