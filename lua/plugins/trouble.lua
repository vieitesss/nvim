return {
    "folke/trouble.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
        {
            "<leader>xx",
            "<cmd>Trouble diagnostics toggle<cr>"
        }
    }
}
