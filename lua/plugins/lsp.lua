return {
    {
        "williamboman/mason.nvim",
        opts = {
            automatic_installation = true,
            ui = {
                icons = {
                    package_installed = "",
                    package_pending = "➜",
                    package_uninstalled = "",
                },
            },
        },
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
    },
    {
        "neovim/nvim-lspconfig",
        event = { "UIEnter", "BufNewFile" },
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "echasnovski/mini.extra",
        },
        config = function()
            require("lsp")
        end,
    },
}
