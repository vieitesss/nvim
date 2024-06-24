return {
    "ramojus/mellifluous.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("mellifluous").setup({
            color_set = 'mellifluous',
            mellifluous = {
                bg_contrast = 'hard',
            },
            -- transparent_background = {
            --     enabled = true
            -- }
        })
        vim.cmd([[colorscheme mellifluous]])
    end
}
