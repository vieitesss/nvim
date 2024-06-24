return {
    "folke/tokyonight.nvim",
    config = function()
        require("tokyonight").setup({
            style = "storm",
            transparent = true,
            styles = {
                comments = { italic = false },
                keywords = { italic = false }
            }
        })
        vim.api.nvim_exec2("colorscheme tokyonight", {})
    end
}
