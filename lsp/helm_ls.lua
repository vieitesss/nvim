---@type vim.lsp.Config
return {
    cmd = { 'helm_ls', 'serve' },
    settings = {},
    filetypes = { 'helm', 'helmfile' },
    root_markers = { 'Chart.yaml' },
}
