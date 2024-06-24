return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {

        "williamboman/mason-lspconfig.nvim",
        name = "mason-lspconfig",
        event = "BufReadPre",
        dependencies = {
            "williamboman/mason.nvim",
            name = "mason",
            opts = {
                automatic_installation = true,
                ui = {
                    icons = {
                        package_installed = "",
                        package_pending = "➜",
                        package_uninstalled = "",
                    },
                }
            }
        },
        config = true
    },
    config = function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

        local keymap = vim.keymap
        local on_attach = function(_, bufnr)
            local opts = { noremap = true, silent = true, buffer = bufnr }

            keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
            keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
            keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
            keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
            keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
            keymap.set("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
            -- keymap.set("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
            keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
            keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
            -- keymap.set("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
        end

        vim.diagnostic.config({
            virtual_text = {
                prefix = ">",
                spacing = 2,
            },
            signs = {
                severity = vim.diagnostic.severity.ERROR,
            }
        })

        local lspconfig = require('lspconfig')

        -- Disable diagnostics
        vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
            vim.lsp.diagnostic.on_publish_diagnostics, {
                underline = false,
                virtual_text = false,
                signs = false,
                update_in_insert = false,
            }
        )

        -- Ignore nil messages.
        local function on_language_status(_, result)
            if result.message == nil then
                return
            end
            local command = vim.api.nvim_command
            command 'echohl ModeMsg'
            command(string.format('echo "%s"', result.message))
            command 'echohl None'
        end

        local servers = {
            yamlls = {
                filetypes = { "yaml" },
            },
            clangd = {
                filetypes = { "c", "cpp" },
            },
            bashls = {
                filetypes = { "sh", "zsh", "bash" },
            },
            tsserver = {
                filetypes = { "javascript", "typescript" },
            },
            marksman = {
                filetypes = { "markdown" }
            },
            texlab = {
                filetypes = { "tex" },
            },
            pyright = {
                filetypes = { "python" },
                root_dir = function(fname)
                    return lspconfig.util.root_pattern(".venv", ".git")(fname) or
                        vim.fn.getcwd()
                end,
                settings = {
                    python = {
                        venvPath = ".",
                        venv = ".venv"
                    }
                }
            },
            cssls = {
                filetypes = { "css" }
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
                            -- Get the language server to recognize the `vim` global
                            enable = true,
                            globals = { "require", "vim", "use", "love" },
                            -- disable = { "lowercase-global" },
                        },
                        workspace = {
                            -- Make the server aware of Neovim runtime files
                            -- library = vim.api.nvim_get_runtime_file("", true),
                            library = {
                                vim.env.VIMRUNTIME,
                            },
                            checkThirdParty = false,
                            -- maxPreload = 2000,
                            -- preloadFileSize = 1000,
                        },
                    },
                },
            },
            jdtls = {
                filetypes = { "java" },
                handlers = {
                    ["$/progress"] = vim.schedule_wrap(on_language_status),
                },
                settings = {
                    java = {
                        project = {
                            referencedLibraries = {
                                "./**/*.jar",
                            }
                        }
                    }
                },
                root_dir = function(fname)
                    return require("lspconfig").util.root_pattern("pom.xml", "gradle.build", "src")(fname) or
                        vim.fn.getcwd()
                end,
            },
        }

        local mason_lspconfig = require("mason-lspconfig")

        mason_lspconfig.setup({
            ensure_installed = vim.tbl_keys(servers)
        })

        local function find_git_root()
            -- Use the current buffer's path as the starting point for the git search
            local current_file = vim.api.nvim_buf_get_name(0)
            local current_dir
            local cwd = vim.fn.getcwd()
            -- If the buffer is not associated with a file, return nil
            if current_file == "" then
                current_dir = cwd
            else
                -- Extract the directory from the current file's path
                current_dir = vim.fn.fnamemodify(current_file, ":h")
            end

            -- Find the Git root directory from the current file's path
            local git_root = vim.fn.systemlist("git -C " ..
                vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
            if vim.v.shell_error ~= 0 then
                return cwd
            end

            return git_root
        end

        mason_lspconfig.setup_handlers {
            function(server_name)
                if servers[server_name] == nil then
                    print("Include '" .. server_name .. "' in your servers table")
                    lspconfig[server_name].setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                    })
                else
                    lspconfig[server_name].setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = servers[server_name].settings or {},
                        filetypes = servers[server_name].filetypes or {},
                        root_dir = servers[server_name].root_dir or function() return find_git_root() end,
                        handlers = servers[server_name].handlers or {},
                    })
                end
            end
        }

        lspconfig.rust_analyzer.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            cmd = {
                "rustup", "run", "nightly", "rust-analyzer"
            },
            root_dir = function(fname)
                return lspconfig.util.root_pattern("Cargo.toml", ".git")(fname) or
                    vim.fn.getcwd()
            end,
        })
    end
}
