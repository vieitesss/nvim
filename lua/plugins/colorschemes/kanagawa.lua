return {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require('kanagawa').setup({
            theme = "wave",
            transparent = true,
            colors = {
                palette = {
                    -- kanagawa wave fg
                    fujiWhite = "#e8e8d8",
                },
            }
        })
        vim.api.nvim_exec2("colorscheme kanagawa", {})
    end,
}
