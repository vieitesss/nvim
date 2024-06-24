return {
    "alexghergh/nvim-tmux-navigation",
    keys = {
        { "<C-h>", "<cmd>lua require('nvim-tmux-navigation').NvimTmuxNavigateLeft()<cr>", { silent = true } },
        { "<C-l>", "<cmd>lua require('nvim-tmux-navigation').NvimTmuxNavigateRight()<cr>", { silent = true } },
        { "<C-j>", "<cmd>lua require('nvim-tmux-navigation').NvimTmuxNavigateDown()<cr>", { silent = true } },
        { "<C-k>", "<cmd>lua require('nvim-tmux-navigation').NvimTmuxNavigateUp()<cr>", { silent = true } },
    },
    config = function()
        require('nvim-tmux-navigation').setup({
            disable_when_zoomed = true,
            -- keybindings = {
            --     left = "<C-h>",
            --     right = "<C-l>",
            --     down = "<C-j>",
            --     up = "<C-k>"
            -- }
        })
    end
}
