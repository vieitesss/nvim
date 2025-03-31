---@type vim.lsp.Config
return {
    cmd = { 'bash-language-server', 'start' },
    settings = {
        bashIde = {
            globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)',
        },
    },
    filetypes = { 'bash', 'sh' },
    root_dir = function(bufnr)
        local current_dir = vim.fs.dirname('.') 
        return vim.fs.root(bufnr, { '.git', current_dir })
    end,
}
