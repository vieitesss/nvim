local lspconfig = require("lspconfig")

local servers = {
    gopls = {
        cmd = { "gopls" },
        filetypes = { "go" },
    },
    clangd = {
        cmd = { "clangd" },
        filetypes = { "c", "cpp" },
    },
    bashls = {
        cmd = { "bash-language-server" },
        filetypes = { "sh", "zsh", "bash" },
    },
    ts_ls = {
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { "javascript", "typescript" },
    },
    marksman = {
        cmd = { "marksman" },
        filetypes = { "markdown" },
    },
    volar = {
        cmd = { "vue-language-server" },
        filetypes = { "vue" },
    },
    texlab = {
        cmd = { "texlab" },
        filetypes = { "tex" },
    },
    terraformls = {
        cmd = { "terraform-ls" },
        filetypes = { "terraform" },
    },
    helm_ls = {
        cmd = { "helm_ls" },
        filetypes = { "yaml" },
        root_dir = function(fname)
            return lspconfig.util.root_pattern(".helmignore", "Chart.yaml")(fname) or vim.fn.getcwd()
        end,
    },
    pyright = {
        cmd = { "pyright-langserver" },
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
        cmd = { "vscode-css-language-server" },
        filetypes = { "css" },
    },
    lua_ls = {
        cmd = { "lua-language-server" },
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
        cmd = { "jdtls" },
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
    rust_analyzer = {
        cmd = { "rustup", "run", "nightly", "rust-analyzer" },
        root_dir = function(fname)
            return lspconfig.util.root_pattern("Cargo.toml", ".git")(fname) or vim.fn.getcwd()
        end,
    },
}

return servers
