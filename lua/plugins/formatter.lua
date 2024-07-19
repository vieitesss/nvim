return {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    keys = {
        {
            "<Leader>fo",
            function()
                require("conform").format({ async = true, lsp_fallback = true })
            end,
            mode = "n",
        }
    },
    opts = {
        formatters = {
            my_rustfmt = {
                command = "cargo +nightly fmt",
            }
        },
        formatters_by_ft = {
            go = { "gofmt" },
            python = { "black" },
            json = { "clang-format" },
            java = { "google-java-format" },
            sh = { "beautysh" },
            rust = { "my_rustfmt" }
        },
    }
}
