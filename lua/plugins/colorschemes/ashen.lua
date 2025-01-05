return {
    "ficcdaf/ashen.nvim",
    priority = 1000,
    lazy = false,
    config = function()
        require("ashen").load()
        vim.cmd("colorscheme ashen")
    end
}
