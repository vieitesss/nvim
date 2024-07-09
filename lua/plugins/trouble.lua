return {
    "folke/trouble.nvim",
    event = "BufEnter",
    config = function()
        require("trouble").setup({
            modes = {
                diagnostics = {
                    auto_close = true,
                    auto_open = true
                }
            }
        })
    end
}
