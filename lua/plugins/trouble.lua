return {
    "folke/trouble.nvim",
    event = "BufReadPre",
    config = function()
        require("trouble").setup({
            modes = {
                diagnostics = {
                    auto_open = true
                }
            }
        })
    end,
    keys = {
        {
            "<leader>xx",
            "<cmd>Trouble diagnostics toggle<cr>"
        }
    }
}
