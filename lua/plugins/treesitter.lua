return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufRead",
    -- lazy = false,
    config = function()
        require('nvim-treesitter.configs').setup({
            modules = {},
            ignore_install = {},
            ensure_installed = {
                "bash",
                "c",
                "java",
                "javascript",
                "json",
                "lua",
                "vim",
                "cpp",
                "python",
                "latex",
                "html",
            }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true, -- false will disable the whole extension
                additional_vim_regex_highlighting = false,
                -- disable = function (lang)
                --     local colorscheme = vim.api.nvim_exec2("colorscheme", { output = true })["output"]
                --     return lang == "latex" and colorscheme == "kanagawa"
                -- end
            },
            indent = { enable = false },
            autotag = { enable = true },
        })
    end
}
