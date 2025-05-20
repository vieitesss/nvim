vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local opts = { noremap = true, silent = true, buffer = event.buf }
        local keymap = vim.keymap.set
  -- • |grn| in Normal mode maps to                 |vim.lsp.buf.rename()|
  -- • |grr| in Normal mode maps to                 |vim.lsp.buf.references()|
  -- • |gri| in Normal mode maps to                 |vim.lsp.buf.implementation()|
  -- • |gra| is mapped in Normal and Visual mode to |vim.lsp.buf.code_action()|
  -- •   |K| in Normal mode maps to                 |vim.lsp.buf.hover()|

        keymap("n", "grd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    end,
})

local servers = {
    "bashls",
    "gopls",
    "lua_ls",
    "marksman",
    "texlab",
    "ts_ls",
    "rust-analyzer",
    "helm_ls",
}

vim.lsp.config("*", {
    root_markers = { ".git" },
})

vim.lsp.enable(servers)
vim.diagnostic.enable(false)
