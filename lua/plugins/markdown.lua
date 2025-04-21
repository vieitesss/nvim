return {
    "OXY2DEV/markview.nvim",
    ft = "markdown",
    config = function()
        require("markview").setup({
            preview = {
                icon_provider = "mini"
            }
        })
        require("markview.extras.checkboxes").setup({})
    end
}
