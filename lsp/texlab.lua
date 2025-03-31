---@type vim.lsp.Config
return {
    cmd = { 'texlab' },
    filetypes = { 'tex', 'plaintex', 'bib' },
    root_markers = { '.git', '.latexmkrc', '.texlabroot', 'texlabroot', 'Tectonic.toml' },
}
