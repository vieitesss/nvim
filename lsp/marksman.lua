---@type vim.lsp.Config
return {
    cmd = { 'marksman', 'server' },
    filetypes = { 'markdown', 'markdown.mdx' },
    root_dir = function(bufnr)
        return vim.fs.root(bufnr, { '.marksman.toml' })
            or vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
    end,
}
