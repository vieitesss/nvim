return {
    "iamcco/markdown-preview.nvim",
    build = "cd app && yarn install",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    init = function()
        vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = "markdown",
}
