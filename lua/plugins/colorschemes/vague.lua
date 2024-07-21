return {
    "vague2k/vague.nvim",
    config = function ()
        require("vague").setup({
            transparent = true,
            style = {
                comments = "none",
                strings = "none",
                keywords = "none",
                conditionals = "none",
                functions = "none",
                headings = "none",
                variables = "none",
                keywords_return = "none",
                operators = "none"
            }
        })
    end
}
