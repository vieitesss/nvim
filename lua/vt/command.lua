return {
    dir = "~/personal/command.nvim",
    dev = true,
		lazy = false,
    config = function()
        require("command").setup()
    end,
    keys = {
        { "<leader>ce", "<cmd>CommandExecute<CR>" },
        { "<leader>cl", "<cmd>CommandExecuteLast<CR>" }
    }
}
