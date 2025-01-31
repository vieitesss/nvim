return {
    {
        "ThePrimeagen/harpoon",
        dependecies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>hh", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", { silent = true } },
            { "<leader>ha", "<cmd>lua require('harpoon.mark').add_file()<cr>",        { silent = true } },
            { "<leader>hn", "<cmd>lua require('harpoon.ui').nav_next()<cr>",          { silent = true } },
            { "<leader>hp", "<cmd>lua require('harpoon.ui').nav_prev()<cr>",          { silent = true } },
            { "<leader>j",  "<cmd>lua require('harpoon.ui').nav_file(1)<cr>",         { silent = true } },
            { "<leader>k",  "<cmd>lua require('harpoon.ui').nav_file(2)<cr>",         { silent = true } },
            { "<leader>l",  "<cmd>lua require('harpoon.ui').nav_file(3)<cr>",         { silent = true } },
            { "<leader>;",  "<cmd>lua require('harpoon.ui').nav_file(4)<cr>",         { silent = true } },
        }
    }
}
