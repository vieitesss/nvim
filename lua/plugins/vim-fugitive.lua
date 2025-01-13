return {
    "tpope/vim-fugitive",
    event = "BufReadPre",
    keys = {
        { "<Space>gs", ":Git<CR>" },
        { "<Space>gd", ":Gvdiffsplit<CR>" },
        { "<Space>gp", ":Git push<CR>" },
        { "<Space>gl", ":Git log<CR>" },
        { "<Space>gb", ":Git blame --date short<CR>" },
        { "<Space>gP", ":Git pull<CR>" },
    }
}
