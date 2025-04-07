return {
    {
        "nvim-lua/plenary.nvim",
        lazy = false
    },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependecies = { "nvim-lua/plenary.nvim" },
        lazy = false,
        config = function()
            local opts = { silent = true }
            local harpoon = require("harpoon")

            harpoon:setup()
            vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, opts)
            vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, opts)
            vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end, opts)
            vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end, opts)
            vim.keymap.set("n", "<C-N>", function() harpoon:list():select(1) end, opts)
            vim.keymap.set("n", "<C-E>", function() harpoon:list():select(2) end, opts)
            vim.keymap.set("n", "<C-I>", function() harpoon:list():select(3) end, opts)
        end
    }
}
