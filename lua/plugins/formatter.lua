return {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    keys = {
        {
            "<Leader>fo",
            function ()
                require'conform'.format({ async = true, lsp_fallback = true })
            end,
            mode = "n",
        }
    },
    opts = {
        formatters_by_ft = {
            python = { "black" },
            json = { "clang-format" },
            java = { "google-java-format" },
            sh = { "beautysh" },
            rust = { "rustfmt" }
        },
    }
}
