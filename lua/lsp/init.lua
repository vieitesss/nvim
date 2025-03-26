local base = require("lsp.base")
local servers = require("lsp.servers")
local lspconfig = require("lspconfig")

vim.diagnostic.enable(false)
-- vim.diagnostic.config({
--     virtual_text = {
--         prefix = ">",
--         spacing = 2,
--     },
--     signs = true,
--     update_in_insert = false,
-- })

local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
    ensure_installed = vim.tbl_keys(servers),
})

mason_lspconfig.setup_handlers {
    function(server_name)
        local server_opts = servers[server_name] or {}
        local opts = vim.tbl_deep_extend("force", {
            capabilities = base.capabilities,
            on_attach = base.on_attach,
            root_dir = server_opts.root_dir or base.root_dir,
        }, server_opts)
        lspconfig[server_name].setup(opts)
    end,
}

lspconfig.rust_analyzer.setup({
    capabilities = base.capabilities,
    on_attach = base.on_attach,
    cmd = { "rustup", "run", "nightly", "rust-analyzer" },
    root_dir = function(fname)
        return lspconfig.util.root_pattern("Cargo.toml", ".git")(fname) or vim.fn.getcwd()
    end,
})
