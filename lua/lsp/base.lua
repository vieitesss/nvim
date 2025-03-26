local M = {}

M.on_attach = function(_, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    local keymap = vim.keymap.set
    keymap("n", "gd", "<cmd>lua require('mini.extra').pickers.lsp({ scope = 'definition' })<CR>", opts)
    keymap("n", "gr", "<cmd>lua require('mini.extra').pickers.lsp({ scope = 'references' })<CR>", opts)
    keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
    keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.root_dir = function(fname)
    local util = require("lspconfig.util")
    return util.root_pattern(".git")(fname) or vim.fn.getcwd()
end

return M
