return {
    {
        "iguanacucumber/magazine.nvim",
        name = "nvim-cmp",
        version = false,
        dependencies = {
            { "iguanacucumber/mag-cmdline",                     name = "cmp-cmdline" },
            { "iguanacucumber/mag-buffer",                      name = "cmp-buffer" },
            { "https://codeberg.org/FelipeLema/cmp-async-path", name = "cmp-path" },
        },
        config = function()
            local cmp = require('cmp')
            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "buffer" },
                },
            })

            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "path" },
                    { name = "cmdline" },
                },
            })
        end
    },
    {
        "saghen/blink.cmp",
        lazy = false,
        event = "InsertEnter",
        dependencies = {
            "iguanacucumber/magazine.nvim",
            "rafamadriz/friendly-snippets",
            { "L3MON4D3/Luasnip", version = "v2.*" },
            --* the sources *--
            -- { "iguanacucumber/mag-nvim-lsp",                    opts = {} },
            -- { "iguanacucumber/mag-nvim-lua", },
            -- { "iguanacucumber/mag-buffer", },
            -- { "iguanacucumber/mag-cmdline", },
            -- { "https://codeberg.org/FelipeLema/cmp-async-path", }
        },
        version = "*",
        build = "cargo build --release",

        ---@module "blink-cmp"
        ---@type blink.cmp.Config
        opts = {
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

            snippets = {
                expand = function(snippet) require("luasnip").lsp_expand(snippet) end,
                active = function(filter)
                    if filter and filter.direction then
                        return require("luasnip").jumpable(filter.direction)
                    end
                    return require("luasnip").in_snippet()
                end,
                jump = function(direction) require("luasnip").jump(direction) end,
            },

            sources = {
                default = { "lsp", "path", "luasnip", "buffer" },
                cmdline = {},
            }
        },

        -- ---@param opts blink.cmp.Config | { sources: { compat: string[] } }
        -- config = function(_, opts)
        --     local enabled = opts.sources.default
        --     for _, source in ipairs(opts.sources.compat or {}) do
        --         print(source)
        --         opts.sources.providers[source] = vim.tbl_deep_extend(
        --             "force",
        --             { name = source, module = "blink.compat.source" },
        --             opts.sources.providers[source] or {}
        --         )
        --         if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
        --             table.insert(enabled, source)
        --         end
        --     end
        --
        --     require("blink.cmp").setup(opts)
        -- end
    }
}
