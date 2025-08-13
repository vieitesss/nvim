---@type vim.lsp.Config
return {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gosum' },
    root_markers = { 'go.mod', 'go.sum' },
}
