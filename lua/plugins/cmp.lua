return {
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "v0.*",
    build = "cargo build --release",

    ---@module "blink-cmp"
    ---@type blink.cmp.Config
    opts = {
        fuzzy = { implementation = 'prefer_rust_with_warning' },
        signature = {
            enabled = true,
        },
        keymap = {
            preset = "default",
            ["<C-space>"] = {},
            ["<C-p>"] = {},
            ["<Tab>"] = {},
            ["<S-Tab>"] = {},

            -- ["<C-e>"] = { "hide" },
            ["<C-y>"] = { "show", "show_documentation", "hide_documentation" },

            ["<C-n>"] = { "select_and_accept" },

            ["<C-k>"] = { "select_prev", "fallback" },
            ["<C-j>"] = { "select_next", "fallback" },

            ["<C-b>"] = { "scroll_documentation_down", "fallback" },
            ["<C-f>"] = { "scroll_documentation_up", "fallback" },

            ["<C-l>"] = { "snippet_forward", "fallback" },
            ["<C-h>"] = { "snippet_backward", "fallback" },
        },

        appearance = {
            use_nvim_cmp_as_default = true,
            nerd_font_variant = "normal",
        },

        completion = {
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 200,
            }
        },

        cmdline = {
            keymap = {
                ['<Tab>'] = { 'show', 'accept' },
                ['<CR>'] = { 'accept_and_enter', 'fallback' },
            },
            completion = {
                menu = {
                    auto_show = function(ctx)
                        return vim.fn.getcmdtype() == ':'
                    end,
                },
            },
        },
        sources = {
            default = { "lsp" },
        }
    },
}
