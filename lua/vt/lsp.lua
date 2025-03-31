vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local opts = { noremap = true, silent = true, buffer = event.buf }
        local keymap = vim.keymap.set
        keymap("n", "gd", "<cmd>lua require('mini.extra').pickers.lsp({ scope = 'definition' })<CR>", opts)
        keymap("n", "gr", "<cmd>lua require('mini.extra').pickers.lsp({ scope = 'references' })<CR>", opts)
        keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
        keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
        keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
        keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
        keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
        keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
    end,
})

local servers = {
    "bashls",
    "gopls",
    "lua_ls",
    "marksman",
    "texlab",
    "ts_ls"
}

vim.lsp.config("*", {
    root_markers = { ".git" },
})

vim.lsp.enable(servers)
vim.diagnostic.enable(false)
