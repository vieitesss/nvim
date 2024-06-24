return {
    "loctvl842/monokai-pro.nvim",
    name = "monokai-pro",
    lazy = false,
    priority = 9999,
    config = function()
        require 'monokai-pro'.setup({
            filter = "spectrum",
            styles = {
                comment = { italic = false },
                keyword = { italic = false },
                type = { italic = false },
                storageclass = { italic = false },
                structure = { italic = false },
                parameter = { italic = false },
                annotation = { italic = false },
                tag_attribute = { italic = false },
            }
        })
        vim.api.nvim_exec2("colorscheme monokai-pro", {})
    end
}
