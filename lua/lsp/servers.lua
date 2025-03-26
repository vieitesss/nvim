local lspconfig = require("lspconfig")

local servers = {
    gopls = {
        filetypes = { "go" },
    },
    clangd = {
        filetypes = { "c", "cpp" },
    },
    bashls = {
        filetypes = { "sh", "zsh", "bash" },
    },
    ts_ls = {
        filetypes = { "javascript", "typescript" },
    },
    marksman = {
        filetypes = { "markdown" },
    },
    volar = {
        filetypes = { "vue" },
    },
    texlab = {
        filetypes = { "tex" },
    },
    terraformls = {
        filetypes = { "terraform" },
    },
    helm_ls = {
        filetypes = { "yaml" },
        root_dir = function(fname)
            return lspconfig.util.root_pattern(".helmignore", "Chart.yaml")(fname) or vim.fn.getcwd()
        end,
    },
    pyright = {
        filetypes = { "python" },
        root_dir = function(fname)
            return lspconfig.util.root_pattern(".venv", ".git")(fname) or vim.fn.getcwd()
        end,
        settings = {
            python = {
                venvPath = ".",
                venv = ".venv",
            },
        },
    },
    cssls = {
        filetypes = { "css" },
    },
    lua_ls = {
        filetypes = { "lua" },
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                },
                completion = {
                    enable = true,
                },
                diagnostics = {
                    enable = true,
                    globals = { "require", "vim", "use", "love" },
                },
                workspace = {
                    library = { vim.env.VIMRUNTIME },
                    checkThirdParty = false,
                },
            },
        },
    },
    jdtls = {
        filetypes = { "java" },
        handlers = {
            ["$/progress"] = vim.schedule_wrap(function(_, result)
                if result.message then
                    vim.api.nvim_echo({ { result.message, "None" } }, false, {})
                end
            end),
        },
        settings = {
            java = {
                project = {
                    referencedLibraries = { "./**/*.jar" },
                },
            },
        },
    },
}

return servers
